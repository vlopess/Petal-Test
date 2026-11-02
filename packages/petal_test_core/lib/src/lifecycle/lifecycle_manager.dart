import 'dart:mirrors';

import '../discovery/discovered_suite.dart';
import '../execution/test_execution.dart';
import '../execution/test_executor.dart';
import '../model/test_result.dart';

class LifecycleManager {
  final TestExecutor executor;
  const LifecycleManager(this.executor);

  Future<TestIssue?> invokeHook(
      InstanceMirror instance, MethodMirror? method, TestPhase phase,
      {Duration? timeout}) async {
    if (method == null) return null;
    try {
      await executor.invoke(instance, method, [], timeout: timeout);
      return null;
    } catch (error, stack) {
      return TestIssue(phase, error, stack);
    }
  }

  Future<TestResult> run(
      InstanceMirror instance, DiscoveredSuite suite, TestExecution execution,
      {Duration? timeout}) async {
    final watch = Stopwatch()..start();
    final issues = <TestIssue>[];
    final setup = await invokeHook(
        instance, suite.beforeEach, TestPhase.beforeEach,
        timeout: timeout);
    if (setup != null) issues.add(setup);
    try {
      if (setup == null) {
        try {
          await executor.invoke(
              instance, execution.test.method, execution.arguments,
              timeout: timeout);
        } catch (error, stack) {
          issues.add(TestIssue(TestPhase.test, error, stack));
        }
      }
    } finally {
      final teardown = await invokeHook(
          instance, suite.afterEach, TestPhase.afterEach,
          timeout: timeout);
      if (teardown != null) issues.add(teardown);
      watch.stop();
    }
    final status = issues.isEmpty
        ? TestStatus.passed
        : issues.every((issue) =>
                issue.phase == TestPhase.test &&
                (issue.error is TestFailure || issue.error is AssertionError))
            ? TestStatus.failed
            : TestStatus.error;
    return TestResult(
        name: execution.name,
        status: status,
        duration: watch.elapsed,
        issues: issues);
  }
}
