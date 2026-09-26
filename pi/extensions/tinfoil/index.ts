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

  // Per-model overrides; anything not listed falls back to the text-only defaults below.
  // Supported reasoning_effort values differ per model (unsupported => 400), see tinfoil docs.
  const vision = ["text", "image"];
  const lowHighMax = { off: null, minimal: "low", low: "low", medium: "low", high: "high", xhigh: "max", max: "max" };
  const lowMedHigh = { off: null, minimal: "low", low: "low", medium: "medium", high: "high", xhigh: "high", max: "high" };
  const meta: Record<string, object> = {
    "kimi-k3": {
      input: vision,
      reasoning: true,
      thinkingLevelMap: lowHighMax,
      contextWindow: 256000,
      maxTokens: 32768,
      cost: { input: 4, output: 20, cacheRead: 0.8, cacheWrite: 0 },
    },
    "deepseek-v4-1-flash": {
      input: vision,
      reasoning: true,
      thinkingLevelMap: { off: "none", minimal: "low", low: "low", medium: "low", high: "high", xhigh: "xhigh", max: "max" },
    },
    "glm-5-3": { reasoning: true, thinkingLevelMap: lowHighMax },
    "glm-5-3-flash": { input: vision, reasoning: true, thinkingLevelMap: lowHighMax },
    "gemma4-31b": {
      input: vision,
      reasoning: true,
      thinkingLevelMap: { off: "none", minimal: "minimal", low: "low", medium: "medium", high: "high", xhigh: "xhigh", max: "max" },
    },
    "gpt-oss-120b": { reasoning: true, thinkingLevelMap: lowMedHigh },
    "gpt-oss-safeguard-120b": { reasoning: true, thinkingLevelMap: lowMedHigh },
  };

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
      ...meta[m.id],
    })),
    // ponytail: inject the verified fetch; drop this if pi ever exposes `fetch` in ProviderConfig.
    streamSimple: (model, context, options) =>
      openAICompletionsApi().streamSimple(model as never, context, {
        ...options,
        fetch: client.fetch,
      }),
  });
}
