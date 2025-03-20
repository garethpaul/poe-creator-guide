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

Updating bot settings
=====================

[Suggest Edits](/edit/updating-bot-settings)

The settings endpoint provides a way for you to opt in/out of Poe's features enabling you to customize the behavior of the bot. This article will describe how you can get Poe to fetch the latest settings from your bot.

#### 1. Set up your endpoint as described by the specs

If you are using the `fastapi_poe` library, then you just need to implement the `get_settings` method in the `PoeBot` class. The following is an example:

Python

```
async def get_settings(self, setting: fp.SettingsRequest) -> fp.SettingsResponse:
    return fp.SettingsResponse(allow_attachments=True)

```

#### 2. Get your access key

You can find this key by going to the bot page and clicking the gear icon.

![](https://files.readme.io/45f8a6d-image.png)

#### 3. Make a post request to Poe's refetch settings endpoint with your bot name and access key.

On Windows, you can use the `Invoke-RestMethod` command. On a Macbook or Linux machine, you can use the curl command as follows:

`curl -X POST https://api.poe.com/bot/fetch_settings/<botname>/<access_key>`

If you don't want to look for the `PROTOCOL_VERSION`, you could write a python script that calls `fp.sync_bot_settings`, and run the script.

Python

```
import fastapi_poe as fp

// Replace the bot name and access key with information of your bot
bot_name = "server_bot_name"
access_key = "your_server_bot_access_key"

fp.sync_bot_settings(bot_name, access_key)

```

That's it. The response to the above request will inform you whether the updated successfully.

Updated 9 months ago

---

* [Table of Contents](#)
* + [1. Set up your endpoint as described by the specs](#1-set-up-your-endpoint-as-described-by-the-specs)
  + [2. Get your access key](#2-get-your-access-key)
  + [3. Make a post request to Poe's refetch settings endpoint with your bot name and access key.](#3-make-a-post-request-to-poes-refetch-settings-endpoint-with-your-bot-name-and-access-key)