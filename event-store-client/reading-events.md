---
outputFileName: index.html
---

# Reading Events

You can use the client API to read events from a stream starting from either end of the stream. There is a method for each direction and one for reading a single event.

## Methods

### Read a single event

```php
readEvent(
    string $stream,
    int $eventNumber,
    bool $resolveLinkTos
): EventReadResult
```

### Read a specific stream forwards

```php
readStreamEventsForward(
    string $stream,
    int $start,
    int $count,
    bool $resolveLinkTos
): StreamEventsSlice
```

### Read a specific stream backwards

```php
readStreamEventsBackward(
    string $stream,
    int $start,
    int $count,
    bool $resolveLinkTos
): StreamEventsSlice
```

### Read all events forwards

```php
readAllEventsForward(
    Position $position,
    int $maxCount,
    bool $resolveLinkTos
): AllEventsSlice
```

### Read all events backwards

```php
readAllEventsBackward(
    Position $position,
    int $maxCount,
    bool $resolveLinkTos
): AllEventsSlice
```

> [!NOTE]
> These methods also have an optional parameter which allows you to specify the `UserCredentials` to use for the request. If you don't supply any, the default credentials for the `EventStoreConnection` are used ([See Connecting to a Server - User Credentials](~/event-store-client/connecting-to-a-server.md#user-credentials)).

## StreamEventsSlice

The reading methods for individual streams each return a `StreamEventsSlice`, which is immutable. The available methods on `StreamEventsSlice` are:

| Method                           | Description                                                                                                                                                                       |
| -------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `stream(): string`               | The status of the operation (Success, StreamNotFound, StreamDeleted)                                                                                                              |
| `stream(): string`               | The name of the stream for the slice                                                                                                                                              |
| `readDirection(): ReadDirection` | Either `ReadDirection::forward()` or `ReadDirection::backward()` depending on which method was used to read                                                                       |
| `fromEventNumber(): int`         | The sequence number of the first event in the stream                                                                                                                              |
| `lastEventNumber(): int`         | The sequence number of the last event in the stream                                                                                                                               |
| `nextEventNumber(): int`         | The sequence number from which the next read should be performed to continue reading the stream                                                                                   |
| `isEndOfStream(): bool`          | Whether this slice contained the end of the stream at the time it was created                                                                                                     |
| `events(): ResolvedEvent[]`      | An array of the events read. See the description of how to interpret a [Resolved Events](~/event-store-client/reading-events.md#resolvedevent) below for more information on this |

## ResolvedEvent

When you read events from a stream (or received over a subscription) you receive an instance of the `RecordedEvent` class packaged inside a `ResolvedEvent`.

Event Store supports a special event type called 'Link Events'. Think of these events as pointers to an event in another stream.

In situations where the event you read is a link event, `ResolvedEvent` allows you to access both the link event itself, as well as the event it points to.

The methods of this class are as follows:

| Method                            | Description                                                                                                                                                                       |
| --------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `event(): ?RecordedEvent`         | The event, or the resolved link event if this `ResolvedEvent` is a link event                                                                                                     |
| `link(): ?RecordedEvent`          | The link event if this `ResolvedEvent` is a link event                                                                                                                            |
| `originalEvent(): ?RecordedEvent` | Returns the event read or which triggered the subscription. If this `ResolvedEvent` represents a link event, the link will be the `OriginalEvent`, otherwise it will be the event |
| `isResolved(): bool`              | Indicates whether this `ResolvedEvent` is a resolved link event                                                                                                                   |
| `originalPosition(): ?Position`   | The logical position of the `OriginalEvent`                                                                                                                                       |
| `originalStreamName(): string`    | The stream name of the `OriginalEvent`                                                                                                                                            |
| `originalEventNumber(): int`      | The event number in the stream of the `OriginalEvent`                                                                                                                             |

> [!NOTE]
> To ensure that the Event Store server follows link events when reading, ensure you set the `ResolveLinkTos` parameter to `true` when calling read methods.

## RecordedEvent

`RecordedEvent` contains all the data about a specific event. Instances of this class are immutable, and expose the following methods:

| Member                         | Description                                                                |
| ------------------------------ | -------------------------------------------------------------------------- |
| `eventStreamId(): string`      | The Event Stream this event belongs to                                     |
| `eventId(): EventId`           | The Unique Identifier representing this event                              |
| `eventNumber(): int`           | The number of this event in the stream                                     |
| `eventType(): string`          | The event type (supplied when writing)                                     |
| `data(): string`               | A byte array representing the data of this event                           |
| `metadata(): string`           | A byte array representing the metadata associated with this event          |
| `isJson(): bool`               | Indicates whether the content was internally marked as json                |
| `created(): DateTimeImmutable` | A `DateTimeImmutable` representing when this event was created.            |

## Read a single event

The `readEvent` method reads a single event from a stream at a specified position. This is the simplest case of reading events, but is still useful for situations such as reading the last event in the stream used as a starting point for a subscription. This function accepts three parameters:

| Parameter              | Description                                                                                                                                                         |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `string $stream`       | The stream to read from                                                                                                                                             |
| `int $eventNumber`     | The event number to read (use `StreamPosition.End` to read the last event in the stream)                                                                            |
| `bool $resolveLinkTos` | Determines whether any link events encountered in the stream will be resolved. See the discussion on [Resolved Events](~/event-store-client/reading-events.md#resolvedevent) for more information on this |

This method returns an instance of `EventReadResult` which indicates if the read was successful, and if so the `ResolvedEvent` that was read.

## Reading a stream forwards

The `readStreamEventsForward` method reads the requested number of events in the order in which they were originally written to the stream from a nominated starting point in the stream.

The parameters are:

| Parameter              | Description                                                                                                                                                         |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `string $stream`       | The name of the stream to read                                                                                                                                      |
| `int $start`           | The earliest event to read (inclusive). For the special case of the start of the stream, you should use the constant `StreamPosition::START`.                       |
| `int $count`           | The maximum number of events to read in this request (assuming that many exist between the start specified and the end of the stream)                               |
| `bool $resolveLinkTos` | Determines whether any link events encountered in the stream will be resolved. See the discussion on [Resolved Events](~/event-store-client/reading-events.md#resolvedevent) for more information on this |

### Example: Read an entire stream forwards from start to end

This example uses the `readStreamEventsForward` method in a loop to page through all events in a stream, reading 200 events at a time to build a list of all the events in the stream.

```php
$streamEvents = [];
$nextSliceStart = StreamPosition::START;

do {
    $currentSlice = $connection->readStreamEventsForward(
        'myStream',
        $nextSliceStart,
        200,
        false
    );

    $nextSliceStart = $currentSlice->nextEventNumber();

    $streamEvents = \array_merge($streamEvents, $currentSlice->events());
} while (! $currentSlice->isEndOfStream());
```

> [!NOTE]
> It's unlikely that client code would need to build a list in this manner. It's far more likely that you would pass events into a left fold to derive the state of some object as of a given event.

## Read a stream backwards

The `readStreamEventsBackward` method reads the requested number of events in the reverse order from that in which they were originally written to the stream from a specified starting point.

The parameters are:

| Parameter              | Description                                                                                                                                                         |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `string $stream`       | The name of the stream to read                                                                                                                                      |
| `int $start`           | The latest event to read (inclusive). For the end of the stream use the constant `StreamPosition.End`                                                               |
| `int $count`           | The maximum number of events to read in this request (assuming that many exist between the start specified and the start of the stream)                             |
| `bool $resolveLinkTos` | Determines whether any link events encountered in the stream will be resolved. See the discussion on [Resolved Events](~/event-store-client/reading-events.md#resolvedevent) for more information on this |

## Read all events

Event Store allows you to read events across all streams using the `readAllEventsForward` and `readAllEventsBackwards` methods. These work in the same way as the regular read methods, but use an instance of the global log file `Position` to reference events rather than the simple integer stream position described previously.

They also return an `AllEventsSlice` rather than a `StreamEventsSlice` which is the same except it uses global `Position`s rather than stream positions.

### Example: Read all events forward from start to end

```php
$allEvents = [];
$nextSliceStart = Position::start();

do {
    $currentSlice = $connection->readAllEventsForward(
        $nextSliceStart,
        200,
        false
    );

    $nextSliceStart = $currentSlice->nextPosition();

    $allEvents = \array_merge($allEvents, $currentSlice->events());
} while (! $currentSlice->isEndOfStream());
```
