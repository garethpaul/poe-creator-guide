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

How we cover your costs
=======================

[Suggest Edits](/edit/how-we-cover-your-costs)

Our intent is to cover all model inference costs and any other significant per-message costs involved in operating any bot on Poe. There are two ways this can happen at present:

* If you use the [bot query API](/docs/accessing-other-bots-on-poe), then the cost of any model inference used by any bot you query will be automatically covered by Poe.
  + This is the easiest option and should be used whenever possible. If you are using a standard base model that is available via a bot on Poe and there is a reason this option does not work for your use case, please [get in contact with us](/docs/how-to-contact-us).
* If you want to use a model that is not currently available on Poe (and therefore not available through the bot query API), we can work with you to pay your model inference costs. Depending on how expensive they are, we may need to restrict availability to your bot to Poe subscribers only, or to limit the number of messages per day that users can send to it.
  + If this is a fine-tuned version of a standard open source model, this will generally involve hosting the model on an inference provider like Fireworks, Together, or Replicate, and giving us visibility into the cost per token or per item.
  + If you are training your own model from scratch and hosting your own inference, we can discuss how we can best cover inference costs.
  + Please [contact us](/docs/how-to-contact-us) for more information about either of the above options.
* If there is some other especially expensive input to your bot (e.g. use of a web search API), we can likely cover that as well.

Updated about 1 year ago

---