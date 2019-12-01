---
outputFileName: snapshots.html
---

# Snapshots

One of the counter-arguments against Event-Sourcing you might heard about is that replaying events takes too much time.

Replaying 20 events for an aggregate is fast, 50 is ok, but 100 events and more become slow depending on the data of the events and the operations needed to replay them.
A DDD rule of thumb says aggregates should be kept small. Keeping that in mind you should be fine with 50 events per aggregate
in most cases.

## But my aggregates record tons of events!

If aggregate reconstitution gets slow you can add an additional layer to the system which
is capable of providing aggregate snapshots.

Choose one of the `Prooph\SnapshotStore\*` implementations and combine it with `prooph/snapshotter` to take snapshots.
Inject the snapshot store into an aggregate repository and the repository will use the snapshot store to speed up
aggregate loading.

# Provided tools

- [Prooph Snapshotter](~/old_documentation/snapshotter/index.md) - take snapshots automatically.
- [Prooph Snapshot-Store](~/old_documentation/snapshot-store/index.md) - store the snapshots somewhere.
