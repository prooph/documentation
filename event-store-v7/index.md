---
outputFileName: index.html
---

# Overview

Prooph Event Store is capable of persisting event messages that are organized in streams. `Prooph\EventStore\EventStore` itself is a facade for different persistence adapters (see the list below) and adds event-driven hook points for `Prooph\EventStore\Plugin\Plugins` which make the Event Store highly customizable.

> [!NOTE]
> If you are looking for a client of [EventStore](http://eventstore.org) and no RDBMS backend, refer to event-store v8.

## Installation

You can install `prooph/event-store` via composer by running the following command:

```sh
$ composer require prooph/event-store
````

## Available persistence implementations

- [PDO](https://github.com/prooph/pdo-event-store) - stable

## Available snapshot store implementations

- [MongoDB](https://github.com/prooph/mongodb-snapshot-store) - stable
- [PDO](https://github.com/prooph/pdo-snapshot-store) - stable
- [Memcached](https://github.com/prooph/memcached-snapshot-store) - stable
- [ArangoDB](https://github.com/prooph/arangodb-snapshot-store) - under development

## Quick Start

For a short overview please see the annotated Quickstart in the examples folder.

## Video Introduction

[![Prooph Event Store v7](https://img.youtube.com/vi/QhpDIqYQzg0/0.jpg)](https://www.youtube.com/watch?v=QhpDIqYQzg0)
