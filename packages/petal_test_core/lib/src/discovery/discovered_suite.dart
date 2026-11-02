import 'dart:mirrors';

/// Reflection-backed descriptions for the discovery prototype.
class DiscoveredTest {
  final MethodMirror method;
  final String displayName;
  final bool disabled;
  final bool only;
  final int repetitions;
  final List<List<Object?>> argumentSets;

  DiscoveredTest({
    required this.method,
    required this.displayName,
    required this.disabled,
    required this.only,
    required this.repetitions,
    required this.argumentSets,
  });
}

class DiscoveredSuite {
  final ClassMirror type;
  final List<DiscoveredTest> tests;
  final MethodMirror? beforeAll;
  final MethodMirror? afterAll;
  final MethodMirror? beforeEach;
  final MethodMirror? afterEach;

  DiscoveredSuite({
    required this.type,
    required List<DiscoveredTest> tests,
    this.beforeAll,
    this.afterAll,
    this.beforeEach,
    this.afterEach,
  }) : tests = List.unmodifiable(tests);
}
