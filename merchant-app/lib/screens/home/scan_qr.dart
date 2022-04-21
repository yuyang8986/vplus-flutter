import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/providers/currentuser_provider.dart';
import 'package:vplus_merchant_app/widgets/components.dart';

class ScanQRScreen extends StatefulWidget {
  @override
  _ScanQRScreenState createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  Helper hlp = Helper();

  var organizationId;

  var _saving = false;

  //var user;

  @override
  void initState() {
    super.initState();
  }

  Future _scan() async {
    String barcode = "";
    var result = await BarcodeScanner.scan();
    barcode = result.rawContent;

    if (barcode == '') {
      final snackBar = SnackBar(content: Text('Invalid Barcode'));
      Scaffold.of(context).showSnackBar(snackBar);
    } else {
      checkQRCode(barcode);
    }
  }

  void checkQRCode(url) async {
    setState(() {
      _saving = true;
    });
    // return;
    var uri = Uri.tryParse(url);

    var organizationId = uri.queryParameters['organizationId'];
    var user = Provider.of<CurrentUserProvider>(context).getloggedInUser;
    var userId = user.id;

    var response = await hlp.getData("api/Organizations/$organizationId",
        hasAuth: true, context: context);

    if (response.isSuccess && response.data != null) {
      if (response.data["organizationId"] != '') {
        var visitDate = new DateTime.now().toString();
        visitDate = visitDate.replaceAll(' ', 'T');

        //add New Rewards
        // Map<String, dynamic> newRewards = {
        //   "ValidTo": visitDate,
        //   "UserId": userId,
        //   "isUsed": true,
        //   "OrganizationId": int.parse(organizationId),
        //   "RewardDescription": "new reward",
        //   "CreatedBy": hlp.getLoggedInUser()['name'].toString()
        // };

        // var newUserReward = await hlp
        //     .postData("api/users/${userId}/reward", newRewards, hasAuth: true);
        // print("newUserReward");
        // print(newUserReward);

        //add New Visit
        Map<String, dynamic> newOrganizationRewardData = {
          "VisitDateTime": visitDate,
          "UserId": userId,
          "OrganizationId": int.parse(organizationId),
          "CreatedBy":
              Provider.of<CurrentUserProvider>(context).getloggedInUser.name
        };

        var response = await hlp.postData(
            "api/visits", newOrganizationRewardData,
            hasAuth: true, context: context);

        if (response.isSuccess && response.data != null) {
          pushNewScreenWithRouteSettings(
            context,
            settings: RouteSettings(
              name: 'DetailsPage',
              arguments: response.data,
            ),
            screen: Container(),
            withNavBar: true,
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
          setState(() {
            _saving = false;
          });
        } else {
          // hlp.showToastError('Error');
        }
      }
    } else {
      hlp.showToastError(
          '${AppLocalizationHelper.of(context).translate('ScanQrCodeFailedAlert')}');
      setState(() {
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        bottom: false,
        top: true,
        child: Scaffold(
          // appBar: CustomAppBar.getAppBar('', true, context: context,
          //     callBack: () {
          //   setState(() {
          //     Provider.of<CurrentUserProvider>(context, listen: false)
          //         .setCurrentUser(
          //             Provider.of<CurrentUserProvider>(context, listen: false)
          //                 .getloggedInUser);
          //   });
          // },
          //     argument:
          //         Provider.of<CurrentUserProvider>(context).getloggedInUser),
          backgroundColor: bodyColor,
          body: ModalProgressHUD(
            inAsyncCall: _saving,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Consumer<CurrentUserProvider>(
                    builder: (ctx, p, widget) {
                      var currentUser = p.getloggedInUser;
                      return Text(
                        currentUser.name == null
                            ? ""
                            : '  Good Day ${currentUser.name}!  ',
                        style: GoogleFonts.ubuntu(
                            textStyle: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        )),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                  // Image(
                  //   image: new AssetImage('assets/images/phone.png'),
                  //   fit: BoxFit.fitHeight,
                  //   height: 300,
                  // ),
                  Container(
                    width: 80,
                    height: 80,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      color: Color(0xff5352ec).withOpacity(.72),
                      textColor: Colors.white,
                      onPressed: () {
                        _scan();
                      },
                      child: Icon(
                        Icons.camera_alt,
                        size: 40,
                      ),
                    ),
                  ),
                  Text(
                      '${AppLocalizationHelper.of(context).translate('ClickCameraScanQrNote')}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.alata(
                          textStyle: GoogleFonts.lato(
                              fontSize: ScreenUtil().setSp(30),
                              fontWeight: FontWeight.w300))),
                ],
              ),
            ),
          ),
        ));
  }
}
