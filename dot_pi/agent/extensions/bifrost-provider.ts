import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

interface BifrostModel {
  id: string;
  name?: string;
  context_length?: number;
  max_input_tokens?: number;
  max_output_tokens?: number;
  pricing?: {
    prompt?: string;
    completion?: string;
    input_cache_read?: string;
    input_cache_write?: string;
  };
}

async function fetchBifrostModels(): Promise<BifrostModel[]> {
  const maxAttempts = 5;
  const delayMs = 1000;

  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    const response = await fetch("http://localhost:8080/v1/models");
    const payload = (await response.json()) as { data: BifrostModel[] };

    if (payload.data.length > 0) {
      return payload.data;
    }

    // Bifrost peut encore être en train de découvrir ses providers
    if (attempt < maxAttempts) {
      await new Promise((resolve) => setTimeout(resolve, delayMs));
    }
  }

  return [];
}

// $/token -> $/million tokens
function perMillion(value: string | undefined): number {
  return value ? parseFloat(value) * 1_000_000 : 0;
}

export default async function (pi: ExtensionAPI) {
  const models = await fetchBifrostModels();

  pi.registerProvider("bifrost", {
    baseUrl: "http://localhost:8080/v1",
    apiKey: "not-needed",
    api: "openai-completions",
    models: models.map((model) => ({
      id: model.id,
      name: model.name ?? model.id,
      reasoning: true,
      input: ["text"],
      cost: {
        input: perMillion(model.pricing?.prompt),
        output: perMillion(model.pricing?.completion),
        cacheRead: perMillion(model.pricing?.input_cache_read),
        cacheWrite: perMillion(model.pricing?.input_cache_write),
      },
      contextWindow: model.context_length ?? 128000,
      maxTokens: model.max_output_tokens ?? 8192,
    })),
  });
}
