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

Quick Start
===========

[Suggest Edits](/edit/quick-start)

In this quick start guide, we will build a bot server in Python and then integrate it with Poe. Once you have created a Poe bot powered by your server, any Poe user can interact with it. The following diagram might be useful in visualizing how your bot server fits into Poe.

![](https://files.readme.io/9bff0b8-image.png)

For more information on Poe server bots, check out the [Poe Protocol Specification](/docs/poe-protocol-specification).

Step 1: Project Setup
---------------------

Make sure you have Python installed. In your terminal, run:

* `git clone https://github.com/poe-platform/server-bot-quick-start`
* `cd server-bot-quick-start`
* `pip3 install -r requirements.txt`

Inside the `server-bot-quick-start` project directory, you will see several different example server bots. For this guide, we will focus on `echobot.py`. Open that file in your editor, and we will move onto the next step, **Deploying Your Bot**.

Step 2: Deploying your Bot
--------------------------

> 📘 Using Modal
> -------------
>
> We recommend using [Modal](https://modal.com/?utm_source=poe) to deploy your `echobot.py` , but you can use any deployment method of your choice (e.g. ngrok, Render, local hosting, etc.). If you already deployed your bot to a public URL, you can skip to [integrating it with Poe](/docs/quick-start#step-3-integrating-with-poe).

### Install the Modal client

Open a terminal and run `pip3 install modal`

### Setup your Modal token

This step involves setting up access to modal from your terminal. You only need to do this once for your computer. In the terminal, run `modal token new --source poe`. If you run into a "command not found" error, try [this](https://modal.com/docs/guide/troubleshooting#command-not-found-errors).

If that command runs successfully, you will taken to your web browser where you will be asked to log into modal using your Github account.

![](https://files.readme.io/0fcb528-image.png)

After you login, click on "create token". You will be prompted to close the browser window after that.

![](https://files.readme.io/83f119a-image.png)

### Deploy to Modal

In terminal, run the following command from your `server-bot-quick-start` directory:

* `modal serve echobot.py`

> 📘 modal serve
> -------------
>
> `modal serve`deploys an ephemeral version of your app which **live updates in response to any code change to echobot.py**. This is meant for development purposes, and your app will shutdown when the command stops running. Once your app is ready for production, you can use `modal deploy` instead to persist your app.

In the terminal output, you should see the endpoint your application is deployed at. You will need this URL for the next step, **Integrating with Poe**.

![](https://files.readme.io/6dcb991b073feeeebb5b3c1ce5ac4bae9b2e3ac6ee5a53f0e46e001b5eeb5e6c-Screen_Shot_2024-08-28_at_1.54.03_PM.png)

Step 3: Integrating with Poe
----------------------------

Navigate to the [Bot Creation Page](https://poe.com/create_bot) on poe.com and select **Server bot** as the bot type. That should bring you to the following form:

![](https://files.readme.io/0e7b602e93b8a3b543cd9d1e32e1dfcdaa0f74f5e329cb2a9a4fdca25a401a50-Screen_Shot_2024-08-28_at_1.56.12_PM.png)

Fill out your bot details, copying down the bot **Name** (you can edit this if you'd like) and the generated **Access Key**. You will need these two values in the next step. Paste the URL from the previous step into **Server URL**. Hit **Create Bot** to finish the bot creation.

> 🚧 Warning
> ---------
>
> Don't forget to update the Server URL if the endpoint your bot is hosted at changes! Generally, Modal seems to re-use the same URL on each deployment, but if you are having trouble sending messages to your bot, you should verify that the URL is correct.

### Configuring the Access Credentials

Near the bottom of `echobot.py`, you should see the following line:

Python

```
app = fp.make_app(bot, allow_without_key=True)

```

Change that line to the following (replace `<YOUR_ACCESS_KEY>` and `<YOUR_BOT_NAME>` with the values you copied in the previous step):

Python

```
app = fp.make_app(bot, access_key=<YOUR_ACCESS_KEY>, bot_name=<YOUR_BOT_NAME>)

```

Now your bot is configured with the proper credentials! Save the changes to `echobot.py`, and Modal should pick up and deploy the changes. That's it! You should be able to talk to your bot on Poe.

Where to go from here
---------------------

* One of the advantages of building a bot on Poe is the ability to invoke other Poe bots. In order to learn how to do that check out: [accessing-other-bots-on-poe.md](/docs/accessing-other-bots-on-poe).
* Check out other detailed guides that show you how to enable specific features:
  + [rendering-an-image-in-the-response.md](/docs/rendering-an-image-in-the-response)
  + [enabling-file-upload-for-your-bot.md](/docs/enabling-file-upload-for-your-bot)
  + [setting-an-introduction-message.md](/docs/setting-an-introduction-message)
* Refer to the [specification](/docs/poe-protocol-specification) to understand the full capabilities offered by Poe server bots.
* Check out the [fastapi-poe](https://pypi.org/project/fastapi-poe/) library, which you can use as a base for creating Poe bots.

Updated 4 months ago

---

* [Table of Contents](#)
* + [Step 1: Project Setup](#step-1-project-setup)
  + [Step 2: Deploying your Bot](#step-2-deploying-your-bot)
    - [Install the Modal client](#install-the-modal-client)
    - [Setup your Modal token](#setup-your-modal-token)
    - [Deploy to Modal](#deploy-to-modal)
  + [Step 3: Integrating with Poe](#step-3-integrating-with-poe)
    - [Configuring the Access Credentials](#configuring-the-access-credentials)
  + [Where to go from here](#where-to-go-from-here)