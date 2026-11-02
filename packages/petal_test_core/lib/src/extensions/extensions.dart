import 'dart:mirrors';

extension ListExtension on List<InstanceMirror> {
  InstanceMirror? firstWhereOrNull(bool Function(InstanceMirror element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
