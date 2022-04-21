import 'package:vplus/models/userPaymentMethod.dart';

class User {
  String name;
  String mobile;
  String email;
  String address;
  int id;
  String api_token;
  String username;
  List<dynamic> role_name;
  int userId;
  int driverId;
  UserPaymentMethod userPaymentMethod;

  User(
      {this.name,
      this.mobile,
      this.email,
      this.address,
      this.id,
      this.api_token,
      this.username,
      this.role_name,
      this.userId,
      this.userPaymentMethod,
      this.driverId});

  User.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    mobile = json['mobile'];
    email = json['email'];
    address = json['address'];
    id = json['id'];
    api_token = json['token'];
    username = json['userName'];
    role_name = json['roleNames'];
    userId = json['userId'] ?? json['user']['userId'];
    userPaymentMethod = json['userPaymentMethod'] != null
        ? new UserPaymentMethod.fromJson(json['userPaymentMethod'])
        : null;
    driverId = json['driverId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['mobile'] = this.mobile;
    data['email'] = this.email;
    data['address'] = this.address;
    data['id'] = this.id;
    data['token'] = this.api_token;
    data['userName'] = this.username;
    data['roleNames'] = this.role_name;
    data['userId'] = this.userId;
    if (this.userPaymentMethod != null) {
      data['userPaymentMethod'] = this.userPaymentMethod.toJson();
    }
    data['driverId'] = this.driverId;
    return data;
  }
}
