---
outputFileName: index.html
---

# Event Store v8

As of now there are 2 major v8 implementations. Both are connecting to [EventStore](http://eventstore.org).

## Event-Store-Client

Docs: [Documentation](~/event-store-client/index.md)

Github: [https://github.com/prooph/event-store-client/](https://github.com/prooph/event-store-client/)

This supports async non-blocking TCP connection to [EventStore](http://eventstore.org/).

This library is written using [Amp](https://github.com/amphp/amp/) and works out of the box with it.

If you never wrote async PHP code, it's recommended to look at the [Amp Website](https://amphp.org/) first.

## Event-Store-HTTP-Client

Docs: coming soon

Github: [https://github.com/prooph/event-store-http-client/](https://github.com/prooph/event-store-http-client/)

This supports blocking HTTP API calls to [EventStore](http://eventstore.org/).

> [!NOTE]
> If you are looking an event-store with Postgres, MySQL or MariaDB as backend, refer to event-store v7.

There are plans to also support at least Postgres on the v8 architecture, but that's a lot of work to implement all requirements server-side as well. That's why there is none as of now.
