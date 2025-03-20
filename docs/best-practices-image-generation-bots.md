getting started
---------------

* [Poe Creator Guide](/docs/welcome-to-poe-for-creators)

Prompt Bots
-----------

* [How to create a prompt bot](/docs/how-to-create-a-prompt-bot)
* [Best practices for text generation prompts](/docs/best-practice-text-generation)
* [Best practices for image generation prompts](/docs/best-practices-image-generation-bots)
* [Best practices for video generation prompts](/docs/best-practices-for-video-generation-prompts)

Server bots
-----------

* [Quick Start](/docs/quick-start)
* [Functional Guides](/docs/server-bots-functional-guides)
* [Recommended bot settings](/docs/recommended-bot-settings)
* [fastapi\_poe: Python API Reference](/docs/fastapi_poe-python-reference)
* [Poe Protocol Specification](/docs/poe-protocol-specification)
* [Example bots](/docs/examples)

Canvas Apps
-----------

* [Quick Start](/docs/canvas-app-quick-start)
* [Canvas limitations](/docs/canvas-limitations)
* [Poe Embed API](/docs/poe-embed-api)

Resources
---------

* [Creator Monetization](/docs/creator-monetization)
* [How we cover your costs](/docs/how-we-cover-your-costs)
* [How to get distribution](/docs/how-to-get-distribution)
* [Fundraising](/docs/fundraising)
* [Frequently asked questions](/docs/frequently-asked-questions)
* [How to contact us](/docs/how-to-contact-us)

Powered by

Best practices for image generation prompts
===========================================

[Suggest Edits](/edit/best-practices-image-generation-bots)

Image generation
================

You can build image generation prompt bots on top of several available models, including:

* [DALL-E-3](https://poe.com/DALL-E-3)
* [StableDiffusion3](https://poe.com/StableDiffusion3)
* [SD3-Turbo](https://poe.com/SD3-Turbo)
* [StableDiffusionXL](https://poe.com/StableDiffusionXL)
* [Playground-v2.5](https://poe.com/Playground-v2.5)
* [FLUX-pro](https://poe.com/FLUX-pro)
* [FLUX-schnell](https://poe.com/FLUX-schnell)
* [FLUX-dev](https://poe.com/FLUX-dev)
* [Playground-v3](https://poe.com/Playground-v3)

These bots support [templating](/docs/best-practices-image-generation-bots#templating) when used as a base bot.

Prompting tips
--------------

1. **Be descriptive, rather than instructive**. Unlike for text generation bots, the style prompt should describe the desired image, **not** be an instruction to the bot. This is especially true for StableDiffusionXL, Playground-v2.5 and Playground-v3. For example, to generate paintings in the style of Vincent Van Gogh:

**Instead of:**

```
You are VanGoghBot. You will generate paintings in the style of Van Gogh.

```

**Try:**

```
painting, Van Gogh

```

2. **Be specific in your prompt:** The more specific and detailed your prompt is, the better the chances of getting the desired image. Instead of using a generic term like `landscape`, try specifying elements like `sunset over a beach with palm trees`. You can also specify multiple elements or style descriptions separated by punctuations, e.g. `beautiful sunset, rain, painting, Van Gogh`.
3. **Utilize the** [**negative prompt**](/docs/best-practices-image-generation-bots#negative-prompts-stablediffusionxl-and-playground-v25-only) **(StableDiffusionXL, Playground-v2.5 and Playground-v3 only):** If there are certain elements you don't want in your image, use the negative prompt feature. For example, if you don't want any buildings in your landscape, include `buildings` in your negative prompt.

### How do style prompts and user prompts get merged?

By default, style prompts and user prompts get concatenated.

For example, with a **style prompt**:

```
cartoon --no color

```

and a **user prompt**:

```
dog --no cat

```

The **final prompt** will be:

```
dog, cartoon --no cat, color

```

**Note:** the `--no` parameter is only accepted by StableDiffusionXL.

### Templating

Poe also supports Jinja templating for image generation bots to provide bot creators with flexibility over how style prompts and user prompts get merged.

Specifically, specify a `{{user_prompt}}` in either (or both!) of the style prompt and negative prompts to indicate where the user's prompt and negative prompts should go, respectively.

For example, with a **style prompt**:

```
happy, smiling {{user_prompt}} on a skateboard --no scooter, {{user_prompt}}, cartoon

```

and a **user prompt**:

```
dog --no cat

```

the **final prompt** will be:

```
happy, smiling dog on a skateboard --no scooter, cat, cartoon

```

### Negative prompts (StableDiffusionXL and Playground-v2.5 only)

Specify a `--no` parameter to indicate elements that should be avoided in the generated image. For example:

![](https://files.readme.io/f35c0f8-image.png)

Updated 7 months ago

---

* [Table of Contents](#)
* + [Image generation](#image-generation)
    - [Prompting tips](#prompting-tips)