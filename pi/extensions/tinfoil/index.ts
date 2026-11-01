import { openAICompletionsApi } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { SecureClient } from "tinfoil";

// Shape of GET /v1/models entries (only the fields we use).
type TinfoilModel = {
  id: string;
  name?: string;
  type?: string;
  endpoints?: string[];
  multimodal?: boolean;
  reasoning?: boolean;
  context_window?: number;
  pricing?: {
    inputTokenPricePer1M?: number;
    outputTokenPricePer1M?: number;
    cachedInputTokenPricePer1M?: number;
  };
};

// Accepted reasoning_effort vocabularies per model; an unsupported value => 400.
// Source: https://docs.tinfoil.sh/guides/reasoning#supported-values-per-model
// kimi-k3 / glm-5-3(-flash) always reason and DEFAULT TO MAX when the param is omitted, so "off" => "low".
const lowHighMax = { off: "low", minimal: "low", low: "low", medium: "low", high: "high", xhigh: "max", max: "max" };
// gpt-oss (Harmony) only defines low/medium/high.
const lowMedHigh = { off: "low", minimal: "low", low: "low", medium: "medium", high: "high", xhigh: "high", max: "high" };
// Full OpenAI scale; "none" disables reasoning.
const fullScale = { off: "none", minimal: "minimal", low: "low", medium: "medium", high: "high", xhigh: "xhigh", max: "max" };

const thinkingLevelMaps: Record<string, Record<string, string>> = {
  "kimi-k3": lowHighMax,
  "glm-5-3": lowHighMax,
  "glm-5-3-flash": lowHighMax,
  "deepseek-v4-flash": fullScale,
  "deepseek-v4-1-flash": fullScale,
  "glm-5-2": fullScale,
  "gemma4-31b": fullScale,
  "gpt-oss-120b": lowMedHigh,
  "gpt-oss-safeguard-120b": lowMedHigh,
};

// Not reported by /v1/models. Reasoning tokens count toward max_tokens (docs suggest ~20K+ for
// tool calls at default effort), so reasoning models get a larger budget.
const maxTokensFor = (m: TinfoilModel) => (m.reasoning ? 32768 : 8192);

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
  const { data } = (await res.json()) as { data: TinfoilModel[] };

  // Only chat-completions models; skips audio/TTS/embedding/safety/tool entries.
  const chatModels = data.filter(
    (m) => m.type === "chat" && (m.endpoints ?? []).includes("/v1/chat/completions"),
  );

  pi.registerProvider("tinfoil", {
    name: "Tinfoil (enclave)",
    baseUrl, // already ends in /v1
    apiKey: "$TINFOIL_API_KEY",
    api: "openai-completions",
    models: chatModels.map((m) => ({
      id: m.id,
      name: `Tinfoil ${m.name ?? m.id}`,
      reasoning: m.reasoning ?? false,
      ...(m.reasoning && thinkingLevelMaps[m.id] ? { thinkingLevelMap: thinkingLevelMaps[m.id] } : {}),
      input: m.multimodal ? ["text", "image"] : ["text"],
      cost: {
        input: m.pricing?.inputTokenPricePer1M ?? 0,
        output: m.pricing?.outputTokenPricePer1M ?? 0,
        cacheRead: m.pricing?.cachedInputTokenPricePer1M ?? 0,
        cacheWrite: 0,
      },
      contextWindow: m.context_window ?? 128000,
      maxTokens: maxTokensFor(m),
      // Tinfoil rejects role "developer" (400 Unknown message role); pi uses it for reasoning models by default.
      // supportsStore: false omits OpenAI's `store` param, matching pi's catalog entries for these same open models.
      compat: { supportsDeveloperRole: false, supportsStore: false },
    })),
    // ponytail: inject the verified fetch; drop this if pi ever exposes `fetch` in ProviderConfig.
    streamSimple: (model, context, options) =>
      openAICompletionsApi().streamSimple(model as never, context, {
        ...options,
        fetch: client.fetch,
      }),
  });
}
