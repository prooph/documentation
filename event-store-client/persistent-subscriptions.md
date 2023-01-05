---
outputFileName: index.html
---

# Persistent Subscriptions Management

The Event Store Client API includes helper methods that use the HTTP API to allow you to manage persistent subscriptions. This document describes the methods found in the `\Prooph\EventStore\Async\PersistentSubscriptions\PersistentSubscriptionsManager` implementations.

## Methods

### Get information for persistent subscriptions 

Returns information about the persistent subscription for a stream you specify with `stream`. If passing `null` as stream, returns information about all persistent subscriptions from all streams. 

```php
public function list(
    ?string $stream = null,
    ?UserCredentials $userCredentials = null
): list<PersistentSubscriptionDetails>
```

### Get information for a persistent subscription for a stream

Gets the details of the persistent subscription `subscriptionName` on `stream`. You must have access to the persistent subscription and the stream.

```php
public function describe(
    string $stream,
    string $subscriptionName,
    ?UserCredentials $userCredentials = null
): PersistentSubscriptionDetails
```

### Replay parked messages

Replays all parked messages for a particular persistent subscription `subscriptionName` on a `stream` that were parked by a negative acknowledgement action.

```php
public function replayParkedMessages(
    string $stream,
    string $subscriptionName,
    ?UserCredentials $userCredentials = null
): void
```
