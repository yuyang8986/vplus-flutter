import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vplus/helper/sizeHelper.dart';

import 'emptyView.dart';

class PrimaryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Function onTap;
  final String imageUrl;
  final bool islarge;

  PrimaryCard(
      {@required this.title,
      this.subtitle,
      @required this.onTap,
      @required this.imageUrl,
      this.islarge = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        onTap();
      },
      child: Container(
        margin: EdgeInsets.all(SizeHelper.heightMultiplier * 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: SizeHelper.heightMultiplier * (islarge ? 14 : 10),
              width: SizeHelper.widthMultiplier * (islarge ? 55 : 30),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  imageUrl ??
                      "https://vplus-merchants.s3-ap-southeast-2.amazonaws.com/default/cuisines/bubble_tea.PNG",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            VEmptyView(20),
            Text(title,
                style: GoogleFonts.lato(
                    fontStyle: FontStyle.italic, fontWeight: FontWeight.w600)),
            if (subtitle != null)
              Text(subtitle,
                  style: GoogleFonts.lato(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
