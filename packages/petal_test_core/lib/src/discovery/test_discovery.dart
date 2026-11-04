import 'dart:mirrors';

import 'package:petal_test_annotations/petal_test_annotations.dart';

import 'discovered_suite.dart';

/// Reads metadata without constructing instances or executing test methods.
class TestDiscovery {
  DiscoveredSuite discover(ClassMirror type) { 
    final tests = <DiscoveredTest>[];
    final hooks = <Type, MethodMirror>{};

    for (final method in type.instanceMembers.values) {
      if (method.isOperator || !method.isRegularMethod) continue;

      final beforeAll = _annotation<BeforeAll>(method);
      final afterAll = _annotation<AfterAll>(method);
      final beforeEach = _annotation<BeforeEach>(method);
      final afterEach = _annotation<AfterEach>(method);

      final annotations = <Type>{
        if (beforeAll != null) BeforeAll,
        if (afterAll != null) AfterAll,
        if (beforeEach != null) BeforeEach,
        if (afterEach != null) AfterEach,
      };

      for (final type in annotations) {
        if (hooks.containsKey(type)) {
          throw FormatException('Multiple methods annotated with $type.');
        }

        _validateArguments(method, const []);
        hooks[type] = method;
      }

      final test = _annotation<Test>(method);
      final repeated = _annotation<RepeatedTest>(method);
      final parameterized = _annotation<ParameterizedTest>(method);
      if (test == null && repeated == null && parameterized == null) continue;

      final displayName = _annotation<DisplayName>(method);
      final disabled = _annotation<Disabled>(method);
      final only = _annotation<Only>(method);
      final source = _annotation<ValueSource>(method);

      if (repeated != null && repeated.value < 1) {
        throw FormatException('Repetition count must be positive.');
      }
      if (parameterized != null && source?.currentData == null) {
        throw FormatException('ParameterizedTest requires a ValueSource.');
      }
      if (parameterized == null && source != null) {
        throw FormatException('ValueSource requires ParameterizedTest.');
      }

      if (parameterized != null && source!.currentData!.isEmpty) {
        throw FormatException('ValueSource must not be empty.');
      }

      if ([beforeAll, afterAll, beforeEach, afterEach].where((hook) => hook != null).isNotEmpty) {
        throw FormatException('A test method cannot also be a lifecycle hook.');
      }
      if (parameterized != null && (method.parameters.length != 1 || method.parameters.single.isNamed)) {
        throw FormatException('Simple parameterized tests require one positional parameter.');
      }

      final argumentSets = <List<Object?>>[];

      if (parameterized != null) {
        argumentSets.addAll(source!.currentData!.map<List<Object?>>((value) => [value]).toList());
      }

      if (parameterized == null) {
        _validateArguments(method, const []);
      }

      for (final arguments in argumentSets) {
        _validateArguments(method, arguments);
      }

      tests.add(DiscoveredTest(
        method: method,
        displayName: displayName?.displayName ?? MirrorSystem.getName(method.simpleName),
        disabled: disabled != null,
        only: only != null,
        repetitions: repeated?.value ?? 1,
        argumentSets: argumentSets,
      ));
    }

    return DiscoveredSuite(
      type: type,
      tests: tests,
      beforeAll: hooks[BeforeAll],
      afterAll: hooks[AfterAll],
      beforeEach: hooks[BeforeEach],
      afterEach: hooks[AfterEach],
    );
  }

  void _validateArguments(MethodMirror method, List<Object?> arguments) {
    final positional = method.parameters.where((parameter) => !parameter.isNamed).toList();
    final requiredCount = positional.where((parameter) => !parameter.isOptional).length;
    if (arguments.length < requiredCount || arguments.length > positional.length || method.parameters.any((parameter) => parameter.isNamed && !parameter.isOptional)) {
      throw FormatException('Invalid arguments for ${MirrorSystem.getName(method.simpleName)}.');
    }
    for (var index = 0; index < arguments.length; index++) {
      if (!reflect(arguments[index]).type.isSubtypeOf(positional[index].type)) {
        throw FormatException('ValueSource type mismatch for ${MirrorSystem.getName(method.simpleName)}.');
      }
    }
  }

  T? _annotation<T>(MethodMirror method) {
    final matches = method.metadata
        .map((metadata) => metadata.reflectee)
        .whereType<T>()
        .toList();
    if (matches.length > 1) {
      throw FormatException(
        'Duplicate $T annotation on ${MirrorSystem.getName(method.simpleName)}.',
      );
    }
    return matches.isEmpty ? null : matches.single;
  }
}
