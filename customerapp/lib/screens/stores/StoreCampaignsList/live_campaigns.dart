import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vplus/models/campaign.dart';
import 'package:vplus/providers/campaign_provider.dart';
import 'package:vplus/screens/stores/StoreCampaignsList/single_live_campaigns.dart';

class LiveCampaigns extends StatefulWidget {
  LiveCampaigns({Key key}) : super(key: key);
  _LiveCampaignsState createState() => _LiveCampaignsState();
}

class _LiveCampaignsState extends State<LiveCampaigns> {
  List<Campaign> activeCampaigns;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Provider.of<CampaignProvider>(context, listen: false)
          .getActiveCampaignsFromAPI(context);
      activeCampaigns =
          Provider.of<CampaignProvider>(context, listen: false).getAllCampaigns;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: (activeCampaigns == null || activeCampaigns.isEmpty)
          ? emptyCampaignNotice()
          : ListView.builder(
            physics: NeverScrollableScrollPhysics() ,
              shrinkWrap: true,
              itemCount: activeCampaigns.length,
              itemBuilder: (builder, idx) {
                return SingleLiveCampaigns(campaign: activeCampaigns[idx]);
              }),
    );
  }

  Widget emptyCampaignNotice() {
    return Container();
  }
}
