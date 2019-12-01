---
outputFileName: index.html
---

# Step 1 - Install, run, and write your first event

[!include[<Getting Started Intro>](~/getting-started/_intro.md)]

This first step covers installation and running Event Store, and writing your first event.

[!include[<Getting Started Install and run>](~/partials/_install-run.md)]

## Interacting with an Event Store Server

There are three ways to interact with Event Store:

1.  With the admin web interface (more details link).
2.  With the HTTP API
3.  With a Client API, which you need to install first. Our documentation covers the [prooph event store client API](~/api/index.md) and the [JVM client](https://github.com/EventStore/EventStore.JVM) but [others](~/getting-started/which-api-sdk.md) are available.

### Event Store Client

[Install](https://github.com/prooph/event-store-client/) using composer, add it to your project:

```bash
composer require prooph/event-store-client
```

* * *

## Connecting to Event Store

If you want to use the admin web interface or the HTTP API, then you use port `2113`, for example, <http://127.0.0.1:2113/> in your web browser, or `curl -i http://127.0.0.1:2113` for the HTTP API.

> [!TIP]
> The default username and password is `admin:changeit`

![The Web Admin Dashboard](~/images/es-web-admin-dashboard.png)

To use a client API, you use port `1113` and create a connection:

### [Async Client](#tab/tabid-event-store-client-async-connect)

When using the Event Store Client, you also need to give the connection a name.

```php
$connection = EventStoreAsyncConnectionFactory::createFromUri(
    Uri::fromString('tcp://admin:changeit@localhost:1113'),
    null,
    'test-connection'
);
```

### [Sync Client](#tab/tabid-event-store-client-sync-connect)

When using the Event Store Client, you also need to give the connection a name.

```php
$connection = EventStoreSyncConnectionFactory::createFromUri(
    Uri::fromString('tcp://admin:changeit@localhost:1113'),
    null,
    'test-connection'
);
```

> [!NEXT]
> In this example we used the `EventStoreAsyncConnectionFactory::createFromUri()` method but others are available.

***

## Writing Events to an Event Stream

Event Store operates on a concept of Event Streams, and the first operation we look at is how to write to a stream. If you are Event Sourcing a domain model, a stream equates to an aggregate function. Event Store can handle hundreds of millions of streams, so create as many as you need.

If you post to a stream that doesn't exist, Event Store creates it before adding the events.

You can write events using the admin web interface by clicking the _Stream Browser_ tab, the _Add Event_ button, filling in the form with relevant values and clicking the _Add_ button at the bottom of the page.

![Creating an event with the web admin interface](~/images/getting-started-add-event.gif)

Open a text editor, copy and paste the following event definition, and save it as _event.json_.

[!code-json[getting-started-write-event-json](~/code-examples/getting-started/event.json "The contents of event.json")]

### [HTTP API](#tab/tabid-4)

Use the following cURL command, passing the name of the stream and the events to write:

[!code-bash[getting-started-write-event-request](~/code-examples/getting-started/write-event.sh?start=1&end=1)]

> [!NOTE]
> You can also post events to the HTTP API as XML, by changing the `Content-Type` header to `XML`.

### [Event Store Client](#tab/tabid-5)

To use the PHP API, use the following method, passing the name of the stream, the version, and the events to write:

```php
yield $conn->appendToStreamAsync(
    $streamName,
    ExpectedVersion::ANY,
    [$eventData]
);
```

* * *

## Next Step

In this first part of our getting started guide you learned how to install and run Event Store and write your first event. The next part covers reading events from a stream.

-   [Step 2 - Read events from a stream and subscribe to changes](~/getting-started/reading-subscribing-events.md)
