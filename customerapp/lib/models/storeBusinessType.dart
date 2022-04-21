class StoreBusinessType {
  int storeBusinessCatTypeId;
  int parentId;
  int catLevel;
  String catName;
  String catDescription;
  bool isActive;
  String imageUrl;
  // List storeBusinessCats;

  StoreBusinessType(
      {this.storeBusinessCatTypeId,
      this.parentId,
      this.catLevel,
      this.catName,
      this.catDescription,
      this.imageUrl,
      this.isActive});

  StoreBusinessType.fromJson(Map<String, dynamic> json) {
    storeBusinessCatTypeId = json['storeBusinessCatTypeId'];
    parentId = json['parentId'];
    catLevel = json['catLevel'];
    catName = json['catName'];
    catDescription = json['catDescription'];
    isActive = json['isActive'];
    imageUrl = json['imageUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['storeBusinessCatTypeId'] = this.storeBusinessCatTypeId;
    data['parentId'] = this.parentId;
    data['catLevel'] = this.catLevel;
    data['catName'] = this.catName;
    data['catDescription'] = this.catDescription;
    data['isActive'] = this.isActive;
    data['imageUrl'] = this.imageUrl;
    return data;
  }
}
