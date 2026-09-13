class UserProfile {
  const UserProfile({required this.displayName, this.bio = ''});

  final String displayName;
  final String bio;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        displayName: json['displayName'] as String? ?? 'Home cook',
        bio: json['bio'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'bio': bio,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };
}
