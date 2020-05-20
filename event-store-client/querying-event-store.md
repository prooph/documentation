---
outputFileName: index.html
---

# Querying Event Store

The Event Store Client API includes helper methods that use the HTTP API to allow you to execute transient projection. This document describes the methods found in the `\Prooph\EventStore\Async\Projections\QueryManager` implementations.

## Methods

### Execute query

Asynchronously executes a query by creating a new transient projection and polls its status until it is Completed.

```php
public function executeAsync(
    string $name,
    string $query,
    int $initialPollingDelay,
    int $maximumPollingDelay,
    string $type = 'JS',
    ?UserCredentials $userCredentials = null
): Promise<State>;
```