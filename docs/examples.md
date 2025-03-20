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

Example bots
============

[Suggest Edits](/edit/examples)

These bots are all server bots built on the API. You can try each of them live in Poe by clicking the link.

* [**StableDiffusionXL**](https://poe.com/StableDiffusionXL)
  + This bot uses SDXL to generate an image for the user based on their prompt.
  + A simplified version of the source code can be found at:
    - <https://github.com/poe-platform/server-bot-quick-start/blob/main/sdxl_bot.py>
    - This is a good starting point for building your own image generation bot.
* [**GPT-4o-mini**](https://poe.com/GPT-4o-Mini)
  + This bot uses OpenAI client to generate chat completions for the user's conversation.
  + A simplified version of the source code can be found at:
    - <https://github.com/poe-platform/server-bot-quick-start/blob/main/wrapper_bot.py>
    - This is a good starting point for building a conversational bot with OpenAI's client library.
* [**Web search**](https://poe.com/Web-Search)
  + This bot conducts web searches and then uses [GPT-4o Mini](https://poe.com/GPT-4o-Mini) via the [bot query API](/docs/accessing-other-bots-on-poe) to write an answer informed by the searches. This bot is an official bot operated by Poe, built entirely on the same API we make available to creators.
* [**Mixtral-8x7B-Chat**](https://poe.com/Mixtral-8x7B-Chat)
  + Created by [Fireworks](https://www.fireworks.ai/), this bot provides access to [Mixtral 8x7B Mixture-of-Experts](https://mistral.ai/news/mixtral-of-experts/).
  + Reference code for this bot, along with other Fireworks-hosted bots on Poe can be found at:
    - <https://github.com/fw-ai/fireworks_poe_bot>

Updated about 2 months ago

---