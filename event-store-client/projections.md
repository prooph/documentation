---
outputFileName: index.html
---

# Projections Management

The Event Store Client API includes helper methods that use the HTTP API to allow you to manage projections. This document describes the methods found in the `\Prooph\EventStore\Async\Projections\ProjectionsManager` implementations.

## Methods

### Enable a Projection

Enables an existing projection by name. You must have access to a projection to enable it.

```php
enableAsync(
    string $name,
    ?UserCredentials $userCredentials = null
): Promise<void>
```

### Disable a Projection

Disables an existing projection by name. You must have access to a projection to disable it.

```php
disableAsync(
    string $name,
    ?UserCredentials $userCredentials = null
): Promise<void>
```

### Abort a Projection

Aborts an existing projection by name. You must have access to a projection to abort it.

```php
abortAsync(
    string $name,
    ?UserCredentials $userCredentials = null
): Promise<void>
```

### Create a One-Time Projection

Creates a projection that runs until the end of the log and then stops. The query parameter contains the JavaScript you want created as a one time projection.

```php
createOneTimeAsync(
    string $query,
    string $type = 'JS',
    ?UserCredentials $userCredentials = null
): Promise<void>
```

## Create a Transient Projection

Create an ad-hoc projection that runs until completion and automatically deleted afterwards. The query parameter contains the JavaScript you want created as a transient projection.

```php
public function createTransientAsync(
    string $name,
    string $query,
    string $type = 'JS',
    ?UserCredentials $userCredentials = null
): Promise<void>
```

### Create a Continuous Projection

Creates a projection that runs until the end of the log and then continues running. The query parameter contains the JavaScript you want created as a one time projection. Continuous projections have explicit names and you can enable or disable them via this name.

```php
createContinuousAsync(
    string $name,
    string $query,
    bool $trackEmittedStreams = false,
    string $type = 'JS',
    ?UserCredentials $userCredentials = null
): Promise<void>
```

### List all Projections

Returns a list of all projections.

```php
listAllAsync(
    ?UserCredentials $userCredentials = null
): Promise<list<ProjectionDetails>>
```

### List One-Time Projections

Returns a list of all One-Time Projections.

```php
listOneTimeAsync(
    ?UserCredentials $userCredentials = null
): Promise<list<ProjectionDetails>>
```

### List Continuous Projections

Returns a list of all Continuous Projections.

```php
listContinuousAsync(
    ?UserCredentials $userCredentials = null
): Promise<list<ProjectionDetails>>
```

### Get projection status

Returns projection status as `\Prooph\EventStore\Projections\ProjectionDetails` instance.

```php
public function getStatusAsync(
    string $name, 
    ?UserCredentials $userCredentials = null
): Promise<ProjectionDetails>;
```

### Get Statistics on a Projection

Returns the statistics associated with a named projection.

```php
getStatisticsAsync(
    string $name,
    ?UserCredentials $userCredentials = null
): Promise<ProjectionStatistics>
```

### Delete Projection

Deletes a named projection. You must have access to a projection to delete it.

```php
deleteAsync(
    string $name,
    ?UserCredentials $userCredentials = null
): Promise<void>
```

### Get State

Retrieves the state of a projection. Returns instance of `\Prooph\EventStore\Projections\State`.

```php
getStateAsync(
    string $name,
    ?UserCredentials $userCredentials = null
): Promise<State>
```

### Get Partition State

Asynchronously gets the state of a projection for a specified partition

```php
getPartitionStateAsync(
    string $name,
    string $partition,
    ?UserCredentials $userCredentials = null
): Promise<State>
```

### Get Result

Asynchronously gets the result of a projection

```php
getResultAsync(
    string $name,
    ?UserCredentials $userCredentials = null
): Promise<State>
```

### Get Partition Result

Asynchronously gets the result of a projection for a specified partition

```php
getPartitionResultAsync(
    string $name,
    string $partition,
    ?UserCredentials $userCredentials = null
): Promise<State>
```

### Get Projection Query

Retrieves Query of a projection.

```php
getQueryAsync(
    string $name,
    ?UserCredentials $userCredentials = null
): Promise<Query>
```

### Update Query

Asynchronously updates the definition of a query

```php
public function updateQueryAsync(
    string $name,
    string $query,
    ?bool $emitEnabled = null,
    ?UserCredentials $userCredentials = null
): Promise<void>;
```

### Reset projection

Asynchronously resets a projection.

```php
public function resetAsync(
    string $name, 
    ?UserCredentials $userCredentials = null
): Promise<void>;
```