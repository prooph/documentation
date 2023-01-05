---
outputFileName: index.html
---

# Projections Management

The Event Store Client API includes helper methods that use the HTTP API to allow you to manage projections. This document describes the methods found in the `\Prooph\EventStore\Async\Projections\ProjectionsManager` implementations.

## Methods

### Enable a Projection

Enables an existing projection by name. You must have access to a projection to enable it.

```php
enable(
    string $name,
    ?UserCredentials $userCredentials = null
): void
```

### Disable a Projection

Disables an existing projection by name. You must have access to a projection to disable it.

```php
disable(
    string $name,
    ?UserCredentials $userCredentials = null
): void
```

### Abort a Projection

Aborts an existing projection by name. You must have access to a projection to abort it.

```php
abort(
    string $name,
    ?UserCredentials $userCredentials = null
): void
```

### Create a One-Time Projection

Creates a projection that runs until the end of the log and then stops. The query parameter contains the JavaScript you want created as a one time projection.

```php
createOneTime(
    string $query,
    string $type = 'JS',
    ?UserCredentials $userCredentials = null
): void
```

## Create a Transient Projection

Create an ad-hoc projection that runs until completion and automatically deleted afterwards. The query parameter contains the JavaScript you want created as a transient projection.

```php
public function createTransient(
    string $name,
    string $query,
    string $type = 'JS',
    ?UserCredentials $userCredentials = null
): void
```

### Create a Continuous Projection

Creates a projection that runs until the end of the log and then continues running. The query parameter contains the JavaScript you want created as a one time projection. Continuous projections have explicit names and you can enable or disable them via this name.

```php
createContinuous(
    string $name,
    string $query,
    bool $trackEmittedStreams = false,
    string $type = 'JS',
    ?UserCredentials $userCredentials = null
): void
```

### List all Projections

Returns a list of all projections.

```php
listAll(
    ?UserCredentials $userCredentials = null
): list<ProjectionDetails>
```

### List One-Time Projections

Returns a list of all One-Time Projections.

```php
listOneTime(
    ?UserCredentials $userCredentials = null
): list<ProjectionDetails>
```

### List Continuous Projections

Returns a list of all Continuous Projections.

```php
listContinuous(
    ?UserCredentials $userCredentials = null
): list<ProjectionDetails>
```

### Get projection status

Returns projection status as `\Prooph\EventStore\Projections\ProjectionDetails` instance.

```php
public function getStatus(
    string $name, 
    ?UserCredentials $userCredentials = null
): ProjectionDetails
```

### Get Statistics on a Projection

Returns the statistics associated with a named projection.

```php
getStatistics(
    string $name,
    ?UserCredentials $userCredentials = null
): ProjectionStatistics
```

### Delete Projection

Deletes a named projection. You must have access to a projection to delete it.

```php
delete(
    string $name,
    ?UserCredentials $userCredentials = null
): void
```

### Get State

Retrieves the state of a projection. Returns instance of `\Prooph\EventStore\Projections\State`.

```php
getState(
    string $name,
    ?UserCredentials $userCredentials = null
): State
```

### Get Partition State

Asynchronously gets the state of a projection for a specified partition

```php
getPartitionState(
    string $name,
    string $partition,
    ?UserCredentials $userCredentials = null
): State
```

### Get Result

Asynchronously gets the result of a projection

```php
getResult(
    string $name,
    ?UserCredentials $userCredentials = null
): State
```

### Get Partition Result

Asynchronously gets the result of a projection for a specified partition

```php
getPartitionResult(
    string $name,
    string $partition,
    ?UserCredentials $userCredentials = null
): State
```

### Get Projection Query

Retrieves Query of a projection.

```php
getQuery(
    string $name,
    ?UserCredentials $userCredentials = null
): Query
```

### Update Query

Asynchronously updates the definition of a query

```php
public function updateQuery(
    string $name,
    string $query,
    ?bool $emitEnabled = null,
    ?UserCredentials $userCredentials = null
): void;
```

### Reset projection

Asynchronously resets a projection.

```php
public function reset(
    string $name, 
    ?UserCredentials $userCredentials = null
): void;
```