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

Canvas limitations
==================

[Suggest Edits](/edit/canvas-limitations)

Client only
-----------

Canvas apps are single-file HTML applications. They cannot run server-side code. Apart from loading resources from CDNs (see *Fetching external resources*), they generally cannot connect to external servers.

No included database
--------------------

Canvas apps do not have an included way to persist data. This will change in the future. If you have your own server that can persist data, a canvas app can connect to it after disabling the CSP (see *Fetching external resources*). Alternatively, you can read/write data by sending messages to a server bot that you control.

File drag-and-drop
------------------

Dragging a file from outside to inside the canvas app does not work reliably on chromium based browsers.

Drag-and-drop within the canvas app is possible across all browsers.

Local storage
-------------

Browser local storage APIs are disabled for canvas apps.

Webcam and microphone
---------------------

Webcam and microphone access is disabled for canvas apps.

Clipboard
---------

Canvas apps can write to the clipboard, but cannot read from the clipboard.

History API
-----------

Canvas apps cannot use the [History API](https://developer.mozilla.org/en-US/docs/Web/API/History_API).

Links/navigation
----------------

Same-origin links (such as `<a href="/about">`) are not possible in canvas apps.

Cross-origin links (such as `<a href="https://quora.com/about" target="_blank">`) are supported, however they require that the user elects to allow untrusted resources ([example](https://poe.com/TargetBlankLink)). When a user clicks a link with `target="_blank"` the following occurs:

1. The *Allow untrusted resources confirmation* is displayed
2. If the user clicks *Allow all*, the canvas bot will reload
3. If the user clicks the link again, the link opens in a new tab

alert() / confirm()
-------------------

`alert` and `confirm` APIs do not work in canvas apps. Calling these methods will log an error message to the browser console.

File downloads
--------------

File downloads are not supported.

For image/video downloads, we recommend rendering the image so the user can right-click and select *Save as* to save the file.

Fetching external resources
---------------------------

Canvas apps can load libraries/resources from a set of trusted origins such as [cdnjs.cloudflare.com](http://cdnjs.cloudflare.com) and [cdn.jsdelivr.net](http://cdn.jsdelivr.net).

[View trusted origins](https://poe.com/canvas_csp)

Canvas apps have strict security restrictions that prevent them from connecting with untrusted origins. If the canvas app tries to load an untrusted resource, the *Allow untrusted external resources* confirmation will show. If the user clicks *Allow all*, the canvas app will reload without the security restrictions, and will then be allowed to load any resource.

To avoid triggering the *Allow untrusted external resources* confirmation, we recommended only loading JavaScript libraries or CSS frameworks from a trusted origin.

**Example:** <https://poe.com/CSPBannerExample>

![](https://files.readme.io/17529e6cbce70f378522bda6c625372e11dbf4bad141c23e26350b0d9c377258-image.png)
![](https://files.readme.io/46e3944ee46576c947915885ec59728435981c4dad4918e2058b8fde4ec0f77b-image.png)

Updated 20 days ago

---

* [Table of Contents](#)
* + [Client only](#client-only)
  + [No included database](#no-included-database)
  + [File drag-and-drop](#file-drag-and-drop)
  + [Local storage](#local-storage)
  + [Webcam and microphone](#webcam-and-microphone)
  + [Clipboard](#clipboard)
  + [History API](#history-api)
  + [Links/navigation](#linksnavigation)
  + [alert() / confirm()](#alert--confirm)
  + [File downloads](#file-downloads)
  + [Fetching external resources](#fetching-external-resources)