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