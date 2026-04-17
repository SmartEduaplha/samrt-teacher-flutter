// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

void main() async {
  final file = File(r'C:\Users\alaaa\Downloads\Telegram Desktop\New folder\elmister_backup_2026-04-13.json');
  final content = await file.readAsString();
  final data = json.decode(content);
  print('Keys: ${data.keys}');
  if (data['students'] != null && data['students'].isNotEmpty) {
    print('Found ${data['students'].length} students');
    print('First student:');
    print(data['students'][0]);
  } else {
    print('No students found under "students" key.');
  }
}
