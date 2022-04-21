import 'package:vplus/helper/DateTimeHelper.dart';

class Campaign {
  int campaignId;
  String campaignName;
  String description;
  DateTime validFromUtc;
  DateTime validToUtc;
  CampaignType campaignType;
  double percentage;
  double discountTarget;
  double discountOff;
  bool isActive;

  Campaign(
      {this.campaignId,
      this.campaignName,
      this.description,
      this.validFromUtc,
      this.validToUtc,
      this.campaignType,
      this.percentage,
      this.discountTarget,
      this.discountOff,
      this.isActive});

  Campaign.fromJson(Map<String, dynamic> json) {
    campaignId = json['campaignId'];
    campaignName = json['campaignName'];
    description = json['description'];
    validFromUtc =
        DateTimeHelper.parseDotNetDateTimeToDart(json['validFromUtc']);
    validToUtc = DateTimeHelper.parseDotNetDateTimeToDart(json['validToUtc']);
    campaignType = CampaignType.values[json['campaignType']];
    percentage = json['percentage'];
    discountTarget = json['discountTarget'];
    discountOff = json['discountOff'];
    isActive = json['isActive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['campaignId'] = this.campaignId;
    data['campaignName'] = this.campaignName;
    data['description'] = this.description;
    data['validFromUtc'] = this.validFromUtc.toString();
    data['validToUtc'] = this.validToUtc.toString();
    data['campaignType'] = this.campaignType.index;
    data['percentage'] = this.percentage;
    data['discountTarget'] = this.discountTarget;
    data['discountOff'] = this.discountOff;
    data['isActive'] = this.isActive;
    return data;
  }
}

enum CampaignType {
  Percentage, // XX Percent Off
  Discount, // when purchase target amount, XX amount off
}
