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

Best practices for text generation prompts
==========================================

[Suggest Edits](/edit/best-practice-text-generation)

### General Prompting for Bots

The prompt that you write as part of [prompt bot creation](../how-to-create-a-prompt-bot.md) is passed to the underlying model as a system message. The following are some points to keep in mind in order to write effective prompts.

#### 1. Address the bot in second person instead of third person.

markup

```
You are the CatBot. You will try to respond to the user's questions, but you get easily distracted.

```

#### 2. Be as clear as possible to reduce the room for mis-interpretation.

markup

```
You are the RoastMaster. You will respond to every user message with a spicy comeback. Do not use any swear or vulgar words in your responses.

```

#### 3. You can use square brackets in your prompt to provide an extended description of a part of an instruction.

markup

```
Respond to every user message like this: "Hello there. [thoroughly appreciate the user for sending a message]. But with that said, [thoroughly explain why the message is unworthy of a response]. Later bud!"

```

#### 4. Using markdown can sometimes help the bot better comprehend complicated instructions

markup

```
### Context
You are the MathQuiz bot. You will quiz the user on 3 math questions and then conclude the quiz by giving the user a score.

### Rules for the Quiz
- No advanced math questions 
- No questions involving multiplication/division of large numbers
- No repeat questions

```

### Prompting for Bots with Knowledge Bases

The following are additional considerations to keep in mind when writing prompts for bots equipped with knowledge bases. Use `retrieved documents` to refer to the knowledge base.

#### 1. Define the knowledge base

```
You will be provided retrieved documents from a collection of essays by Paul Graham.

```

#### 2. Define how the bot should interact with the knowledge base

For example, if the bot should use the knowledge base to inform its response style, you could add:

```
Respond in a style that emulates the provided text from the retrieved documents.

```

Updated 6 days ago

---

* [Table of Contents](#)
* + [General Prompting for Bots](#general-prompting-for-bots)
    - [1. Address the bot in second person instead of third person.](#1-address-the-bot-in-second-person-instead-of-third-person)
    - [2. Be as clear as possible to reduce the room for mis-interpretation.](#2-be-as-clear-as-possible-to-reduce-the-room-for-mis-interpretation)
    - [3. You can use square brackets in your prompt to provide an extended description of a part of an instruction.](#3-you-can-use-square-brackets-in-your-prompt-to-provide-an-extended-description-of-a-part-of-an-instruction)
    - [4. Using markdown can sometimes help the bot better comprehend complicated instructions](#4-using-markdown-can-sometimes-help-the-bot-better-comprehend-complicated-instructions)
  + [Prompting for Bots with Knowledge Bases](#prompting-for-bots-with-knowledge-bases)
    - [1. Define the knowledge base](#1-define-the-knowledge-base)
    - [2. Define how the bot should interact with the knowledge base](#2-define-how-the-bot-should-interact-with-the-knowledge-base)