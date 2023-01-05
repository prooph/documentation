---
outputFileName: index.html
---

# Competing Consumers

This document explains how to use Event Store Cliet API for setting up and consuming competing consumer subscription groups. For an overview of competing consumers and how they relate to other subscription types, please see the [overview document](~/getting-started/projections.md).

> [!NOTE]
> The Administration UI includes a _Competing Consumers_ section where a user can create, update, delete and view subscriptions and their statuses.

# Methods

## Creating a Persistent Subscription

Before interacting with a subscription group, you need to create one. You will receive an error if you attempt to create a subscription group more than once. This requires admin permissions.

```php
createPersistentSubscription(
    string $stream,
    string $groupName,
    PersistentSubscriptionSettings $settings,
    ?UserCredentials $userCredentials = null
): PersistentSubscriptionCreateResult
```

## Updating a Persistent Subscription

You can edit the settings of an existing subscription while it is running. This action drops the current subscribers and resets the subscription internally. This requires [admin permissions](~/server/users-and-access-control-lists.md).

```php
updatePersistentSubscription(
    string $stream,
    string $groupName,
    PersistentSubscriptionSettings $settings,
    ?UserCredentials $userCredentials = null
): PersistentSubscriptionUpdateResult
```

## Deleting a Persistent Subscription

```php
deletePersistentSubscription(
    string $stream,
    string $groupName,
    ?UserCredentials $userCredentials = null
): DeletePersistentSubscription
```

## Connecting to a Persistent Subscription

```php
connectToPersistentSubscription(
    string $stream,
    string $groupName,
    Closure $eventAppeared,
    ?Closure $subscriptionDropped = null,
    int $bufferSize = 10,
    bool $autoAck = true,
    ?UserCredentials $userCredentials = null
): EventStorePersistentSubscription
```

## Persistent Subscription Settings

Both the `create` and `update` methods take a `PersistentSubscriptionSettings` object as a parameter. The methods use this object to provide the settings for the persistent subscription. A fluent builder is available for these options that you can locate using the `create()` method. The following table shows the options you can set on a persistent subscription.

| Method                                   | Description                                                                                                       |
| ---------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| `resolveLinkTos()`                       | Tells the subscription to resolve link events.                                                                    |
| `doNotResolveLinkTos()`                  | Tells the subscription to not resolve link events.                                                                |
| `preferRoundRobin()`                     | If possible preference a round robin between the connections with messages (if not possible uses next available). |
| `preferDispatchToSingle()`               | If possible preference dispatching to a single connection (if not possible will use next available).              |
| `startFromBeginning()`                   | Start the subscription from the first event in the stream.                                                        |
| `startFrom(int $position)`               | Start the subscription from the position-th event in the stream.                                                  |
| `startFromCurrent()`                     | Start the subscription from the current position.                                                                 |
| `withMessageTimeoutOf(int $timeout)`     | Sets the timeout for a client before retrying the message.                                                        |
| `checkPointAfter(int $time)`             | The amount of time the system should try to checkpoint after.                                                     |
| `minimumCheckPointCountOf(int $count)`   | The minimum number of messages to write a checkpoint for.                                                         |
| `maximumCheckPointCountOf(int $count)`   | The maximum number of messages not checkpointed before forcing a checkpoint.                                      |
| `withMaxRetriesOf(int $count)`           | Sets the number of times to retry a message should before considering it a bad message.                           |
| `withLiveBufferSizeOf(int $count)`       | The size of the live buffer (in memory) before resorting to paging.                                               |
| `withReadBatchOf(int $count)`            | The size of the read batch when in paging mode.                                                                   |
| `withBufferSizeOf(int $count)`           | The number of messages to buffer when in paging mode.                                                             |
| `withExtraStatistics()`                  | Tells the backend to measure timings on the clients so statistics contain histograms of them.                     |

## Creating a Subscription Group

The first step of dealing with a subscription group is to create one. You will receive an error if you attempt to create a subscription group multiple times. You must have admin permissions to create a persistent subscription group.

> [!NOTE]
> Normally you wouldn't create the subscription group in your general executable code. Instead, you create it as a step during an install or as an admin task when setting up Event Store. You should assume the subscription exists in your code.

```php
$settings = PersistentSubscriptionSettings::create()
    ->doNotResolveLinkTos()
    ->startFromCurrent()
    ->build();

$result = $conn->createPersistentSubscription(
    $stream,
    'agroup',
    $settings,
    $myCredentials
);
```

| Parameter                                  | Description                                          |
| ------------------------------------------ | ---------------------------------------------------- |
| `string $stream`                           | The stream to the persistent subscription is on.     |
| `string $groupName`                        | The name of the subscription group to create.        |
| `PersistentSubscriptionSettings $settings` | The settings to use when creating this subscription. |
| `UserCredentials $credentials`             | The user credentials to use for this operation.      |

## Updating a Subscription Group

You can edit the settings of an existing subscription group while it is running, you don't need to delete and recreate it to change settings. When you update the subscription group, it resets itself internally dropping the connections and having them reconnect. You must have admin permissions to update a persistent subscription group.

```php
$settings = PersistentSubscriptionSettings::create()
    ->doNotResolveLinkTos()
    ->startFromCurrent()
    ->build();

$result = $conn->updatePersistentSubscription(
    $stream,
    'agroup',
    $settings,
    $myCredentials
);
```

> [!NOTE]
> If you change settings such as `startFromBeginning`, this doesn't reset the group's checkpoint. If you want to change the current position in an update, you must delete and recreate the subscription group.

| Parameter                                  | Description                                          |
| ------------------------------------------ | ---------------------------------------------------- |
| `string $stream`                           | The stream to the persistent subscription is on.     |
| `string $groupName`                        | The name of the subscription group to update.        |
| `PersistentSubscriptionSettings $settings` | The settings to use when updating this subscription. |
| `UserCredentials $credentials`             | The user credentials to use for this operation.      |

## Deleting a Subscription Group

Remove a subscription group with the delete operation. Like the creation of groups, you rarely do this in your runtime code and is undertaken by an administrator running a script.

```php
$result = $conn->deletePersistentSubscription(
    $stream,
    'groupname',
    DefaultData::adminCredentials()
);
```

| Parameter                      | Description                                      |
| ------------------------------ | ------------------------------------------------ |
| `string $stream`               | The stream to the persistent subscription is on. |
| `string $groupName`            | The name of the subscription group to update.    |
| `UserCredentials $credentials` | The user credentials to use for this operation.  |

## Connecting to a Subscription Group

Once you have created a subscription group, clients can connect to that subscription group. A subscription in your application should only have the connection in your code, you should assume that the subscription was created via the client API, the restful API, or manually in the UI.

The most important parameter to pass when connecting is the buffer size. This parameter represents how many outstanding messages the server should allow this client. If this number is too small, your subscription will spend much of its time idle as it waits for an acknowledgment to come back from the client. If it's too big, you waste resources and can start causing time out messages depending on the speed of your processing.

```php
$subscription = $conn->connectToPersistentSubscription(
    'foo',
    'nonexisting2',
    $eventAppeared,
    $subscriptionDropped,
    $bufferSize,
    $autoAck
);
```

| Parameter                                                     | Description                                                                |
| ------------------------------------------------------------- |----------------------------------------------------------------------------|
| `string $stream`                                              | The stream to the persistent subscription is on.                           |
| `string $groupName`                                           | The name of the subscription group to connect to.                          |
| `Closure(EventStorePersistentSubscription, ResolvedEvent, null|int): void $eventAppeared` | The action to call when an event arrives over the subscription. |
| `null| Closure(EventStorePersistentSubscription, SubscriptionDropReason, null     |Throwable): void $subscriptionDropped` | The action to call if the subscription is dropped. |
| `UserCredentials $credentials`                                | The user credentials to use for this operation.                            |
| `int $bufferSize`                                             | The number of in-flight messages this client is allowed.                   |
| `bool $autoAck`                                               | Whether to automatically acknowledge messages after eventAppeared returns. |
| `UserCredentials $credentials`                                | The user credentials to use for this operation.                            |

## Acknowledgements

Clients must acknowledge (or not acknowledge) messages in the competing consumer model. If you enable auto-ack the subscription will automatically acknowledge messages once your handler completes them. If you throw an exception, it will shut down your subscription with a message and the uncaught exception.

You can choose to not auto-ack messages. This can be useful when you have multi-threaded processing of messages in your subscriber and need to pass control to something else. There are methods on the subscription object that you can call `Acknowledge,` and `NotAcknowledge` both take a `ResolvedEvent` (the one you processed) both also have overloads for passing and `ResolvedEvent[]`.

## Consumer Strategies

When creating a persistent subscription, the settings allow for different consumer strategies via the `WithNamedConsumerStrategy` method. Built-in strategies are defined in the enum `SystemConsumerStrategies`.

> [!NOTE]
> HTTP clients bypass the consumer strategy which means it ignores any ordering or pinning.

| Strategy Name        | Description                                                                                                                                                         |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| RoundRobin (default) | Distributes events to all clients evenly. If the client bufferSize is reached the client is ignored until events are acknowledged/not acknowledged.                 |
| DispatchToSingle     | Distributes events to a single client until the bufferSize is reached. After which the next client is selected in a round robin style, and the process is repeated. |
| Pinned               | For use with an indexing projection such as the system $by_category projection.                                                                                     |

Event Store inspects event for its source stream id, hashing the id to one of 1024 buckets assigned to individual clients. When a client disconnects it's buckets are assigned to other clients. When a client connects, it is assigned some of the existing buckets. This naively attempts to maintain a balanced workload.

The main aim of this strategy is to decrease the likelihood of concurrency and ordering issues while maintaining load balancing. _This is not a guarantee_, and you should handle the usual ordering and concurrency issues.
