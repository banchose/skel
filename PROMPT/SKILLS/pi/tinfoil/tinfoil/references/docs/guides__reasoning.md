> ## Documentation Index
> Fetch the complete documentation index at: https://docs.tinfoil.sh/llms.txt
> Use this file to discover all available pages before exploring further.

# Reasoning effort

> Control how much a reasoning model thinks before answering using the reasoning_effort parameter.

## Reasoning effort

Reasoning models can spend extra tokens thinking through a problem before they answer. The OpenAI-compatible `reasoning_effort` parameter controls how much of that thinking the model does. Higher effort generally improves quality on hard tasks at the cost of more latency and output tokens.

Pass `reasoning_effort` as a string on the chat completions request. Use a [reasoning-capable model](#supported-values-per-model) and a value it supports.

```python Python theme={"dark"}
from tinfoil import TinfoilAI

client = TinfoilAI(api_key="<YOUR_API_KEY>")

response = client.chat.completions.create(
    model="<MODEL_NAME>",
    reasoning_effort="medium",
    messages=[
        {"role": "user", "content": "What is 17 * 23? Think step by step."}
    ],
)

print(response.choices[0].message.content)
```

```typescript JavaScript theme={"dark"}
import { TinfoilAI } from 'tinfoil';

const client = new TinfoilAI({
  apiKey: process.env.TINFOIL_API_KEY
});

const response = await client.chat.completions.create({
  model: '<MODEL_NAME>',
  reasoning_effort: 'medium',
  messages: [
    { role: 'user', content: 'What is 17 * 23? Think step by step.' }
  ]
});

console.log(response.choices[0]?.message?.content);
```

```go Go theme={"dark"}
package main

import (
    "context"
    "fmt"
    "log"
    "os"

    "github.com/openai/openai-go/v3"
    "github.com/openai/openai-go/v3/option"
    "github.com/tinfoilsh/tinfoil-go"
)

func main() {
    client, err := tinfoil.NewClient(
        option.WithAPIKey(os.Getenv("TINFOIL_API_KEY")),
    )
    if err != nil {
        log.Fatal(err)
    }

    response, err := client.Chat.Completions.New(context.TODO(), openai.ChatCompletionNewParams{
        Model:           "<MODEL_NAME>",
        ReasoningEffort: "medium",
        Messages: []openai.ChatCompletionMessageParamUnion{
            openai.UserMessage("What is 17 * 23? Think step by step."),
        },
    })
    if err != nil {
        log.Fatal(err)
    }

    fmt.Println(response.Choices[0].Message.Content)
}
```

```rust Rust theme={"dark"}
use tinfoil::chat::{
    ChatCompletionRequestMessage, ChatCompletionRequestUserMessage,
    ChatCompletionRequestUserMessageContent, CreateChatCompletionRequestArgs, ReasoningEffort,
};
use tinfoil::Client;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let client = Client::new_default().await?;

    let request = CreateChatCompletionRequestArgs::default()
        .model("<MODEL_NAME>")
        .reasoning_effort(ReasoningEffort::Medium)
        .messages(vec![ChatCompletionRequestMessage::User(
            ChatCompletionRequestUserMessage {
                content: ChatCompletionRequestUserMessageContent::Text(
                    "What is 17 * 23? Think step by step.".to_string(),
                ),
                name: None,
            },
        )])
        .build()?;

    let response = client.chat().create(request).await?;
    println!("{}", response.choices[0].message.content.as_deref().unwrap_or(""));
    Ok(())
}
```

```swift Swift theme={"dark"}
import TinfoilAI
import OpenAI

let client = try await TinfoilAI.create(
    apiKey: ProcessInfo.processInfo.environment["TINFOIL_API_KEY"] ?? ""
)

let chatQuery = ChatQuery(
    messages: [
        .user(.init(content: .string("What is 17 * 23? Think step by step.")))
    ],
    model: "<MODEL_NAME>",
    reasoningEffort: .medium
)

let response = try await client.chats(query: chatQuery)
print(response.choices.first?.message.content ?? "No response")
```

```bash CLI theme={"dark"}
tinfoil http post https://inference.tinfoil.sh/v1/chat/completions \
  -e inference.tinfoil.sh \
  -r tinfoilsh/confidential-model-router \
  -H "Authorization: Bearer $TINFOIL_API_KEY" \
  -H "Content-Type: application/json" \
  -b '{"model": "<MODEL_NAME>", "reasoning_effort": "medium", "messages": [{"role": "user", "content": "What is 17 * 23? Think step by step."}]}'
```

```bash cURL theme={"dark"}
curl -X POST https://inference.tinfoil.sh/v1/chat/completions \
  -H "Authorization: Bearer <YOUR_API_KEY>" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "<MODEL_NAME>",
    "reasoning_effort": "medium",
    "messages": [{"role": "user", "content": "What is 17 * 23? Think step by step."}]
  }'
```

> [!NOTE]
>
> Swift's `ReasoningEffort` enum covers `none`, `minimal`, `low`, `medium`, and `high`; pass other values with `.customValue("xhigh")`. Rust's `ReasoningEffort` enum covers `none`, `minimal`, `low`, `medium`, `high`, and `xhigh`.

## Supported values per model

The accepted values differ by model. Sending an unsupported value returns a `400` error.

| Model | Type | Supported `reasoning_effort` values |
| - | - | - |
| `kimi-k3` | Chat / Vision | `low`, `high`, `max` |
| `deepseek-v4-1-flash` | Chat / Vision | `none`, `low`, `high`, `xhigh`, `max` |
| `glm-5-3` | Chat | `low`, `high`, `max` |
| `gemma4-31b` | Chat / Vision | `none`, `minimal`, `low`, `medium`, `high`, `xhigh`, `max` |
| `gpt-oss-120b` | Chat | `low`, `medium`, `high` |
| `gpt-oss-safeguard-120b` | Safety | `low`, `medium`, `high` |

On the standard scale, `none` disables reasoning and effort increases up to `max`. Kimi K3 and GLM-5.3 always use reasoning and default to `max`; GLM-5.3 does not honour `enable_thinking`, so use `reasoning_effort: "low"` for the lightest reasoning. The `gpt-oss` models use OpenAI's Harmony response format, which defines only `low`, `medium`, and `high`; sending `none`, `minimal`, `xhigh`, or `max` to these models returns a `400` error.

`llama3-3-70b` is not a reasoning model. It accepts the parameter without error but does not produce a reasoning trace.

## Reading the reasoning trace

The model's thinking is returned in the `reasoning` field of the response message, separate from the final answer in `content`. Higher effort generally produces a longer trace. A non-empty trace is not guaranteed for every request: GLM may answer simple prompts without an exposed reasoning body, so treat `null` or an empty string as valid and read the final answer from `content`.

```python Python theme={"dark"}
response = client.chat.completions.create(
    model="<MODEL_NAME>",
    reasoning_effort="high",
    messages=[{"role": "user", "content": "Why is the sky blue?"}],
)

message = response.choices[0].message
print("Reasoning:", message.reasoning)
print("Answer:", message.content)
```

```bash cURL theme={"dark"}
curl -s -X POST https://inference.tinfoil.sh/v1/chat/completions \
  -H "Authorization: Bearer <YOUR_API_KEY>" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "<MODEL_NAME>",
    "reasoning_effort": "high",
    "messages": [{"role": "user", "content": "Why is the sky blue?"}]
  }' | jq '.choices[0].message | {reasoning, content}'
```

> [!NOTE]
>
> Available models and their supported values can change. Query the [models endpoint](/sdk/direct-api-access.md) to see which models report `"reasoning": true`.


This documentation is built and hosted on [Mintlify](https://mintlify.com), a developer documentation platform.