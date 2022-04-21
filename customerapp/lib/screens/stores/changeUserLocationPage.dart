import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/appLocalizationHelper.dart';
import 'package:vplus/helper/locationHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/userSavedAddress.dart';
import 'package:vplus/providers/currentuser_provider.dart';
import 'package:vplus/providers/groceries_item_provider.dart';
import 'package:vplus/providers/storeList_provider.dart';
import 'package:vplus/providers/user_address_provider.dart';
import 'package:vplus/screens/account/address_manage.dart';
import 'package:vplus/screens/home/home.dart';
import 'package:vplus/screens/stores/addNewUserLoctionPage.dart';
import 'package:vplus/screens/stores/storeListPage.dart';
import 'package:vplus/styles/color.dart';
import 'package:vplus/widgets/address_list_tile.dart';
import 'package:vplus/widgets/address_search.dart';
import 'package:vplus/widgets/emptyView.dart';

class ChangeAddressPage extends StatefulWidget {
  @override
  _ChangeAddressPageState createState() => _ChangeAddressPageState();
}

class _ChangeAddressPageState extends State<ChangeAddressPage> {
  String newLocation;
  Coordinates newCoord;
  bool isLoading;
  int userId;
  ScrollController listViewController = new ScrollController();
  @override
  void initState() {
    userId = Provider.of<CurrentUserProvider>(context, listen: false)
        .getloggedInUser
        .userId;
    setState(() {
      isLoading = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Provider.of<UserAddressProvider>(context, listen: false)
          .getUserAddressByUserId(context, userId);
      setState(() {
        isLoading = false;
      });
      listViewController = new ScrollController();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        title: Text(
            "${AppLocalizationHelper.of(context).translate("locationChoose")}",
            style: GoogleFonts.lato(
                color: Colors.black, fontWeight: FontWeight.normal)),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
          inAsyncCall: isLoading,
          progressIndicator: CircularProgressIndicator(),
          child: SingleChildScrollView(
              controller: listViewController, child: body(context))),
    );
  }

  Widget relocateButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        print("Relocate");
        setState(() {
          isLoading = true;
        });
        newLocation =
            await Provider.of<CurrentUserProvider>(context, listen: false)
                .getUserCurrentAddressFromSensor();
        newCoord =
            await Provider.of<CurrentUserProvider>(context, listen: false)
                .getUserCurrentCoordFromSensor();
        updateUserLocation();
        setState(() {
          isLoading = false;
        });
      },
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Icon(Icons.location_on,
            color: appThemeColor, size: ScreenUtil().setSp(60)),
        Text("${AppLocalizationHelper.of(context).translate("Relocate")}",
            style: GoogleFonts.lato(
                color: Colors.black, fontWeight: FontWeight.normal))
      ]),
    );
  }

  Widget addNewUserAddressButton(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      new Expanded(
        child: OutlinedButton(
          child: Text(
            "${AppLocalizationHelper.of(context).translate("deliveryAddressAdd")}",
            style: new TextStyle(color: Colors.white),
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => addNewUserLocationPage()));
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: appThemeColor,
          ),
        ),
      )
    ]);
  }

  Widget manageUserAddressButton(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      new Expanded(
        child: OutlinedButton(
          child: Text(
            "Manage Your Delivery Addresses",
            style: new TextStyle(color: Colors.black),
          ),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => AddressManagePage()));
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.grey,
          ),
        ),
      )
    ]);
  }

  Widget body(BuildContext context) {
    String userLocation =
        Provider.of<CurrentUserProvider>(context, listen: false).getUserAddress;
    return Container(
      margin: EdgeInsets.all(SizeHelper.widthMultiplier * 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AddressSearch((v, c) {
            setState(() {
              newLocation = v;
              newCoord = c;
              updateUserLocation();
            });
          }),
          VEmptyView(50),
          Row(
            children: [
              Text(
                  "  ${AppLocalizationHelper.of(context).translate("Current Location:")}",
                  style: GoogleFonts.lato(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              relocateButton(context),
            ],
          ),
          VEmptyView(30),
          Text(
              (userLocation == null)
                  ? "  ${AppLocalizationHelper.of(context).translate("Loading Location Data....")}"
                  : "  ${userLocation.trim()}",
              overflow: TextOverflow.ellipsis,
              maxLines: 5,
              style: GoogleFonts.lato(
                  color: Colors.black, fontWeight: FontWeight.normal)),
          VEmptyView(150),

          Text("${AppLocalizationHelper.of(context).translate("deliveryAddress")}",
              style: GoogleFonts.lato(
                  color: Colors.black, fontWeight: FontWeight.normal, fontSize: SizeHelper.textMultiplier * 2)),
          VEmptyView(50),
          // Text(
          //     "${AppLocalizationHelper.of(context).translate("New Location:")}",
          //     style: GoogleFonts.lato(
          //         color: Colors.black, fontWeight: FontWeight.bold)),
          // VEmptyView(30),
          // Text(
          //     (newLocation != null && newLocation.length > 0)
          //         ? "${newLocation.trim()}"
          //         : "${AppLocalizationHelper.of(context).translate("No Location Choosen")}",
          //     overflow: TextOverflow.ellipsis,
          //     maxLines: 5,
          //     style: GoogleFonts.lato(
          //         color: Colors.black, fontWeight: FontWeight.normal)),
          Consumer<UserAddressProvider>(builder: (ctx, p, w) {
            List<UserSavedAddress> addressList = p.getUserSavedAddressList;
            return Container(
              child: (addressList == null || addressList.isEmpty)
                  ? Center(
                      child: Container(
                          child: Text(
                            "${AppLocalizationHelper.of(context).translate("noDeliveryAddressAdd")}",
                        style: GoogleFonts.lato(
                            fontSize: SizeHelper.textMultiplier * 2.5),
                      )),
                    )
                  : SingleChildScrollView(
                      controller: listViewController,
                      child: Column(
                        children: <Widget>[
                          ListView.builder(
                              itemCount: addressList.length,
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (ctx, idx) {
                                UserSavedAddress address = addressList[idx];
                                return Padding(
                                  padding: EdgeInsets.all(
                                      SizeHelper.heightMultiplier * .01),
                                  child: AddressListTile(
                                    address: address,
                                  ),
                                );
                              }),
                        ],
                      ),
                    ),
            );
          }),
          VEmptyView(50),
          // manageUserAddressButton(context),
          addNewUserAddressButton(context),
        ],
      ),
    );
  }

  void updateUserLocation() {
    if (newLocation != null && newLocation.length > 0) {
      Provider.of<CurrentUserProvider>(context, listen: false)
          .setUserAddress(newLocation);
      if (newCoord != null) {
        Provider.of<CurrentUserProvider>(context, listen: false)
            .setUserCoord(newCoord);
        // update the store list after change coordinates
        Provider.of<StoreListProvider>(context, listen: false).setStoreList =
            [];
        // Provider.of<StoreListProvider>(context, listen: false)
        //     .getStoreListFromAPI(context, null, 1, true, newCoord);
        Provider.of<GroceriesItemProvider>(context, listen: false)
            .getGroceriesItemListByCoordinates(
                context, "${newCoord.latitude},${newCoord.longitude}");
        ;
      }
    }
  }
}
