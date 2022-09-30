void main(){
  final Map<String, dynamic> json = {
    "name": "John",
    "age": 24
  };

  final user = User.fromJson(json);
  print(user.name);
  print(user.age);
}

class User {
  final String name;
  final int age;
  User._(this.name, this.age) { }

  factory User.fromJson(Map<String, dynamic>json){
    final name = json["name"];
    final age = json["age"];

    return User._(name, age);
  }
}