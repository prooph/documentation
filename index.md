# Welcome to prooph documentation

The team and community behind prooph welcomes you and hopes we can help you find what you're looking for.

## Event Store VS Event Store Client

prooph's event-store (implemented by pdo-event-store) is a pure PHP implementation as a thin layer on top of a PDO connection.

The [Event Store](http://eventstore.org/) is a server implementation and the client can communicate with it via a TCP connection.

Generally speaking, the server implementation is a much more mature implementation and provides better performance due to its multi threading nature, but it requires more setup.

> [!NOTE]
> If you are planning to use Event Store, you are required to read the official [Event Store documentation](https://eventstore.org/docs/). This guide will focus on the PHP client implementation.

## What to choose?

- If you need the better performance and server-side projections, use [Event Store](http://eventstore.org/).
But keep in mind that you will need to write asynchronous code in PHP using [Amp](https://github.com/amphp/amp/).

- If you need to maintain an existing stack of RDBMS and throw event-sourcing at it, event-store v7 is exactly what you want.
There is little differences in performance, and there are no server-side projections. You don't need to write async code.
