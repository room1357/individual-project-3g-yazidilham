class UserProfile {
  final String uid;
  final String email;
  final String username;
  final String fullName;
  final String? photoUrl; // 🔹 opsional: bisa null jika belum ada foto

  UserProfile({
    required this.uid,
    required this.email,
    required this.username,
    required this.fullName,
    this.photoUrl, // 🔹 parameter opsional
  });

  /// Konversi ke JSON
  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'username': username,
    'fullName': fullName,
    'photoUrl': photoUrl ?? '', // 🔹 default kosong
  };

  /// Buat instance dari JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    uid: json['uid'] ?? '',
    email: json['email'] ?? '',
    username: json['username'] ?? '',
    fullName: json['fullName'] ?? '',
    photoUrl: json['photoUrl'], // 🔹 aman meski null
  );
}
