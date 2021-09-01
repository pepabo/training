class User {
  final int id;
  final String name;
  final String gravatarURL;
  final int? followingCount;
  final int? followersCount;
  final bool isCurrentUser;

  User(
    this.id,
    this.name,
    this.gravatarURL,
    this.followingCount,
    this.followersCount,
    this.isCurrentUser,
  );

  factory User.fromJSON(Map<String, dynamic> json) {
    return User(
      json['id'] as int,
      json['name'] as String,
      json['gravatar_url'] as String,
      json['following_count'] as int?,
      json['followers_count'] as int?,
      json['is_current_user'] as bool,
    );
  }
}
