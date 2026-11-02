import 'package:petal_test_core/petal_test_core.dart';

class TerminalReporter {
  final StringSink output;
  TerminalReporter(this.output);

  void report(SuiteResult suite) {
    output.writeln('Petal Test\n\n${suite.name}');
    for (final test in suite.tests.where((element) =>
        element.status != TestStatus.disabled &&
        element.status != TestStatus.skipped)) {
      final symbol = switch (test.status) {
        TestStatus.passed => '✓',
        TestStatus.failed || TestStatus.error => '✗',
        TestStatus.disabled || TestStatus.skipped => '-',
      };
      output.writeln('  $symbol ${test.name} (${test.status.name})');
      if (test.reason != null) output.writeln('    ${test.reason}');
      for (final issue in test.issues) {
        _issue(issue);
      }
    }
    for (final issue in suite.issues) {
      _issue(issue);
    }
    output.writeln('\nTests: ${suite.tests.length}');
    for (final status in TestStatus.values) {
      output.writeln('${status.name}: ${suite.count(status)}');
    }
    output.writeln('Suite errors: ${suite.issues.length}');
    output.writeln('Duration: ${suite.duration.inMilliseconds}ms');
  }

  void _issue(TestIssue issue) {
    output.writeln('    ${issue.phase.name}: ${issue.error}');
    output.writeln(issue.stackTrace);
  }
}
