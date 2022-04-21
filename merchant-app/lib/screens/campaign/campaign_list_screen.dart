import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/campaign.dart';
import 'package:vplus_merchant_app/providers/campaign_provider.dart';
import 'package:vplus_merchant_app/screens/campaign/campaign_list_tile.dart';
import 'package:vplus_merchant_app/screens/campaign/showNewCampaignDialog.dart';
import 'package:vplus_merchant_app/styles/color.dart';
import 'package:vplus_merchant_app/widgets/customAppBar.dart';

class CampaignListScreen extends StatefulWidget {
  CampaignListScreen({Key key}) : super(key: key);
  _CampaignListScreenState createState() => _CampaignListScreenState();
}

class _CampaignListScreenState extends State<CampaignListScreen> {
  List<Campaign> allCampaigns;
  List<SpeedDialChild> fabItems;
  @override
  void initState() {
    super.initState();
    fabItems = [
      SpeedDialChild(
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 3.5 * SizeHelper.imageSizeMultiplier,
        ),
        backgroundColor: appThemeColor,
        onTap: () {
          showNewCampaignDialog(context, CampaignType.Percentage);
        },
        label: "percentage",
        labelStyle: GoogleFonts.lato(
          fontWeight: FontWeight.w500,
          fontSize: 1.5 * SizeHelper.textMultiplier,
        ),
        labelBackgroundColor: Colors.white,
      ),
      SpeedDialChild(
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 3.5 * SizeHelper.imageSizeMultiplier,
        ),
        backgroundColor: appThemeColor,
        onTap: () {
          showNewCampaignDialog(context, CampaignType.Discount);
        },
        label: "discount",
        labelStyle: GoogleFonts.lato(
          fontWeight: FontWeight.w500,
          fontSize: 1.5 * SizeHelper.textMultiplier,
        ),
        labelBackgroundColor: Colors.white,
      ),
    ];
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Provider.of<CampaignProvider>(context, listen: false)
          .getAllCampaignsFromAPI(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        "Campaign manage",
        true,
        showLogo: false,
        context: context,
        screenPage: CustomAppBar.kitchenPage,
      ),
      floatingActionButton: buildSpeedDial(),
      body: Consumer<CampaignProvider>(
        builder: (ctx, p, w) {
          allCampaigns = p.getAllCampaigns;
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
              child: CampaignListTile(
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

  SpeedDial buildSpeedDial() {
    return SpeedDial(
        marginRight: (SizeHelper.isPortrait)
            ? 20
            : MediaQuery.of(context).size.width * 0.75,
        backgroundColor: appThemeColor,
        animatedIcon: AnimatedIcons.add_event,
        animatedIconTheme: IconThemeData(
            size: SizeHelper.isMobilePortrait
                ? 5 * SizeHelper.imageSizeMultiplier
                : 2.5 * SizeHelper.imageSizeMultiplier),
        curve: Curves.bounceIn,
        children: fabItems);
  }
}
