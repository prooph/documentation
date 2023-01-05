---
outputFileName: index.html
---

# Connecting to a Server

## EventStoreConnection

The `EventStoreConnection` class maintains a full-duplex connection between the client and the Event Store server.

## Default Ports

`1113` - TCP Port (your connection reading and writing goes here)
`2113` - HTTP Port (your connection interacting with http api goes here)

## Creating a Connection

The `EventStoreConnectionFactory` class uses the static `create*` methods to create a new connection. All methods allow you to optionally specify a name for the connection, which the connection returns when it raises events (see [Connection Events](#connection-events)).

| Method                                                                                                | Description                                                                                       |
| ----------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------|
| `createFromUri(?Uri $uri, ?ConnectionSettings $connectionSettings = null)`                            | Connects to Event Store (see URIs below)                                                          |
| `createFromEndPoint(EndPoint $endPoint, ?ConnectionSettings $connectionSettings)`                     | Connects to a single node                                                                         |
| `createFromConnectionString(string $connectionString, ?ConnectionSettings $settings = null)`          | Connects to Event Store from connection string                                                    |
| `createFromSettings(?ConnectionSettings $settings = null)`                                            | Connects to Event Store (see [Customising Connection Settings](#customising-connection-settings)) |
| `createFromClusterSettings(ConnectionSettings $connectionSettings, ClusterSettings $clusterSettings)` | Connects to an Event Store HA cluster (see [Cluster Settings](#cluster-settings))                 |

> [!NOTE]
> The connection returned by these methods is inactive. Use the `connect()` method to establish a connection with the server.

## URIs

The create methods support passing of a URI to the connection as opposed to passing `EndPoints`. This URI should be in the format of:

-   **Single Node**: `tcp://user:password@myserver:11234`
-   **Cluster**: `discover://user:password@myserver:1234`

Where the port number points to the TCP port of the Event Store instance (1113 by default) or points to the manager gossip port for discovery purposes.

With the URI based mechanism you can pass a domain name and the client will resolve it.

> [!NOTE]
> The client performs a non-blocking DNS call for single node.

## Customising Connection Settings

### Connection String

Many of the overloads accept a connection string that you can use to control settings of the connection. A benefit to having these as a connection string instead of using the fluent API is that you can change them between environments without recompiling (i.e. a single node in `dev` and a cluster in `production`).

The connection string format should look familiar to those who have used connection strings in the past. It consists of a series of key/value pairs separated by semicolons.

You can set the following values using the connection string.

| Name                        | Format                                        | Description                                                          |
| --------------------------- | --------------------------------------------- | -------------------------------------------------------------------- |
| verboseLogging              | True/false                                    | Enables verbose logging                                              |
| maxQueueSize                | Integer                                       | Maximum number of outstanding operations                             |
| maxConcurrentItems          | Integer                                       | Maximum number of concurrent async operations                        |
| maxRetries                  | Integer                                       | Maximum number of retry attempts                                     |
| maxReconnections            | Integer                                       | The maximum number of times to try reconnecting                      |
| requireMaster               | True/false                                    | If set the server will only process if it is master                  |
| reconnectionDelay           | Integer (milliseconds)                        | The delay before attempting to reconnect                             |
| operationTimeout            | Integer (milliseconds)                        | The time before considering an operation timed out                   |
| operationTimeoutCheckPeriod | Integer (milliseconds)                        | The frequency in which to check timeouts                             |
| defaultUserCredentials      | String in format username:password            | The default credentials for the connection                           |
| useSslConnection            | True/false                                    | whether to use SSL for this connection                               |
| targetHost                  | String                                        | The hostname expected on the certificate                             |
| validateServer              | True/false                                    | Whether to validate the remote server                                |
| failOnNoServerResponse      | True/False                                    | Whether to fail on no server response                                |
| heartbeatInterval           | Integer (milliseconds)                        | The interval at which to send the server a heartbeat                 |
| heartbeatTimeout            | Integer (milliseconds)                        | The amount of time to receive a heartbeat response before timing out |
| clusterDns                  | string                                        | The DNS name of the cluster for discovery                            |
| maxDiscoverAttempts         | Integer                                       | The maximum number of attempts to try to discover the cluster        |
| externalGossipPort          | Integer                                       | The port to try to gossip on                                         |
| gossipTimeout               | Integer (milliseconds)                        | The amount of time before timing out a gossip response               |
| gossipSeeds                 | Comma separated list of ip:port               | A list of seeds to try to discover from                              |
| connectTo                   | A URI in format described above to connect to | The URI to connect to                                                |

> [!INFO]
> You can also use spacing instead of camel casing in your connection string.

```php
$connectionString = 'ConnectTo=tcp://admin:changeit@localhost:1113; HeartBeatTimeout=500'
```

Sets the connection string to connect to `localhost` on the default port and sets the heartbeat timeout to 500ms.

```php
$connectionString = 'Connect To = tcp://admin:changeit@localhost:1113; Gossip Timeout = 500'
```

Using spaces:

```php
$connectionString = 'ConnectTo=discover://admin:changeit@mycluster:3114; HeartBeatTimeout=500'
```

Tells the connection to try gossiping to a manager node found under the DNS 'mycluster' at port '3114' to connect to the cluster.

```php
$connectionString = 'GossipSeeds=192.168.0.2:1111,192.168.0.3:1111; HeartBeatTimeout=500'
```

Tells the connection to try gossiping to the gossip seeds `192.168.0.2` or `192.168.0.3` on port '1111' to discover information about the cluster.

> [!NOTE]
> See the fluent API below for defaults of values.

> [!NOTE]
> You can also use the `ConnectionString` class to return a `ConnectionSettings` object.

### Fluent API

Settings used for modifying the behavior of an `EventStoreConnection` are encapsulated into an object of type `ConnectionSettings` passed as a parameter to the `create*` methods listed above.

Instances of `ConnectionSettings` are created using a fluent builder class:

```php
$builder = ConnectionSettings::create();
$settings = $builder->build();
```

This creates an instance of `ConnectionSettings` with default options. You can override these by chaining the additional builder methods described below.

### Logging

The API can log information to different destinations. By default logging is disabled.

| Builder Method                    | Description                                                                                                                                                     |
| --------------------------------- | -------------------------------------------------------------------------------------|
| `useConsoleLogger()`              | Output log messages to console                                                       |
| `useFileLogger(Handle $file)`     | Output log messages to a file using Amp File Handle                                  |
| `useCustomLogger(Logger $logger)` | Output log messages to the specified instance of `Logger` (Psr\Log\LoggerInterface). |
| `enableVerboseLogging()`          | Turns on verbose logging.                                                            |

By default information about connection, disconnection and errors are logged, however it can be useful to have more information about specific operations as they are occuring.

### User Credentials

Event Store supports Access Control Lists that restrict permissions for a stream based on users and groups. `EventStoreConnection` allows you to supply credentials for each operation, however it is often more convenient to set default credentials for all operations on the connection.

| Builder Method                                            | Description                                                                                                                       |
| --------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| `setDefaultUserCredentials(UserCredentials $credentials)` | Sets the default `UserCredentials` to use for this connection. If you don't supply any credentials, the operation will use these. |

You create a `UserCredentials` object as follows:

```php
$credentials = new UserCredentials('username', 'password');
```

### Security

The API and Event Store can communicate either over SSL or an unencrypted channel (by default).

To configure the client-side of the SSL connection, use the builder method below.

```php
useSslConnection(string $targetHost, bool $validateServer)
```

Uses an SSL-encrypted connection where `targetHost` is the name specified on the SSL certificate installed on the server, and `validateServer` controls whether the connection validates the server certificate.

> [!WARNING]
> In production systems where credentials are sent from the client to Event Store, you should always use SSL encryption and you should set `validateServer` to `true`.

### Node Preference

When connecting to an Event Store HA cluster you can specify that operations are performed on any node, or only on the node that is the master.

| Builder Method          | Description                                                                                                |
| ----------------------- | ---------------------------------------------------------------------------------------------------------- |
| `performOnMasterOnly()` | Require the master to serve all write and read requests (Default).                                         |
| `performOnAnyNode()`    | Allow for writes to be forwarded and read requests to be served locally if the current node is not master. |

### Handling Failures

The following methods on the `ConnectionSettingsBuilder` allow you to change the way the connection handles operation failures and connection issues.

#### Reconnections

| Builder Method                                    | Description                                                                                                                                         |
| --------------------------------------------------| --------------------------------------------------------------------------------------------------------------------------------------------------- |
| `withConnectionTimeoutOf(int $timeout)`          | Sets the timeout to connect to a server before aborting and attempting a reconnect (Default: 1000ms).                                               |
| `limitReconnectionsTo(int $limit)`               | Limits the number of reconnections this connection can try to make (Default: 10).                                                                   |
| `keepReconnecting()`                              | Allows infinite reconnection attempts.                                                                                                              |
| `setReconnectionDelayTo(int $reconnectionDelay)` | Sets the delay between reconnection attempts (Default: 100ms).                                                                                      |
| `setHeartbeatInterval(int $interval)`            | Sets how often the connection should expect heartbeats (lower values detect broken sockets faster) (Default: 750ms).                                |
| `setHeartbeatTimeout(int $timeout)`              | Sets how long to wait without heartbeats before determining a connection to be dead (must be longer than the heatrbeat interval) (Default: 1500ms). |

#### Operations

| Builder Method                                     | Description                                                              |
| ---------------------------------------------------| ------------------------------------------------------------------------ |
| `setOperationTimeout(int $timeout)`                | Sets the operation timeout duration (Default: 7000ms).                   |
| `setTimeoutCheckPeriodTo(int $timeoutCheckPeriod)` | Sets how often to check for timeouts (Default: 1000ms).                  |
| `limitAttemptsForOperationTo(int $limit)`          | Limits the number of operation attempts (Default: 11).                   |
| `limitRetriesForOperationTo(int $limit)`           | Limits the number of operation retries (Default: 10).                    |
| `keepRetrying()`                                   | Allows infinite operation retries.                                       |
| `limitOperationsQueueTo(int $limit)`               | Sets the limit for number of outstanding operations (Default: 5000).     |
| `failOnNoServerResponse()`                         | Marks that no response from server should cause an error on the request. |

## Cluster Settings

When connecting to an Event Store HA cluster you must pass an instance of `ClusterSettings` as well as the usual `ConnectionSettings`. Primarily you use this to tell the `EventStoreConnection` how to discover all the nodes in the cluster. A connection to a cluster will automatically handle reconnecting to a new node if the current connection fails.

### Using DNS Discovery

DNS discovery uses a single DNS entry with several records listing all node IP addresses. The `EventStoreConnection` will then use a well known port to gossip with the nodes.

Use `ClusterSettings::create()->discoverClusterViaDns()` followed by:

| Builder Method                                     | Description                                                                         |
| -------------------------------------------------- | ------------------------------------------------------------------------------------|
| `setClusterDns(string $clusterDns)`                | Sets the DNS name under which to list cluster nodes.                                |
| `setClusterGossipPort(int $clusterGossipPort)`     | Sets the well-known port on which the cluster gossip is taking place.               |
| `setMaxDiscoverAttempts(int $maxDiscoverAttempts)` | Sets the maximum number of attempts for discovery (Default: 10).                    |
| `setGossipTimeout(int $timeout)`                   | Sets the period after which gossip times out if none is received (Default: 1000ms). |

> [!NOTE]
> If you are using the commercial edition of Event Store HA with Manager nodes in place, the gossip port should be the port number of the external HTTP port on which the managers are running. If you are using the open source edition of Event Store HA the gossip port should be the External HTTP port that the nodes are running on. If you cannot use a well-known port for this across all nodes you can instead use gossip seed discovery and set the `EndPoint` of some seed nodes instead.

### Connecting Using Gossip Seeds

The second supported method for node discovery uses a hardcoded set of `IPEndPoint`s as gossip seeds.

Use `ClusterSettings::create()->discoverClusterViaGossipSeeds()` followed by:

| Builder Method                                      | Description                                                                           |
| ----------------------------------------------------| ------------------------------------------------------------------------------------- |
| `setGossipSeedEndPoints(EndPoint[] $gossipSeeds)`   | Sets gossip seed endpoints for the client.                                            |
| `setGossipSeedEndPoints(GossipSeed[] $gossipSeeds)` | Same as above, but allows a specific `Host` header to be sent with all HTTP requests. |
| `setMaxDiscoverAttempts(int $maxDiscoverAttempts)`  | Sets the maximum number of attempts for discovery (Default: 10).                      |
| `setGossipTimeout(int $timeout)`                    | Sets the period after which gossip times out if none is received (Default: 1000ms).   |

## Connection Events

`EventStoreConnection` exposes events that your application can use to be notifed of changes to the status of the connection.

<!-- TODO: Not moved. -->

| Event                                                                    | Description                                                                                                                                                                                                 |
| ------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `EventHandler<ClientConnectionEventArgs> Connected`                      | Fired when an `EventStoreConnection` connects to an Event Store server.                                                                                                   |
| `EventHandler<ClientConnectionEventArgs> Disconnected`                   | Fired when an `EventStoreConnection` disconnects from an Event Store server by some means other than by calling the `close` method.                                       |
| `EventHandler<ClientReconnectingEventArgs> Reconnecting`                 | Fired when an `EventStoreConnection` is attempting to reconnect to an Event Store server following a disconnection.                                                       |
| `EventHandler<ClientClosedEventArgs> Closed`                             | Fired when an `EventStoreConnection` is closed either using the `close` method or when reconnection limits are reached without a successful connection being established. |
| `EventHandler<ClientErrorEventArgs> ErrorOccurred`                       | Fired when an error is thrown on an `EventStoreConnection`.                                                                                                               |
| `EventHandler<ClientAuthenticationFailedEventArgs> AuthenticationFailed` | Fired when a client fails to authenticate to an Event Store server.                                                                                                                                         |
