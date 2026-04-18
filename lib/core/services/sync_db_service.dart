import 'dart:async';
import 'package:flutter/foundation.dart';
import 'firebase_db_service.dart';
import 'local_db_service.dart';

/// خدمة المزامنة الموحدة — تدمج بين التخزين المحلي (LocalDb) والسحابي (Firebase)
/// تضمن أن البيانات تُخزَّن محلياً فوراً وتُزامن مع Firebase
class SyncDbService<T> {
  final String collectionName;
  final T Function(Map<String, dynamic>) fromMap;
  final Map<String, dynamic> Function(T) toMap;

  late final FirebaseDbService<T> _remote;
  late final LocalDbService<T> _local;

  SyncDbService({
    required this.collectionName,
    required this.fromMap,
    required this.toMap,
  }) {
    _remote = FirebaseDbService<T>(
      collectionName: collectionName,
      fromMap: fromMap,
      toMap: toMap,
    );
    _local = LocalDbService<T>(
      entityName: collectionName,
      fromMap: fromMap,
      toMap: toMap,
    );
  }

  // ─── CRUD Operations ──────────────────────────────────────────────────────────

  /// جلب كل السجلات (من المحلي أولاً لسرعة الاستجابة)
  Future<List<T>> list() async {
    return _local.list();
  }

  /// فلتر السجلات (محلياً)
  Future<List<T>> filter(Map<String, dynamic> conditions) async {
    return _local.filter(conditions);
  }

  /// جلب سجل واحد
  Future<T?> get(String id) async {
    return _local.get(id);
  }

  /// إضافة سجل جديد (محلياً ثم سحابياً)
  Future<T> create(Map<String, dynamic> data) async {
    // 1. نقوم بالإنشاء في Firebase أولاً للحصول على الـ ID الرسمي
    final remoteItem = await _remote.create(data);
    
    // 2. نقوم بمزامنته فوراً في التخزين المحلي بنفس الـ ID
    final rawData = toMap(remoteItem);
    await _local.createWithId(rawData['id'], rawData);
    
    return remoteItem;
  }

  /// تحديث سجل (في الاثنين معاً)
  Future<T> update(String id, Map<String, dynamic> data) async {
    // تحديث محلي فوري
    final localUpdate = await _local.update(id, data);
    
    // تحديث سحابي
    try {
      await _remote.update(id, data);
    } catch (e) {
      // يمكن إضافة لوج هنا في حالة فشل التحديث السحابي (سيتم المزامنة لاحقاً عبر snapshots)
      debugPrint('Firebase update failed for $id, will sync later: $e');
    }
    
    return localUpdate;
  }

  /// حذف سجل
  Future<void> delete(String id) async {
    await _local.delete(id);
    await _remote.delete(id);
  }

  // ─── Stream Operations (Real-time Mirroring) ────────────────────────────────

  /// استماع حي مع تحديث تلقائي للتخزين المحلي
  Stream<List<T>> snapshots() {
    return _remote.snapshots().map((remoteList) {
      // نقوم بتحديث التخزين المحلي في الخلفية كلما تغيرت البيانات في Firebase
      _mirrorToLocal(remoteList);
      return remoteList;
    });
  }

  /// استماع حي بفلتر
  Stream<List<T>> snapshotsFilter(Map<String, dynamic> conditions) {
    return _remote.snapshotsFilter(conditions).map((remoteList) {
      // ملاحظة: هنا لا نقوم بتحديث التخزين المحلي بالكامل لأننا نستلم جزءاً فقط من البيانات
      // لكننا سنعتمد على snapshots() الشاملة للمزامنة الكلية
      return remoteList;
    });
  }

  /// وظيفة خاصة لمزامنة البيانات المستلمة من Firebase إلى LocalDb
  void _mirrorToLocal(List<T> items) async {
    final rawData = items.map((item) => toMap(item)).toList();
    await _local.saveRawRecords(rawData);
  }
}
