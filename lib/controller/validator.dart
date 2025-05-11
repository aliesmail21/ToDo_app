class Validators {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "First Name is required";
    }
    if (!RegExp(r'^[a-zA-Z]').hasMatch(value)) {
      return "Only letters are allowed";
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    }
    if (!value.contains("@")) {
      return "Email must contain @";
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    if (value.length < 8) {
      return "Password can't be less than 8 characters";
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return "Confirm your password";
    }
    if (value != password) {
      return "Password don't match";
    }
    return null;
  }
}
