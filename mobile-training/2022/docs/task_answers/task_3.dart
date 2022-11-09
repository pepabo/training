void main() {
  printName("taro");
  printName("taro", lastName: "yamada");
  printName("taro", lastName: "");
  printName("taro", lastName: null);
}


void printName(String firstName, {String? lastName}){
  if (lastName?.isNotEmpty == true){
    print("Full Name: $firstName $lastName");
  } else {
    print("Fisrt Name: $firstName");
  }
}