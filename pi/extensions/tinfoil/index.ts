import { openAICompletionsApi } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { SecureClient } from "tinfoil";

// No local proxy needed: the SDK verifies the enclave in-process and seals
// bodies with HPKE (EHBP), so plain outbound HTTPS from the container is enough.
export default async function (pi: ExtensionAPI) {
  const apiKey = process.env.TINFOIL_API_KEY;
  if (!apiKey) return;

  const client = new SecureClient();
  await client.ready();
  const baseUrl = client.getBaseURL().replace(/\/$/, "");

  const res = await client.fetch(`${baseUrl}/models`, {
    headers: { Authorization: `Bearer ${apiKey}` },
  });
  if (!res.ok) throw new Error(`tinfoil /v1/models: ${res.status}`);
  const { data } = (await res.json()) as { data: { id: string }[] };

  pi.registerProvider("tinfoil", {
    name: "Tinfoil (enclave)",
    baseUrl, // already ends in /v1
    apiKey: "$TINFOIL_API_KEY",
    api: "openai-completions",
    models: data.map((m) => ({
      id: m.id,
      name: `Tinfoil ${m.id}`,
      reasoning: false,
      input: ["text"],
      cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
      contextWindow: 128000,
      maxTokens: 8192,
    })),
    // ponytail: inject the verified fetch; drop this if pi ever exposes `fetch` in ProviderConfig.
    streamSimple: (model, context, options) =>
      openAICompletionsApi().streamSimple(model as never, context, {
        ...options,
        fetch: client.fetch,
      }),
  });
}
