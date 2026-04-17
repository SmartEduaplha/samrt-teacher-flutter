import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../features/groups/data/models/group_model.dart';
import '../../features/students/data/models/student_model.dart';

class DataImporter {
  /// Parses the JSON file and imports data (Groups and Students) into Firestore.
  static Future<void> importData(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found: $filePath');
      }

      final content = await file.readAsString();
      final data = json.decode(content) as Map<String, dynamic>;

      final firestore = FirebaseFirestore.instance;

      // 1. Import Groups
      if (data.containsKey('groups') && data['groups'] != null) {
        final groupsList = data['groups'] as List<dynamic>;
        final groupsBatch = firestore.batch();

        for (var g in groupsList) {
          final groupData = g as Map<String, dynamic>;
          
          final scheduleList = (groupData['schedule'] as List<dynamic>?)?.map((s) {
            final sm = s as Map<String, dynamic>;
            return ScheduleSlot(
              day: _translateDayToEnglish(sm['day'] as String? ?? ''),
              startTime: sm['time'] as String? ?? '16:00',
              endTime: sm['time'] as String? ?? '18:00', // Default end time
            );
          }).toList() ?? [];

          final groupModel = GroupModel(
            id: groupData['id'] as String,
            name: groupData['name'] as String? ?? 'Unnamed Group',
            type: _inferGroupType(groupData['name'] as String?),
            academicYear: groupData['grade'] as String? ?? '',
            defaultMonthlyPrice: (groupData['monthlyFee'] as num?)?.toDouble() ?? 0.0,
            groupMonthlyDiscount: 0.0, // Default for import
            schedule: scheduleList,
            notes: groupData['notes'] as String? ?? '',
            isActive: true,
            createdDate: DateTime.now().toIso8601String(),
            updatedDate: DateTime.now().toIso8601String(),
          );

          final docRef = firestore.collection('groups').doc(groupModel.id);
          groupsBatch.set(docRef, groupModel.toMap());
        }

        await groupsBatch.commit();
        debugPrint('✅ Imported ${groupsList.length} groups.');
      }

      // 2. Import Students
      if (data.containsKey('students') && data['students'] != null) {
        final studentsList = data['students'] as List<dynamic>;
        
        // Firestore batches support up to 500 writes
        int count = 0;
        WriteBatch batch = firestore.batch();
        int totalImported = 0;

        for (var s in studentsList) {
          final sData = s as Map<String, dynamic>;
          final discountData = sData['discount'] as Map<String, dynamic>?;
          double discountValue = 0.0;
          if (discountData != null && discountData['enabled'] == true) {
             discountValue = double.tryParse(discountData['value'].toString()) ?? 0.0;
          }

          final studentModel = StudentModel(
            id: sData['id'] as String,
            fullName: sData['fullName'] as String? ?? 'Unnamed',
            groupId: sData['groupId'] as String? ?? '',
            phoneNumber: sData['phone'] as String? ?? '',
            parentPhoneNumber: sData['parentPhone'] as String? ?? '',
            gender: sData['gender'] == 'female' ? 'female' : 'male',
            academicYear: sData['grade'] as String? ?? '',
            joinDate: sData['registrationDate'] as String? ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
            studentMonthlyDiscount: discountValue,
            notes: sData['notes'] as String? ?? '',
            isActive: true,
            createdDate: DateTime.now().toIso8601String(),
            updatedDate: DateTime.now().toIso8601String(),
          );

          final docRef = firestore.collection('students').doc(studentModel.id);
          batch.set(docRef, studentModel.toMap());
          
          count++;
          totalImported++;

          if (count == 400) {
            await batch.commit();
            batch = firestore.batch();
            count = 0;
          }
        }

        if (count > 0) {
          await batch.commit();
        }
        
        debugPrint('✅ Imported $totalImported students.');
      }

    } catch (e) {
      debugPrint('❌ Error during import: $e');
      rethrow;
    }
  }

  static String _translateDayToEnglish(String arabicDay) {
    switch (arabicDay) {
      case 'السبت': return 'saturday';
      case 'الأحد': return 'sunday';
      case 'الإثنين': return 'monday';
      case 'الثلاثاء': return 'tuesday';
      case 'الأربعاء': return 'wednesday';
      case 'الخميس': return 'thursday';
      case 'الجمعة': return 'friday';
      default: return 'saturday';
    }
  }

  static String _inferGroupType(String? name) {
    if (name == null) return GroupType.center.value;
    if (name.contains('سنتر')) return GroupType.center.value;
    if (name.contains('برافيت')) return GroupType.privateGroup.value;
    if (name.contains('خاص')) return GroupType.privateLesson.value;
    if (name.contains('أونلاين')) return GroupType.online.value;
    return GroupType.center.value;
  }
}
