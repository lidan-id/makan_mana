import 'package:firebase_auth/firebase_auth.dart';

class UserData {
  final User? user;
  final bool isAdmin;

  UserData({required this.user, required this.isAdmin});
}

Future<UserData> loadUserData() async {
  final currentUser = FirebaseAuth.instance.currentUser;
  bool isAdmin = false;

  if (currentUser != null) {
    try {
      final tokenResult = await currentUser.getIdTokenResult(true);
      final role = (tokenResult.claims?['role'] ?? '').toString().toLowerCase();
      isAdmin = (role == 'admin');
    } catch (e) {
      isAdmin = false;
    }
  }

  return UserData(user: currentUser, isAdmin: isAdmin);
}
