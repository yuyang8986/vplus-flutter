class ExtraCostOptionViewModel {
  int extraCostOptionId;
  int extraCostType;
  double percent;
  double fixedAmount;
  int menuAddOnOptionId;

  ExtraCostOptionViewModel(
      {this.extraCostOptionId,
      this.extraCostType,
      this.percent,
      this.fixedAmount,
      this.menuAddOnOptionId});

  ExtraCostOptionViewModel.fromJson(Map<String, dynamic> json) {
    extraCostOptionId = json['extraCostOptionId'];
    extraCostType = json['extraCostType'];
    percent = json['percent'];
    fixedAmount = json['fixedAmount'];
    menuAddOnOptionId = json['menuAddOnOptionId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    //data['extraCostOptionId'] = this.extraCostOptionId;
    data['extraCostType'] = this.extraCostType;
    data['percent'] = this.percent;
    data['fixedAmount'] = this.fixedAmount;
    //data['menuAddOnOptionId'] = this.menuAddOnOptionId;
    return data;
  }
}
