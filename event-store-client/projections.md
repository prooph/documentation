---
outputFileName: index.html
---

# Projections Management

The Event Store Client API includes helper methods that use the HTTP API to allow you to manage projections. This document describes the methods found in the `ProjectionsManager` class.

## Methods

### Enable a Projection

Enables an existing projection by name. You must have access to a projection to enable it.

```php
enableAsync(
    string $name,
    ?UserCredentials $userCredentials = null
): Promise
```

### Disable a Projection

Disables an existing projection by name. You must have access to a projection to disable it.

```php
disableAsync(
    string $name,
    ?UserCredentials $userCredentials = null
): Promise
```

### Abort a Projection

Aborts an existing projection by name. You must have access to a projection to abort it.

```php
abortAsync(
    string $name,
    ?UserCredentials $userCredentials = null
): Promise
```

### Create a One-Time Projection

Creates a projection that runs until the end of the log and then stops. The query parameter contains the JavaScript you want created as a one time projection.

```php
createOneTimeAsync(
    string $query,
    ?UserCredentials $userCredentials = null
): Promise
```

### Create a Continuous Projection

Creates a projection that runs until the end of the log and then continues running. The query parameter contains the JavaScript you want created as a one time projection. Continuous projections have explicit names and you can enable or disable them via this name.

```php
createContinuousAsync(
    string $name,
    string $query,
    ?UserCredentials $userCredentials = null
): Promise
```

### List all Projections

Returns a list of all projections.

```php
listAllAsync(
    ?UserCredentials $userCredentials = null
): Promise<ProjectionDetails[]>
```

### List One-Time Projections

Returns a list of all One-Time Projections.

```php
listOneTimeAsync(
    ?UserCredentials $userCredentials = null
): Promise<ProjectionDetails[]>
```

### Get Statistics on a Projection

Returns the statistics associated with a named projection.

```php
getStatisticsAsync(
    string $name,
    ?UserCredentials $userCredentials = null
): Promise<string>
```

### Delete Projection

Deletes a named projection. You must have access to a projection to delete it.

```php
deleteAsync(
    string $name,
    ?UserCredentials $userCredentials = null
): Promise
```

### Get State

Retrieves the state of a projection.

```php
getStateAsync(
    string $name,
    ?UserCredentials $userCredentials = null
): Promise<string>
```

### Get Partition State

Retrieves the state of the projection via the given partition.

```php
getPartitionStateAsync(
    string $name,
    string $partition,
    ?UserCredentials $userCredentials = null
): Promise<string>
```

### Get Result

Retrieves the result of the projection.

```php
getResultAsync(
    string $name,
    ?UserCredentials $userCredentials = null
): Promise<string>
```

### Get Partition Result

Retrieves the result of the projection via the given partition.

```php
getPartitionResultAsync(
    string $name,
    string $partition,
    ?UserCredentials $userCredentials = null
): Promise<string>
```
