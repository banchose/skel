---
name: owui-upgrade
description: Upgrade the HRI OpenWebUI Helm release on EKS (namespace openwebui, cluster EksTest) — pre-flight gates, read-only helm diff recon, RDS snapshot, the OPENAI_API duplicate-env STOP gate, Alembic log verification, functional tests, rollback. Use whenever asked to upgrade, bump, diff, or roll back OpenWebUI / the open-webui chart, or to plan an OpenWebUI version change.
---

# OpenWebUI upgrade (HRI / EksTest)

Procedure distilled from the 0.9.6 → 0.10.2 → 0.11.1 upgrade runbooks. Every
rule here was paid for by a real incident or a wrong prediction. Follow the
order; the gates exist because skipping them caused outages.

**You do not deploy unattended.** The script prompts `[y/N]`. Bare Enter = N =
safe abort. Never auto-answer `y` on the user's behalf.

---

## Environment facts

| Item | Value |
| --- | --- |
| Cluster context | `arn:aws:eks:us-east-1:405350004483:cluster/EksTest` |
| Namespace | `openwebui` |
| Workload | StatefulSet `openwebui-open-webui`, pod `openwebui-open-webui-0` (replicas 1, no HPA) |
| Helm release | `openwebui` |
| Script | `~/gitdir/aws/HRI-INFRA/OpenWebUI/helm-openwebui.sh` |
| Hostname | `ono.healthresearch.org` (Ingress nginx, `proxy-body-size: 50m`) |
| RDS | `pg-test-0`, PostgreSQL 17.4, DB `owuivector` |
| Vector DB | pgvector, **same** Postgres as the app DB |
| Embeddings | in-cluster LiteLLM (`litellm-service:4000`), model `titan-embed` |
| K8s secret | `openwebui-database` (database-url, litellm-api-key, webui-secret-key) |
| AWS profile/region | `test` / `us-east-1` |
| Auth | local only — no OAuth/OIDC/LDAP |
| securityContext | `{}` — pod runs as root |
| MCP proxies | `aws-knowledge-mcpo-proxy`, `aws-mcp-docs-cf`, `mcp-proxy-time-server` (**3**, not 4) |
| Non-chart injections | 4× OTel auto-instrumentation init containers from `amazon-cloudwatch-observability` |

Chart → app mapping is not derivable; always look it up (step 2).
Known: `16.1.0`→0.11.1 · `16.0.0`/`15.2.1`→0.11.0 · `15.2.0`→0.10.2 ·
`15.1.0`→0.10.1 · `15.0.0`→0.10.0 · `14.8.0`–`14.11.0`→0.9.6

---

## STOP conditions

Abort (answer `N`) and report to the user if any of these appear:

1. **`OPENAI_API_KEY` or `OPENAI_API_BASE_URL` in `extraEnvVars`.** The chart
   renders its own from native values. A duplicate where one uses `value:` and
   the other `valueFrom:` makes Kubernetes reject the pod spec:
   `spec.containers[0].env[N].valueFrom: Invalid value: "": may not be
   specified when 'value' is not empty`. The StatefulSet sits in `FailedCreate`
   with the old pod already gone = **outage**. This broke April 2026 and nearly
   broke June.
2. `volumeClaimTemplates`, `storageClass`, or `kind: PersistentVolumeClaim`
   changing in the diff.
3. RDS snapshot not reaching `available`.
4. Anything in the diff beyond labels + image tags that you cannot explain.

---

## Procedure

### 1. Read the target release's **Changed** section
Not Added/Fixed — *Changed* is where default flips and migration warnings live.
The `⚠️ Database Migrations` banner tells you a migration exists, **not** how
long it takes. Do not size timeouts from it.

### 2. Resolve chart → app version
```bash
helm repo update
helm search repo open-webui/open-webui -o json | jq -r '.[0] | "\(.version) -> app \(.app_version)"'
helm search repo open-webui/open-webui --versions | head -20
helm -n openwebui list -o yaml   # current deployed
```
**If the newest app version is only days old, check whether it is a repair
release for its predecessor.** That decided the skip-0.11.0 call (0.11.0 shipped
four defects incl. knowledge search silently returning empty — RAG-critical
here). Skipping an intermediate release means both releases' migrations run in
one pod start; that is fine (10 revisions ran in ~97s).

### 3. Capture cluster facts
```bash
K=arn:aws:eks:us-east-1:405350004483:cluster/EksTest
kubectl --context $K -n openwebui get sts openwebui-open-webui -o yaml | grep -A5 securityContext
kubectl --context $K -n openwebui get hpa
kubectl --context $K -n openwebui get cronjob
kubectl --context $K -n openwebui get pods
```
Note crash-looping dependencies and CronJob suspend state.

### 4. Standalone read-only recon diff — studied unhurried
Never see the diff for the first time at the script's `[y/N]` prompt.
```bash
helm diff upgrade openwebui open-webui/open-webui \
  --version <TARGET_CHART> -n openwebui \
  --reuse-values --set image.tag=<TARGET_APP> \
  --kube-context $K | tee ~/temp/boom/owui-<TARGET_CHART>-diff.txt

# the ONLY reliable way to enumerate real changes:
grep -nE 'has changed|has been (added|removed)|^[-+] ' ~/temp/boom/owui-<TARGET_CHART>-diff.txt | head -60

# then what actually matters:
grep -nE 'volumeClaimTemplates|storageClass|kind: PersistentVolumeClaim' <file>
grep -nE 'redis' <file>
grep -nE 'OPENAI_API_KEY|OPENAI_API_BASE_URL' <file>
```
`--reuse-values` makes this an **approximation** — the script builds its values
block explicitly. The script's own diff is the authoritative gate.

**Broken grep — do not reuse:** `'^\s*[-+].*name:.*openwebui'` is not a rename
check. It matches YAML sequence dashes, not diff markers, and returns false
positives like `- name: openwebui-open-webui-redis`.

**Chart major bumps here have twice been label + image-tag only** (14→15, 15→16).
[Inference] this chart's major tracks the app version, not template
restructuring. Treat a chart major as *probably* cosmetic — but still diff it.
The Redis `matchLabels` immutability risk flagged as a hard-stop in 2026 turned
out to be diff *context* lines.

### 5. Clear pre-flight gates
- Fix any crash-looping dependency **before** the upgrade (e.g. the 30-day
  `mcp-proxy-time-server` crash loop with 8171 restarts was repaired first).
- **Suspend `openwebui-db-sync`:**
  ```bash
  kubectl --context $K -n openwebui patch cronjob openwebui-db-sync -p '{"spec":{"suspend":true}}'
  ```
  It was *not* suspended on the 16.1.0 run — no collision occurred, which was
  luck, not correctness. Re-enable after verification (`suspend":false`).
- Confirm tool imports / MCP proxy count.

### 6. Confirm script pins, run the env grep
Pin `CHART_VERSION` **and** `image.tag` together in the script.
```bash
grep -nE 'OPENAI_API_KEY|OPENAI_API_BASE_URL|openaiApiKeyExistingSecret|openaiBaseApiUrl' \
  ~/gitdir/aws/HRI-INFRA/OpenWebUI/helm-openwebui.sh
```
Expected: `openaiBaseApiUrl` + `openaiApiKeyExistingSecret` present; **bare
`OPENAI_API_*` absent**; `RAG_OPENAI_*` present. Correct chart-native form:
```yaml
enableOpenaiApi: true
openaiBaseApiUrl: "http://litellm-service.openwebui.svc.cluster.local:4000/v1"
openaiApiKeyExistingSecret: "openwebui-database"
openaiApiKeyExistingSecretKey: "litellm-api-key"
```

**Never rotate `WEBUI_SECRET_KEY` during an upgrade.** MCP tool-server stored
credentials are encrypted with a key that follows it. Expect
`secret/openwebui-database unchanged` in the diff.

`--timeout=300s` on `rollout status` is **adequate** — proven across a
4-revision and a 10-revision migration. Do not raise it on migration-count
grounds; that prediction was wrong once already.

### 7. Run the script
`~/gitdir/aws/HRI-INFRA/OpenWebUI/helm-openwebui.sh`

It: patches PV reclaim → Retain, creates and waits on a fresh RDS snapshot
(`pg-test-0-pre-owui-<chart>-<date>-<time>`), rebuilds the `openwebui-database`
secret from Secrets Manager, writes a temp values file, `helm repo update`,
prints its own diff, prompts `[y/N]`.

**The snapshot it creates is the rollback target. Record its ID.**

### 8. Compare the script's diff to the recon diff
They matched exactly on the last run. Differences need explaining before `y`.

### 9. Verify the Alembic chain in the **full** pod log
```bash
kubectl --context $K -n openwebui logs openwebui-open-webui-0 -c open-webui \
  | grep -nE 'Running upgrade|Traceback|ERROR|Unable to renew'
```
- **Grep the FULL log — no `--tail`.** Startup/Alembic output scrolls out of a
  tail window within ~2 minutes. The buffer is intact while the pod has 0 restarts.
- `authlib.jose.errors import BadSignatureError` — **not an error**, it is an
  import line caught by a grep on "error."
- `Unable to renew session cleanup lock` — **should be permanently absent**
  since 0.11.1. Its return is a real signal: investigate Redis connectivity
  from the pod. The old "single startup hit = ignore" rule is retired.
- `Defaulted container "open-webui" out of: …` — cosmetic, from the injected
  OTel init containers. Silence with `-c open-webui`.
- Expect context impl `PostgresqlImpl`, transactional DDL. Record the head
  revision. Last known head: `d4c1a8e37b62`.
- **Migrations run whether or not the feature is in use.** "Not applicable"
  does not mean "will not run" — `repair double encoded user oauth` executed as
  a no-op on this OAuth-free instance.

### 10. Functional-test the real integrations
Exercise from inside the upgraded instance:

| Path | How |
| --- | --- |
| Native tool calling | invoke any tool |
| MCP proxy → AWS docs | `aws-knowledge-mcpo-proxy` / `aws-mcp-docs-cf` |
| MCP proxy → time | `mcp-proxy-time-server` |
| RAG **retrieval** | semantic query across known files; sane distances (~0.8) |
| RAG **ingestion** | upload a KB file — *this is the one that keeps getting skipped* |
| KB exact-match search | search across PDFs |
| Memory data | expect paths `work/aws/openwebui`, `work/aws/litellm`, `work/openwebui/tools`, `work/aws/waf` |
| Login | local auth |

**A 403 Forbidden on upload is WAF, not the upgrade.** `ono` sits behind the
shared ALB "WildRide" / `HRI-APP-WAF` WebACL and is carved out of
`BlockExcludedCRSExceptOno`. Check with `tailwaf`.

No `nc` inside the pod since 0.11.1 (netcat, pytest, docker SDK, python-jose
all removed from the image).

### 11. Record the outcome
Write a dated outcome section into the runbook note, **including predictions
that were wrong** — those are the most useful part and the reason this skill
exists. Then re-enable `openwebui-db-sync`.

---

## Rollback

**Helm only (2–3 min)** — reverts chart + image, including a chart-major revert:
```bash
helm rollback openwebui -n openwebui --kube-context $K
```

**Schema is the hard part. Alembic is forward-only in practice.** An older pod
against a newer schema may misbehave. If it does, restore the DB to a **new**
instance (never overwrite `pg-test-0`):
```bash
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier pg-test-0-rollback \
  --db-snapshot-identifier <SNAP_ID> \
  --profile test --region us-east-1
# ~10-15 min, then:
aws rds describe-db-instances --db-instance-identifier pg-test-0-rollback \
  --profile test --region us-east-1 --query 'DBInstances[0].Endpoint.Address' --output text
# update DATABASE_URL in the openwebui-database secret, then:
kubectl rollout restart statefulset/openwebui-open-webui -n openwebui
```
Full rollback incl. DB: ~20–40 min.

**Not rollback-worthy on their own:** UI redesign, per-model config switches,
displayed model-name prefixes. Do not restore a database for a cosmetic or
config change.

### Backups
| Backup | Location |
| --- | --- |
| RDS manual snapshots | `pg-test-0-pre-owui-<chart>-<date>-<time>` (script-created, per upgrade) |
| RDS automated daily | `rds:pg-test-0-<date>-05-05` |
| pg_dump custom format | `s3://openwebui-db-backups/pg-dumps/` |

**Recovery pg_dump-to-S3** (one-off Job): SA `openwebui-s3-sync-sa` (IAM role
`AmazonEKS_OpenWebUI_S3_Backup_Role`), image `postgres:17-alpine`, creds from
the `openwebui-database` secret, `pg_dump -Fc` → `s3://openwebui-db-backups/pg-dumps/`.
`kubectl apply -f`, then `kubectl wait --for=condition=Complete job/<name> -n openwebui --timeout=600s`.

---

## Known standing issues (not upgrade-caused)

- 4 OTel auto-instrumentation init containers injected (java, nodejs, python,
  dotnet); 3 are for runtimes OpenWebUI does not use. [Unverified] which
  annotation narrows the language set. Separate cleanup task.
- `openwebui-db-sync` still syncs stale SQLite artifacts (`webui.db`,
  `vector_db/`) — real data is in RDS. Long-term: retire the stale targets.
- RDS `StorageEncrypted: false`; no storage autoscaling (test instance).
- `helm-openwebui.sh-worked` is **misnamed — it is the BROKEN April precursor**
  (stray `d"`, duplicate env, no version pin, no diff step). Do not use it.
- Orphaned Released PV `pvc-b61c783d-…` — safe to delete.
