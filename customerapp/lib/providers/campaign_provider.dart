import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/apiHelper.dart';
import 'package:vplus/models/campaign.dart';
import 'package:vplus/models/store.dart';

class CampaignProvider extends ChangeNotifier {
  List<Campaign> activeCampaigns;
  get getAllCampaigns => activeCampaigns;

  Future<bool> getActiveCampaignsFromAPI(BuildContext context) async {
    Helper hlp = Helper();
    var response = await hlp.getData("api/Campaign/get/all",
        context: context, hasAuth: true);

    if (response.isSuccess == true && response.data != null) {
      // show only active campaigns
      activeCampaigns =
          List.from(response.data).map((e) => Campaign.fromJson(e)).toList();
      activeCampaigns = activeCampaigns.where((e) => e.isActive).toList();
      notifyListeners();
    } else {
      hlp.showToastError("Failed to get campaigns data");
    }
    return response.isSuccess;
  }

  Future<List<Store>> getAttendedStoresByCampaignId(
      BuildContext context, int campaignId) async {
    Helper hlp = Helper();
    var response = await hlp.getData("api/Campaign/get/$campaignId/stores",
        context: context, hasAuth: true);

    if (response.isSuccess == true && response.data != null) {
      List<Store> stores =
          List.from(response.data).map((e) => Store.fromJson(e)).toList();
      return stores;
    } else {
      return new List.empty();
    }
  }
}
