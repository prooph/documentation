---
outputFileName: index.html
---

# Writing to a Stream

You can use the client API to write one or more events to a stream atomically. You do this by appending the events to the stream in one operation, or by starting a transaction on the stream, writing events in one or more operations in that transaction, and then committing the transaction.

You can make an optimistic concurrency check during the write by specifying the version at which you expect the stream to be. Identical write operations are idempotent if the optimistic concurrency check is not disabled. You can find more information on optimistic concurrency and idempotence [here](~/event-store-client/optimistic-concurrency-and-idempotence.md).

## Methods

### Appending to a stream in a single write

```php
appendToStreamAsync(
    string $stream,
    int $expectedVersion,
    EventData[] $events
): Promise<WriteResult>
```

### Using a transaction to append to a stream across multiple writes

#### On `EventStoreConnection`

```php
startTransactionAsync(
    string $stream,
    int $expectedVersion
): Promise<EventStoreAsyncTransaction>
```

```php
continueTransaction(
    int $transactionId
): EventStoreAsyncTransaction
```

#### On `EventStoreTransaction`

```php
writeAsync(
    EventData[] $events
): Promise
```

```php
commitAsync(): Promise<WriteResult>
```

```php
rollback(): void
```

## EventData

The writing methods all use a type named `EventData` to represent an event to be stored. Instances of `EventData` are immutable.

Event Store does not have any built-in serialisation, so the body and metadata for each event are represented in `EventData` as a `string`.

The members on `EventData` are:

| Member             | Description                                                                                                                                                                                               |
| ------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `EventId $eventId` | A unique identifier representing this event. Event Store uses this for idempotency if you write the same event twice you should use the same identifier both times.                                       |
| `string type`      | The name of the event type. You can use this for pattern matching in projections, so should be a "friendly" name rather than a CLR type name, for example.                                                |
| `bool isJson`      | If the data and metadata fields are serialized as JSON, you should set this to `true`. Setting this to `true` will cause the projections framework to attempt to deserialize the data and metadata later. |
| `string data`      | The serialized data representing the event to be stored.                                                                                                                                                  |
| `string metadata`  | The serialized data representing metadata about the event to be stored.                                                                                                                                   |

## Append to a stream in a single write

The `appendToStreamAsync` method writes events atomically to the end of a stream, working in an asynchronous manner.

The parameters are:

| Parameter              | Description                                                                                                                                                                                                                                                                                                                                                                           |
| -----------------------| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `string $stream`       | The name of the stream to which to append.                                                                                                                                                                                                                                                                                                                                            |
| `int $expectedVersion` | The version at which you expect the stream to be in order that an optimistic concurrency check can be performed. This should either be a positive integer, or one of the constants `ExpectedVersion.NoStream`, `ExpectedVersion.EmptyStream`, or to disable the check, `ExpectedVersion.Any`. See [here](optimistic-concurrency-and-idempotence.md) for a broader discussion of this. |
| `EventData[] $events`  | The events to append. There is also an overload of each method which takes the events as a `params` array.                                                                                                                                                                                                                                                                            |
