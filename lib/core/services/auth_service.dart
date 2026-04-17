import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import '../services/local_db_service.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/students/data/models/student_model.dart';

/// خدمة المصادقة السحابية — تستخدم FirebaseAuth
class AuthService {
  final _firebaseAuth = fb_auth.FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final LocalDbService<UserModel>? _localDb;

  AuthService({LocalDbService<UserModel>? localDb}) : _localDb = localDb;

  // ─── Session ──────────────────────────────────────────────────────────────────

  Future<bool> isAuthenticated() async {
    return _firebaseAuth.currentUser != null;
  }

  /// الاستماع لحالة تسجيل الدخول (مفيد جداً في Riverpod)
  Stream<fb_auth.User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  Future<UserModel?> me() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists || doc.data() == null) {
        // Try local cache first if firestore doc is missing or offline
        final localUser = await _localDb?.get(user.uid);
        if (localUser != null) return localUser;

        // Fallback to basic info from Auth if both missing
        return UserModel(
          id: user.uid,
          email: user.email ?? '',
          fullName: user.displayName ?? 'No Name',
          profilePicture: user.photoURL,
          createdDate: DateTime.now().toIso8601String(),
          updatedDate: DateTime.now().toIso8601String(),
        );
      }
      final userModel = UserModel.fromMap(doc.data()!);
      // Update local cache
      _localDb?.createWithId(user.uid, userModel.toMap());
      return userModel;
    } catch (_) {
      // Return local cache on error (e.g. offline)
      return await _localDb?.get(user.uid);
    }
  }

  // ─── Auth Operations ──────────────────────────────────────────────────────────

  /// تسجيل الدخول بالبريد وكلمة المرور
  Future<UserModel> login(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final dbUser = await me();
      if (dbUser == null) throw Exception('المستخدم غير موجود في قاعدة البيانات');
      return dbUser;
    } on fb_auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-email') {
        throw Exception('البريد الإلكتروني غير صحيح أو غير مسجل');
      } else if (e.code == 'wrong-password') {
        throw Exception('كلمة المرور غير صحيحة');
      } else if (e.code == 'invalid-credential') {
        throw Exception('البريد الإلكتروني أو كلمة المرور غير صحيحة');
      } else {
        throw Exception('خطأ في تسجيل الدخول: ${e.message}');
      }
    }
  }

  /// تسجيل مسترحم جديد
  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user!;
      await user.updateDisplayName(fullName);

      final userModel = UserModel(
        id: user.uid,
        email: email,
        fullName: fullName,
        createdDate: DateTime.now().toIso8601String(),
        updatedDate: DateTime.now().toIso8601String(),
      );

      // حفظ بيانات المستخدم الإضافية في Firestore
      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
      // حفظ محلياً أيضاً
      await _localDb?.createWithId(user.uid, userModel.toMap());

      return userModel;
    } on fb_auth.FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('كلمة المرور ضعيفة جداً');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('البريد الإلكتروني مستخدم بالفعل');
      } else {
        throw Exception('خطأ في إنشاء الحساب: ${e.message}');
      }
    }
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  /// تحديث بيانات الملف الشخصي
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('لم تسجل الدخول');

    data['updated_date'] = DateTime.now().toIso8601String();
    
    await _firestore.collection('users').doc(user.uid).set(data, SetOptions(merge: true));
    
    // التحديث محلياً لضمان "Stored locally and sync immediately"
    await _localDb?.update(user.uid, data);
    
    return (await me())!;
  }

  /// رفع صورة البروفايل إلى Firebase Storage
  Future<String> uploadProfileImage(XFile image) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('لم تسجل الدخول');

    try {
      final ref = _storage.ref().child('users').child(user.uid).child('profile.jpg');
      
      // الرفع (استخدام putData للدعم الشامل للمنصات بما فيها الويب)
      final bytes = await image.readAsBytes();
      final uploadTask = await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // الحصول على الرابط
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('فشل رفع الصورة: $e');
    }
  }

  /// تسجيل الدخول عبر جوجل
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        clientId: '718868725787-bg6gge4h1uujesn7898pvglvjvrlnhtk.apps.googleusercontent.com',
      ).signIn();
      if (googleUser == null) throw Exception('تم إلغاء عملية الدخول');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final fb_auth.AuthCredential credential = fb_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final fb_auth.UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final fb_auth.User? user = userCredential.user;

      if (user == null) throw Exception('فشل تسجيل الدخول عبر جوجل');

      // نتحقق إذا كان المستخدم موجوداً مسبقاً في Firestore
      final query = await _firestore.collection('users').doc(user.uid).get();
      if (query.exists) {
        return UserModel.fromMap(query.data()!);
      }

      // إذا لم يكن موجوداً، نقوم بإنشاء حساب جديد له (التسجيل التلقائي)
      final newUser = UserModel(
        id: user.uid,
        email: user.email ?? '',
        fullName: user.displayName ?? 'محاضر جديد',
        profilePicture: user.photoURL,
        createdDate: DateTime.now().toIso8601String(),
        updatedDate: DateTime.now().toIso8601String(),
      );

      await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
      // حفظ محلياً
      await _localDb?.createWithId(user.uid, newUser.toMap());
      return newUser;
    } catch (e) {
      if (e is fb_auth.FirebaseAuthException) {
        throw Exception('خطأ Firebase: ${e.message}');
      }
      throw Exception('خطأ في الدخول عبر جوجل: $e');
    }
  }

  // ─── Student Portal Auth ──────────────────────────────────────────────────────

  /// تسجيل دخول الطالب باستخدام كود البوابة
  Future<StudentModel> loginStudent(String portalCode) async {
    try {
      // 1. تسجيل دخول مجهول أولاً لتوفير سياق Auth للقواعد
      // نتحقق أولاً إذا كان المستخدم مسجلاً بالفعل (ربما معلم)
      if (_firebaseAuth.currentUser == null) {
        try {
          await _firebaseAuth.signInAnonymously();
        } on fb_auth.FirebaseAuthException catch (e) {
          if (e.code == 'admin-restricted-operation') {
            throw Exception('عذراً، يجب تفعيل ميزة "تسجيل الدخول المجهول" (Anonymous Auth) في لوحة تحكم Firebase لإتمام دخول الطلاب.');
          }
          rethrow;
        }
      }

      // 2. البحث عن الطالب بالكود
      final query = await _firestore
          .collection('students')
          .where('portal_code', isEqualTo: portalCode)
          .where('is_active', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('كود الطالب غير صحيح أو الحساب غير نشط');
      }

      final studentData = query.docs.first.data();
      return StudentModel.fromMap(studentData);
    } on fb_auth.FirebaseAuthException catch (e) {
      throw Exception('خطأ في المصادقة: ${e.message}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('خطأ في الاتصال بالخادم: $e');
    }
  }
}
