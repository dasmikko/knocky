import 'package:knocky/models/thread.dart';
import 'package:event_bus/event_bus.dart';

/// The global [EventBus] object.
EventBus eventBus = EventBus();

class ReplyEvent {
  ThreadPost post;

  ReplyEvent(this.post);
}

class ThreadScrollToEvent {
  int index;

  ThreadScrollToEvent(this.index);
}
