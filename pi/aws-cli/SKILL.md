# AWS CLI Command and Scripting Guidelines

Safe, explicit AWS CLI usage — no ambient credentials, no silent mutations, no assumed values.

## Every command

- End with `--region <region> --profile <profile>` — always explicit, in that order, as the last two flags.
- Use `--output json` when capturing values into variables (avoids format surprises from profile defaults).
- If the profile is unclear, **stop and ask**.

## Discovery and reads

- Discovery commands are encouraged — look before you leap.
- Batch read-only operations freely.
- Capture resource IDs into environment variables instead of filling in placeholders.
- Use `--no-paginate` or loop with `--starting-token` when capturing full lists — default output truncates silently on many commands.

## Modifications

- Never batch reads and writes in the same block.
- One setting change at a time.
- Before changing:
  - Confirm the change is still required and why.
  - Echo any environment variables or values being used — never assume, always verify inputs.
- After changing:
  - Check the return code.
  - Verify the new value with a follow-up read.
- Use `--dry-run` where supported (EC2, etc.) before the real call for cheap confidence.
- If confidence in the change is not high, ask for additional information.

## Profiles (quick reference)

| Profile | Scope |
|---------|-------|
| test | OpenWebUI |
| net | ALB, WAF, NAT GW, IGW, … |
| man | Billing |
| production | pisal, pisalapi, attmove, +others |

> This list is approximate — ask if a workload doesn't clearly map to one of these.
