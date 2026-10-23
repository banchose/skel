> ## Documentation Index
> Fetch the complete documentation index at: https://docs.tinfoil.sh/llms.txt
> Use this file to discover all available pages before exploring further.

# Vision models

> Vision models available on Tinfoil for image analysis, OCR, and screenshot-to-code generation.

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
> **Strengths:** Native image understanding, visual reasoning, document analysis, screenshot-to-code generation, and vision-guided agentic workflows
>
> **Best for:** Visual knowledge work, document understanding, design-to-code workflows, and multimodal agents
>
> **Model weights:** [moonshotai/Kimi-K3](https://huggingface.co/moonshotai/Kimi-K3)
>
> **Configuration repo:** [tinfoilsh/confidential-kimi-k3](https://github.com/tinfoilsh/confidential-kimi-k3)
>
> > [!NOTE]
> >
> > **Multimodal:** Supports text and image inputs with native reasoning and tool calling. See [Image Processing Guide](/guides/image-processing.md) for usage examples.

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
> **Parameters:** 552B (MoE, 6 of 384 routed experts plus 1 shared active per token; Engram memory)
>
> **Quantization:** FP8 attention / FP4 experts (native quantized release from DeepSeek)
>
> **Context:** 1M tokens
>
> **Strengths:** Image understanding over very long context, optional reasoning with configurable effort, built-in speculative decoding for fast generation, tool calling
>
> **Best for:** Image-grounded document analysis alongside very large text inputs, and vision-guided agentic workloads
>
> **Model weights:** [deepseek-ai/DeepSeek-V4.1-Flash](https://huggingface.co/deepseek-ai/DeepSeek-V4.1-Flash)
>
> **Configuration repo:** [tinfoilsh/confidential-deepseek-v4-1-flash](https://github.com/tinfoilsh/confidential-deepseek-v4-1-flash)
>
> > [!NOTE]
> >
> > **Multimodal:** Supports text and image inputs with optional reasoning and tool calling. See [Image Processing Guide](/guides/image-processing.md) for usage examples.

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
> **Strengths:** Image understanding, object detection, document parsing, OCR, chart comprehension, and pointing
>
> **Best for:** Image analysis, document understanding, OCR tasks, and visual reasoning with built-in thinking mode
>
> **Model weights:** [google/gemma-4-31B-it](https://huggingface.co/google/gemma-4-31B-it)
>
> **Configuration repo:** [tinfoilsh/confidential-gemma4-31b](https://github.com/tinfoilsh/confidential-gemma4-31b)
>
> > [!NOTE]
> >
> > **Multimodal:** Supports variable aspect ratios and configurable image token budgets for balancing speed and detail. See [Image Processing Guide](/guides/image-processing.md) for usage examples.


This documentation is built and hosted on [Mintlify](https://mintlify.com), a developer documentation platform.