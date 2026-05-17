import '../models/user_model.dart';

class AuthService {
  static UserModel? _currentUser;

  static UserModel? get currentUser => _currentUser;

  static List<UserModel> dummyUsers = [
    UserModel(
      email: "santri@quranmemo.com",
      password: "santri123",
      role: "santri",
      name: "Ahmad Santri",
    ),
    UserModel(
      email: "ustad@quranmemo.com",
      password: "ustad123",
      role: "ustad",
      name: "Ustad Abdul",
    ),
    UserModel(
      email: "ortu@quranmemo.com",
      password: "ortu123",
      role: "ortu",
      name: "Bapak Santri",
    ),
  ];

  static Future<bool> login(String email, String password) async {
    try {
      final user = dummyUsers.firstWhere(
        (u) => u.email == email && u.password == password,
      );
      _currentUser = user;
      return true;
    } catch (e) {
      return false;
    }
  }

  static void logout() {
    _currentUser = null;
  }

  static bool isLoggedIn() {
    return _currentUser != null;
  }
}