import 'dart:mirrors';

import 'package:petal_test_annotations/petal_test_annotations.dart';
import 'package:petal_test_core/petal_test_core.dart';
import 'package:test/test.dart' as checks;

class DiscoveryFixture {
  DiscoveryFixture() {
    throw StateError('Must not construct');
  }

  @BeforeEach()
  void setup() => throw StateError('Must not execute');

  @Test()
  @Disabled()
  @RepeatedTest(value: 3)
  @DisplayName(displayName: 'repeated')
  void repeated() {}

  @Test()
  @ParameterizedTest()
  @ValueSource.int([1, 2])
  void parameterized(int value) {}

  @Test()
  @Only()
  void plain() {}
}

class InvalidFixture {
  @ParameterizedTest()
  void missingSource(int value) {}
}

class InvalidParameterizedFixture {
  @Test()
  @ValueSource.int([1, 2])
  void missingSource(int value) {}
}

class InvalidParameterizedAmountFixture {
  @ParameterizedTest()
  @ValueSource.int([1, 2])
  void missingSource(int value1, int value2) {}
}

class InvalidParameterizedTestFixture {
  @ParameterizedTest()
  @ValueSource.int([])
  void missingSource(int value1) {}
}

class InvalidRepetitionFixture {
  @RepeatedTest(value: 0)
  void repeated() {}
}

class InvalidRepetition2Fixture {
  @RepeatedTest(value: -1)
  void repeated() {}
}

class DuplicateHookFixture {
  @BeforeEach()
  void first() {}
  @BeforeEach()
  void second() {}
}

class DuplicateHookMethodFixture {
  @BeforeEach()
  @BeforeEach()
  void first() {}
}

class DuplicateHookTestFixture {
  @Test()
  @BeforeEach()
  void second() {}
}

class NoParametersFixture {
  @ParameterizedTest()
  @ValueSource.int([1])
  void check() {}
}

class WrongSourceTypeFixture {
  @ParameterizedTest()
  @ValueSource.strings(['abc'])
  void check(int value) {}
}

class RequiredHookArgumentFixture {
  @BeforeEach()
  void setup(int value) {}
}

class RequiredTestArgumentFixture {
  @Test()
  void check(int value) {}
}

class DuplicateTestAnnotationFixture {
  @Test()
  @Test()
  void check() {}
}

class DuplicateValueSourceFixture {
  @ParameterizedTest()
  @ValueSource.int([1])
  @ValueSource.int([2])
  void check(int value) {}
}

class EmptyFixture {}

class UnannotatedFixture {
  void helper() {}
  @Test()
  void check() {}
}

class RepeatedOnlyFixture {
  @RepeatedTest(value: 2)
  void check() {}
}

class AllHooksFixture {
  @BeforeAll()
  void init() {}
  @AfterAll()
  void dispose() {}
  @BeforeEach()
  void setup() {}
  @AfterEach()
  void teardown() {}
  @Test()
  void check() {}
}

class ValueTypesFixture {
  @ParameterizedTest()
  @ValueSource.strings(['abc', 'def'])
  void strings(String value) {}
  @ParameterizedTest()
  @ValueSource.booleans([true, false])
  void booleans(bool value) {}
  @ParameterizedTest()
  @ValueSource.double([1.5, 2.5])
  void doubles(double value) {}
}

class ParentFixture {
  @BeforeEach()
  void setup() {}
  @Test()
  void inherited() {}
  @Test()
  @DisplayName(displayName: 'parent')
  void overridden() {}
  @Test()
  void removed() {}
}

class ChildFixture extends ParentFixture {
  @override
  @Test()
  @DisplayName(displayName: 'child')
  void overridden() {}
  @override
  void removed() {}
}

class DuplicateAfterEachFixture {
  @AfterEach()
  void first() {}
  @AfterEach()
  void second() {}
}

class DuplicateBeforeAllFixture {
  @BeforeAll()
  void first() {}
  @BeforeAll()
  void second() {}
}

class DuplicateAfterAllFixture {
  @AfterAll()
  void first() {}
  @AfterAll()
  void second() {}
}

void main() {
  checks.test(
    'discovery reads metadata without construction or invocation',
    () {
      final suite = TestDiscovery().discover(reflectClass(DiscoveryFixture));
      checks.expect(suite.tests, checks.hasLength(3));
      checks.expect(suite.beforeEach?.simpleName, #setup);
      final repeated = suite.tests.singleWhere(
        (t) => t.method.simpleName == #repeated,
      );
      checks.expect(repeated.disabled, checks.isTrue);
      checks.expect(repeated.repetitions, 3);
      checks.expect(repeated.displayName, 'repeated');
      final parameterized = suite.tests.singleWhere(
        (t) => t.method.simpleName == #parameterized,
      );
      checks.expect(parameterized.argumentSets, [
        [1],
        [2],
      ]);
      final plain = suite.tests.singleWhere(
        (t) => t.method.simpleName == #plain,
      );
      checks.expect(plain.only, checks.isTrue);
      checks.expect(plain.repetitions, 1);
      checks.expect(plain.argumentSets, []);
    },
  );

  checks.test('rejects parameterized tests without a source', () {
    // Source - https://stackoverflow.com/a/60288447
    // Posted by Hugo Passos
    // Retrieved 2026-11-04, License - CC BY-SA 4.0

    checks.expect(
      () => TestDiscovery().discover(reflectClass(InvalidFixture)),
      checks.throwsA(
        checks.isA<FormatException>().having(
          (error) => error.message, // The feature you want to check.
          'message', // The description of the feature.
          'ParameterizedTest requires a ValueSource.', // The error message.
        ),
      ),
    );
  });

  checks.test(
    'rejects source tests without a parameterized test annotation',
    () {
      // Source - https://stackoverflow.com/a/60288447
      // Posted by Hugo Passos
      // Retrieved 2026-11-04, License - CC BY-SA 4.0

      checks.expect(
        () =>
            TestDiscovery().discover(reflectClass(InvalidParameterizedFixture)),
        checks.throwsA(
          checks.isA<FormatException>().having(
            (error) => error.message, // The feature you want to check.
            'message', // The description of the feature.
            'ValueSource requires ParameterizedTest.', // The error message.
          ),
        ),
      );
    },
  );

  checks.test('rejects parameterized tests with two parameters', () {
    // Source - https://stackoverflow.com/a/60288447
    // Posted by Hugo Passos
    // Retrieved 2026-11-04, License - CC BY-SA 4.0

    checks.expect(
      () => TestDiscovery().discover(
        reflectClass(InvalidParameterizedAmountFixture),
      ),
      checks.throwsA(
        checks.isA<FormatException>().having(
          (error) => error.message, // The feature you want to check.
          'message', // The description of the feature.
          'Simple parameterized tests require one positional parameter.', // The error message.
        ),
      ),
    );
  });

  checks.test('rejects empty value sources', () {
    // Source - https://stackoverflow.com/a/60288447
    // Posted by Hugo Passos
    // Retrieved 2026-11-04, License - CC BY-SA 4.0

    checks.expect(
      () => TestDiscovery().discover(
        reflectClass(InvalidParameterizedTestFixture),
      ),
      checks.throwsA(
        checks.isA<FormatException>().having(
          (error) => error.message, // The feature you want to check.
          'message', // The description of the feature.
          'ValueSource must not be empty.', // The error message.
        ),
      ),
    );
  });

  checks.test('rejects repetition count equal to zero', () {
    checks.expect(
      () => TestDiscovery().discover(reflectClass(InvalidRepetitionFixture)),
      checks.throwsA(
        checks.isA<FormatException>().having(
          (error) => error.message,
          'message',
          'Repetition count must be positive.',
        ),
      ),
    );
  });

  checks.test('rejects multiple hooks of the same kind', () {
    // Source - https://stackoverflow.com/a/60288447
    // Posted by Hugo Passos
    // Retrieved 2026-11-04, License - CC BY-SA 4.0

    checks.expect(
      () => TestDiscovery().discover(reflectClass(DuplicateHookFixture)),
      checks.throwsA(
        checks.isA<FormatException>().having(
          (error) => error.message, // The feature you want to check.
          'message', // The description of the feature.
          'Multiple methods annotated with BeforeEach.', // The error message.
        ),
      ),
    );
  });

  checks.test('rejects test method with hooks', () {
    // Source - https://stackoverflow.com/a/60288447
    // Posted by Hugo Passos
    // Retrieved 2026-11-04, License - CC BY-SA 4.0

    checks.expect(
      () => TestDiscovery().discover(reflectClass(DuplicateHookTestFixture)),
      checks.throwsA(
        checks.isA<FormatException>().having(
          (error) => error.message, // The feature you want to check.
          'message', // The description of the feature.
          'A test method cannot also be a lifecycle hook.', // The error message.
        ),
      ),
    );
  });
  checks.test('rejects multiple hooks of the same kind and method', () {
    // Source - https://stackoverflow.com/a/60288447
    // Posted by Hugo Passos
    // Retrieved 2026-11-04, License - CC BY-SA 4.0

    checks.expect(
      () => TestDiscovery().discover(reflectClass(DuplicateHookMethodFixture)),
      checks.throwsA(
        checks.isA<FormatException>().having(
          (error) => error.message, // The feature you want to check.
          'message', // The description of the feature.
          'Duplicate BeforeEach annotation on first.', // The error message.
        ),
      ),
    );
  });

  checks.test('rejects negative repetition counts', () {
    checks.expect(
      () => TestDiscovery().discover(reflectClass(InvalidRepetition2Fixture)),
      checks.throwsA(
        checks.isA<FormatException>().having(
          (error) => error.message,
          'message',
          'Repetition count must be positive.',
        ),
      ),
    );
  });

  checks.test('rejects parameterized tests without parameters', () {
    checks.expect(
      () => TestDiscovery().discover(reflectClass(NoParametersFixture)),
      checks.throwsA(
        checks.isA<FormatException>().having(
          (error) => error.message,
          'message',
          'Simple parameterized tests require one positional parameter.',
        ),
      ),
    );
  });

  checks.test('rejects value sources with incompatible types', () {
    checks.expect(
      () => TestDiscovery().discover(reflectClass(WrongSourceTypeFixture)),
      checks.throwsA(
        checks.isA<FormatException>().having(
          (error) => error.message,
          'message',
          'ValueSource type mismatch for check.',
        ),
      ),
    );
  });

  checks.test('rejects hooks with required arguments', () {
    checks.expect(
      () => TestDiscovery().discover(reflectClass(RequiredHookArgumentFixture)),
      checks.throwsA(
        checks.isA<FormatException>().having(
          (error) => error.message,
          'message',
          'Invalid arguments for setup.',
        ),
      ),
    );
  });

  checks.test('rejects ordinary tests with required arguments', () {
    checks.expect(
      () => TestDiscovery().discover(reflectClass(RequiredTestArgumentFixture)),
      checks.throwsA(
        checks.isA<FormatException>().having(
          (error) => error.message,
          'message',
          'Invalid arguments for check.',
        ),
      ),
    );
  });

  checks.test('rejects duplicate Test annotations', () {
    checks.expect(
      () => TestDiscovery().discover(
        reflectClass(DuplicateTestAnnotationFixture),
      ),
      checks.throwsA(
        checks.isA<FormatException>().having(
          (error) => error.message,
          'message',
          'Duplicate Test annotation on check.',
        ),
      ),
    );
  });

  checks.test('rejects duplicate ValueSource annotations', () {
    checks.expect(
      () => TestDiscovery().discover(reflectClass(DuplicateValueSourceFixture)),
      checks.throwsA(
        checks.isA<FormatException>().having(
          (error) => error.message,
          'message',
          'Duplicate ValueSource<dynamic> annotation on check.',
        ),
      ),
    );
  });

  checks.test('rejects multiple AfterEach methods', () {
    checks.expect(
      () => TestDiscovery().discover(reflectClass(DuplicateAfterEachFixture)),
      checks.throwsA(
        checks.isA<FormatException>().having(
          (error) => error.message,
          'message',
          'Multiple methods annotated with AfterEach.',
        ),
      ),
    );
  });

  checks.test('rejects multiple BeforeAll methods', () {
    checks.expect(
      () => TestDiscovery().discover(reflectClass(DuplicateBeforeAllFixture)),
      checks.throwsA(
        checks.isA<FormatException>().having(
          (error) => error.message,
          'message',
          'Multiple methods annotated with BeforeAll.',
        ),
      ),
    );
  });

  checks.test('rejects multiple AfterAll methods', () {
    checks.expect(
      () => TestDiscovery().discover(reflectClass(DuplicateAfterAllFixture)),
      checks.throwsA(
        checks.isA<FormatException>().having(
          (error) => error.message,
          'message',
          'Multiple methods annotated with AfterAll.',
        ),
      ),
    );
  });

  checks.test('discovers an empty suite', () {
    final suite = TestDiscovery().discover(reflectClass(EmptyFixture));
    checks.expect(suite.tests, checks.isEmpty);
    checks.expect(suite.beforeAll, checks.isNull);
    checks.expect(suite.afterAll, checks.isNull);
    checks.expect(suite.beforeEach, checks.isNull);
    checks.expect(suite.afterEach, checks.isNull);
  });

  checks.test(
    'ignores unannotated methods and uses default name and repetition',
    () {
      final suite = TestDiscovery().discover(reflectClass(UnannotatedFixture));
      checks.expect(suite.tests, checks.hasLength(1));
      checks.expect(suite.tests.single.method.simpleName, #check);
      checks.expect(suite.tests.single.displayName, 'check');
      checks.expect(suite.tests.single.repetitions, 1);
      checks.expect(suite.tests.single.disabled, checks.isFalse);
      checks.expect(suite.tests.single.only, checks.isFalse);
    },
  );

  checks.test('discovers RepeatedTest without Test', () {
    final suite = TestDiscovery().discover(reflectClass(RepeatedOnlyFixture));
    checks.expect(suite.tests, checks.hasLength(1));
    checks.expect(suite.tests.single.repetitions, 2);
  });

  checks.test('assigns each lifecycle method to its field', () {
    final suite = TestDiscovery().discover(reflectClass(AllHooksFixture));
    checks.expect(suite.beforeAll?.simpleName, #init);
    checks.expect(suite.afterAll?.simpleName, #dispose);
    checks.expect(suite.beforeEach?.simpleName, #setup);
    checks.expect(suite.afterEach?.simpleName, #teardown);
    checks.expect(suite.tests, checks.hasLength(1));
  });

  checks.test('discovers typed parameter sources without Test', () {
    final suite = TestDiscovery().discover(reflectClass(ValueTypesFixture));
    checks.expect(suite.tests, checks.hasLength(3));
    final strings = suite.tests.singleWhere(
      (test) => test.method.simpleName == #strings,
    );
    final booleans = suite.tests.singleWhere(
      (test) => test.method.simpleName == #booleans,
    );
    final doubles = suite.tests.singleWhere(
      (test) => test.method.simpleName == #doubles,
    );
    checks.expect(strings.argumentSets, [
      ['abc'],
      ['def'],
    ]);
    checks.expect(booleans.argumentSets, [
      [true],
      [false],
    ]);
    checks.expect(doubles.argumentSets, [
      [1.5],
      [2.5],
    ]);
  });

  checks.test(
    'discovers inherited tests and hooks using overridden metadata',
    () {
      final suite = TestDiscovery().discover(reflectClass(ChildFixture));
      checks.expect(suite.beforeEach?.simpleName, #setup);
      checks.expect(suite.tests, checks.hasLength(2));
      checks.expect(
        suite.tests.any((test) => test.method.simpleName == #inherited),
        checks.isTrue,
      );
      checks.expect(
        suite.tests.any((test) => test.method.simpleName == #removed),
        checks.isFalse,
      );
      final overridden = suite.tests.singleWhere(
        (test) => test.method.simpleName == #overridden,
      );
      checks.expect(overridden.displayName, 'child');
    },
  );
}
