import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/screenHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/userSavedAddress.dart';
import 'package:vplus/providers/user_address_provider.dart';
import 'package:vplus/styles/color.dart';

class AddressListTile extends StatelessWidget {
  final UserSavedAddress address;
  final bool allowRemove;
  final Function onHit;
  final bool isChosen;

  AddressListTile(
      {Key key,
      @required this.address,
      this.allowRemove = true,
      this.onHit,
      this.isChosen = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: ListTile(
        onTap: () {
          onHit(address);
        },
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(
                  left: ScreenHelper.isLandScape(context)
                      ? 10
                      : SizeHelper.widthMultiplier * 2),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${address.unitNo}",
                        style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold,
                            fontSize: ScreenHelper.isLandScape(context)
                                ? SizeHelper.textMultiplier * 3
                                : SizeHelper.textMultiplier * 2)),
                    Text("${address.streetNo} " + "${address.streetName}",
                        style: GoogleFonts.lato(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.normal)),
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: SizeHelper.widthMultiplier * 45,
                      ),
                      child: Text("${address.postCode}",
                          style: GoogleFonts.lato(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.normal)),
                    ),
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: SizeHelper.widthMultiplier * 45,
                      ),
                      child: Text("${address.country}",
                          style: GoogleFonts.lato(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.normal)),
                    ),
                  ]),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Chip(label: Text(address.tag)),
                allowRemove
                    ? Container()
                    : Checkbox(value: isChosen, onChanged: null),
                allowRemove
                    ? Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        IconButton(
                            icon:
                                Icon(Icons.delete_rounded, color: Colors.grey),
                            onPressed: () {
                              show(context, address);
                            })
                      ])
                    : Container(),
              ],
            )
          ],
        ),
      ),
    );
  }

  show(BuildContext context, UserSavedAddress address) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("Are you still want to delete?"),
          actions: <Widget>[
            FlatButton(
              color: Colors.white,
              child: Text("Cancel"),
              onPressed: () {
                print("Cancel");
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              color: appThemeColor,
              child: Text("Delete"),
              onPressed: () {
                print("Delete");
                Provider.of<UserAddressProvider>(context, listen: false)
                    .deleteUserAddressByUserAddress(context, address);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
