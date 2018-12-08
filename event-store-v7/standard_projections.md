# Overview

The standard projections are some kind of event-indexing, so you can retrieve events from
all streams at once (`AllStreamProjectionRunner`), by category (`CategoryStreamProjectionRunner`)
or by message name (`MessageNameStreamProjectionRunner`).

## Installation

```bash
composer require prooph/standard-projections
```

## Requirements

- PHP >= 7.1
- Prooph EventStore v7

## AllStreamProjectionRunner

Imagine you have two streams, a stream called `user` and a stream called `blogposts`. If you are
interessted in all events coming from both streams, you can use an EventStoreQuery like this:

```php
$eventStore
    ->createQuery()
    ->fromAll()
```

This is slightly unperformant, especially when you have one stream per aggregate, so that you have
to query thousands of streams. This is where the `AllStreamProjectionRunner` comes handy. It projects
all events from all streams into a single large stream, so you can run queries like:

```php
$eventStore
    ->createQuery()
    ->fromStream('$all')
```

## CategoryStreamProjectionRunner

Let's say you use one stream per aggregate for users. So you have event streams with names: `user-1`, `user-2` and so on.
You are interested in the events from all user-streams, so your query looks like:

```php
$eventStore
    ->createQuery()
    ->fromCategory('user')
```

With the `CategoryStreamProjectionRunner` you create a single stream for all those events. You can query it like:

```php
$eventStore
    ->createQuery()
    ->fromStream('$ct-user')
```

## MessageNameStreamProjectionRunner

The `MessageNameStreamProjectionRunner` creates a stream for each occurring message name. Let's say you
have user-streams with one stream per aggregate again, and streams like `user-1`, `user-2`, and so on.
You are interessted in all `UserWasRegistered` events, so your query looks like:

```php
$eventStore
    ->createQuery()
    ->fromCategory('user')
    ->when(
        [
            UserWasRegistered::class => function (array $state, UserWasRegistered $event): void {
                // do something
            } 
        ]
    )
```

This is unperformant in two ways: First we need to query all user-streams and then we need to iterate
over events, we are not interested in. With the `MessageNameStreamProjectionRunner` your query would look like:

```php
$eventStore
    ->createQuery()
    ->fromStream('$mn-UserRegistered')
```

## Usage

The runners are expected to run in a simple CLI script. As it's framework agnostic, you have to
provide these cli-scripts yourself. This is how they basically look like:

```php
<?php

$container = require 'container.php';

$projectionManager = $container->get(\Prooph\EventStore\Projection\ProjectionManager::class);

$runner = new \Prooph\StandardProjections\AllStreamProjectionRunner($projectionManager);
$runner();
```
