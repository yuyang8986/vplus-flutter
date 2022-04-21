import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/models/campaign.dart';
import 'package:vplus_merchant_app/providers/current_stores_provider.dart';

class CampaignProvider extends ChangeNotifier {
  List<Campaign> allCampaigns;

  Future<bool> getAllCampaignsFromAPI(BuildContext context) async {
    Helper hlp = Helper();
    var response = await hlp.getData("api/Campaign/get/all",
        context: context, hasAuth: true);

    if (response.isSuccess == true && response.data != null) {
      // show all campaigns, including not active compaign
      allCampaigns =
          List.from(response.data).map((e) => Campaign.fromJson(e)).toList();
      notifyListeners();
    } else {
      hlp.showToastError("Failed to get campaigns data");
    }
    return response.isSuccess;
  }

  Future<bool> createCampaign(
      BuildContext context,
      String campaignName,
      String description,
      CampaignType campaignType,
      double percentage,
      double discountTarget,
      double discountOff) async {
    Helper hlp = Helper();
    Map<String, dynamic> data = {
      "campaignName": campaignName,
      "description": description,
      "campaignType": campaignType.index,
      "percentage": percentage,
      "discountTarget": discountTarget,
      "discountOff": discountOff,
    };
    var response = await hlp.putData("api/Campaign/create", data,
        context: context, hasAuth: true);

    if (response.isSuccess == true) {
      getAllCampaignsFromAPI(context); // get latest compaign list
    } else {
      hlp.showToastError("Failed to create a new campaign");
    }
    return response.isSuccess;
  }

  Future<bool> updateCampaignStatus(
      BuildContext context, int campaignId, bool campaignStatus) async {
    Helper hlp = Helper();

    var response = await hlp.putData(
        "api/Campaign/setActive/$campaignId/$campaignStatus", null,
        context: context, hasAuth: true);

    if (response.isSuccess == true) {
      getAllCampaignsFromAPI(context); // get latest compaign list
    } else {
      hlp.showToastError("Failed to update the campaign status");
    }
    return response.isSuccess;
  }

  Future<bool> deleteCampaign(
    BuildContext context,
    int campaignId,
  ) async {
    Helper hlp = Helper();

    var response = await hlp.deleteData("api/Campaign/delete/$campaignId",
        context: context, hasAuth: true);

    if (response.isSuccess == true) {
      hlp.showToastSuccess("Successfully deleted, campaign now set disabled.");
      getAllCampaignsFromAPI(context); // get latest compaign list
    } else {
      hlp.showToastError("Failed to deltete the campaign");
    }
    return response.isSuccess;
  }

  get getAllCampaigns => allCampaigns;
  Future<bool> retractCampaign(
      BuildContext context, int storeId, int campaignId) async {
    Helper hlp = Helper();

    Map<String, dynamic> data = {
      "storeId": storeId,
      "campaignId": campaignId,
    };

    var response = await hlp.putData("api/Campaign/retract", data,
        context: context, hasAuth: true);

    if (response.isSuccess == true) {
      // hlp.showToastSuccess("Successfully retract the campaign.");
      getAllCampaignsFromAPI(context); // get latest compaign list
    } else {
      // hlp.showToastError("Failed to retract the campaign");
    }
    return response.isSuccess;
  }

  Future<bool> assignCampaign(
      BuildContext context, int storeId, int campaignId) async {
    Helper hlp = Helper();

    Map<String, dynamic> data = {
      "storeId": storeId,
      "campaignId": campaignId,
    };

    var response = await hlp.putData("api/Campaign/assign", data,
        context: context, hasAuth: true);

    if (response.isSuccess == true) {
      // hlp.showToastSuccess("Successfully assign the campaign.");
      getAllCampaignsFromAPI(context); // get latest compaign list
    } else {
      // hlp.showToastError("Failed to assign the campaign");
    }
    return response.isSuccess;
  }

  Future<bool> setCampaignUsePromoRate(
      BuildContext context, int campaignId, bool allowPromoRate) async {
    Helper hlp = Helper();

    var response = await hlp.putData(
        "api/Campaign/setPromoRate/$campaignId/$allowPromoRate", null,
        context: context, hasAuth: true);
    if (response.isSuccess == true) {
      getAllCampaignsFromAPI(context); // get latest compaign list
    } else {
      // hlp.showToastError("Failed to assign the campaign");
    }
    return response.isSuccess;
  }
}
