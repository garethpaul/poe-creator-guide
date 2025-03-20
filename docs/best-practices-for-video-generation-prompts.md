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

Best practices for video generation prompts
===========================================

[Suggest Edits](/edit/best-practices-for-video-generation-prompts)

Video generation bots
=====================

* [Pika](https://poe.com/Pika)

Prompting tips
--------------

1. **Be descriptive, rather than instructive**. Unlike for text generation bots, the style prompt should describe the desired video, **not** be an instruction to the bot. The best prompt structure is:

`Style, camera angle, description of character/ scene + verb (doing something) + background/ environment/setting + any additional information`

For example:

`Artistic. Low angle shot. An elderly woman wearing a floral sundress, tending to her vibrant garden. Golden hour lighting. --aspect 1:1`

[![Watch the video](https://pfst.cf2.poecdn.net/base/image/7eb64d64ef7fa487e2ee08654fdb7f5de08c462eaf0d840652d144ac255dc990?w=960&h=960&pmaid=100789168)](https://pfst.cf2.poecdn.net/base/video/845adb21e0af25a619cbed576304d6006f18698cba338d90b779d5d5b3b8eba3)

2. **Keep prompts concise**. Unlike for image generation bots (such as Midjourney), shorter prompts tend to work better.
3. **Add camera motions** Adding camera motions can produce more cinematic results.

* --zoom (in/out)
* --rotate (cw/ccw)
* --tilt (up/down)
* --pan (left/right)

Updated 8 months ago

---

* [Table of Contents](#)
* + [Video generation bots](#video-generation-bots)
    - [Prompting tips](#prompting-tips)