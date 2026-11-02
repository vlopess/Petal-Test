enum TestStatus { passed, failed, error, skipped, disabled }

enum TestPhase {
  construction,
  beforeAll,
  beforeEach,
  test,
  afterEach,
  afterAll
}

class TestFailure implements Exception {
  final String message;
  const TestFailure(this.message);
  @override
  String toString() => 'TestFailure: $message';
}

class TestIssue {
  final TestPhase phase;
  final Object error;
  final StackTrace stackTrace;
  const TestIssue(this.phase, this.error, this.stackTrace);
}

class TestResult {
  final String name;
  final TestStatus status;
  final Duration duration;
  final List<TestIssue> issues;
  final String? reason;
  TestResult(
      {required this.name,
      required this.status,
      this.duration = Duration.zero,
      this.issues = const [],
      this.reason});
}

class SuiteResult {
  final String name;
  final List<TestResult> tests;
  final List<TestIssue> issues;
  final Duration duration;
  SuiteResult(
      {required this.name,
      required this.tests,
      required this.duration,
      required this.issues});

  int count(TestStatus status) => tests.where((test) => test.status == status).length;
  bool get successful => issues.isEmpty && count(TestStatus.failed) == 0 && count(TestStatus.error) == 0;
  int get exitCode => successful ? 0 : 1;
}
