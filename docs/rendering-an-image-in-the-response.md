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

Rendering an image in the response
==================================

[Suggest Edits](/edit/rendering-an-image-in-the-response)

The Poe API allows you to embed images in your bot's response using Markdown syntax. The following is an example implementation describing a bot that returns a static response containing an image.

Python

```
from typing import AsyncIterable
from modal import Image, Stub, asgi_app
import fastapi_poe as fp

IMAGE_URL = "https://images.pexels.com/photos/46254/leopard-wildcat-big-cat-botswana-46254.jpeg"

class SampleImageResponseBot(fp.PoeBot):
    async def get_response(
        self, request: fp.QueryRequest
    ) -> AsyncIterable[fp.PartialResponse]:
        yield fp.PartialResponse(text=f"This is a test image. ![leopard]({IMAGE_URL})")
    
REQUIREMENTS = ["fastapi-poe==0.0.36"]
image = Image.debian_slim().pip_install(*REQUIREMENTS)
stub = Stub("image-response-poe")

@stub.function(image=image)
@asgi_app()
def fastapi_app():
    bot = SampleImageResponseBot()
    app = fp.make_app(bot, allow_without_key=True)
    return app

```

In order to run this code, you will need to setup Modal. For that, please follow Steps 1 and 2 in our [Quick start](/docs/quick-start). If you already have Modal set up, simply run `modal deploy main.py`. Modal will then deploy your bot server to the cloud and output the server url. Use that url when creating a server bot on [Poe](https://poe.com/create_bot?server=1).

The following is what the response looks like for someone using the above described bot.

![](https://files.readme.io/0c8c4a4-image.png)

Updated 12 months ago

---