import 'package:event_bus/event_bus.dart';

/// The global [EventBus] object.
EventBus eventBus = EventBus();

/// Event A.
class ClickDrawerEvent {
  bool clicked;

  ClickDrawerEvent(this.clicked);
}
