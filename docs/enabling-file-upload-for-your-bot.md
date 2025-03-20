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

Enabling file upload for your bot
=================================

[Suggest Edits](/edit/enabling-file-upload-for-your-bot)

The Poe API allows your bot to takes files as input. There are several settings designed to streamline the process of enabling file uploads for your bot:

* `allow_attachments` (default `False`): Turning this on will allow Poe users to send files to your bot. Attachments will be sent as attachment objects with url, content\_type, and name.
* `expand_text_attachments` (default `True`): If `allow_attachments=True`, Poe will parse text files and send their content in the parsed\_content field of the attachment object.
* `enable_image_comprehension` (default `False`): If `allow_attachments=True`, Poe will use image vision to generate a description of image attachments and send their content in the `parsed_content` field of the attachment object. If this is enabled, the Poe user will only be able to send at most one image per message due to image vision limitations.

Python

```
async def get_settings(self, setting: fp.SettingsRequest) -> fp.SettingsResponse:
    return fp.SettingsResponse(
      allow_attachments=True, expand_text_attachments=True, enable_image_comprehension=True
    )

```

You can update settings by following [this](/docs/updating-bot-settings) guide.

That's it! Your bot should now be able to handle image and text attachments in addition to the user's chat input. 🎉

  

**Note**: If you have either attachment parsing setting on (`expand_text_attachments` or `enable_image_comprehension`), fastapi\_poe will automatically concatenate the `parsed_content` into the message body they are attached to. See [templates.py](https://github.com/poe-platform/fastapi_poe/blob/main/src/fastapi_poe/templates.py) for how the file contents are concatenated.

If you would like to disable this, you can use `concat_attachments_to_message=False` when initializing your PoeBot class. You can also override `concat_attachment_content_to_message_body()` if you want to use your own templates.

Python

```
bot = YourBot(concat_attachments_to_message=False)  
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

The final code (including the setup code you need to host this on [Modal](https://modal.com/)) that goes into your `main.py` is as follows:

Python

```
from __future__ import annotations
from typing import AsyncIterable
import requests
from PyPDF2 import PdfReader
import fastapi_poe as fp

from modal import Image, Stub, asgi_app

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
    
REQUIREMENTS = ["fastapi-poe==0.0.36", "PyPDF2==3.0.1", "requests==2.31.0"]
image = Image.debian_slim().pip_install(*REQUIREMENTS)
stub = Stub("pdf-counter-poe")

@stub.function(image=image)
@asgi_app()
def fastapi_app():
    bot = PDFSizeBot()
    app = fp.make_app(bot, allow_without_key=True)
    return app

```

Updated 12 months ago

---

* [Table of Contents](#)
* + [Parsing your own files](#parsing-your-own-files)