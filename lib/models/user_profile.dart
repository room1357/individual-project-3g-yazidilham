class UserProfile {
  final String uid;
  final String email;
  final String username;
  final String fullName;

  UserProfile({
    required this.uid,
    required this.email,
    required this.username,
    required this.fullName,
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'username': username,
    'fullName': fullName,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    uid: json['uid'],
    email: json['email'],
    username: json['username'],
    fullName: json['fullName'],
  );
}
