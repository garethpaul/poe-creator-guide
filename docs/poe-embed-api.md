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

Poe Embed API
=============

The Poe Embed API is used for connecting web applications embedded in Poe with the Poe environment.

[Suggest Edits](/edit/poe-embed-api)

Getting started
---------------

The Poe Embed API is automatically included in HTML applications running inside Poe. Visit [poe.com/App-Creator](http://poe.com/App-Creator) to build a canvas app that uses the api.

Methods
-------

Methods are accessible through the `window.Poe` global object.

| `sendUserMessage` | Sends a message on behalf of the current user |
| --- | --- |
| `sendUserMessage` | Sends a message in the chat on behalf of the current user. |
| `registerHandler` | Registers a function to receive the results of `sendUserMessage` |

### `window.Poe.sendUserMessage`

Sends a message in the chat on behalf of the current user. In some cases it may throw a `PoeEmbedAPIError`. To see the results of the message, use the `registerHandler` method.

The current user will be charged for the cost of the sent messages and in some cases will be asked to authorize the costs. Try it with [poe.com/EmbedAPIDebugger](http://poe.com/EmbedAPIDebugger).

TypeScript

```

 sendUserMessage<Stream extends boolean>(
    /** The text to send.  In most cases this should start with `@BotName` */
    text: string,
    options?: {
      /** Files to include */
      attachments?: File[];
      /** Whether to invoke the handler with incomplete results as they are available or to only invoke it with the final complete result.  Each result contains all tokens so far. */
      stream?: Stream;
      /** Whether to open the chat on send. */
      openChat?: boolean;
      /** The registered name of the handler function to invoke with the results */
      handler?: string;
      /** Optional additional context to pass to the handler. */
      handlerContext?: HandlerContext;
    }
  ): Promise<
    { success: boolean}
  >;

```

### `window.Poe.registerHandler`

Registers a callback function to the results of `sendUserMessage`. The callback receives results if the `name` of the handler, matches the `handler` argument passed into `sendUserMessage`.

TypeScript

```
  registerHandler(
    /**
     * String identifier for the handler. Used to associate responses with this callback.
     */
    name: string,
    /**
     * Callback function that receives response messages. Each result contains an array
     * of messages with their content and status.
     * The handlerContext specified in the sendUserMessage call will also be passed to the callback.
     */
    func: (result: SendUserMessageResult, context: HandlerContext) => void
  ): VoidFunction;

```

Example:

TypeScript

```
let someFile: File

window.Poe.registerHandler("myHandler", (result) => {
  console.log(result.responses[0]?.content)
})

let result = await window.Poe.sendUserMessage(
    "@assistant what is this?",
    { attachments: [someFile], stream: true, handler: "myHandler" }
 )
 console.log(result) // { success: true }

```

Objects
-------

### **`SendUserMessageResult`**

This object is passed into handlers of *sendUserMessage* calls.

TypeScript

```

type SendUserMessageResult = {
  status: "incomplete" | "complete" | "error";
  /**
   * In most cases, this will be a single bot message however in some cases a single human message
   * may trigger multiple bot responses.
   */
  responses: Message[];
};

```

### `Message`

A message from a bot that may appear in `SendUserMessageResult["responses"]`. *content* always contains the text of the message so far.

typescript

```
/** A message from the bot. */
type Message = {
  messageId: string;
  /** The name of the bot that sent the message. e.g. "Assistant" */
  senderId: string;
  /** The entire content of the message recieved so far */
  content: string;
  /** Either text/plain or text/markdown */
  contentType: string;
  /** Each status should be handled to let the user know the current state of the message. */
  status: "incomplete" | "complete" | "error";
  /** A user friendly message to explain the current status.  Usually only specified for error status. */
  statusText?: string;
  attachments?: MessageAttachment[];
};

```

Errors
------

### `PoeEmbedAPIError`

The error that may be thrown by `sendUserMessage`.

TypeScript

```
interface PoeEmbedAPIError extends Error {
  errorType: PoeEmbedAPIErrorType;
}

type PoeEmbedAPIErrorType = "UNKNOWN" | "INVALID_INPUT" | "USER_REJECTED_CONFIRMATION" | "ANOTHER_CONFIRMATION_IS_OPEN"

```

PoeApiErrorType is a union of strings:

* `UNKNOWN` - Something unexpected happened. This may occur when using an old version of the sdk
* `INVALID_INPUT` - When the input was invalid. Check `error.message` for more info
* `USER_REJECTED_CONFIRMATION` - When the action requires user confirmation, and the user rejected it
* `ANOTHER_CONFIRMATION_IS_OPEN` - When the action (e.g. *sendUserMessage*) requires user confirmation, but another confirmation is already open.
  + This error is only relevant to “inline” codeblock previews that are rendered inside a message.

Typescript Definitions
----------------------

TypeScript

```

/** The public interface of the Embed API.  This class is accessible from `window.Poe` */
interface PoeEmbedAPI {
  /** Send a message to the bot. */
  sendUserMessage<Stream extends boolean>(
    /** The text to send.  In most cases this should start with `@BotName` */
    text: string,
    options?: {
      /** Files to include in the user message. */
      attachments?: File[];
      /** Whether to invoke the handler with incomplete results as they are available or to only invoke it with the final complete result.  Each result contains all tokens so far. */
      stream?: Stream;
      /** Whether to open the chat on send. */
      openChat?: boolean;
      /** The name of the handler function to invoke with the results */
      handler?: string;
      /** Optional additional context to pass to the handler. */
      handlerContext?: HandlerContext;
    }
  ): Promise<
    { success: boolean}
  >;

  /** Register a handler function that is invoked with the results of the `sendUserMessage` call. The handler should be registered before the `sendUserMessage` call is made and ideally before the user has made interactions with the page. */
  registerHandler(
    /** The name of the handler function to register. This name should match the `handler` option in `sendUserMessage`. */
    name: string,
    /** The function that is invoked with the results of the `sendUserMessage` call. */
    func: (result: SendUserMessageResult, context: HandlerContext) => void
  ): VoidFunction;

  APIError: typeof PoeEmbedAPIError;
}

/** Error that may be thrown by an Embed API method such as `sendUserMessage` */
class PoeEmbedAPIError extends Error {
  errorType: PoeEmbedAPIErrorType;
}

type MessageAttachment = {
  attachmentId: string;
  mimeType: string;
  url: string;
  isInline: boolean;
  name: string;
};

/** A message from the bot. */
type Message = {
  messageId: string;
  /** The name of the bot that sent the message. e.g. "Assistant" */
  senderId: string;
  /** The entire content of the message recieved so far */
  content: string;
  /** Either text/plain or text/markdown */
  contentType: string;
  /** Each status should be handled to let the user know the current state of the message. */
  status: "incomplete" | "complete" | "error";
  /** A user friendly message to explain the current status.  Usually only specified for error status. */
  statusText?: string;
  attachments?: MessageAttachment[];
};

type SendUserMessageResult = {
  status: "incomplete" | "complete" | "error";
  /**
   * In most cases, this will be a single bot message however in some cases a single human message
   * may trigger multiple bot responses.
   */
  responses: Message[];
};

type HandlerContext = Record<string, any>;
type HandlerFunc = (
  result: SendUserMessageResult,
  context: HandlerContext
) => void;

type PoeEmbedAPIErrorType =
  | "UNKNOWN"
  | "INVALID_INPUT"
  | "USER_REJECTED_CONFIRMATION"
  | "ANOTHER_CONFIRMATION_IS_OPEN";

/** accessible via window.Poe */
declare global {
  interface Window {
    Poe: PoeEmbedAPI;
  }
}

```

Updated 23 days ago

---

* [Table of Contents](#)
* + [Getting started](#getting-started)
  + [Methods](#methods)
    - [`window.Poe.sendUserMessage`](#windowpoesendusermessage)
    - [`window.Poe.registerHandler`](#windowpoeregisterhandler)
  + [Objects](#objects)
    - [**`SendUserMessageResult`**](#sendusermessageresult)
    - [`Message`](#message)
  + [Errors](#errors)
    - [`PoeEmbedAPIError`](#poeembedapierror)
  + [Typescript Definitions](#typescript-definitions)