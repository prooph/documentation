---
outputFileName: index.html
---

# Stream Metadata

Every stream in Event Store has metadata associated with it. Internally, the metadata includes information such as the ACL of the stream and the maximum count and age for the events in the stream. Client code can also put information into stream metadata for use with projections or through the client API.

A common use of this information is to store associated details about an event that is not part of the event. Examples of these are:

-   "which user wrote the event?"
-   "Which application server were they talking to?"
-   "From what IP address did the request come from?"

This information is not part of the actual event but is metadata associated with the event. Event Store stores stream metadata as JSON, and you can access it over the HTTP APIs.

## Methods

### Read Stream Metadata

```php
getStreamMetadataAsync(
    string $stream,
    ?UserCredentials $userCredentials = null
): Promise<StreamMetadataResult>
```

```php
getStreamMetadataAsRawBytesAsync(
    string $stream,
    ?UserCredentials $userCredentials = null
): Promise<RawStreamMetadataResult>
```

### Write Stream Metadata

```php
setStreamMetadataAsync(
    string $stream,
    int $expectedMetastreamVersion,
    StreamMetadata $metadata,
    ?UserCredentials $userCredentials = null
): Promise<WriteResult>
```

```php
setRawStreamMetadataAsync(
    string $stream,
    int $expectedMetastreamVersion,
    string $metadata,
    ?UserCredentials $userCredentials = null
): Promise<WriteResult>
```

## Read Stream Metadata

To read stream metadata over the Event Store Client API you can use methods found on the `EventStoreConnection`. You can use the `getStreamMetadata` methods in two ways. The first is to return a fluent interface over the stream metadata, and the second is to return you the raw JSON of the stream metadata.

```php
getStreamMetadataAsync(
    string $stream,
    ?UserCredentials $userCredentials = null
): Promise<StreamMetadataResult>
```

This returns a `StreamMetadataResult`. The methods on this result are:

| Method                             | Description                                              |
| ---------------------------------- | -------------------------------------------------------- |
| `stream(): string`                 | The name of the stream                                   |
| `isStreamDeleted(): bool`          | `true` is the stream is deleted, `false` otherwise.      |
| `metastreamVersion(): int`         | The version of the metastream format                     |
| `streamMetadata(): StreamMetadata` | A `StreamMetadata` object representing the metadata JSON |

You can then access the `StreamMetadata` via the `StreamMetadata` object. It contains typed methods for well known stream metadata entries.

| Method                   | Description                                                                                                                                                                                                                                                                   |
| ------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `maxAge(): ?int`         | The maximum age of events in the stream. Items older than this will be automatically removed.                                                                                                                                                                                 |
| `maxCount(): ?int`       | The maximum count of events in the stream. When you have more than count the oldest will be removed.                                                                                                                                                                          |
| `truncateBefore(): ?int` | When set says that items prior to event 'E' can be truncated and will be removed.                                                                                                                                                                                             |
| `cacheControl(): ?int`   | The head of a feed in the atom api is not cacheable. This allows you to specify a period of time you want it to be cacheable. Low numbers are best here (say 30-60 seconds) and introducing values here will introduce latency over the atom protocol if caching is occuring. |
| `acl(): ?StreamAcl`      | The access control list for this stream.                                                                                                                                                                                                                                      |

If instead you want to work with raw JSON you can use the raw methods for stream metadata.

```php
getStreamMetadataAsRawBytesAsync(
    string $stream,
    ?UserCredentials $userCredentials = null
): Promise<RawStreamMetadataResult>
```

This returns a `RawStreamMetadataResult`. The methods on this result are:

| Member                     | Description                                                                                       |
| -------------------------- | ------------------------------------------------------------------------------------------------- |
| `stream(): string`         | The name of the stream                                                                            |
| `isStreamDeleted(): bool`  | True is the stream is deleted, false otherwise.                                                   |
| `metastreamVersion(): int` | The version of the metastream (see [Expected Version](optimistic-concurrency-and-idempotence.md)) |
| `streamMetadata(): string` | The raw data of the metadata JSON                                                                 |

> [!NOTE]
> If you have security enabled, reading metadata may require that you pass credentials. By default it is only allowed for admins though you can change this via default ACLs. If you do not pass credentials and they are required you will receive an `AccessedDeniedException`.

## Writing Metadata

You can write metadata in both a typed and a raw mechanism. When writing it is generally easier to use the typed mechanism. Both writing mechanisms support an `expectedVersion` which works the same as on any stream and you can use to control concurrency, read [Expected Version](~/event-store-client/optimistic-concurrency-and-idempotence.md) for further details.

```php
setStreamMetadataAsync(string $stream, int $expectedMetastreamVersion, StreamMetadata $metadata, ?UserCredentials $userCredentials = null): Promise<WriteResult>
```

The `StreamMetadata` passed above has a builder that you can access via the `StreamMetadata::create()` method. The options available on the builder are:

| Method                                         | Description                                                                                                                                                                            |
| ---------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `setMaxCount(int $count)`                      | Sets the maximum count of events in the stream.                                                                                                                                        |
| `setMaxAge(int $age)`                          | Sets the maximum age of events in the stream.                                                                                                                                          |
| `setTruncateBefore(int $seq)`                  | Sets the event number from which previous events can be scavenged.\<                                                                                                                   |
| `setCacheControl(int $cacheControl)`           | The amount of time the stream head is cachable.                                                                                                                                        |
| `setReadRoles(string[] $roles)`                | Sets the roles allowed to read the underlying stream.                                                                                                                                  |
| `setWriteRoles(string[] $roles)`               | Sets the roles allowed to write to the underlying stream.                                                                                                                              |
| `setDeleteRoles(string[] $roles)`              | Sets the roles allowed to delete the underlying stream.                                                                                                                                |
| `setMetadataReadRoles(string[] $roles)`        | Sets the roles allowed to read the metadata stream.                                                                                                                                    |
| `setMetadataWriteRoles(string[] $roles)`       | Sets the roles allowed to write the metadata stream. Be careful with this privilege as it gives all the privileges for a stream as that use can assign themselves any other privilege. |
| `setCustomProperty(string $key, mixed $value)` | The setCustomProperty method allows the setting of arbitrary custom fields into the stream metadata.                                                                                   |
| `removeCustomProperty(string $key)`            | The removeCustomProperty method allows the removal of custom fields from the stream metadata.                                                                                          |

You can add user-specified metadata via the `setCustomProperty` method. Some examples of good uses of user-specified metadata are:

-   which adapter is responsible for populating a stream.
-   which projection caused a stream to be created.
-   a correlation ID of some business process.

```php
setStreamMetadataAsync(
    string $stream,
    int $expectedMetastreamVersion,
    StreamMetadata $metadata,
    ?UserCredentials $userCredentials = null
): Promise<WriteResult>
```

This method will put the data that is in metadata as the stream metadata. Metadata in this case can be anything in a vector of bytes. The server only understands JSON.

> [!NOTE]
> Writing metadata may require that you pass credentials if you have security enabled by default it is only allowed for admins though you can change this via default ACLs. If you do not pass credentials and they are required you will receive an `AccessedDeniedException`.
