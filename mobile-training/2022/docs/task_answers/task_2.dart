void main(){
  final List<int> intList = [1, 3, 5, 7, 9];
  int sum = 0;
  intList.forEach((i) {
    sum += i;
  });
  print("合計結果: $sum");

  sum = intList.reduce((value, element) {
    return value+element;
  });
  print("合計結果: $sum");

  final List<String> strList = ["p","e","p","a","b","o"];
  String join = "";
  strList.forEach((i) {
    join = join +  i;
  });
  print("結合結果: $join");

  join = strList.reduce((value, element) {
    return value+element;
  });
  print("結合結果: $join");

}