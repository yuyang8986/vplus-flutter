import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/campaign.dart';
import 'package:vplus_merchant_app/models/store.dart';
import 'package:vplus_merchant_app/providers/campaign_provider.dart';
import 'package:vplus_merchant_app/providers/current_stores_provider.dart';
import 'package:vplus_merchant_app/screens/campaign/join_campaign_list_tile.dart';
import 'package:vplus_merchant_app/widgets/customAppBar.dart';

class StoreAddCampaignScreen extends StatefulWidget {
  StoreAddCampaignScreen({Key key}) : super(key: key);
  _StoreAddCampaignScreenState createState() => _StoreAddCampaignScreenState();
}

class _StoreAddCampaignScreenState extends State<StoreAddCampaignScreen> {
  List<Campaign> allCampaigns;
  List<SpeedDialChild> fabItems;
  Store currentStore;
  @override
  void initState() {
    super.initState();
    currentStore = Provider.of<CurrentStoresProvider>(context, listen: false)
        .getSelectedStore;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Provider.of<CampaignProvider>(context, listen: false)
          .getAllCampaignsFromAPI(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        "Join Campaign",
        true,
        showLogo: false,
        context: context,
        screenPage: CustomAppBar.kitchenPage,
      ),
      body: Consumer<CampaignProvider>(
        builder: (ctx, p, w) {
          allCampaigns = p.getAllCampaigns;
          // for org admin, only show the active campaign
          allCampaigns = allCampaigns?.where((e) => e.isActive)?.toList();
          return (allCampaigns == null || allCampaigns.isEmpty)
              ? emptyCampaignListNotice()
              : campaignList();
        },
      ),
    );
  }

  Widget campaignList() {
    return Container(
      child: ListView.builder(
          itemCount: allCampaigns.length,
          itemBuilder: (context, idx) {
            return Padding(
              padding:
                  EdgeInsets.symmetric(vertical: SizeHelper.heightMultiplier),
              child: JoinCampaignListTile(
                campaign: allCampaigns[idx],
              ),
            );
          }),
    );
  }

  Widget emptyCampaignListNotice() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text("No campaign.", style: GoogleFonts.lato())],
      ),
    );
  }
}
