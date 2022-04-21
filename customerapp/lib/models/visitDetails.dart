import 'package:vplus/helper/dateTimeHelper.dart';

class VisitDetails {
  int visitId;
  String visitDateTime;
  int userId;
  int organizationId;
  String organizationName;
  String organizationAddress;
  String rewardDescription;
  String createdBy;
  String createdDate;
  Null updatedBy;
  Null updatedDate;

  VisitDetails(
      {this.visitId,
      this.visitDateTime,
      this.userId,
      this.organizationId,
      this.organizationName,
      this.organizationAddress,
      this.rewardDescription,
      this.createdBy,
      this.createdDate,
      this.updatedBy,
      this.updatedDate});

  VisitDetails.fromJson(Map<String, dynamic> json) {
    visitId = json['visitId'];
    visitDateTime = json['visitDateTime'];
    userId = json['userId'];
    organizationId = json['organizationId'];
    organizationName = json['organizationName'];
    organizationAddress = json['organizationAddress'];
    rewardDescription = json['rewardDescription'];
    createdBy = json['createdBy'];
    createdDate = json['createdDate'];
    updatedBy = json['updatedBy'];
    updatedDate = json['updatedDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['visitId'] = this.visitId;
    data['visitDateTime'] = DateTimeHelper.parseDotNetDateTimeToDart(this.visitDateTime);
    data['userId'] = this.userId;
    data['organizationId'] = this.organizationId;
    data['organizationName'] = this.organizationName;
    data['organizationAddress'] = this.organizationAddress;
    data['rewardDescription'] = this.rewardDescription;
    data['createdBy'] = this.createdBy;
    data['createdDate'] = this.createdDate;
    data['updatedBy'] = this.updatedBy;
    data['updatedDate'] = this.updatedDate;
    return data;
  }
}
