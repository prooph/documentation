---
outputFileName: index.html
---

# Creating Read Models

If you want to create a read model from your events, this guide will show you the basic building blocks. We are doing this in 3 steps:

a) Enable `$by_category` projection

b) Create a persistent subscription

c) Write a script that subscribes to it.

* * *

Your event streams should be organized as one stream per aggregate. If you have 5 users in your system and the aggregate ids are simply `1`, `2`, `3`, `4`, `5`, then you may have 5 streams with these names:
`user-1`, `user-2`, `user-3`, `user-4`, `user-5`.

By enabling the `$by_category` projection, you will create another stream called `$ce-user` which will contain all events of all your user streams. The data will not be duplicated though, only a link to the original event will be created.

* * *

Next we need to create a persistent subscription. You can either do this via the EventStore UI, or programatically:

```php
$settings = PersistentSubscriptionSettings::create()
    ->build();

$result = yield $eventStoreConnection
    ->createPersistentSubscriptionAsync(
        '$ce-user',
        'mysql-read-model',
        $settings,
        new UserCredentials('admin', 'changeit')
    );

assert($result instanceof PersistentSubscriptionCreateResult);

$failure = PersistentSubscriptionCreateStatus::failure();

if ($result->status()->equals($failure)) {
    throw new RuntimeException('An error occured');
}
```

* * *

Now we need to create our subscription logic. Create a script called 'mysql-user-read-model.php'.

```php
<?php

declare(strict_types=1);

namespace Acme;

use Amp\Loop;
use Prooph\EventStoreClient\EventStoreConnectionFactory;
use Prooph\EventStoreClient\Uri;

Loop::run(function () {
    $connection = EventStoreConnectionFactory::createFromUri(
        Uri::fromString('tcp://admin:changeit@localhost:1113'),
        null,
        'test-connection'
    );
    
    yield $connection->connectAsync();
    
    yield $connection->connectToPersistentSubscriptionAsync(
        '$ce-user',
        'mysql-read-model',
        new UserEventAppeared(
            "host=127.0.0.1 user=username password=password db=test"
        )
    );
});
```

The `UserEventAppeared` class looks like this (let's use [amp/mysql](https://github.com/amphp/mysql) here, to have an async connection again):

```php
<?php

declare(strict_types=1);

namespace Acme;

use Amp\Mysql;
use Amp\Promise;
use Prooph\EventStoreClient\EventStorePersistentSubscription;
use Prooph\EventStoreClient\Internal\ResolvedEvent

class UserEventAppeared
{
    /** @var Mysql\Pool */
    private $pool;

    public function __construct($connectionString)
    {
        $this->pool = Mysql\pool($connectionString);
    }

    public function __invoke(
        EventStorePersistentSubscription $subscription,
        ResolvedEvent $resolvedEvent,
        ?int $retryCount = null
    ): Promise
    {
        switch ($resolvedEvent->originalEvent()->eventType()) {
            case 'user-registered':
                $data = $resolvedEvent->originalEvent()->data();
                $id = $data['id'];
                $name = $data['name'];
                $email = $data['email'];

                $statement = yield $this->pool->prepare(
                    "INSERT INTO user (id, name, email) VALUES (?, ?, ?)"
                );

                return $statement->execute([$id, $name, $email]);
                break;
            default:
                // ignore
                break;
        }
    }
}
```

Note that we did not convert the `ResolvedEvent` back to your DomainEvent class, but you can inject your MessageTransformer and do this if you want to. We also handled a single event type ('user-registered').
