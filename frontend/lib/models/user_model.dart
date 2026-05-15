class UserModel {
  final String email;
  final String password;
  final String role; // 'santri', 'ustad', 'ortu'
  final String name;

  UserModel({
    required this.email,
    required this.password,
    required this.role,
    required this.name,
  });
}