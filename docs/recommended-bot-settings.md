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

Recommended bot settings
========================

[Suggest Edits](/edit/recommended-bot-settings)

There are various settings that can be applied to your bot. For the best user experience we recommend turning on the following settings for your bot:

* `enable_multi_bot_chat_prompting=True`: This will automatically apply some prompting to make sure your bots respond appropriately when there are multiple bots in the chat.
  + We recommend turning this on for all bots as long as they don’t rely on the conversation history having specific formatting.
  + This may cause two human messages to appear consecutively though; if that’s an issue, you can turn on `enforce_author_role_alternation` to automatically handle this.
* `allow_attachments=True`: Turn on attachments for your bot
  + For text attachments, this will by default parse the text attachment and include it in the prompt (since `expand_text_attachments=True` by default)
* Recommend turning on for all text-based bots without native vision capabilities:
  + `enable_image_comprehension=True`: Poe converts images into text prompts using a vision model
    - You should enable this for models which doesn’t support multimodality yet.

Updated 10 months ago

---