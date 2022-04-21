import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/campaign.dart';
import 'package:vplus_merchant_app/providers/campaign_provider.dart';
import 'package:vplus_merchant_app/styles/color.dart';
import 'package:vplus_merchant_app/widgets/components.dart';

class CampaignListTile extends StatelessWidget {
  final Campaign campaign;
  CampaignListTile({this.campaign});
  @override
  Widget build(BuildContext context) {
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(campaign.campaignName,
                  style: GoogleFonts.lato(
                      fontSize: SizeHelper.textMultiplier * 2.5)),
              Text("status: ${campaign.isActive ? "active" : "not active"}",
                  style: GoogleFonts.lato(
                      fontSize: SizeHelper.textMultiplier * 2.5)),

              // Text(
              //     "Campaign start time: ${DateTimeHelper.parseDateTimeToDateHHMM(campaign.validFromUtc.toLocal())}",
              //     style: GoogleFonts.lato()),
              // Text(
              //     "Campaign end time: ${DateTimeHelper.parseDateTimeToDateHHMM(campaign.validToUtc.toLocal())}",
              //     style: GoogleFonts.lato()),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: SizeHelper.widthMultiplier * 28,
                child: RoundedSelectButton(
                  campaign.isAllowGlobalPromo ? "remove promo" : "enable promo",
                  () async {
                    await Provider.of<CampaignProvider>(context, listen: false)
                        .setCampaignUsePromoRate(context, campaign.campaignId,
                            !campaign.isAllowGlobalPromo);
                  },
                  backgroundColor: campaign.isAllowGlobalPromo
                      ? campaignInactiveButtonColor
                      : campaignActiveButtonColor,
                  textColor: Colors.white,
                ),
              ),
              SizedBox(
                width: SizeHelper.widthMultiplier * 28,
                child: RoundedSelectButton(
                  campaign.isActive ? "disable campaign" : "enable campaign",
                  () async {
                    Provider.of<CampaignProvider>(context, listen: false)
                        .updateCampaignStatus(
                            context, campaign.campaignId, !campaign.isActive);
                  },
                  backgroundColor: campaign.isActive
                      ? campaignInactiveButtonColor
                      : campaignActiveButtonColor,
                  textColor: Colors.white,
                ),
              ),
              RoundedSelectButton(
                "Delete",
                () async {
                  Provider.of<CampaignProvider>(context, listen: false)
                      .deleteCampaign(context, campaign.campaignId);
                },
                backgroundColor: campaignDeleteButtonColor,
                textColor: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
