class Organization {
  int organizationId;
  String organizationName;
  String location;
  String phone;
  String email;
  String qrCodeUrl;
  bool isCOVIDSignInEnabled;
  bool isActive;

  Organization(
      {this.organizationId,
      this.organizationName,
      this.location,
      this.phone,
      this.email,
      this.qrCodeUrl,
      this.isCOVIDSignInEnabled,
      this.isActive});

  Organization.fromJson(Map<String, dynamic> json) {
    organizationId = json['organizationId'];
    organizationName = json['organizationName'];
    location = json['location'];
    phone = json['phone'];
    email = json['email'];
    qrCodeUrl = json['qrCodeUrl'];
    isCOVIDSignInEnabled = json['isCOVIDSignInEnabled'];
    isActive = json['isActive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['organizationId'] = this.organizationId;
    data['organizationName'] = this.organizationName;
    data['location'] = this.location;
    data['phone'] = this.phone;
    data['email'] = this.email;
    data['qrCodeUrl'] = this.qrCodeUrl;
    data['isCOVIDSignInEnabled'] = this.isCOVIDSignInEnabled;
    data['isActive'] = this.isActive;
    return data;
  }
}
