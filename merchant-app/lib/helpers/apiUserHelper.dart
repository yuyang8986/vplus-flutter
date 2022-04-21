import 'package:vplus_merchant_app/models/apiUser.dart';

class ApiUserHelper {
  static bool isSuperAdmin(ApiUser user) {
    return user.roleNames.contains("SuperAdmin");
  }

  static bool isAdmin(ApiUser user) {
    return (user.roleNames.contains("OrganizationAdmin") ||
        user.roleNames.contains("SuperAdmin"));
  }
}
