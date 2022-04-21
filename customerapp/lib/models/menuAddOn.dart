import 'menuAddOnOption.dart';

class MenuAddOn {
  int menuAddOnId;
  String menuAddOnName;
  String subtitle;
  String note;
  bool isMulti;
  bool isActive;
  int index;
  int storeMenuId;
  List<MenuAddOnOption> menuAddOnOptions;

  MenuAddOn({
    this.menuAddOnId,
    this.menuAddOnName,
    this.subtitle,
    this.note,
    this.isMulti,
    this.isActive,
    this.index,
    this.menuAddOnOptions,
    this.storeMenuId,
  });

  MenuAddOn.fromJson(Map<String, dynamic> json) {
    menuAddOnId = json['menuAddOnId'];
    storeMenuId = json['storeMenuId'];
    menuAddOnName = json['menuAddOnName'];
    subtitle = json['subtitle'];
    note = json['note'];
    isMulti = json['isMulti'];
    isActive = json['isActive'];
    index = json['index'];
    menuAddOnOptions = json['menuAddOnOptions'] == null
        ? null
        : new List<MenuAddOnOption>.from(
            json["menuAddOnOptions"].map((x) => MenuAddOnOption.fromJson(x)));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['menuAddOnId'] = this.menuAddOnId;
    data['menuAddOnName'] = this.menuAddOnName;
    data['subtitle'] = this.subtitle;
    data['note'] = this.note;
    data['isMulti'] = this.isMulti;
    data['isActive'] = this.isActive;
    data['index'] = this.index;
    data['storeMenuId'] = this.storeMenuId;
    data['menuAddOnOptions'] =
        this.menuAddOnOptions.map((x) => x.toJson()).toList();
    return data;
  }
}
