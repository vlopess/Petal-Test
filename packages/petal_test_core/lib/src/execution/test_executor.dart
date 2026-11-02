import 'dart:async';
import 'dart:mirrors';

/// Invokes exactly one method. It does not select tests or manage lifecycle.
class TestExecutor {
  Future<void> invoke(
      InstanceMirror instance, MethodMirror method, List<Object?> arguments,
      {Duration? timeout}) async {
    if (timeout != null && timeout <= Duration.zero) {
      throw ArgumentError.value(timeout, 'timeout', 'Must be positive');
    }
    final invocation = Future<void>.sync(() async {
      final returned = instance.invoke(method.simpleName, arguments).reflectee;
      if (returned is Future) await returned;
    });
    if (timeout == null) {
      await invocation;
    } else {
      await invocation.timeout(timeout);
    }
  }
}
