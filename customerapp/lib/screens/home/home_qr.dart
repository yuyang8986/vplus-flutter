import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/appLocalizationHelper.dart';
import 'package:vplus/screens/order/order_tables_init_page.dart';
import 'package:vplus/styles/color.dart';
import 'package:vplus/helper/helper.dart';
import 'package:vplus/providers/currentuser_provider.dart';
import 'package:vplus/widgets/appBar.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class HomeQR extends StatefulWidget {
  @override
  _HomeQRState createState() => _HomeQRState();
}

class _HomeQRState extends State<HomeQR> {
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

    //This is only used for testing!!!!!!!!
    barcode =
        'http://192.168.10.30:20430/#/order?storeId=113&isTakeAway=false&tableNumber=newTable';
    // barcode =
    //     'http://192.168.10.30:20430/#/order?storeId=113&isTakeAway=true&tableNumber=null';

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

    String queryString = uri.toString().split('?')[1];

    List<String> queryParameters = queryString.split('&');

    String storeId = queryParameters[0].split('=')[1];
    String isTakeAway = queryParameters[1].split('=')[1];
    String tableNumber = queryParameters[2].split('=')[1];

    // var storeId = uri.queryParameters['storeId'];
    // var isTakeAway = uri.queryParameters['isTakeAway'];
    // var tableNumber = uri.queryParameters['tableNumber'];

    print('StoreId $storeId');
    print('isTakeAway $isTakeAway');
    print('tableNumber $tableNumber');

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => OrderTablesInitPage(
                  int.parse(storeId),
                  tableNumber,
                  isTakeAway == "true" ? true : false,
                  null,
                )));

    setState(() {
      _saving = false;
    });

    // var organizationId = uri.queryParameters['organizationId'];
    // var user = Provider.of<CurrentUserProvider>(context).getloggedInUser;
    // var userId = user.id;

    // var organization = await hlp.getData(
    //   "api/Organizations/$organizationId",
    //   hasAuth: true, context: context
    // );

    // if (organization.length > 0) {
    //   if (organization["organizationId"] != '') {
    //     var visitDate = new DateTime.now().toString();
    //     visitDate = visitDate.replaceAll(' ', 'T');

    //     //add New Rewards
    //     // Map<String, dynamic> newRewards = {
    //     //   "ValidTo": visitDate,
    //     //   "UserId": userId,
    //     //   "isUsed": true,
    //     //   "OrganizationId": int.parse(organizationId),
    //     //   "RewardDescription": "new reward",
    //     //   "CreatedBy": hlp.getLoggedInUser()['name'].toString()
    //     // };

    //     // var newUserReward = await hlp
    //     //     .postData("api/users/${userId}/reward", newRewards, hasAuth: true);
    //     // print("newUserReward");
    //     // print(newUserReward);

    //     //add New Visit
    //     Map<String, dynamic> newOrganizationRewardData = {
    //       "VisitDateTime": visitDate,
    //       "UserId": userId,
    //       "OrganizationId": int.parse(organizationId),
    //       "CreatedBy": Provider.of<CurrentUserProvider>(context).getloggedInUser.name
    //     };

    //     var newOrganizationReward = await hlp
    //         .postData("api/visits", newOrganizationRewardData, hasAuth: true, context: context);

    //     if (newOrganizationReward.length > 0) {
    //       pushNewScreenWithRouteSettings(
    //         context,
    //         settings: RouteSettings(
    //           name: 'DetailsPage',
    //           arguments: newOrganizationReward,
    //         ),
    //         screen: Details(),
    //         withNavBar: true,
    //         pageTransitionAnimation: PageTransitionAnimation.cupertino,
    //       );
    //       setState(() {
    //         _saving = false;
    //       });
    //     } else {
    //       hlp.showToastError('Error');
    //     }
    //   }
    // } else {
    //   hlp.showToastError('The Code you scanned is not valid');
    //   setState(() {
    //     _saving = false;
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBar('', true, context: context, callBack: () {
        setState(() {
          Provider.of<CurrentUserProvider>(context, listen: false)
              .setCurrentUser(
                  Provider.of<CurrentUserProvider>(context, listen: false)
                      .getloggedInUser);
        });
      }, argument: Provider.of<CurrentUserProvider>(context).getloggedInUser),
      backgroundColor: bodyColor,
      body: ModalProgressHUD(
        inAsyncCall: _saving,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                Provider.of<CurrentUserProvider>(context).getloggedInUser ==
                        null
                    ? ""
                    : Provider.of<CurrentUserProvider>(context)
                                .getloggedInUser
                                .name ==
                            null
                        ? ""
                        : "${AppLocalizationHelper.of(context).translate("Greeting")}" +
                            " ${Provider.of<CurrentUserProvider>(context).getloggedInUser.name}!  ",
                style: GoogleFonts.ubuntu(
                    textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                )),
                textAlign: TextAlign.center,
              ),
              Image(
                image: new AssetImage('assets/images/phone.png'),
                fit: BoxFit.fitHeight,
                height: 300,
              ),
              Container(
                width: 80,
                height: 80,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  color: Color(0xff5352ec).withOpacity(.72),
                  textColor: Colors.white,
                  onPressed: () {
                   Helper().showToastSuccess("This service is currently not available");
                   // _scan();
                  },
                  child: Icon(
                    Icons.camera_alt,
                    size: 40,
                  ),
                ),
              ),
              Text(
                  "${AppLocalizationHelper.of(context).translate("ClickCameraScanQrNote")}",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.alata(
                      textStyle: TextStyle(
                          fontSize: ScreenUtil().setSp(30),
                          fontWeight: FontWeight.w300))),
            ],
          ),
        ),
      ),
    );
  }
}
