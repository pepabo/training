class Validator {
  static final emailFormat = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  static String? emailValidator(String? email) {
    if (email == null) return "メールアドレスを入力してください。";

    if (email.isEmpty) {
      return "メールアドレスを入力してください。";
    }
    return emailFormat.hasMatch(email) ? null : "メールアドレスのフォーマットが間違っています。";
  }

  static bool isValidEmail(String? email) {
    if (email == null) return false;

    return emailFormat.hasMatch(email);
  }

  static String? passwordValidator(String? password) {
    if (password == null) return "パスワードを入力してください。";

    return password.isEmpty ? "パスワードを入力してください。" : null;
  }

  static bool isValidPassword(String? password) {
    if (password == null) return false;

    return password.isNotEmpty;
  }
}
