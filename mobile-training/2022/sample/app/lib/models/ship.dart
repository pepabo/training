class Ship {
  final String? name;
  final String? image;
  Ship._(this.name, this.image);

  factory Ship.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final image = json['image'];
    return Ship._(name, image);
  }
}
