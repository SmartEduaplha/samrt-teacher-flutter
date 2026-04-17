import 'package:cloud_firestore/cloud_firestore.dart';

/// محرك قاعدة البيانات السحابية — يستخدم Firestore مع دعم الأوفلاين التلقائي
class FirebaseDbService<T> {
  final String collectionName;
  final T Function(Map<String, dynamic>) fromMap;
  final Map<String, dynamic> Function(T) toMap;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseDbService({
    required this.collectionName,
    required this.fromMap,
    required this.toMap,
  });

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(collectionName);

  String _now() => DateTime.now().toIso8601String();

  // ─── CRUD Operations ──────────────────────────────────────────────────────────

  /// جيب كل السجلات
  Future<List<T>> list() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // التأكد أن الآي دي هو الخاص بـ Firestore
      return fromMap(data);
    }).toList();
  }

  /// فلتر بسيط — يدعم: مساواة تامة
  Future<List<T>> filter(Map<String, dynamic> conditions) async {
    Query<Map<String, dynamic>> query = _collection;
    for (var entry in conditions.entries) {
      query = query.where(entry.key, isEqualTo: entry.value);
    }
    
    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return fromMap(data);
    }).toList();
  }

  /// جيب سجل واحد بالـ id
  Future<T?> get(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    final data = doc.data()!;
    data['id'] = doc.id;
    return fromMap(data);
  }

  /// أضف سجل جديد ويرجع الكائن بعد الإضافة
  Future<T> create(Map<String, dynamic> data) async {
    final docRef = _collection.doc();
    final newRecord = {
      ...data,
      'id': docRef.id,
      'created_date': _now(),
      'updated_date': _now(),
    };
    
    await docRef.set(newRecord);
    return fromMap(newRecord);
  }

  /// عدّل سجل موجود ويرجع الكائن المحدّث
  Future<T> update(String id, Map<String, dynamic> data) async {
    final updateData = {
      ...data,
      'updated_date': _now(),
    };
    
    await _collection.doc(id).update(updateData);
    final updatedDoc = await _collection.doc(id).get();
    
    final mappedData = updatedDoc.data()!;
    mappedData['id'] = id;
    
    return fromMap(mappedData);
  }

  /// احذف سجل
  Future<void> delete(String id) async {
    await _collection.doc(id).delete();
  }

  // ─── Stream Operations (Real-time) ──────────────────────────────────────────

  /// استماع حي لكل السجلات
  Stream<List<T>> snapshots() {
    return _collection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return fromMap(data);
      }).toList();
    });
  }

  /// استماع حي لسجلات بفلتر معين
  Stream<List<T>> snapshotsFilter(Map<String, dynamic> conditions) {
    Query<Map<String, dynamic>> query = _collection;
    for (var entry in conditions.entries) {
      query = query.where(entry.key, isEqualTo: entry.value);
    }
    
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return fromMap(data);
      }).toList();
    });
  }
}
