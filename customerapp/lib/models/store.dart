import 'package:flutter/material.dart';
import 'package:vplus/helper/DateTimeHelper.dart';
import 'package:vplus/models/campaign.dart';
import 'package:vplus/models/storeBusinessType.dart';
import 'package:vplus/models/storeMenu.dart';

class Store {
  int storeId;
  String storeName;
  String logoImage;
  String logoUrl;
  String backgroundColorHex;
  String location;
  String phone;
  String email;
  String storeCode;
  int organizationId;
  List<int> storeBusinessCatIds;
  StoreBusinessType parentCategory;
  List<StoreBusinessType> storeBusinessCategories;
  StoreMenu storeMenus;
  double taxRate;
  bool isActive;
  double distance;
  List<double> coordinate; // [lat,lng] format
  Campaign campaign;
  TimeOfDay openTime;
  TimeOfDay closeTime;
  String coverImageUrl;

  Store({
    this.storeId,
    this.storeName,
    this.logoImage,
    this.logoUrl,
    this.backgroundColorHex,
    this.location,
    this.phone,
    this.email,
    this.coverImageUrl,
    this.storeCode,
    this.organizationId,
    this.storeBusinessCatIds,
    this.parentCategory,
    this.storeBusinessCategories,
    this.storeMenus,
    this.taxRate,
    this.isActive,
    this.distance,
    this.coordinate,
    this.campaign,
    this.openTime,
    this.closeTime,
  });

  Store.fromJson(Map<String, dynamic> json) {
    storeId = json['storeId'];
    storeName = json['storeName'];
    logoImage = json['logoImage'];
    logoUrl = json['logoUrl'];
    backgroundColorHex = json['backgroundColorHex'];
    location = json['location'];
    phone = json['phone'];
    email = json['email'];
    organizationId = json['organizationId'];
    storeCode = json['storeCode'];
    taxRate = json['taxRate'];
    coverImageUrl = json['coverImageUrl'];

    parentCategory = json['parentCategory'] == null
        ? null
        : new StoreBusinessType.fromJson(json['parentCategory']);
    storeBusinessCategories = json['storeBusinessCategories'] == null
        ? null
        : new List<StoreBusinessType>.from(json['storeBusinessCategories']
            .map((e) => StoreBusinessType.fromJson(e)));
    storeBusinessCatIds = storeBusinessCategories == null
        ? null
        : new List<int>.from(
            storeBusinessCategories.map((e) => e.storeBusinessCatTypeId));
    // storeMenus = json['storeMenu'] == null
    //     ? null
    //     : new List<StoreMenu>.from(
    //         json['storeMenu'].map((e) => StoreMenu.fromJson(e)));
    storeMenus = json['storeMenu'] == null
        ? null
        : StoreMenu.fromJson(Map<String, dynamic>.from(json['storeMenu']));

    isActive = json['isActive'];
    distance = json['distance'];
    coordinate = json['coordinate'] == null
        ? null
        : [
            json['coordinate']['coordinates'][0]['y'],
            json['coordinate']['coordinates'][0]['x']
          ];
    campaign = json['campaign'] == null
        ? null
        : new Campaign.fromJson(json['campaign']);
    openTime = json['storeOpenTime'] == null
        ? null
        : new TimeOfDay.fromDateTime(
            (DateTimeHelper.parseDotNetDateTimeToDart(json['storeOpenTime']))
                .toLocal());
    closeTime = json['storeCloseTime'] == null
        ? null
        : new TimeOfDay.fromDateTime(
            (DateTimeHelper.parseDotNetDateTimeToDart(json['storeCloseTime']))
                .toLocal());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['storeId'] = this.storeId;
    data['storeName'] = this.storeName;
    data['logoImage'] = this.logoImage;
    data['logoUrl'] = this.logoUrl;
    data['backgroundColorHex'] = this.backgroundColorHex;
    data['location'] = this.location;
    data['phone'] = this.phone;
    data['email'] = this.email;
    data['organizationId'] = this.organizationId;
    data['storeCode'] = this.storeCode;
    data['taxRate'] = this.taxRate;
    data['parentCategory'] =
        parentCategory == null ? null : parentCategory.toJson();
    data['storeBusinessCategories'] = storeBusinessCategories == null
        ? null
        : new List<String>.from(storeBusinessCategories.map((e) => e.toJson()));
    data['storeBusinessCatIds'] = storeBusinessCategories != null
        ? new List<int>.from(
            storeBusinessCategories.map((e) => e.storeBusinessCatTypeId))
        : null;
    data['storeMenu'] = storeMenus == null ? null : this.storeMenus.toJson();
    data['isActive'] = this.isActive;
    data['campaign'] = this.campaign == null ? null : this.campaign.toJson();
    return data;
  }
}
