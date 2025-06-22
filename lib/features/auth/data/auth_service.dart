import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> registerWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final User? user = userCredential.user;

      if (user != null) {
        await user.updateDisplayName(name);
        await user.reload();

        // إنشاء وثيقة المستخدم مع حقل fcmToken فارغ مبدئيًا
        await _firestore.collection('users').doc(user.uid).set({
          'email': email.trim(),
          'name': name,
          'fcmToken': null, // حقل فارغ لتجنب الأخطاء لاحقًا
          'createdAt': FieldValue.serverTimestamp(),
        });
        logger.i("✅ User document created for: ${user.email}");

        // تحديث رمز FCM بعد إنشاء الوثيقة
        try {
          final token = await FirebaseMessaging.instance.getToken();
          if (token != null) {
            await _firestore.collection('users').doc(user.uid).update({
              'fcmToken': token,
            });
            logger.i("✅ FCM token updated for user ${user.uid}: $token");
          } else {
            logger.w("⚠️ Failed to retrieve FCM token during registration.");
          }
        } catch (e) {
          logger.e("❌ Error updating FCM token during registration: $e");
        }

        logger.i("✅ User registered successfully: ${user.email}");
      }
      return user;
    } catch (e) {
      logger.e("❌ Registration error: $e");
      rethrow;
    }
  }

  Future<User?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final User? user = userCredential.user;
      if (user != null) {
        logger.i("✅ User logged in successfully: ${user.email}");
      }
      return user;
    } catch (e) {
      logger.e("❌ Login error: $e");
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      logger.i("✅ User logged out successfully");
    } catch (e) {
      logger.e("❌ Logout error: $e");
      rethrow;
    }
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in.');
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      await user.updatePassword(newPassword);
      logger.i("✅ Password changed successfully for user: ${user.email}");
    } catch (e) {
      logger.e("❌ Error changing password: $e");
      rethrow;
    }
  }

  User? get currentUser => _auth.currentUser;
}
