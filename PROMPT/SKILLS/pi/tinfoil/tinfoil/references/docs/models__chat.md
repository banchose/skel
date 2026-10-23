> ## Documentation Index
> Fetch the complete documentation index at: https://docs.tinfoil.sh/llms.txt
> Use this file to discover all available pages before exploring further.

# Chat models

> Chat models available on Tinfoil, using the OpenAI chat completions API.

Chat models use the OpenAI chat completions API.

> ![Moonshot](https://mintcdn.com/tinfoil/HITkMM0WLVDu_kgw/images/model-icons/moonshot-dark.png?fit=max\&auto=format\&n=HITkMM0WLVDu_kgw\&q=85\&s=c5deba0135dc742cf0eec46195087a10)
>
> Kimi K3
>
> [`kimi-k3`](#kimi-k3)
>
> **Parameters:** 2.8T total (104B activated)
>
> **Quantization:** MXFP4 weights / MXFP8 activations (native quantization-aware release from Moonshot AI)
>
> **Context:** 256K tokens
>
> **Strengths:** Long-horizon coding, complex reasoning, multimodal understanding, and agentic workflows with tool calling
>
> **Structured Outputs:** Structured response formatting support
>
> **Best for:** Complex reasoning, repo-level coding, visual knowledge work, and long-running agentic tasks
>
> **Model weights:** [moonshotai/Kimi-K3](https://huggingface.co/moonshotai/Kimi-K3)
>
> **Configuration repo:** [tinfoilsh/confidential-kimi-k3](https://github.com/tinfoilsh/confidential-kimi-k3)
>
> > [!NOTE]
> >
> > **Vision + Language:** Supports text and image inputs with native reasoning and tool calling for agentic workflows.

> ![Z.AI](https://mintcdn.com/tinfoil/GXlDUK5K0yNgB7O7/images/model-icons/zai.png?fit=max\&auto=format\&n=GXlDUK5K0yNgB7O7\&q=85\&s=36bb4bfa914e58deb8fbde1eba1af343)
>
> GLM-5.3
>
> [`glm-5-3`](#glm-5-3)
>
> **Parameters:** 743B (39B active)
>
> **Quantization:** NVFP4 MoE experts (Inferact release; attention, shared experts, and dense layers kept in BF16)
>
> **Context:** 1M tokens
>
> **Strengths:** Frontier agentic coding and long-horizon tool use, with always-on reasoning and configurable effort
>
> **Structured Outputs:** Structured response formatting support
>
> **Best for:** Agentic engineering, repo-scale code generation and refactoring, and long-running tool-use sessions over very long context
>
> **Model weights:** [Inferact/GLM-5.3-NVFP4](https://huggingface.co/Inferact/GLM-5.3-NVFP4)
>
> **Configuration repo:** [tinfoilsh/confidential-glm5-3-nvfp4](https://github.com/tinfoilsh/confidential-glm5-3-nvfp4)
>
> > [!NOTE]
> >
> > **Reasoning is always on.** Control it with `reasoning_effort` (`low`, `high`, or `max`; defaults to `max`). GLM-5.3 does not honour `enable_thinking`; use `reasoning_effort: "low"` for the lightest reasoning. Reasoning tokens count toward `max_tokens`, so structured outputs and strict tool calls at the default effort need a generous `max_tokens` (around 20K) or a lower effort.

> ![DeepSeek](https://mintcdn.com/tinfoil/7kpqELCdP4WIVCil/images/model-icons/deepseek.png?fit=max\&auto=format\&n=7kpqELCdP4WIVCil\&q=85\&s=8b0e67d9e8e4077d980d15f7fe14ca56)
>
> DeepSeek V4.1 Flash
>
> [`deepseek-v4-1-flash`](#deepseek-v4-1-flash)
>
> > [!WARNING]
> >
> > **Experimental:** this model is not yet fully productionized. Capacity and performance may change while we finish rolling it out.
>
> **Version:** V4.1 Flash release
>
> **Parameters:** 552B (MoE, 6 of 384 routed experts plus 1 shared active per token; Engram memory)
>
> **Quantization:** FP8 attention / FP4 experts (native quantized release from DeepSeek)
>
> **Context:** 1M tokens
>
> **Strengths:** Very long context, image input, optional reasoning with configurable effort (`low`, `high`, `xhigh`, `max`), built-in speculative decoding for fast generation, tool calling
>
> **Structured Outputs:** Structured response formatting support
>
> **Best for:** Long-document and image-grounded analysis, large-codebase understanding, and high-volume agentic workloads over very long inputs
>
> **Model weights:** [deepseek-ai/DeepSeek-V4.1-Flash](https://huggingface.co/deepseek-ai/DeepSeek-V4.1-Flash)
>
> **Configuration repo:** [tinfoilsh/confidential-deepseek-v4-1-flash](https://github.com/tinfoilsh/confidential-deepseek-v4-1-flash)

> ![Google DeepMind](https://mintcdn.com/tinfoil/vfMAM73wcpT2SrpR/images/model-icons/gemma.png?fit=max\&auto=format\&n=vfMAM73wcpT2SrpR\&q=85\&s=7b20f1c96812bd1c9fd512c4fead47c7)
>
> Gemma 4 31B
>
> [`gemma4-31b`](#gemma4-31b)
>
> **Parameters:** 31B
>
> **Quantization:** None (served in BF16)
>
> **Context:** 256K tokens
>
> **Strengths:** Built-in thinking mode, image understanding, native function calling, multilingual support for 35+ languages
>
> **Structured Outputs:** Structured response formatting support
>
> **Best for:** Reasoning tasks, coding, image analysis, and agentic workflows with tool calling
>
> **Model weights:** [google/gemma-4-31B-it](https://huggingface.co/google/gemma-4-31B-it)
>
> **Configuration repo:** [tinfoilsh/confidential-gemma4-31b](https://github.com/tinfoilsh/confidential-gemma4-31b)
>
> > [!NOTE]
> >
> > **Vision + Language:** Processes text and image inputs. Features step-by-step reasoning with configurable thinking mode.

> ![OpenAI](https://mintcdn.com/tinfoil/7kpqELCdP4WIVCil/images/model-icons/openai.png?fit=max\&auto=format\&n=7kpqELCdP4WIVCil\&q=85\&s=1b9cbe9cd3cbfe37d282867e0d448c69)
>
> GPT-OSS 120B
>
> [`gpt-oss-120b`](#gpt-oss-120b)
>
> **Parameters:** 117B (5.1B active)
>
> **Quantization:** MXFP4 (native MXFP4 MoE weights, as released by OpenAI)
>
> **Context:** 131K tokens
>
> **Strengths:** Configurable reasoning effort levels, full chain-of-thought access, built-in capabilities including function calling, web browsing, and Python code execution
>
> **Structured Outputs:** Structured response formatting support
>
> **Best for:** Production use cases requiring configurable reasoning and tool use
>
> **Model weights:** [openai/gpt-oss-120b](https://huggingface.co/openai/gpt-oss-120b)
>
> **Configuration repo:** [tinfoilsh/confidential-gpt-oss-120b](https://github.com/tinfoilsh/confidential-gpt-oss-120b)

> ![Llama](https://mintcdn.com/tinfoil/7kpqELCdP4WIVCil/images/model-icons/llama.png?fit=max\&auto=format\&n=7kpqELCdP4WIVCil\&q=85\&s=0e9748643c3987fbf26b9b7531745bc9)
>
> Llama 3.3 70B
>
> [`llama3-3-70b`](#llama3-3-70b)
>
> **Parameters:** 70B
>
> **Quantization:** FP8 (FP8 weights with dynamic FP8 activations, quantized from the BF16 release)
>
> **Context:** 128K tokens
>
> **Strengths:** Multilingual, dialogue-optimized, function calling
>
> **Structured Outputs:** Structured response formatting support
>
> **Best for:** Conversational AI applications and complex dialogue systems
>
> **Model weights:** [RedHatAI/Llama-3.3-70B-Instruct-FP8-dynamic](https://huggingface.co/RedHatAI/Llama-3.3-70B-Instruct-FP8-dynamic)
>
> **Configuration repo:** [tinfoilsh/confidential-llama3-3-70b](https://github.com/tinfoilsh/confidential-llama3-3-70b)


This documentation is built and hosted on [Mintlify](https://mintlify.com), a developer documentation platform.