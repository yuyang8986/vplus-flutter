import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/appLocalizationHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/userSavedAddress.dart';
import 'package:vplus/providers/currentuser_provider.dart';
import 'package:vplus/providers/user_address_provider.dart';
import 'package:vplus/widgets/address_list_tile.dart';

class AddressManagePage extends StatefulWidget {
  AddressManagePage({Key key}) : super(key: key);
  _AddressManagePage createState() => _AddressManagePage();
}
class _AddressManagePage extends State<AddressManagePage> {
  int userId;
  bool isLoading;
  List<UserSavedAddress> addressList;
  ScrollController listViewController;
  @override
  void initState() {
    super.initState();
    userId = Provider.of<CurrentUserProvider>(context, listen: false)
        .getloggedInUser.userId;
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
              "Manage Your Address",
              style: GoogleFonts.lato(
                  color: Colors.black, fontWeight: FontWeight.normal)),
          centerTitle: true,
        ),
          body: ModalProgressHUD(
              inAsyncCall: isLoading,
              child: Consumer<UserAddressProvider>(
              builder: (ctx, p, w) {
                addressList = p.getUserSavedAddressList;
                return Container(
                    child: (addressList == null || addressList.isEmpty)
                        ? Center(
                          child: Container(
                          child: Text(
                              "There are no address added"
                          )),
                        ):
                    SingleChildScrollView(
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
                                  padding:
                                  EdgeInsets.all(SizeHelper.heightMultiplier),
                                  child: AddressListTile(
                                    address: address,
                                  ),
                                );
                              }),
                        ],
                      ),
                    ),

                );
                }
              )
          )
    );
  }
}