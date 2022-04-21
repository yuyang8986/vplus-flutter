class FormValidateService {
  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (value.length > 0 && !regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
  }

  String validateEmailNotNull(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (value.isEmpty) return 'Please enter Email';
    if (value.length > 0 && !regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
  }

  String validateMobile(String value) {
    if (value.isEmpty || value == null) return null;
    Pattern pattern = r'(\(+61\)|\+61|\(0[1-9]\)|0[1-9])?( ?-?[0-9]){6,9}';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value) || value.length > 12)
      return 'Phone Number is not valid';
    else
      return null;
  }

  String validatePassword(String value) {
    if (value.isEmpty) return "Password cannot be empty";

    if (value.length < 7 || value.length > 20)
      return "Password should be at least 7 characters and less than 20 characters";
    else
      return null;
  }
}
