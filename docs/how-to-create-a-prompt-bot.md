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

How to create a prompt bot
==========================

[Suggest Edits](/edit/how-to-create-a-prompt-bot)

Step 1: Open the create bot page
--------------------------------

If you are using a web browser, go to [poe.com](https://poe.com) and click on the "Create a bot" button in the left sidebar. Alternatively you can navigate directly to [poe.com/create\_bot](https://poe.com/create_bot). If you are using the Poe mobile app, tap the ≡ icon the top-left to open the sidebar and then tap on the "Create a bot" button at the top of the menu.

Step 2: Customize how your bot will look
----------------------------------------

#### Upload a picture (Optional)

This helps give your bot a distinctive appearance.

![](https://files.readme.io/bc8108a-image.png)

#### Select a bot name

The name is a unique identifier and can be 4-20 characters, including letters, numbers, dashes, periods and underscores.[Symbols are canonicalized, e.g. Bot\_A, BotA and Bot-A are considered the same identifier.] The field will come prefilled with a randomly generated name that you can leave as it is. You can always come back and update the name later.

![](https://files.readme.io/35c61b0-Screenshot_2024-07-09_at_09.09.21.png)
  

#### Write a bot description (Optional)

A piece of text that describes your bot. This will be shown to people who land on the bot page.

![](https://files.readme.io/84ae028-Screenshot_2024-07-09_at_09.10.54.png)

Step 3: Define your bot's behavior
----------------------------------

#### Select a base bot

This is the underlying bot that your prompt bot is powered by.

![](https://files.readme.io/b90ccb3-Screenshot_2024-07-09_at_09.05.21.png)
  

#### Provide a prompt

Describe what your bot should do or how it should behave. For more information on how to write a good prompt, check out [prompts best practices](best-practice-text-generation) guide. You can also use the "Prompt visible from bot profile" option to decide whether your prompt should be visible to the public.

![](https://files.readme.io/135613e-image.png)

#### Provide a knowledge base (Optional)

For text generation bots, you can add a knowledge base to provide external information for your bot to reference. Your bot will retrieve relevant parts of the knowledge base for a given user message and use them to inform its response.

A knowledge base consists of one or more knowledge sources which are created from uploaded files or raw text input. Major text file formats (such as .txt, .pdf, .docx, and .html) are supported for file uploads. The size of each knowledge base is limited to 5GB or 30 million characters combined across all knowledge sources.

You can optionally enable "Cite sources" for your bot. This will enable citation UI elements for your bot in addition to instructing the bot to produce in-line citations when appropriate.

![](https://files.readme.io/30d6931-image.png)

#### Provide a greeting message (Optional)

This is the message that the bot starts with when users land on the bot page. This can be used to explain to the users what the bot does or get necessary information that the bot needs to get started.

![](https://files.readme.io/bd46445-Screenshot_2024-07-09_at_09.12.01.png)

Step 4: Decide if you need any advanced features (Optional)
-----------------------------------------------------------

#### Suggest replies

Whether a user should see some LLM-generated reply options after getting a response from the bot. This could help in lowering friction for users if the option is a good fit for your bot.

#### Render markdown content

Allows messages with the bot to be rendered using Markdown. If this is off, messages are rendered as plain text.

Poe supports GitHub-Flavored Markdown (GFM, specified at <https://github.github.com/gfm/>). However, for security and privacy reasons, prompt bots only support images hosted at imgur.com and unsplash.com. Images that use any other URL will fail to render. Please reach out to us on [Discord](https://discord.gg/TKxT6kBpgm) if you wish to make a request for us to support additional image hosting sites.

#### Custom temperature

Allows you to specify the temperature you want to use for your bot. Higher temperatures will introduce more randomness in your bot's responses. Lower temperatures will produce more consistent results, which can be useful for fact-based bots (especially those equipped with a knowledge base).

#### Optimize prompt for Previews

Allows additional instruction to be added to optimize generating interactive web applications. And here's the instruction we will use.

Markdown

```
    # Guidelines for Generating React Components
    - If you generate React components, make sure to include `type=react` to the code block's info string (i.e. "```jsx type=react"). The code block should be a single React component.
    - Put everything in one standalone React component. Do not assume any additional files (e.g. CSS files).
    - When creating a React component, ensure it has no required props (or provide default values for all props) and use a default export.
    - Prefer not to use local storage in your React code.
    - You may use only the following libraries in your React code:
        - react
        - @headlessui/react
        - Tailwind CSS
        - lucide-react (for icons)
        - recharts (for charts)
        - @tanstack/react-table (for tables)
        - framer-motion (for animations and motion effects)
    - NO OTHER REACT LIBRARIES ARE INSTALLED OR ABLE TO BE IMPORTED. Do not use any other libraries in your React code unless the user specifies.
    - Do NOT use arbitrary values with Tailwind CSS. For example, `<div className="relative w-[800px] h-[500px]"></div>` is invalid and disallowed. Instead, use Tailwind's default utility classes, such as `<div className="relative w-full max-w-3xl h-96"></div>`.

    Here is an example of a valid React component:
    ```jsx type=react
    import React from 'react';
    function Greeting() {{
        return (
            <h1 className="text-xl font-bold text-blue-600">
                Hello World!
            </h1>
        );
    }}
    export default Greeting;
    ```
    ---

    # Guidelines for Generating HTML Code
    - If you generate HTML code, ensure your HTML code is responsive and adapts well to narrow mobile screens.
    - If you generate HTML code, ensure your HTML code is a complete and self-contained HTML code block. Enclose your HTML code within a Markdown code block. Include any necessary CSS or JavaScript within the same code block.

    Here is an example of a valid HTML code block:
    ```html
    <!DOCTYPE html>
    <html>
    <head>
        <style>
            .circle {{
                width: 50px;
                height: 50px;
                background: red;
                border-radius: 50%;
                position: absolute;
                transition: 0.3s;
            }}
        </style>
    </head>
    <body>
        <div class="circle"></div>
        <script>
            const circle = document.querySelector('.circle');
            document.addEventListener('mousemove', (e) => {{
                circle.style.left = e.pageX - 25 + 'px';
                circle.style.top = e.pageY - 25 + 'px';
            }});
        </script>
    </body>
    </html>
    ```
    ---

    Follow these guidelines for your responses:
    - Only if the user explicitly requests web applications, visual aids, interactive tools, or games, you may generate them using HTML or React code. Visual aids can include presentations, illustrations, diagrams, graphs, and charts. Do NOT generate these unless the user asks for them explicitly. When generating games, use HTML code by default.
    - Do not use image URLs or audio URLs, unless the URL is provided by the user. Assume you can access only the URLs provided by the user. Most images and other static assets should be programmatically generated.
    - If you modify existing HTML, CSS, JavaScript, or React code, always provide the full code in its entirety, even if your response becomes too long. Do not use shorthands like "... rest of the code remains the same ..." or "... previous code remains the same ...".
    """

```

Step 5: Create your bot
-----------------------

After filling out all the required fields, click on the "Create bot" button at the bottom of the screen. That's it! You will be taken to your new bot's page, and from there you can start chatting or share the bot with your friends.

Updated 2 months ago

---

* [Table of Contents](#)
* + [Step 1: Open the create bot page](#step-1-open-the-create-bot-page)
  + [Step 2: Customize how your bot will look](#step-2-customize-how-your-bot-will-look)
  + [Step 3: Define your bot's behavior](#step-3-define-your-bots-behavior)
  + [Step 4: Decide if you need any advanced features (Optional)](#step-4-decide-if-you-need-any-advanced-features-optional)
  + [Step 5: Create your bot](#step-5-create-your-bot)