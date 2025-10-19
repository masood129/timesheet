class UserModel {
  final int userId;
  final String username;
  final String role;
  // Add more fields if needed from API response (e.g., GroupId, GroupName)

  UserModel({
    required this.userId,
    required this.username,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['UserId'] as int,
      username: json['Username'] as String,
      role: json['Role'] as String,
    );
  }
}