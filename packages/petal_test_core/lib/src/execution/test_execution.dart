import '../discovery/discovered_suite.dart';

/// One concrete invocation, after parameter and repetition expansion.
class TestExecution {
  final DiscoveredTest test;
  final List<Object?> arguments;
  final int parameterIndex;
  final int repetition;
  TestExecution(
      {required this.test,
      required List<Object?> arguments,
      required this.parameterIndex,
      required this.repetition})
      : arguments = List.unmodifiable(arguments);

  String get name {
    final parameter = test.method.parameters.isNotEmpty
        ? ' [case ${parameterIndex + 1}]'
        : '';
    final repeated = test.repetitions > 1 ? ' [repeat ${repetition + 1}]' : '';
    return '${test.displayName}$parameter$repeated';
  }
}
