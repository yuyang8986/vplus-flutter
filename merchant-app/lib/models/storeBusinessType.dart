class StoreBusinessType {
  int storeBusinessCatTypeId;
  int parentId;
  int catLevel;
  String catName;
  String catDescription;
  bool isActive;
  // List storeBusinessCats;

  StoreBusinessType(
      {this.storeBusinessCatTypeId,
      this.parentId,
      this.catLevel,
      this.catName,
      this.catDescription,
      this.isActive});

  StoreBusinessType.fromJson(Map<String, dynamic> json) {
    storeBusinessCatTypeId = json['storeBusinessCatTypeId'];
    parentId = json['parentId'];
    catLevel = json['catLevel'];
    catName = json['catName'];
    catDescription = json['catDescription'];
    isActive = json['isActive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['storeBusinessCatTypeId'] = this.storeBusinessCatTypeId;
    data['parentId'] = this.parentId;
    data['catLevel'] = this.catLevel;
    data['catName'] = this.catName;
    data['catDescription'] = this.catDescription;
    data['isActive'] = this.isActive;
    return data;
  }
}
