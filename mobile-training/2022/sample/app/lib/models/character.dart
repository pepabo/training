class Character {
  final int? id;
  final String? name;
  final String? image;
  Character._(this.id, this.name, this.image);

  factory Character.fromJson(Map<String, dynamic> json){
    final name = json['name'];
    final image = json['image'];
    return Character._(0, name, image);
  }
}