
class User {
  String userName;
  String phone;
  String email;
  String address;
  int id;
  String api_token;
  String username;
  List<dynamic> role_name;
  int userId;
  int driverId;

  User(
      {this.userName,
      this.phone,
      this.email,
      this.address,
      this.id,
      this.api_token,
      this.username,
      this.role_name,
      this.userId,
      this.driverId});

  User.fromJson(Map<String, dynamic> json) {
    userName = json['userName'];
    phone = json['phone'];
    email = json['email'];
    address = json['address'];
    id = json['id'];
    api_token = json['token'];
    username = json['userName'];
    role_name = json['roleNames'];
    userId = json['userId'] ?? json['user']['userId'];
    driverId = json['driverId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userName'] = this.userName;
    data['phone'] = this.phone;
    data['email'] = this.email;
    data['address'] = this.address;
    data['id'] = this.id;
    data['token'] = this.api_token;
    data['userName'] = this.username;
    data['roleNames'] = this.role_name;
    data['userId'] = this.userId;
    data['driverId'] = this.driverId;
    return data;
  }
}
