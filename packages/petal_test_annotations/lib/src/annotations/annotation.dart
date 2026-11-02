/// Annotations to Test, metadata to used to mark in methods and class as part of test.
/// 

library;


/// Before each test, petal test will execute this (SetUp)
class BeforeEach {
  const BeforeEach();
}

/// After each test, petal test will execute this (SetUp)
class AfterEach {
  const AfterEach();
}

/// Way to say to petal test that a method is a test
class Test {
  const Test();
}

/// Marks test as disable
class Disabled {
  const Disabled();
}

/// Masks test repeateble test
class RepeatedTest{
  final int value ;
  const RepeatedTest({this.value  = 1});
}

class BeforeAll {
  const BeforeAll();
}


class AfterAll {
  const AfterAll();
}

class DisplayName {
  final String displayName;
  const DisplayName({this.displayName = ''});
}

class Only {
  const Only();
}


class ValueSource<T> {
  final List<int>? ints;
  final List<double>? doubles;
  final List<bool>? booleans;
  final List<String>? strings;
  final List<T>? classes;
  final List<dynamic>? _currentData;
  List<dynamic>? get currentData => _currentData;

  const factory ValueSource.int(List<int>? ints) = ValueSource._ints;

  const ValueSource._ints(this.ints) : 
    doubles = null, 
    booleans = null, 
    strings = null, 
    classes = null,
    _currentData = ints;

  const factory ValueSource.double(List<double>? doubles) = ValueSource._doubles;

  const ValueSource._doubles(this.doubles) : 
    ints = null, 
    booleans = null, 
    strings = null, 
    classes = null,
    _currentData = doubles;

  const factory ValueSource.booleans(List<bool>? booleans) = ValueSource._booleans;

  const ValueSource._booleans(this.booleans) : 
    ints = null, 
    doubles = null, 
    strings = null, 
    classes = null,
    _currentData = booleans;

  const factory ValueSource.strings(List<String>? strings) = ValueSource._strings;

  const ValueSource._strings(this.strings) : 
    ints = null, 
    doubles = null, 
    booleans = null, 
    classes = null,
    _currentData = strings;

  const factory ValueSource.classes(List<T>? classes) = ValueSource._classes;

  const ValueSource._classes(this.classes) : 
    ints = null, 
    doubles = null, 
    booleans = null, 
    strings = null,
    _currentData = classes;
}

class ParameterizedTest {
  final String displayName;
  const ParameterizedTest({this.displayName = ''});
}