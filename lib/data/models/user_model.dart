class UserModel {
  final String id;
  final String name;
  final String email;
  final String? accessToken;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.accessToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      accessToken: json['accessToken'], // optional
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'accessToken': accessToken,
    };
  }
}
