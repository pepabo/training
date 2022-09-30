import 'package:microposts_app/user.dart';

class Micropost {
  final int id;
  final String content;
  final String createdAtTimeAgoInWords;
  final User user;

  Micropost(
    this.id,
    this.content,
    this.createdAtTimeAgoInWords,
    this.user,
  );

  factory Micropost.fromJSON(Map<String, dynamic> json) {
    return Micropost(
      json['id'] as int,
      json['content'] as String,
      json['created_at_time_ago_in_words'] as String,
      User.fromJSON(json['user']),
    );
  }
}
