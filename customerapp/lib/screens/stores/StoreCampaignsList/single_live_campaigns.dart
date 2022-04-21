import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/campaign.dart';
import 'package:vplus/models/store.dart';
import 'package:vplus/providers/campaign_provider.dart';
import 'package:vplus/screens/stores/StoreCampaignsList/storelist_campaign_listview.dart';
import 'package:vplus/screens/stores/store_campaign_badge.dart';

class SingleLiveCampaigns extends StatefulWidget {
  final Campaign campaign;
  SingleLiveCampaigns({Key key, this.campaign}) : super(key: key);
  _SingleLiveCampaignsState createState() => _SingleLiveCampaignsState();
}

class _SingleLiveCampaignsState extends State<SingleLiveCampaigns> {
  Campaign campaign;
  List<Store> campaignStores;
  @override
  void initState() {
    super.initState();
    campaign = this.widget.campaign;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      campaignStores =
          await Provider.of<CampaignProvider>(context, listen: false)
              .getAttendedStoresByCampaignId(context, campaign.campaignId);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return (campaignStores == null || campaignStores.isEmpty)
        ? noStoreNotice()
        : Container(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text("${campaign.campaignName}", style: GoogleFonts.lato()),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: SizeHelper.widthMultiplier * 4),
                child: StoreCampaignBadge(
                  campaign: campaign,
                  isLargeSize: true,
                ),
              ),
              StoreListCampaignListView(
                campaignStores: campaignStores,
              )
            ],
          ));
  }

  Widget noStoreNotice() {
    // for active campaign which no store joined, show this notice.
    return Container();
  }
}
