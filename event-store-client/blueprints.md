---
outputFileName: index.html
---

# Event Sourcing Blueprints

In fact, we recommend not using any framework or library as part of your domain model, and building the few lines of code needed to implement a left fold yourself - partly to ensure understanding and partly to keep your domain model dependency-free.

The demo presented here is meant to be a blueprint for a homegrown implementation.

We are showing here an OOP apprach. To start with the bare minimum, we need 4 different things:

- DomainEvent
- AggregateRoot
- MessageTransformer
- AggregateRepository

A domain event represents something that happened in your application in the _past_.
A corresponding interface can look like this:

```php
<?php

declare(strict_types=1);

namespace Acme;

use Prooph\EventStoreClient\EventId;

interface DomainEvent
{
    public function eventId(): ?string;

    public function eventType(): string;

    public function toArray(): array;

    public static function from(EventId $eventId, array $data): self;
}
```

The event id is a UUID of your event, represented as string here. It can also be null, in this case we will automatically generate a UUID.

The event type is the name of the event, represented as string. This can be for example `UserRegistered` or `BlogPostPublished`.

The toArray-method returns an array representation of the internal state of the event, that we can later use to encode the event as JSON.

The from-method returns a DomainEvent from EventId and an array, we will use this to reconstruct a DomainEvent from the eventstore.

* * *

Next let's have a look at how the message transformer could look like. Its job is to convert your DomainEvents into an instance of `Prooph\EventStoreClient\EventData` and an `Prooph\EventStoreClient\ResolvedEvent` back to your DomainEvent.

```php
<?php

declare(strict_types=1);

namespace Acme;

use Acme\DomainEvent;
use Prooph\EventStoreClient\EventData;
use Prooph\EventStoreClient\EventId;
use Prooph\EventStoreClient\ResolvedEvent;
use Prooph\EventStoreClient\Util\Json;

class MessageTransformer
{
    /**
     * key = event type
     * value = event class name
     * @var array
     */
    protected $map;

    // key = event-type, value = event class name
    public function __construct(array $map)
    {
        $this->map = $map;
    }

    public function toDomainEvent(ResolvedEvent $event): DomainEvent
    {
        $event = $event->originalEvent();
        $eventType = $event->eventType();

        if (! isset($this->map[$eventType])) {
            throw new \RuntimeException(
                'No event class for type ' . $eventType . ' given'
            );
        }

        $payload = Json::decode($event->data());

        $class = $this->map[$eventType];

        return $class::from($event->eventId(), $payload);
    }

    public function toEventData(DomainEvent $event): EventData
    {
        if ($eventId = $event->eventId()) {
            $eventId = EventId::fromString($eventId);
        } else {
            $eventId = EventId::generate();
        }

        return new EventData(
            $eventId,
            $event->eventType(),
            true,
            Json::encode($event->toArray())
        );
    }
}
```

The toDomainEvent-method converts an instance of `Prooph\EventStoreClient\ResolvedEvent` to your DomainEvent.

The toEventData-method converts your DomainEvent to an instance of `Prooph\EventStoreClient\EventData`.

The constructor expects an array of key => value pairs, where key is the event type and value is the class name of your event. You can then use it like this:

```php
$transformer = new MessageTransformer([
    'user-registered' => Acme\UserRegistered::class,
    'blogpost-published' => Acme\BlogPostPublished::class, 
]);
```

* * *

Now let's look at an aggregate root base class.

```php
<?php

declare(strict_types=1);

namespace Acme;

use Prooph\EventStoreClient\ExpectedVersion;

abstract class AggregateRoot
{
    /** @var int */
    protected $expectedVersion = ExpectedVersion::EMPTY_STREAM;

    /**
     * List of events that are not committed to the EventStore
     *
     * @var DomainEvent[]
     */
    protected $recordedEvents = [];

    /**
     * We do not allow public access to __construct
     * this way we make sure that an aggregate root can only
     * be constructed by static factories
     */
    protected function __construct()
    {
    }

    public function expectedVersion(): int
    {
        return $this->expectedVersion;
    }

    public function setExpectedVersion(int $version): void
    {
        $this->expectedVersion = $version;
    }

    /**
     * Get pending events and reset stack
     *
     * @return DomainEvent[]
     */
    public function popRecordedEvents(): array
    {
        $pendingEvents = $this->recordedEvents;

        $this->recordedEvents = [];

        return $pendingEvents;
    }

    /**
     * Record an aggregate changed event
     */
    protected function recordThat(DomainEvent $event): void
    {
        $this->recordedEvents[] = $event;

        $this->apply($event);
    }

    public static function reconstituteFromHistory(array $historyEvents): self
    {
        $instance = new static();
        $instance->replay($historyEvents);

        return $instance;
    }

    /**
     * Replay past events
     *
     * @param DomainEvent[]
     */
    public function replay(array $historyEvents): void
    {
        foreach ($historyEvents as $pastEvent) {
            /** @var DomainEvent $pastEvent */
            $this->apply($pastEvent);
        }
    }

    abstract public function aggregateId(): string;

    /**
     * Apply given event
     */
    abstract protected function apply(DomainEvent $event): void;
}
```

We have a bunch of methods here, so let's have a closer look.

The expectedVersion-method returns the current expected version in the event stream. You can always set it to ExpectedVersion::ANY to disable concurrency checks, if you want to have an aggregate root without optimistic locking.

The setExpectedVersion-method sets the current expected version in the event-stream, this is later used by our aggregate repository.

The popRecordedEvents-method will extract all recorded DomainEvents so we can persist them to the eventstore.

The recordThat-method is called in your implementation of an aggregate root each time when you want to record a new domain event.

The reconstituteFromHistory-method expects an array of DomainEvents and will give you an instance of your aggregate root back.

The replay-method expected an array of events and applies them to your aggregate root.

The aggregateId-method returns your aggregate id as string. This is usually a UUID.

The apply-method applies a domain event to your aggregate root and has to be implemented by its subclasses.

A possible implementation of an apply-method could be:

```php
protected function apply(DomainEvent $event): void
{
    if ($event instanceof UserRegistered) {
        $this->aggregateId = $event->aggregateId();
        $this->username = $event->username();
        $this->email = $event->email();
        
        return;
    }
    
    // other events
}
```

* * *

Last but not least, the aggregate repository:

```php
<?php

declare(strict_types=1);

namespace Prooph\EventSourcing\Demo;

use Acme\MessageTransformer;
use Amp\Promise;
use Amp\Success;
use Prooph\EventStoreClient\EventStoreConnection;
use Prooph\EventStoreClient\ExpectedVersion;
use Prooph\EventStoreClient\Internal\Consts;
use Prooph\EventStoreClient\SliceReadStatus;
use Prooph\EventStoreClient\UserCredentials;
use function Amp\call;

class AggregateRepository
{
    /** @var EventStoreConnection */
    protected $eventStoreConnection;
    /** @var MessageTransformer */
    protected $transformer;
    /** @var string */
    protected $streamCategory;
    /** @var string */
    protected $aggregateRootClassName;
    /** @var bool */
    protected $optimisticConcurrency;

    public function __construct(
        EventStoreConnection $eventStoreConnection,
        MessageTransformer $transformer,
        string $streamCategory,
        string $aggregateRootClassName,
        bool $useOptimisticConcurrencyByDefault = true
    ) {
        $this->eventStoreConnection = $eventStoreConnection;
        $this->transformer = $transformer;
        $this->streamCategory = $streamCategory;
        $this->aggregateRootClassName = $aggregateRootClassName;
        $this->optimisticConcurrency = $useOptimisticConcurrencyByDefault;
    }

    public function saveAggregateRoot(
        AggregateRoot $aggregateRoot,
        int $expectedVersion = null,
        UserCredentials $credentials = null
    ): Promise
    {
        return call(function () use ($aggregateRoot, $expectedVersion, $credentials) {
            $domainEvents = $aggregateRoot->popRecordedEvents();
     
            if (empty($domainEvents)) {
                return new Success();
            }
            
            $aggregateId = $aggregateRoot->aggregateId();
            $stream = $this->streamCategory . '-' . $aggregateId;
            
            $eventData = [];
            
            foreach ($domainEvents as $event) {
                $eventData[] = $this->transformer->toEventData($event);
            }
            
            if (null === $expectedVersion) {
                $expectedVersion = $this->optimisticConcurrency
                    ? $aggregateRoot->expectedVersion()
                    : ExpectedVersion::ANY;
            }
            
            $writeResult = yield $this->eventStoreConnection
                ->appendToStreamAsync(
                    $stream,
                    $expectedVersion,
                    $eventData,
                    $credentials
             );
            
            $aggregateRoot->setExpectedVersion(
                $writeResult->nextExpectedVersion()
            );
            
            return new Success($aggregateRoot);
        });
    }

    /**
     * Returns null if no stream events can be found for aggregate root otherwise the reconstituted aggregate root
     * 
     * @return Promise<?object> 
     */
    public function getAggregateRoot(
        string $aggregateId,
        UserCredentials $credentials = null
    ): Promise
    {
        return call(function () use ($aggregateId, $credentials) {
            $stream = $this->streamCategory . '-' . $aggregateId;
            
            $start = 0;
            $count = Consts::MAX_READ_SIZE;
    
            do {
                $events = [];
    
                $streamEventsSlice = yield $this->eventStoreConnection
                    ->readStreamEventsForwardAsync(
                        $stream,
                        $start,
                        $count,
                        true,
                        $credentials
                    );
    
                if (! $streamEventsSlice->status()->equals(
                    SliceReadStatus::success())
                ) {
                    return null;
                }
    
                $start = $streamEventsSlice->nextEventNumber();
    
                foreach ($streamEventsSlice->events() as $event) {
                    $events[] = $this->transformer->toDomainEvent($event);
                }
    
                if (isset($aggregateRoot)) {
                    assert($aggregateRoot instanceof AggregateRoot);
                    $aggregateRoot->replay($events);
                } else {
                    $className = $this->aggregateRootClassName;
                    $aggregateRoot = $className::reconstituteFromHistory($events);
                }
            } while (! $streamEventsSlice->isEndOfStream());
    
            $aggregateRoot->setExpectedVersion(
                $streamEventsSlice->lastEventNumber()
            );
    
            return new Success($aggregateRoot);
        });
    }
}
```

Our repository has two methods: `saveAggregateRoot` and `getAggregateRoot`. If you paid attention, there is also the additional feature of disabling the optimistic concurrency checks.

If you want to publish your events to an event bus or message broker, you may want to inject this logic here or make use of an event dispatcher within the aggregate repository. The same goes for snapshots.

```php
   /**
     * Returns null if no stream events can be found for aggregate root otherwise the reconstituted aggregate root
     *
     * @return Promise<?object>
     */
    public function getAggregateRootAsOff(string $aggregateId, \DateTimeImmutable $asOff, UserCredentials $credentials = null): Promise {
        if ($asOff->getTimezone()->getName() !== 'UTC') {
            $asOff = $asOff->setTimezone(new \DateTimeZone('UTC'));
        }

        return call(function () use ($aggregateId, $credentials, $asOff) {
            $stream = $this->streamCategory . '-' . $aggregateId;
            $start = 0;
            $count = Consts::MAX_READ_SIZE;
            do {
                $events = [];
                /** @var $streamEventsSlice StreamEventsSlice */
                $streamEventsSlice = yield $this->eventStoreConnection
                    ->readStreamEventsForwardAsync(
                        $stream,
                        $start,
                        $count,
                        true,
                        $credentials
                    );

                if (!$streamEventsSlice->status()->equals(
                    SliceReadStatus::success())
                ) {
                    return null;
                }

                $start = $streamEventsSlice->nextEventNumber();

                foreach ($streamEventsSlice->events() as $event) {
                    $domainEvent = $this->transformer->toDomainEvent($event);

                    if ($domainEvent->createdAt() > $asOff) {
                        break;
                    }
                    $events[] = $this->transformer->toDomainEvent($event);
                }

                if (isset($aggregateRoot)) {
                    assert($aggregateRoot instanceof AggregateRoot);
                    $aggregateRoot->replay($events);
                } else {
                    /** @var $className AggregateRoot */
                    $className = $this->aggregateRootClassName;
                    $aggregateRoot = $className::reconstituteFromHistory($events);
                }
            } while (!$streamEventsSlice->isEndOfStream());

            if (!isset($aggregateRoot)) {
                return null;
            }

            $aggregateRoot->setExpectedVersion(
                $streamEventsSlice->lastEventNumber()
            );

            return new Success($aggregateRoot);
        });
    }
```
 
