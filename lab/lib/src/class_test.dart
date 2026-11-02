import 'package:petal_test_annotations/petal_test_annotations.dart';

class ClassTest {
  @BeforeAll()
  void init() {
    print("Init Test");
    print("=====================");
  }
  

  @AfterAll()
  void dispose() {
    print("Dispose Test");
    print("=====================");
  }

  @BeforeEach()
  void setUp() {
    print("Before Each Test");
    print("=====================");
  }

  @AfterEach()
  void tearDown() {
    print("=====================");
    print("After Each Test");
    print("---------------------");
  }

  @Test()
  @DisplayName(displayName: "Esse teste vai repetir várias vezes")
  @RepeatedTest(value: 3)
  @Disabled()
  void test1() {
    print('Eu sou o teste 1 e repito várias vezes');
  }

  @Test()
  @Disabled()
  @DisplayName(displayName: "Eu sou mais um teste")
  void test2() {
    print('Eu sou o teste 2.');
  }

  @Test()
  void test3() {
    print('Eu sou o teste 3.');
  }

  @Test()
  @Only()
  @ParameterizedTest()
  @ValueSource.int([1, 2, 3, 4, 5])
  void test4(int value) {
    print("Eu sou o número $value");
  }
}
