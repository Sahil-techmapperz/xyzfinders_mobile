import 'dart:io';

void main() {
  final dir = Directory('d:/xyzfinders_web/xyzfinders_mobile/lib/presentation/screens/categories');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('_detail_screen.dart'));
  
  for (var file in files) {
    String content = file.readAsStringSync();
    content = content.replaceAll(
      "key.replaceAll('_', ' ').capitalizeFirstLetter()",
      "key.replaceAll(RegExp(r'(?<=[a-z])(?=[A-Z])'), ' ').replaceAll('_', ' ').capitalizeFirstLetter()"
    );
    file.writeAsStringSync(content);
  }
  print('Done fixing camelCase in categories');
}
