class Offer {
  int userRewardId;
  String rewardDescription;
  String validTo;
  bool isUsed;
  int organizationId;
  String organizationName;
  String organizationAddress;
  String organizationCurrentReward;
  int userId;
  Null createdBy;
  String createdDate;
  Null updatedBy;
  Null updatedDate;

  Offer(
      {this.userRewardId,
      this.rewardDescription,
      this.validTo,
      this.isUsed,
      this.organizationId,
      this.organizationName,
      this.organizationAddress,
      this.organizationCurrentReward,
      this.userId,
      this.createdBy,
      this.createdDate,
      this.updatedBy,
      this.updatedDate});

  Offer.fromJson(Map<String, dynamic> json) {
    userRewardId = json['userRewardId'];
    rewardDescription = json['rewardDescription'];
    validTo = json['validTo'];
    isUsed = json['isUsed'];
    organizationId = json['organizationId'];
    organizationName = json['organizationName'];
    organizationAddress = json['organizationAddress'];
    organizationCurrentReward = json['organizationCurrentReward'];
    userId = json['userId'];
    createdBy = json['createdBy'];
    createdDate = json['createdDate'];
    updatedBy = json['updatedBy'];
    updatedDate = json['updatedDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userRewardId'] = this.userRewardId;
    data['rewardDescription'] = this.rewardDescription;
    data['validTo'] = this.validTo;
    data['isUsed'] = this.isUsed;
    data['organizationId'] = this.organizationId;
    data['organizationName'] = this.organizationName;
    data['organizationAddress'] = this.organizationAddress;
    data['organizationCurrentReward'] = this.organizationCurrentReward;
    data['userId'] = this.userId;
    data['createdBy'] = this.createdBy;
    data['createdDate'] = this.createdDate;
    data['updatedBy'] = this.updatedBy;
    data['updatedDate'] = this.updatedDate;
    return data;
  }
}
