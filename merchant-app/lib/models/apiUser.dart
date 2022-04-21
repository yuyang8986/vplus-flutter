import 'package:vplus_merchant_app/models/organization.dart';
import 'package:vplus_merchant_app/models/store.dart';

class ApiUser {
  String name;
  String mobile;
  String email;
  String address;
  int id;
  String token;
  String username;
  List<String> roleNames;
  int organizationId;
  bool isEmailVerified;
  int storeId;
  Organization organization;
  Store store;
  int storeKitchenId;

  ApiUser(
      {this.name,
      this.mobile,
      this.email,
      this.address,
      this.id,
      this.token,
      this.username,
      this.roleNames,
      this.organizationId,
      this.storeId,
      this.isEmailVerified,
      this.organization,
      this.store,
      this.storeKitchenId});

  ApiUser.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    mobile = json['mobile'];
    email = json['email'];
    address = json['address'];
    id = json['id'];
    token = json['token'];
    username = json['userName'];
    roleNames = json['roleNames'] == null
        ? null
        : new List<String>.from(json["roleNames"].map((x) => x));
    organizationId = json['organizationId'];
    storeId = json['storeId'];
    isEmailVerified = json['isEmailVerified'];
    organization = json['organization'] == null
        ? null
        : new Organization.fromJson(json['organization']);
    store = json['store'] == null ? null : new Store.fromJson(json['store']);
    storeKitchenId = json['storeKitchenId'] ?? null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['mobile'] = this.mobile;
    data['email'] = this.email;
    data['address'] = this.address;
    data['id'] = this.id;
    data['token'] = this.token;
    data['userName'] = this.username;
    data["roleNames"] = roleNames == null
        ? null
        : new List<String>.from(roleNames.map((x) => x));
    data['isEmailVerified'] = this.isEmailVerified;
    data['organizationId'] = this.organizationId;
    data['storeId'] = this.storeId;
    data['organization'] =
        this.organization == null ? null : this.organization.toJson();
    data['store'] = this.store == null ? null : this.store.toJson();
    data['storeKitchenId'] = this.storeKitchenId;
    return data;
  }
}

enum ApiUserRole {
  OrganizationAdmin,
  OrganizationStaff,
  Customer,
  StoreKitchen,
  SuperAdmin,
  Driver,
}
