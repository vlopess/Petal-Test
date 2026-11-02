import 'dart:mirrors';

import '../discovery/discovered_suite.dart';
import '../lifecycle/lifecycle_manager.dart';
import '../model/test_result.dart';
import 'test_execution.dart';
import 'test_executor.dart';

class TestRunner {
  final LifecycleManager lifecycle;
  TestRunner({LifecycleManager? lifecycle})
      : lifecycle = lifecycle ?? LifecycleManager(TestExecutor());

  List<TestExecution> plan(DiscoveredSuite suite) {
    final executions = <TestExecution>[];

    for (final test in suite.tests) {
      for (var parameter = 0;
          parameter < test.argumentSets.length;
          parameter++) {
        for (var repetition = 0; repetition < test.repetitions; repetition++) {
          executions.add(
            TestExecution(
              test: test,
              arguments: test.argumentSets[parameter],
              parameterIndex: parameter,
              repetition: repetition,
            ),
          );
        }
      }
    }

    return executions;
  }

  Future<SuiteResult> run(
    DiscoveredSuite suite, {
    Duration? timeout = const Duration(seconds: 30),
  }) async {
    if (timeout != null && timeout <= Duration.zero) {
      throw ArgumentError.value(timeout, 'timeout', 'Must be positive');
    }
    final watch = Stopwatch()..start();
    final results = <TestResult>[];
    final issues = <TestIssue>[];
    final executions = plan(suite);
    final hasOnly = suite.tests.any((test) => test.only && !test.disabled);

    bool shouldRun(TestExecution item) => !item.test.disabled && (!hasOnly || item.test.only);
    final hasTestsToRun = executions.any(shouldRun);

    InstanceMirror? shared;
    TestIssue? setupIssue;
    InstanceMirror instantiate() => suite.type.newInstance(const Symbol(''), []);

    if (hasTestsToRun) {
      try {
        shared = instantiate();
        setupIssue = await lifecycle.invokeHook(
            shared, suite.beforeAll, TestPhase.beforeAll,
            timeout: timeout);
      } catch (error, stack) {
        setupIssue = TestIssue(TestPhase.construction, error, stack);
      }
      if (setupIssue != null) issues.add(setupIssue);
    }
    try {
      for (final execution in executions) {
        if (!shouldRun(execution) || setupIssue != null) {
          results.add(TestResult(
              name: execution.name,
              status: execution.test.disabled
                  ? TestStatus.disabled
                  : TestStatus.skipped,
              reason: execution.test.disabled
                  ? 'Disabled'
                  : !shouldRun(execution)
                      ? 'Filtered by Only'
                      : 'Suite setup failed'));
          continue;
        }
        results.add(await lifecycle.run(shared!, suite, execution, timeout: timeout));
      }
    } finally {
      if (shared != null) {
        final teardown = await lifecycle.invokeHook(
            shared, suite.afterAll, TestPhase.afterAll,
            timeout: timeout);
        if (teardown != null) issues.add(teardown);
      }
      watch.stop();
    }
    return SuiteResult(
        name: MirrorSystem.getName(suite.type.simpleName),
        tests: results,
        issues: issues,
        duration: watch.elapsed);
  }
}
