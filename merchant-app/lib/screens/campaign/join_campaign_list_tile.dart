import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/campaign.dart';
import 'package:vplus_merchant_app/providers/campaign_provider.dart';
import 'package:vplus_merchant_app/providers/current_stores_provider.dart';
import 'package:vplus_merchant_app/styles/color.dart';
import 'package:vplus_merchant_app/widgets/components.dart';

class JoinCampaignListTile extends StatefulWidget {
  final Campaign campaign;

  JoinCampaignListTile({
    this.campaign,
  });
  _JoinCampaignListTileState createState() => _JoinCampaignListTileState();
}

class _JoinCampaignListTileState extends State<JoinCampaignListTile> {
  Campaign campaign;
  int storeId;
  int joinedCampaignId;
  bool isSelectedCampaign;
  @override
  void initState() {
    super.initState();
    campaign = this.widget.campaign;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentStoresProvider>(
      builder: (ctx, p, w) {
        storeId = p.getSelectedStore.storeId;
        joinedCampaignId = p.getSelectedStore?.campaign?.campaignId;
        isSelectedCampaign = (joinedCampaignId == null)
            ? false
            : joinedCampaignId == campaign.campaignId;
        return Container(
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                  color: cornerRadiusContainerBorderColor,
                  width: SizeHelper.textMultiplier * 0.5),
              borderRadius: BorderRadius.circular(15)),
          padding: EdgeInsets.symmetric(
              vertical: SizeHelper.heightMultiplier,
              horizontal: SizeHelper.widthMultiplier * 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(campaign.campaignName,
                      style: GoogleFonts.lato(
                          fontSize: SizeHelper.textMultiplier * 2.5)),
                  RoundedSelectButton(
                    isSelectedCampaign ? "Quit" : "Join",
                    () async {
                      if (isSelectedCampaign) {
                        await Provider.of<CampaignProvider>(context,
                                listen: false)
                            .retractCampaign(
                                context, storeId, joinedCampaignId);
                      } else {
                        if (joinedCampaignId != null)
                          await Provider.of<CampaignProvider>(context,
                                  listen: false)
                              .retractCampaign(
                                  context, storeId, joinedCampaignId);
                        await Provider.of<CampaignProvider>(context,
                                listen: false)
                            .assignCampaign(
                                context, storeId, campaign.campaignId);
                      }

                      p.getSingleStoreFromAPI(context, storeId);
                    },
                    backgroundColor: isSelectedCampaign
                        ? campaignDeleteButtonColor
                        : campaignActiveButtonColor,
                    textColor: Colors.white,
                  ),
                ],
              ),
              Text("Description: ${campaign.description}",
                  textAlign: TextAlign.start,
                  style: GoogleFonts.lato(
                      fontSize: SizeHelper.textMultiplier * 2.5)),
            ],
          ),
        );
      },
    );
  }
}
