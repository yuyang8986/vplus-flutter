import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/screenHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/providers/currentuser_provider.dart';
import 'package:vplus/screens/stores/changeUserLocationPage.dart';
import 'package:vplus/styles/color.dart';
import 'package:vplus/widgets/components.dart';
import 'package:vplus/widgets/emptyView.dart';

class UserLocationBar extends StatefulWidget {
  @override
  _UserLocationBarState createState() => _UserLocationBarState();
}

class _UserLocationBarState extends State<UserLocationBar> {
  LocationData currentUserLocation;

  // @override
  // void initState() {
  //   currentUserLocation =
  //       Provider.of<CurrentUserProvider>(context, listen: false)
  //           .getUserCurrentLocation;
  // }

  @override
  Widget build(BuildContext context) {
    String currentUserAddress =
        Provider.of<CurrentUserProvider>(context, listen: true).getUserAddress;
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: ScreenHelper.isLandScape(context)
              ? 20
              : SizeHelper.widthMultiplier * 3.2,
          vertical: ScreenHelper.isLandScape(context)
              ? 20
              : SizeHelper.heightMultiplier * 3),
      child: InkWell(
        onTap: () {
          // Navigator.push(context,
          //     MaterialPageRoute(builder: (ctx) => ChangeAddressPage()));
          if(Provider.of<CurrentUserProvider>(context, listen: false).getloggedInUser == null)
          {
            return;
          }
          pushNewScreen(context,
              screen: ChangeAddressPage(), withNavBar: false);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.location_on,
                color: appThemeColor, size: ScreenUtil().setSp(60)),
            Expanded(
              child: Container(
                child: Text(
                    (currentUserAddress == null)
                        ? "Loading Location Data...."
                        : "${currentUserAddress.trim()}",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: GoogleFonts.lato(fontWeight: FontWeight.w700)),
              ),
            ),
            WEmptyView(40),
            Icon(Icons.arrow_downward, size: ScreenUtil().setSp(40)),
          ],
        ),
      ),
    );
  }
}
