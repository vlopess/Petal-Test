import 'dart:mirrors' show InstanceMirror, MethodMirror, reflect;

import 'package:petal_test_annotations/petal_test_annotations.dart';
import 'package:petal_test_core/src/extensions/extensions.dart';






void main(List<String> arguments) {
  final InstanceMirror reflectedClassTest = reflect(ClassTest());
  MethodMirror? setUpAnnotation;
  MethodMirror? tearDownAnnotation;
  MethodMirror? beforeAllAnnotation;
  MethodMirror? afterAllAnnotation;
  MethodMirror? onlyOneAnnotation;
  List<dynamic>? params;
  int count = 1;
  

  reflectedClassTest.type.instanceMembers.forEach((_, MethodMirror methodMirror){
    if (methodMirror.isOperator || !methodMirror.isRegularMethod) return;
  

    if (setUpAnnotation == null) {
      final BeforeEach? setUp = methodMirror.metadata
          .firstWhereOrNull((metadata) => metadata.reflectee is BeforeEach)
          ?.reflectee;
      if(setUp != null) setUpAnnotation = methodMirror;      
    }

    if (tearDownAnnotation == null) {
      final AfterEach? tearDown = methodMirror.metadata
          .firstWhereOrNull((metadata) => metadata.reflectee is AfterEach)?.reflectee;
      if(tearDown != null) tearDownAnnotation = methodMirror;      
    }


    if (beforeAllAnnotation == null) {
      final BeforeAll? beforeAll = methodMirror.metadata
          .firstWhereOrNull((metadata) => metadata.reflectee is BeforeAll)
          ?.reflectee;
      if(beforeAll != null) beforeAllAnnotation = methodMirror;      
    }

    if (afterAllAnnotation == null) {
      final AfterAll? afterAll = methodMirror.metadata
          .firstWhereOrNull((metadata) => metadata.reflectee is AfterAll)?.reflectee;
      if(afterAll != null) afterAllAnnotation = methodMirror;      
    }    

    if (onlyOneAnnotation == null) {
      final Only? onlyOne = methodMirror.metadata
          .firstWhereOrNull((metadata) => metadata.reflectee is Only)?.reflectee;

      if(onlyOne != null) {
        if(methodMirror.metadata.firstWhereOrNull((metadata) => 
                              metadata.reflectee is ParameterizedTest) != null){
          final ValueSource? data = methodMirror.metadata.firstWhereOrNull((metadata) => 
                              metadata.reflectee is ValueSource)?.reflectee;

          if(data != null) params = data.currentData;                                                             
        }

        if(methodMirror.metadata.firstWhereOrNull((metadata) => metadata.reflectee is Disabled) == null) {
          onlyOneAnnotation = methodMirror;      
        }
      }

    }     

  });


  if(beforeAllAnnotation != null) reflectedClassTest.invoke(beforeAllAnnotation!.simpleName, []);

  if (onlyOneAnnotation != null) {
    invoke(count,
     setUpAnnotation,
     reflectedClassTest,
     onlyOneAnnotation!,
     tearDownAnnotation);

  } else {
    reflectedClassTest.type.instanceMembers.forEach((_, MethodMirror methodMirror){
      if (methodMirror.isOperator || !methodMirror.isRegularMethod) return;

      final InstanceMirror? testMethod = methodMirror.metadata
          .firstWhereOrNull((metadata) => metadata.reflectee is Test);

      if(testMethod == null) return;
      
      if(methodMirror.metadata.firstWhereOrNull((metadata) => metadata.reflectee is Disabled) != null) return;

      final RepeatedTest? repeatedTestAnnotation = methodMirror.metadata.
                                                firstWhereOrNull((metadata) => metadata.reflectee is RepeatedTest)?.reflectee;

      if (repeatedTestAnnotation != null) {
        count = repeatedTestAnnotation.value;
      }

      if(methodMirror.metadata.firstWhereOrNull((metadata) => 
                          metadata.reflectee is ParameterizedTest) != null){
        final ValueSource? data = methodMirror.metadata.firstWhereOrNull((metadata) => 
                            metadata.reflectee is ValueSource)?.reflectee;
                            
        if(data != null) params = data.currentData;                                                             
      }

      final DisplayName? displayTestAnnotation = methodMirror.metadata.
                                              firstWhereOrNull((metadata) => metadata.reflectee is DisplayName)?.reflectee;

      if(displayTestAnnotation != null) print("\t${displayTestAnnotation.displayName}:\n");

      invoke(count, setUpAnnotation, reflectedClassTest, methodMirror, tearDownAnnotation, values: params);

    });
  }


  if(afterAllAnnotation != null) reflectedClassTest.invoke(afterAllAnnotation!.simpleName, []);

}

void invoke(int count, MethodMirror? setUpAnnotation, InstanceMirror reflectedClassTest, MethodMirror methodMirror, MethodMirror? tearDownAnnotation, {List<dynamic>? values}) {
  if(values != null) count = values.length;
  for (var i = 0; i < count; i++) {
    if(setUpAnnotation != null) reflectedClassTest.invoke(setUpAnnotation.simpleName, []);
    final value = values?[i];
    reflectedClassTest.invoke(
      methodMirror.simpleName,
      value != null ? [value] : [],
    );
    if(tearDownAnnotation != null) reflectedClassTest.invoke(tearDownAnnotation.simpleName, []);
  }
}

class ClassTest {

  @BeforeAll()
  void init(){
    print("Init Test");
    print("=====================");    
  }

  @AfterAll()
  void dispose(){
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
  void test1(){
    print('Eu sou o teste 1 e repito várias vezes');
  }

  @Test()
  @Disabled()
  @DisplayName(displayName: "Eu sou mais um teste")
  void test2(){
    print('Eu sou o teste 2.');
  }

  @Test()
  void test3(){
    print('Eu sou o teste 3.');
  }

  @Test()
  @ParameterizedTest()
  @ValueSource.int([1, 2, 3, 4, 5])
  void test4(int value){
    print("Eu sou o número $value");
  }
}
