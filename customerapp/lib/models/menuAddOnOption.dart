import 'extraCost.dart';

class MenuAddOnOption {
  int menuAddOnOptionId;
  String optionName;
  String optionSubtitle;
  bool isActive;
  bool isSelected; // for frontend select only
  String imageUrl;
  String image;
  ExtraCostOptionViewModel extraCostOptionViewModel;

  MenuAddOnOption({
    this.menuAddOnOptionId,
    this.optionName,
    this.optionSubtitle,
    this.isActive,
    this.isSelected,
    this.imageUrl,
    this.image,
    this.extraCostOptionViewModel,
  });

  MenuAddOnOption.fromJson(Map<String, dynamic> json) {
    menuAddOnOptionId = json['menuAddOnOptionId'];
    optionName = json['optionName'];
    optionSubtitle = json['subtitle'];
    isActive = json['isActive'];
    imageUrl = json['imageUrl'];
    image = json['imageData'];
    isSelected = isSelected ?? false; // this prop is for frontend select only
    extraCostOptionViewModel = json['extraCostOption'] != null
        ? new ExtraCostOptionViewModel.fromJson(json['extraCostOption'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['menuAddOnOptionId'] = this.menuAddOnOptionId;
    data['optionName'] = this.optionName;
    data['isActive'] = this.isActive;
    data['imageUrl'] = this.imageUrl;
    data['image'] = this.image;
    data['subtitle'] = this.optionSubtitle;
    if (this.extraCostOptionViewModel != null) {
      data['extraCostOptionViewModel'] = this.extraCostOptionViewModel.toJson();
    }
    return data;
  }
}

enum AddonOptionPriceMethodType {
  //0
  Free,

  //1
  Percentage,

  //2
  FixedAmount
}
