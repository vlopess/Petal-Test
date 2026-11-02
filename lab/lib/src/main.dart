import 'dart:io';
import 'dart:mirrors';

import 'package:petal_test_cli/petal_test_cli.dart';
import 'package:petal_test_core/petal_test_core.dart';

import 'class_test.dart';

Future<void> main(List<String> arguments) async {
  final suite = TestDiscovery().discover(reflectClass(ClassTest));
  final result = await TestRunner().run(suite);
  TerminalReporter(stdout).report(result);
  exitCode = result.exitCode;
}
