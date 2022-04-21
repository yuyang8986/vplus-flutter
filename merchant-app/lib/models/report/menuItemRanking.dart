class MenuItemRanking {
  String menuItemName;
  int menuItemCount;
  double menuItemAmount;
  int menuItemId;

  MenuItemRanking(
      {this.menuItemName,
      this.menuItemCount,
      this.menuItemAmount,
      this.menuItemId});

  MenuItemRanking.fromJson(Map<String, dynamic> json) {
    menuItemName = json['menuItemName'];
    menuItemCount = json['menuItemCount'];
    menuItemAmount = json['menuItemAmount'];
    menuItemId = json['menuItemId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['menuItemName'] = this.menuItemName;
    data['menuItemCount'] = this.menuItemCount;
    data['menuItemAmount'] = this.menuItemAmount;
    data['menuItemId'] = this.menuItemId;
    return data;
  }
}
