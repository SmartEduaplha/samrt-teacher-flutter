import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// محرك قاعدة البيانات المحلية — يحاكي localDb.js بالكامل
/// كل entity تُخزَّن كـ JSON Array تحت مفتاح "localDb_{entityName}"
class LocalDbService<T> {
  final String entityName;
  final T Function(Map<String, dynamic>) fromMap;
  final Map<String, dynamic> Function(T) toMap;

  const LocalDbService({
    required this.entityName,
    required this.fromMap,
    required this.toMap,
  });

  String get _key => 'localDb_$entityName';

  // ─── Private Helpers ─────────────────────────────────────────────────────────

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<List<Map<String, dynamic>>> _getCollection() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final decoded = json.decode(raw) as List<dynamic>;
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveCollection(List<Map<String, dynamic>> records) async {
    final prefs = await _prefs;
    await prefs.setString(_key, json.encode(records));
  }

  String _generateId() {
    final ms = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    final us = DateTime.now().microsecond.toRadixString(36);
    return '$us$ms';
  }

  String _now() => DateTime.now().toIso8601String();

  // ─── CRUD Operations ──────────────────────────────────────────────────────────

  /// جيب كل السجلات
  Future<List<T>> list() async {
    final records = await _getCollection();
    return records.map((r) => fromMap(r)).toList();
  }

  /// فلتر بسيط — يدعم: مساواة تامة
  Future<List<T>> filter(Map<String, dynamic> conditions) async {
    final records = await _getCollection();
    final filtered = records.where((record) {
      return conditions.entries.every((entry) {
        final fieldVal = record[entry.key];
        return fieldVal == entry.value;
      });
    }).toList();
    return filtered.map((r) => fromMap(r)).toList();
  }

  /// جيب سجل واحد بالـ id
  Future<T?> get(String id) async {
    final records = await _getCollection();
    final match = records.where((r) => r['id'] == id);
    if (match.isEmpty) return null;
    return fromMap(match.first);
  }

  /// أضف سجل جديد ويرجع الكائن بعد الإضافة
  Future<T> create(Map<String, dynamic> data) async {
    final records = await _getCollection();
    final newRecord = {
      ...data,
      'id': _generateId(),
      'created_date': _now(),
      'updated_date': _now(),
    };
    records.add(newRecord);
    await _saveCollection(records);
    return fromMap(newRecord);
  }

  /// عدّل سجل موجود ويرجع الكائن المحدّث
  Future<T> update(String id, Map<String, dynamic> data) async {
    final records = await _getCollection();
    final idx = records.indexWhere((r) => r['id'] == id);
    if (idx == -1) throw Exception('[$entityName] Record #$id not found');
    records[idx] = {
      ...records[idx],
      ...data,
      'id': id,
      'updated_date': _now(),
    };
    await _saveCollection(records);
    return fromMap(records[idx]);
  }

  /// احذف سجل
  Future<void> delete(String id) async {
    final records = await _getCollection();
    records.removeWhere((r) => r['id'] == id);
    await _saveCollection(records);
  }

  /// أضف سجل يدوي مع تحديد الـ ID (للمزامنة)
  Future<T> createWithId(String id, Map<String, dynamic> data) async {
    final records = await _getCollection();
    final newRecord = {
      ...data,
      'id': id,
      'created_date': data['created_date'] ?? _now(),
      'updated_date': data['updated_date'] ?? _now(),
    };
    // استبدال إذا كان موجوداً بالفعل أو إضافة
    records.removeWhere((r) => r['id'] == id);
    records.add(newRecord);
    await _saveCollection(records);
    return fromMap(newRecord);
  }

  /// حفظ قائمة كاملة من السجلات الخام (للمزامنة مع Firebase)
  Future<void> saveRawRecords(List<Map<String, dynamic>> rawRecords) async {
    await _saveCollection(rawRecords);
  }

  /// احذف كل السجلات (للإعادة / الاختبار)
  Future<void> deleteAll() async {
    await _saveCollection([]);
  }

  /// بحث نصي في حقل معين (يحتوي على)
  Future<List<T>> search(String field, String query) async {
    final records = await _getCollection();
    final q = query.toLowerCase();
    final filtered = records.where((r) {
      final val = r[field]?.toString().toLowerCase() ?? '';
      return val.contains(q);
    }).toList();
    return filtered.map((r) => fromMap(r)).toList();
  }

  // ─── Backup / Restore ────────────────────────────────────────────────────────

  /// تصدير البيانات كـ JSON string
  Future<String> exportData() async {
    final records = await _getCollection();
    return json.encode(records);
  }

  /// استيراد بيانات من JSON string
  Future<void> importData(String jsonString) async {
    final data = json.decode(jsonString) as List<dynamic>;
    await _saveCollection(data.cast<Map<String, dynamic>>());
  }
}
