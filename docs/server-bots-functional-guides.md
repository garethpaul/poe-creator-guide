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

Functional Guides
=================

[Suggest Edits](/edit/server-bots-functional-guides)

If you are just getting started with server bots, we recommend checking out our [quick start](/docs/quick-start) guide. The following guides provide examples of accomplishing specific things with your bot.

* The examples assume that you have installed the latest version of fastapi\_poe (you can install this using pip by running `pip install fastapi_poe`.
* The full code examples also assume that you are hosting your bot on Modal. Although we recommend Modal for it's simplicity, you should be able to deploy your server bot on any cloud provider. To learn how to setup Modal, please follow Steps 1 and 2 in our [Quick start](/docs/quick-start). If you already have Modal set up, simply copy the full code examples into a file called `main.py` and then run `modal deploy main.py`. Modal will then deploy your bot server to the cloud and output the server url. Use that url when creating a server bot on [Poe](https://poe.com/create_bot?server=1).

Accessing other bots on Poe
===========================

The Poe bot query API allows creators to invoke other bots on Poe (which includes bots created by Poe like GPT-3.5-Turbo and Claude-Instant and bots created by other creators) and this access is provided for free so that creators do not have to worry about LLM costs. For every user message, server bot creators get to make up to ten calls to another bot of their choice.

#### Declare dependency in your PoeBot class

You have to declare your bot dependencies using the [settings](/docs/poe-protocol-specification#settings) endpoint.

Python

```
async def get_settings(self, setting: fp.SettingsRequest) -> fp.SettingsResponse:
    return fp.SettingsResponse(server_bot_dependencies={"GPT-3.5-Turbo": 1})

```

In your `get_response` handler, use the `stream_request` function to invoke any bot you want. The following is an example where we forward the user's query to `GPT-3.5-Turbo` and return the result.

Python

```
async def get_response(
    self, request: fp.QueryRequest
) -> AsyncIterable[fp.PartialResponse]:
    async for msg in fp.stream_request(
        request, "GPT-3.5-Turbo", request.access_key
    ):
        yield msg

```

The final code for your `PoeBot` should look like:

PythonFull Setup Code (Python)

```
class GPT35TurboBot(fp.PoeBot):
    async def get_response(
        self, request: fp.QueryRequest
    ) -> AsyncIterable[fp.PartialResponse]:
        async for msg in fp.stream_request(
            request, "GPT-3.5-Turbo", request.access_key
        ):
            # Add whatever logic you'd like here before yielding the result!
            yield msg

    async def get_settings(self, setting: fp.SettingsRequest) -> fp.SettingsResponse:
        return fp.SettingsResponse(server_bot_dependencies={"GPT-3.5-Turbo": 1})

```

```
from __future__ import annotations
from typing import AsyncIterable
from modal import App, Image, asgi_app
import fastapi_poe as fp

class GPT35TurboBot(fp.PoeBot):
    async def get_response(
        self, request: fp.QueryRequest
    ) -> AsyncIterable[fp.PartialResponse]:
        async for msg in fp.stream_request(
            request, "GPT-3.5-Turbo", request.access_key
        ):
            # Add whatever logic you'd like here before yielding the result!
            yield msg

    async def get_settings(self, setting: fp.SettingsRequest) -> fp.SettingsResponse:
        return fp.SettingsResponse(server_bot_dependencies={"GPT-3.5-Turbo": 1})

      
REQUIREMENTS = ["fastapi-poe==0.0.48"]
image = Image.debian_slim().pip_install(*REQUIREMENTS)
app = App("gpt35turbo-poe")


@app.function(image=image)
@asgi_app()
def fastapi_app():
    bot = GPT35TurboBot()
    # see https://creator.poe.com/docs/quick-start#configuring-the-access-credentials
    app = fp.make_app(bot, access_key=<YOUR_ACCESS_KEY>, bot_name=<YOUR_BOT_NAME>)
    return app

```

Thats it! Try chatting with your bot now, and you should see responses from GPT-3.5-Turbo.

> 🚧 Warning
> ---------
>
> If you see some error related to bot call counts, it's possible your dependencies are not updated properly. See [Updating Bot Settings](/docs/server-bots-functional-guides#updating-bot-settings) for possible resolutions.

Rendering an image in your response
===================================

The Poe API allows you to embed images in your bot's response using Markdown syntax. The following is an example implementation describing a bot that returns a static response containing an image.

PythonFull Setup Code (Python)

```
IMAGE_URL = "https://images.pexels.com/photos/46254/leopard-wildcat-big-cat-botswana-46254.jpeg"

class SampleImageResponseBot(fp.PoeBot):
    async def get_response(
        self, request: fp.QueryRequest
    ) -> AsyncIterable[fp.PartialResponse]:
        yield fp.PartialResponse(text=f"This is a test image. ![leopard]({IMAGE_URL})")

```

```
from typing import AsyncIterable
from modal import App, Image, asgi_app, exit
import fastapi_poe as fp

IMAGE_URL = "https://images.pexels.com/photos/46254/leopard-wildcat-big-cat-botswana-46254.jpeg"

class SampleImageResponseBot(fp.PoeBot):
    async def get_response(
        self, request: fp.QueryRequest
    ) -> AsyncIterable[fp.PartialResponse]:
        yield fp.PartialResponse(text=f"This is a test image. ![leopard]({IMAGE_URL})")
  
REQUIREMENTS = ["fastapi-poe==0.0.48"]
image = Image.debian_slim().pip_install(*REQUIREMENTS)
app = App("imageresponse-poe")


@app.function(image=image)
@asgi_app()
def fastapi_app():
    bot = SampleImageResponseBot()
    # see https://creator.poe.com/docs/quick-start#configuring-the-access-credentials
    # app = fp.make_app(bot, access_key=<YOUR_ACCESS_KEY>, bot_name=<YOUR_BOT_NAME>)
    app = fp.make_app(bot, allow_without_key=True)
    return app


```

The following is what the response looks like for someone using the above described bot.

![](https://files.readme.io/0c8c4a4-image.png)

Rendering HTML in your response
===============================

### Using a HTML code block

If a Markdown message contains a HTML code block, both the code block and the preview will be rendered. Note that the code block content must begin with `<html>`.

For example the following message:

md

```
```html
<html>
  <h1>hello world</h1>
</html>
```

```

Will render like this:

![](https://files.readme.io/b5e8dff-image.png)

### Using inline HTML

If a bot's Markdown output contains a block outside a code block, the HTML block will be rendered without displaying the code.

The following message:

```
<html>
   <h1>hello world</h1>
</html>

```

Will render like this:

![](https://files.readme.io/31c83c4-image.png)
> ❗️ Avoid Empty Lines
> --------------------
>
> The HTML block should not contain any empty lines, as Markdown will interpret these as separate blocks, breaking the HTML structure.

### Embedding an iframe in a message

When a bot's markdown output contains `<iframe src="{{url}}">` outside of a code block, the iframe will be rendered. For best results, always include the height attribute.

The following message:

```
<iframe 
  height="315"
  src="https://www.youtube.com/embed/GBxblAUN3ro?si=K9BxwGdjexz1Vf_4"></iframe>

```

Will render like this:

![](https://files.readme.io/65251f4b045a00c6696fc26f8c5e76e1c2129751aecbfde3fbc06f598c97608d-image.png)

Enabling file upload for your bot
=================================

The Poe API allows your bot to take files as input. There are several settings designed to streamline the process of enabling file uploads for your bot:

* `allow_attachments` (default `False`): Turning this on will allow Poe users to send files to your bot. Attachments will be sent as attachment objects with url, content\_type, and name.
* `expand_text_attachments` (default `True`): If `allow_attachments=True`, Poe will parse text files and send their content in the `parsed_content` field of the attachment object.
* `enable_image_comprehension` (default `False`): If `allow_attachments=True`, Poe will use image vision to generate a description of image attachments and send their content in the `parsed_content` field of the attachment object. If this is enabled, the Poe user will only be able to send at most one image per message due to image vision limitations.

Python

```
async def get_settings(self, setting: fp.SettingsRequest) -> fp.SettingsResponse:
    return fp.SettingsResponse(
      allow_attachments=True, expand_text_attachments=True, enable_image_comprehension=True
    )

```

That's it! Your bot should now be able to handle image and text attachments in addition to the user's chat input. 🎉

**Note**: If you have either attachment parsing setting on (`expand_text_attachments` or `enable_image_comprehension`), `fastapi_poe` will automatically add user-role messages containing each file's `parsed_content` into the conversation prior to the last user message. See [templates.py](https://github.com/poe-platform/fastapi_poe/blob/main/src/fastapi_poe/templates.py) for how the file contents are added. Note that because this adds additional user-role messages to the conversation, if the LLM you are using requires role alternation between the bot and the user, you will need to reformat the conversation. `make_prompt_author_role_alternated` is provided to help with that.

If you would like to disable the file content insertion, you can use `should_insert_attachment_messages=False` when initializing your PoeBot class. You can also override `insert_attachment_messages()` if you want to use your own templates.

Python

```
bot = YourBot(should_insert_attachment_messages=False)  
app = make_app(bot)

```

### Parsing your own files

If your expected filetypes are not supported, or you want to perform more complex operations and would rather handle the file contents yourself, that is also possible using the file url, which is passed in through the attachment object. Here is an example of setting up a bot which counts the number of pages in a PDF document.

We will utilize a python library called `pypdf2` (which you can install using `pip install pypdf2`) to parse the pdf and count the number of pages. We will use the `requests` library (which you can install using `pip install requests`) to download the file.

Python

```
def _fetch_pdf_and_count_num_pages(url: str) -> int:
    response = requests.get(url)
    if response.status_code != 200:
        raise FileDownloadError()
    with open("temp_pdf_file.pdf", "wb") as f:
        f.write(response.content)
    reader = PdfReader("temp_pdf_file.pdf")
    return len(reader.pages)

```

Now we will set up a bot class that will iterate through the user messages and identify the latest pdf file to compute the number of pages for.

Python

```
class PDFSizeBot(fp.PoeBot):
    async def get_response(
        self, request: fp.QueryRequest
    ) -> AsyncIterable[fp.PartialResponse]:
        for message in reversed(request.query):
            for attachment in message.attachments:
                if attachment.content_type == "application/pdf":
                    try:
                        num_pages = _fetch_pdf_and_count_num_pages(attachment.url)
                        yield fp.PartialResponse(text=f"{attachment.name} has {num_pages} pages")
                    except FileDownloadError:
                        yield fp.PartialResponse(text="Failed to retrieve the document.")
                    return

```

The final code should look like:

PythonFull Setup Code (Python)

```
class FileDownloadError(Exception):
    pass

def _fetch_pdf_and_count_num_pages(url: str) -> int:
    response = requests.get(url)
    if response.status_code != 200:
        raise FileDownloadError()
    with open("temp_pdf_file.pdf", "wb") as f:
        f.write(response.content)
    reader = PdfReader("temp_pdf_file.pdf")
    return len(reader.pages)

class PDFSizeBot(fp.PoeBot):
    async def get_response(
        self, request: fp.QueryRequest
    ) -> AsyncIterable[fp.PartialResponse]:
        for message in reversed(request.query):
            for attachment in message.attachments:
                if attachment.content_type == "application/pdf":
                    try:
                        num_pages = _fetch_pdf_and_count_num_pages(attachment.url)
                        yield fp.PartialResponse(text=f"{attachment.name} has {num_pages} pages")
                    except FileDownloadError:
                        yield fp.PartialResponse(text="Failed to retrieve the document.")
                    return

    async def get_settings(self, setting: fp.SettingsRequest) -> fp.SettingsResponse:
        return fp.SettingsResponse(allow_attachments=True)

```

```
from __future__ import annotations
from typing import AsyncIterable
import requests
from PyPDF2 import PdfReader
import fastapi_poe as fp

from modal import App, Image, asgi_app, exit

class FileDownloadError(Exception):
    pass


def _fetch_pdf_and_count_num_pages(url: str) -> int:
    response = requests.get(url)
    if response.status_code != 200:
        raise FileDownloadError()
    with open("temp_pdf_file.pdf", "wb") as f:
        f.write(response.content)
    reader = PdfReader("temp_pdf_file.pdf")
    return len(reader.pages)


class PDFSizeBot(fp.PoeBot):
    async def get_response(
        self, request: fp.QueryRequest
    ) -> AsyncIterable[fp.PartialResponse]:
        for message in reversed(request.query):
            for attachment in message.attachments:
                if attachment.content_type == "application/pdf":
                    try:
                        num_pages = _fetch_pdf_and_count_num_pages(attachment.url)
                        yield fp.PartialResponse(text=f"{attachment.name} has {num_pages} pages")
                    except FileDownloadError:
                        yield fp.PartialResponse(text="Failed to retrieve the document.")
                    return

    async def get_settings(self, setting: fp.SettingsRequest) -> fp.SettingsResponse:
        return fp.SettingsResponse(allow_attachments=True)

REQUIREMENTS = ["fastapi-poe==0.0.48"]
image = Image.debian_slim().pip_install(*REQUIREMENTS)
app = App("pdfsizebot-poe")


@app.function(image=image)
@asgi_app()
def fastapi_app():
    bot = PDFSizeBot()
    # see https://creator.poe.com/docs/quick-start#configuring-the-access-credentials
    app = fp.make_app(bot, access_key=<YOUR_ACCESS_KEY>, bot_name=<YOUR_BOT_NAME>)
    return app


```

Sending files with your response
================================

The Poe API allows you to send attachments with your bot response. When using the `fastapi_poe` library, send file attachments with your bot response by calling `post_message_attachment` within the `get_response` function of your bot.

### **Example**

In this example, the bot will take the input from the user, write it into a text file, and attach that text file in the response to the user. Copy the following code into a file called `main.py` (you can pick any name but the deployment commands that follow assume that this is the file name). Change the `access_key` stub with your actual key that you can generate on the [create bot](https://poe.com/create_bot) page.

PythonFull Setup Code (Python)

```
class AttachmentOutputDemoBot(fp.PoeBot):
    async def get_response(
        self, request: fp.QueryRequest
    ) -> AsyncIterable[fp.PartialResponse]:
        await self.post_message_attachment(
           message_id=request.message_id, file_data=request.query[-1].content, filename="dummy.txt"
        )
        yield fp.PartialResponse(text=f"Attached a text file containing your last message.")

```

```
from __future__ import annotations
from typing import AsyncIterable
import fastapi_poe as fp
from modal import App, Image, asgi_app


class AttachmentOutputDemoBot(fp.PoeBot):
    async def get_response(
        self, request: fp.QueryRequest
    ) -> AsyncIterable[fp.PartialResponse]:
        await self.post_message_attachment(
           message_id=request.message_id, file_data=request.query[-1].content, filename="dummy.txt"
        )
        yield fp.PartialResponse(text=f"Attached a text file containing your last message.")

REQUIREMENTS = ["fastapi-poe==0.0.48"]
image = Image.debian_slim().pip_install(*REQUIREMENTS)
app = App("attachment-output-demo-poe")

@app.function(image=image)
@asgi_app()
def fastapi_app():
    bot = AttachmentOutputDemoBot()
    # see https://creator.poe.com/docs/quick-start#configuring-the-access-credentials
    # app = fp.make_app(bot, access_key=<YOUR_ACCESS_KEY>, bot_name=<YOUR_BOT_NAME>)
    app = fp.make_app(bot, allow_without_key=True)
    return app


```

> 📘 Limitations
> -------------
>
> * The `access_key` should be the key associated with the bot sending the response. It can be found in the edit bot page.
> * It does not matter where `post_message_attachment` is called, as long as it is within the body of `get_response`. It can be called multiple times to attach multiple (up to 20) files.
> * A file should not be larger than 50MB.

Rendering an audio player in your response
------------------------------------------

If an attachment is an mp3 file, you'll see an audio player display. The following is an example implementation describing a bot that returns a response containing an audio file.

Python

```
AUDIO_URL = "..."

class AttachmentOutputDemoBot(fp.PoeBot):
    async def get_response(
        self, request: fp.QueryRequest
    ) -> AsyncIterable[fp.PartialResponse]:
        await self.post_message_attachment(
           message_id=request.message_id, download_url=AUDIO_URL
        )
        yield fp.PartialResponse(text="Hi")

```

![](https://files.readme.io/6fd02917dde2644a091175c00c13ea6ba9d54b9c83120c9fd6bf24f82b85d3b0-Screenshot_2024-11-19_at_16.47.25.png)

Rendering a video player in your response
-----------------------------------------

If an attachment is one of the following: quicktime, mpeg, mp4, mpg, avi, x-msvideo, x-ms-wmv, or x-flv you’ll see an video player display. The following is an example implementation describing a bot that returns a response containing an video file.

Python

```
VIDEO_URL = "..."

class AttachmentOutputDemoBot(fp.PoeBot):
    async def get_response(
        self, request: fp.QueryRequest
    ) -> AsyncIterable[fp.PartialResponse]:
        await self.post_message_attachment(
           message_id=request.message_id, download_url=VIDEO_URL
        )
        yield fp.PartialResponse(text="")

```

![](https://files.readme.io/c0551f6575dca96e7825dd11a160bec38c15673e601a9f4dfc6afd03ec80e44c-Screenshot_2024-11-19_at_16.49.49.png)

Creating bots that help their users create prompt bots
======================================================

Your bot can help users create prompt bots with pre-filled fields. Here are some example use-case for this:

* Your bot helps users do prompt engineering, then provides a link the user can use to create a bot easily with the prompt they have developed.
* When a user uploads training data, your bot could run fine-tuning and provide a link to create a new prompt bot. This new bot's prompt would include the fine-tuned model ID, which its base bot can extract from the prompt to do inference.

More specifically, your bot’s response can contain a link to pre-fill the form fields on [poe.com/create\_bot](http://poe.com/create_bot) by passing GET parameters. The user can submit the form as-is or manually edit before submitting. The supported GET parameters are:

* `prompt` — this is the string which will pre-fill the prompt section on the form.
* `base_bot` — this is the string name for a bot to pre-select from the base bot list on the form.\*

Python

```
import urllib

class FineTuneTrainingBot(fp.PoeBot):
    async def get_response(
        self, request: fp.QueryRequest
    ) -> AsyncIterable[fp.PartialResponse]:
		    fine_tune_id = my_api.generate_fine_tune_id(request)
        params = {
          "prompt": f"{{user_prompt}} --fine-tune-id {fine_tune_id}",
          "base_bot": "FineTuneInferenceBot"
        }
        url_base = "https://poe.com/create_bot?"
        url_params = urllib.parse.urlencode(params)
        yield fp.PartialResponse(
              text=f"[Finish creating your bot.]({url_base}{url_params})")

```

\*If you are interested in including your bot in this list, please reach out to [[email protected]](/cdn-cgi/l/email-protection#a3c7c6d5c6cfccd3c6d1d0e3d3ccc68dc0ccce)

Setting an introduction message
===============================

The Poe API allows you to set a friendly introduction message for your bot, providing you with a way to instruct the users on how they should use the bot. In order to do so, you have to override `get_settings` and set the parameter called `introduction_message` to whatever you want that message to be.

Python

```
async def get_settings(self, setting: fp.SettingsRequest) -> fp.SettingsResponse:
    return fp.SettingsResponse(
        introduction_message="Welcome to the trivia bot. Please provide me a topic that you would like me to quiz you on."
    )

```

The final code looks like:

PythonFull Setup Code (Python)

```
class TriviaBotSample(fp.PoeBot):
    async def get_response(self, query: fp.QueryRequest) -> AsyncIterable[fp.PartialResponse]:
        # implement the trivia bot.
        yield fp.PartialResponse(text="Bot under construction. Please visit later")

    async def get_settings(self, setting: fp.SettingsRequest) -> fp.SettingsResponse:
        return fp.SettingsResponse(
            introduction_message="Welcome to the trivia bot. Please provide me a topic that you would like me to quiz you on."
        )

```

```
from __future__ import annotations
from typing import AsyncIterable
from modal import App, Image, asgi_app
import fastapi_poe as fp

class TriviaBotSample(fp.PoeBot):
    async def get_response(self, query: fp.QueryRequest) -> AsyncIterable[fp.PartialResponse]:
        # implement the trivia bot.
        yield fp.PartialResponse(text="Bot under construction. Please visit later")

    async def get_settings(self, setting: fp.SettingsRequest) -> fp.SettingsResponse:
        return fp.SettingsResponse(
            introduction_message="Welcome to the trivia bot. Please provide me a topic that you would like me to quiz you on."
        )
    
REQUIREMENTS = ["fastapi-poe==0.0.48"]
image = Image.debian_slim().pip_install(*REQUIREMENTS)
app = App("trivia-bot-poe")


@app.function(image=image)
@asgi_app()
def fastapi_app():
    bot = TriviaBotSample()
    # see https://creator.poe.com/docs/quick-start#configuring-the-access-credentials
    # app = fp.make_app(bot, access_key=<YOUR_ACCESS_KEY>, bot_name=<YOUR_BOT_NAME>)
    app = fp.make_app(bot, allow_without_key=True)
    return app


```

Multi Bot Support
=================

The Poe client support @-mentioning other bots within the same chat. To include this support in with your bot, you need to enable `enable_multi_bot_chat_prompting` (Default False) in your bot settings. When this is enabled, Poe will check the previous chat history to see if there are multiple bots, and if so, it will combine the previous messages and add prompting such that your bot will have sufficient context about the conversation so far.

If this setting is not enabled, you will continue to see bot/user messages as separate `ProtocolMessages` just like before.

Updating bot settings
=====================

Bots on poe each have [settings](/docs/poe-protocol-specification#settings) that control how the bot behaves. For example, one such setting is `server_bot_dependencies`, which allows you to [call other bots on poe](/docs/server-bots-functional-guides#accessing-other-bots-on-poe). It is important to note that after modifying these settings, (i.e. after modifying `get_settings()` in your `PoeBot` class), these updates still need to be sent to the Poe servers. This is typically done automatically on server bot startup, within fastapi\_poe's make\_app function,

> ❗️ Warning!!!
> -------------
>
> If you are not using `fastapi_poe` or you do not provide the `access_key` and `bot_name` into make\_app() (see [configuring access credentials](/docs/quick-start#configuring-the-access-credentials)), **you will need to manually sync these settings** using the steps below.

#### 1. Modify the bot settings to your desired specification

If you are using the `fastapi_poe` library, then you just need to implement the `get_settings` method in the `PoeBot` class. The following is an example:

Python

```
async def get_settings(self, setting: fp.SettingsRequest) -> fp.SettingsResponse:
    return fp.SettingsResponse(allow_attachments=True, server_bot_dependencies={"GPT-3.5-Turbo": 1, "Claude-instant": 1})

```

#### 2. Get your access key and bot name

You can find both the access key and the bot name in the "edit bot" page by clicking on your bot -> clicking the triple dots -> edit bot.

![](https://files.readme.io/45f8a6d-image.png)

#### 3. Make a post request to Poe's refetch settings endpoint with your bot name and access key.

This is done by calling`fp.client.sync_bot_settings` from within a python script.

Python

```
import fastapi_poe as fp

# Replace the bot name and access key with information of your bot
bot_name = "server_bot_name"
access_key = "your_server_bot_access_key"

fp.sync_bot_settings(bot_name, access_key)

```

If you are not using the python `fastapi_poe` library, you can also use `curl`:

`curl -X POST https://api.poe.com/bot/fetch_settings/<botname>/<access_key>`

Note that it is highly recommended to use `fastapi_poe`, and some features may not work smoothly without it.

Using OpenAI function calling
=============================

The Poe API allows you to use OpenAI function calling when accessing OpenAI models. In order to use this feature, you will simply need to provide a tools list which contains objects describing your function and an executables list which contains functions that correspond to the tools list. The following is an example.

Python

```
def get_current_weather(location, unit="fahrenheit"):
    """Get the current weather in a given location"""
    if "tokyo" in location.lower():
        return json.dumps({"location": "Tokyo", "temperature": "11", "unit": unit})
    elif "san francisco" in location.lower():
        return json.dumps(
            {"location": "San Francisco", "temperature": "72", "unit": unit}
        )
    elif "paris" in location.lower():
        return json.dumps({"location": "Paris", "temperature": "22", "unit": unit})
    else:
        return json.dumps({"location": location, "temperature": "unknown"})


tools_executables = [get_current_weather]

tools_dict_list = [
    {
        "type": "function",
        "function": {
            "name": "get_current_weather",
            "description": "Get the current weather in a given location",
            "parameters": {
                "type": "object",
                "properties": {
                    "location": {
                        "type": "string",
                        "description": "The city and state, e.g. San Francisco, CA",
                    },
                    "unit": {"type": "string", "enum": ["celsius", "fahrenheit"]},
                },
                "required": ["location"],
            },
        },
    }
]
tools = [fp.ToolDefinition(**tools_dict) for tools_dict in tools_dict_list]

```

Additionally, you will need to define a dependency of two calls on an OpenAI model of your choice (in this case, the GPT-3.5-Turbo). You need a dependency of two because as part of the OpenAI function calling [flow](https://platform.openai.com/docs/guides/function-calling/common-use-cases), you need to call OpenAI twice. Adjust this dependency limit if you want to make more than one function calling request while computing your response.

Python

```
async def get_settings(self, setting: fp.SettingsRequest) -> fp.SettingsResponse:
    return fp.SettingsResponse(server_bot_dependencies={"GPT-3.5-Turbo": 2})

```

The final code (including the setup code you need to host this on [Modal](https://modal.com/)) that goes into your `main.py` is as follows:

PythonFull Setup Code (Python)

```
def get_current_weather(location, unit="fahrenheit"):
    """Get the current weather in a given location"""
    if "tokyo" in location.lower():
        return json.dumps({"location": "Tokyo", "temperature": "11", "unit": unit})
    elif "san francisco" in location.lower():
        return json.dumps(
            {"location": "San Francisco", "temperature": "72", "unit": unit}
        )
    elif "paris" in location.lower():
        return json.dumps({"location": "Paris", "temperature": "22", "unit": unit})
    else:
        return json.dumps({"location": location, "temperature": "unknown"})


tools_executables = [get_current_weather]

tools_dict_list = [
    {
        "type": "function",
        "function": {
            "name": "get_current_weather",
            "description": "Get the current weather in a given location",
            "parameters": {
                "type": "object",
                "properties": {
                    "location": {
                        "type": "string",
                        "description": "The city and state, e.g. San Francisco, CA",
                    },
                    "unit": {"type": "string", "enum": ["celsius", "fahrenheit"]},
                },
                "required": ["location"],
            },
        },
    }
]
tools = [fp.ToolDefinition(**tools_dict) for tools_dict in tools_dict_list]


class GPT35FunctionCallingBot(fp.PoeBot):
    async def get_response(
        self, request: fp.QueryRequest
    ) -> AsyncIterable[fp.PartialResponse]:
        async for msg in fp.stream_request(
            request,
            "GPT-3.5-Turbo",
            request.access_key,
            tools=tools,
            tool_executables=tools_executables,
        ):
            yield msg

    async def get_settings(self, setting: fp.SettingsRequest) -> fp.SettingsResponse:
        return fp.SettingsResponse(server_bot_dependencies={"GPT-3.5-Turbo": 2})

```

```
from __future__ import annotations

import json
from typing import AsyncIterable

import fastapi_poe as fp
from modal import App, Image, asgi_app, exit


def get_current_weather(location, unit="fahrenheit"):
    """Get the current weather in a given location"""
    if "tokyo" in location.lower():
        return json.dumps({"location": "Tokyo", "temperature": "11", "unit": unit})
    elif "san francisco" in location.lower():
        return json.dumps(
            {"location": "San Francisco", "temperature": "72", "unit": unit}
        )
    elif "paris" in location.lower():
        return json.dumps({"location": "Paris", "temperature": "22", "unit": unit})
    else:
        return json.dumps({"location": location, "temperature": "unknown"})


tools_executables = [get_current_weather]

tools_dict_list = [
    {
        "type": "function",
        "function": {
            "name": "get_current_weather",
            "description": "Get the current weather in a given location",
            "parameters": {
                "type": "object",
                "properties": {
                    "location": {
                        "type": "string",
                        "description": "The city and state, e.g. San Francisco, CA",
                    },
                    "unit": {"type": "string", "enum": ["celsius", "fahrenheit"]},
                },
                "required": ["location"],
            },
        },
    }
]
tools = [fp.ToolDefinition(**tools_dict) for tools_dict in tools_dict_list]


class GPT35FunctionCallingBot(fp.PoeBot):
    async def get_response(
        self, request: fp.QueryRequest
    ) -> AsyncIterable[fp.PartialResponse]:
        async for msg in fp.stream_request(
            request,
            "GPT-3.5-Turbo",
            request.access_key,
            tools=tools,
            tool_executables=tools_executables,
        ):
            yield msg

    async def get_settings(self, setting: fp.SettingsRequest) -> fp.SettingsResponse:
        return fp.SettingsResponse(server_bot_dependencies={"GPT-3.5-Turbo": 2})


REQUIREMENTS = ["fastapi-poe==0.0.48"]
image = Image.debian_slim().pip_install(*REQUIREMENTS)
app = App("functioncalling-poe")

@app.function(image=image)
@asgi_app()
def fastapi_app():
    bot = GPT35FunctionCallingBot()
    # see https://creator.poe.com/docs/quick-start#configuring-the-access-credentials
    app = fp.make_app(bot, access_key=<YOUR_ACCESS_KEY>, bot_name=<YOUR_BOT_NAME>)
    return app


```

![](https://files.readme.io/a293e19-image.png)

  

Storing Metadata with a Bot Response
====================================

Bots can persist additional data about their response by yielding a `DataResponse`. This metadata is stored in the `metadata` field of the associated `ProtocolMessage` and will be available in future requests to the same bot. This enables state management across multiple messages in a conversation without exposing internal details to users.

For example, consider some troubleshooting bot that uses metadata to track which diagnostic steps have been attempted:

Python

```
class TroubleShootingBot(fp.PoeBot):
  async def get_response(
        self, request: fp.QueryRequest
    ) -> AsyncIterable[fp.PartialResponse]:
    
        diagnosis_steps_to_directions = {
            "Check printer light": "Check the light on the top of the printer.",
            "Check connection": "Check the printer is connected to wifi.",
            "Check drivers": "Check your device has the latest drivers."
        }

        # Access metadata to remove steps that have already been tried.
        for prev_message in request.query:
            if prev_message.role == "bot" and prev_message.metadata is not None:
                message_metadata = json.loads(prev_message.metadata)
                if message_metadata.get("diagnosis_step") is not None:
                    diagnosis_steps_to_directions.pop(message_metadata["diagnosis_step"])

        # If there are no remaining steps, return a message saying so.
        if not diagnosis_steps_to_directions:
            yield fp.PartialResponse(text="I've tried everything.")
            return

        # Recommend a next step
        recommended_next_step = random.choice(list(diagnosis_steps_to_directions.keys()))
        yield fp.PartialResponse(text=diagnosis_steps_to_directions[recommended_next_step])

        # Persist the recommended step in the message metadata
        yield fp.DataResponse(
            metadata=json.dumps({"diagnosis_step": recommended_next_step}),
        )


```

Beyond storing conversation state, `DataResponse` can also be useful for persisting data that doesn't make sense to expose to the user, like identifiers or performance metrics.

> 📘 Important Notes
> -----------------
>
> * Only yield one `DataResponse` per request - if multiple are sent, only the last one is stored
> * Metadata is only visible to the bot that created it - so using this field to pass data between bots will not work.

Accessing HTTP request information
==================================

In the special case that you need to access specific http information about the requests coming to your bot, our python client ([fastapi\_poe](https://github.com/poe-platform/fastapi_poe)) exposes the underlying Starlette [Request](https://www.starlette.io/requests/) object in the ".http\_request" attribute of the request object passed to the query handler. This allows you to access the request information such as the url and query params. The following is an example (including the setup code you need to host this on [Modal](https://modal.com/)):

PythonFull Setup Code (Python)

```
class HttpRequestBot(fp.PoeBot):
    async def get_response_with_context(
        self, request: fp.QueryRequest, context: fp.RequestContext
    ) -> AsyncIterable[fp.PartialResponse]:
        request_url = context.http_request.url
        query_params = context.http_request.query_params
        yield fp.PartialResponse(
            text=f"The request url is: {request_url}, query params are: {query_params}"
        )

```

```
from __future__ import annotations

from typing import AsyncIterable

import fastapi_poe as fp
from modal import App, Image, asgi_app, exit


class HttpRequestBot(fp.PoeBot):
    async def get_response_with_context(
        self, request: fp.QueryRequest, context: fp.RequestContext
    ) -> AsyncIterable[fp.PartialResponse]:
        request_url = context.http_request.url
        query_params = context.http_request.query_params
        yield fp.PartialResponse(
            text=f"The request url is: {request_url}, query params are: {query_params}"
        )

REQUIREMENTS = ["fastapi-poe==0.0.48"]
image = Image.debian_slim().pip_install(*REQUIREMENTS)
app = App("http-request-poe")

@app.function(image=image)
@asgi_app()
def fastapi_app():
    bot = HttpRequestBot()
    # see https://creator.poe.com/docs/quick-start#configuring-the-access-credentials
    app = fp.make_app(bot, access_key=<YOUR_ACCESS_KEY>, bot_name=<YOUR_BOT_NAME>)
    return app


```

Programmatically accessing your Server bot
==========================================

We also provide a helper function for you to test the bot query API in a lower friction manner.  ***This helper function is for testing and debugging responses only.***

#### Get your API Key

Navigate to [poe.com/api\_key](https://poe.com/api_key) and copy your user API key. Note that access to an API key is currently limited to Poe subscribers to minimize abuse.

![](https://files.readme.io/219ab72-image.png)

**Usage done with this API key will count against your user account's message limits on Poe, *so be sure to only use it for testing and not for cases when other people are using your bot*.**

#### Access the bot query API using "get\_bot\_response"

In your python shell, run the following after replacing the placeholder with your API key.

Python

```
import asyncio
import fastapi_poe as fp

# Create an asynchronous function to encapsulate the async for loop
async def get_responses(api_key, messages):
    async for partial in fp.get_bot_response(messages=messages, bot_name="GPT-3.5-Turbo", api_key=api_key):
        print(partial)
 
# Replace <api_key> with your actual API key, ensuring it is a string.
api_key = <api_key>
message = fp.ProtocolMessage(role="user", content="Hello world")

# Run the event loop
# For Python 3.7 and newer
asyncio.run(get_responses(api_key, [message]))

# For Python 3.6 and older, you would typically do the following:
# loop = asyncio.get_event_loop()
# loop.run_until_complete(get_responses(api_key))
# loop.close()

```

If you are using an ipython shell, you can instead use the following simpler code.

Python

```
import fastapi_poe as fp

message = fp.ProtocolMessage(role="user", content="Hello world")
async for partial in fp.get_bot_response(messages=[message], bot_name="GPT-3.5-Turbo", api_key=<api_key>): 
    print(partial)

```

Updated 21 days ago

---

* [Table of Contents](#)
* + [Accessing other bots on Poe](#accessing-other-bots-on-poe)
  + [Rendering an image in your response](#rendering-an-image-in-your-response)
  + [Rendering HTML in your response](#rendering-html-in-your-response)
  + [Enabling file upload for your bot](#enabling-file-upload-for-your-bot)
  + [Sending files with your response](#sending-files-with-your-response)
    - [Rendering an audio player in your response](#rendering-an-audio-player-in-your-response)
    - [Rendering a video player in your response](#rendering-a-video-player-in-your-response)
  + [Creating bots that help their users create prompt bots](#creating-bots-that-help-their-users-create-prompt-bots)
  + [Setting an introduction message](#setting-an-introduction-message)
  + [Multi Bot Support](#multi-bot-support)
  + [Updating bot settings](#updating-bot-settings)
  + [Using OpenAI function calling](#using-openai-function-calling)
  + [Storing Metadata with a Bot Response](#storing-metadata-with-a-bot-response)
  + [Accessing HTTP request information](#accessing-http-request-information)
  + [Programmatically accessing your Server bot](#programmatically-accessing-your-server-bot)