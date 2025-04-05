// import 'package:flutter_test/flutter_test.dart';
// import 'package:littlesteps/services/auth_service.dart';
// import 'package:mockito/mockito.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class MockFirebaseAuth extends Mock implements FirebaseAuth {}

// void main() {
//   group('AuthService', () {
//     late MockFirebaseAuth mockFirebaseAuth;
//     late AuthService authService;

//     setUp(() {
//       mockFirebaseAuth = MockFirebaseAuth();
//       authService = AuthService(mockFirebaseAuth);
//     });

//     test('signInWithEmailAndPassword success', () async {
//       when(mockFirebaseAuth.signInWithEmailAndPassword(
//         email: 'test@example.com',
//         password: 'password',
//       )).thenAnswer((_) async => UserCredentialMock());

//       await authService.signInWithEmailAndPassword(
//         'test@example.com',
//         'password',
//       );
      
//       verify(mockFirebaseAuth.signInWithEmailAndPassword(
//         email: 'test@example.com',
//         password: 'password',
//       )).called(1);
//     });
//   });
// }

// class UserCredentialMock extends Mock implements UserCredential {}