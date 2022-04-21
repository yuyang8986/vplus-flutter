import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/campaign.dart';
import 'package:vplus/styles/color.dart';
import 'package:vplus/widgets/custom_dialog.dart';

class StoreCampaignBadge extends StatelessWidget {
  final Campaign campaign;
  final bool isLargeSize;
  StoreCampaignBadge({Key key, this.campaign, this.isLargeSize = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        color: isLargeSize ? Colors.transparent : appThemeColor,
        padding: EdgeInsets.all(2),
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: SizeHelper.heightMultiplier * (isLargeSize ? 1.5 : 0),
          ),
          child: Text(campaign.campaignName,
              style: GoogleFonts.lato(
                  fontWeight: FontWeight.w900,
                  color: isLargeSize ? Colors.black : Colors.white,
                  fontSize:
                      SizeHelper.textMultiplier * (isLargeSize ? 2 : 1.7))),
        ),
      ),
    );
  }
}
