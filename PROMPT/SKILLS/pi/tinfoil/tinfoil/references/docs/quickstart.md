> ## Documentation Index
> Fetch the complete documentation index at: https://docs.tinfoil.sh/llms.txt
> Use this file to discover all available pages before exploring further.

# Quickstart

> Make your first inference request with Tinfoil in minutes.

## Try our API

Use one of the Tinfoil SDKs to make some inference requests to an AI model. It's as easy as getting an API key and running one of our examples.

> **[Get an API key](/get-api-key.md)**
>
> You'll need a Tinfoil API key to make inference requests. Create one here.

### Installation

Install the SDK for your language.

> [!NOTE]
>
> The Go, Swift, and CLI setups below use [beta V3 attestation verification](/resources/feature-status.md). The Python, JavaScript, and Rust setups are outside the V3 beta.

**Python**

```bash theme={"dark"}
pip install tinfoil
```

**JavaScript**

```bash theme={"dark"}
npm install tinfoil
```

**Swift**

```swift theme={"dark"}
// Package.swift
dependencies: [
    .package(url: "https://github.com/tinfoilsh/tinfoil-swift.git", branch: "main")
]
```

**Go**

```bash theme={"dark"}
go get github.com/tinfoilsh/tinfoil-go
```

**Rust**

```bash theme={"dark"}
cargo add tinfoil --git https://github.com/tinfoilsh/tinfoil-rs
cargo add tokio --features full
```

**CLI**

```bash theme={"dark"}
curl -fsSL https://github.com/tinfoilsh/tinfoil-cli/raw/main/install.sh | sh
```

See [Updating the CLI](/sdk/cli-sdk.md#updating-the-cli) for self-update and its release requirements.

### Inference

Make your first inference request with the `gpt-oss-120b` model.

**Python**

```python theme={"dark"}
import os
from tinfoil import TinfoilAI

client = TinfoilAI(
    api_key=os.getenv("TINFOIL_API_KEY")
)

chat_completion = client.chat.completions.create(
    messages=[
        {
            "role": "user",
            "content": "Hello!",
        }
    ],
    model="gpt-oss-120b",
)
print(chat_completion.choices[0].message.content)
```

**JavaScript**

```typescript theme={"dark"}
import { TinfoilAI } from "tinfoil";

const client = new TinfoilAI({
  apiKey: process.env.TINFOIL_API_KEY
});

const completion = await client.chat.completions.create({
  messages: [{ role: "user", content: "Hello!" }],
  model: "gpt-oss-120b",
});

console.log(completion.choices[0]?.message?.content);
```

**Swift**

```swift theme={"dark"}
import TinfoilAI
import OpenAI

let client = try await TinfoilAI.create(
    apiKey: ProcessInfo.processInfo.environment["TINFOIL_API_KEY"] ?? ""
)

let chatQuery = ChatQuery(
    messages: [
        .user(.init(content: .string("Hello!")))
    ],
    model: "gpt-oss-120b"
)

let response = try await client.chats(query: chatQuery)
print(response.choices.first?.message.content ?? "No response")
```

**Go**

```go theme={"dark"}
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

    chatCompletion, err := client.Chat.Completions.New(context.TODO(), openai.ChatCompletionNewParams{
        Messages: []openai.ChatCompletionMessageParamUnion{
            openai.UserMessage("Hello!"),
        },
        Model: "gpt-oss-120b",
    })
    if err != nil {
        log.Fatal(err)
    }

    fmt.Println(chatCompletion.Choices[0].Message.Content)
}
```

**Rust**

```rust theme={"dark"}
use tinfoil::chat::{
    ChatCompletionRequestMessage, ChatCompletionRequestUserMessage,
    ChatCompletionRequestUserMessageContent, CreateChatCompletionRequestArgs,
};
use tinfoil::Client;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let client = Client::new_default().await?;

    let request = CreateChatCompletionRequestArgs::default()
        .model("gpt-oss-120b")
        .messages(vec![ChatCompletionRequestMessage::User(
            ChatCompletionRequestUserMessage {
                content: ChatCompletionRequestUserMessageContent::Text(
                    "Hello!".to_string(),
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

**CLI**

```bash theme={"dark"}
tinfoil http post https://inference.tinfoil.sh/v1/chat/completions \
  -e inference.tinfoil.sh \
  -r tinfoilsh/confidential-model-router \
  -H "Authorization: Bearer $TINFOIL_API_KEY" \
  -H "Content-Type: application/json" \
  -b '{"model": "gpt-oss-120b", "messages": [{"role": "user", "content": "Hello!"}]}'
```

## Connect other OpenAI-compatible apps

Tinfoil has an OpenAI-compatible API, so apps and tools that accept a custom base URL can use Tinfoil models. Use your Tinfoil API key and a model ID from the [model catalog](/models/overview.md). How you connect decides whether your client verifies the secure enclave itself.

| Connection | Base URL | Verification |
| - | - | - |
| [Tinfoil SDK](/sdk/overview.md) | Set by the SDK | Connection-time |
| [Tinfoil Proxy](/local-proxy/app.md) | `http://127.0.0.1:3301/v1` | Connection-time |
| Direct | `https://inference.tinfoil.sh/v1` | Audit-time only |

> [!WARNING]
>
> A direct connection skips connection-time verification: your app trusts the TLS certificate for `inference.tinfoil.sh` instead of checking the secure enclave's attestation. Requests are still covered by [audit-time verification](/verification/verification-in-tinfoil.md#in-band-vs-out-of-band-verification). Use an SDK or the proxy when you can, and connect directly only from apps that can run neither, such as mobile apps.

## Next steps

> **[SDK documentation](/sdk/overview.md)**
>
> Migration, async usage, and per-model examples across all Tinfoil SDKs.

> **[Model catalog](/models/overview.md)**
>
> Browse all available AI models.


This documentation is built and hosted on [Mintlify](https://mintlify.com), a developer documentation platform.