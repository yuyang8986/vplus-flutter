import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:geocoder/model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:vplus/helper/FormValidationService.dart';
import 'package:vplus/helper/address_search__helper.dart';
import 'package:vplus/helper/apiHelper.dart';
import 'package:vplus/helper/appLocalizationHelper.dart';
import 'package:vplus/helper/screenHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/geo/place.dart';
import 'package:vplus/models/userSavedAddress.dart';
import 'package:vplus/providers/currentuser_provider.dart';
import 'package:vplus/providers/user_address_provider.dart';
import 'package:vplus/styles/color.dart';
import 'package:vplus/widgets/address_search.dart';
import 'package:vplus/widgets/components.dart';
import 'package:vplus/widgets/emptyView.dart';

class addNewUserLocationPage extends StatefulWidget {
  @override
  _addNewUserLocationPage createState() => _addNewUserLocationPage();
}

class _addNewUserLocationPage extends State<addNewUserLocationPage> {
  bool isLoading;
  String doorNumber;
  String postNumber;
  String tags;
  String addressComment;
  String contactName;
  String contactNumber;
  String streetNumber;
  String streetName;
  String city;
  String zipCode;
  String tag;
  String coordinate;
  int userId;
  Helper hlp;
  int _selectIndex = 0;
  final TextEditingController _controller = new TextEditingController();
  @override
  void initState() {
    hlp = Helper();
    userId = Provider.of<CurrentUserProvider>(context, listen: false)
        .getloggedInUser
        .userId;
    isLoading = false;
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
            "${AppLocalizationHelper.of(context).translate("deliveryLocationAdd")}",
            style: GoogleFonts.lato(
                color: Colors.black, fontWeight: FontWeight.normal)),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: Container(
          child: SingleChildScrollView(
            child: Container(
              padding:
                  EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 40),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: SizeHelper.heightMultiplier * 1,
                        horizontal: SizeHelper.widthMultiplier * 3.5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          // margin: EdgeInsets.only(bottom: 5),
                          child: Text(
                            "${AppLocalizationHelper.of(context).translate("Street Name")}",
                            style: GoogleFonts.lato(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: SizeHelper.textMultiplier *2.5),
                          ),
                        ),
                        Container(
                          width: SizeHelper.widthMultiplier * 50,
                          child: TextField(
                            textAlign: TextAlign.center,
                            //  controller: _storeAddressCtrl,
                            textAlignVertical: TextAlignVertical.center,
                            textInputAction: TextInputAction.done,
                            onEditingComplete: () {
                              FocusScope.of(context).nextFocus();
                            },
                            decoration: InputDecoration(
                              hintText: "${AppLocalizationHelper.of(context).translate("addressEntry")}",
                                contentPadding: EdgeInsets.all(10.0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                )
                            ),
                            controller: _controller,
                            readOnly: true,
                            onTap: () async {
                              try {
                                // generate a new token here
                                final sessionToken = Uuid().v4();
                                final Suggestion result = await showSearch(
                                  context: context,
                                  delegate: AddressSearchDelegate(sessionToken),
                                );
                                // result with no input
                                // This will change the text displayed in the TextField
                                // result with auto suggest
                                if (result?.placeId != "") {
                                  final placeDetails =
                                      await PlaceApiHelper(sessionToken)
                                          .getPlaceDetailFromId(result.placeId);
                                  setState(() {
                                    //addressController.text = result.description;
                                    // street number can be null, allow store address correct to street
                                    coordinate = "${placeDetails.lat}" +
                                        "," +
                                        "${placeDetails.lng}";
                                    streetNumber =
                                        placeDetails.streetNumber ?? "";
                                    streetName = placeDetails.street ?? "";
                                    city = placeDetails.city ?? "";
                                    zipCode = placeDetails.zipCode ??
                                        ""; // zip code could also be null for api resp
                                    try {
                                      _controller.text = streetNumber +
                                          " " +
                                          streetName +
                                          " " +
                                          city +
                                          " " +
                                          zipCode;
                                    } catch (e) {
                                      _controller.text = "";
                                      Helper().showToastError(
                                          AppLocalizationHelper.of(context)
                                              .translate(
                                                  'FailedToGetStoreAddressNote'));
                                    }
                                  });
                                }
                                // no auto suggest, use user input result
                                else if (result.placeId == "") {
                                  setState(() {
                                    _controller.text = result.description;
                                  });
                                }
                              } catch (e) {
                                print(e.toString());
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  VEmptyView(30),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: SizeHelper.heightMultiplier * 1,
                        horizontal: SizeHelper.widthMultiplier * 3.5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 30),
                          child: Text(
                            "${AppLocalizationHelper.of(context).translate("Door Number")}",
                            style: GoogleFonts.lato(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: SizeHelper.textMultiplier*2.5),
                          ),
                        ),
                        Container(
                          width: SizeHelper.widthMultiplier * 50,
                          child: TextField(
                            maxLength: 50,
                            onChanged: (value) {
                              setState(
                                    () {
                                  doorNumber = value.trim();
                                },
                              );
                            },
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(10.0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                  VEmptyView(30),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: SizeHelper.heightMultiplier * 1,
                        horizontal: SizeHelper.widthMultiplier * 3.5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 30),
                          child: Text(
                            "${AppLocalizationHelper.of(context).translate("Postcode")}",
                            style: GoogleFonts.lato(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: SizeHelper.textMultiplier*2.5),
                          ),
                        ),
                        Container(
                          width: SizeHelper.widthMultiplier * 50,
                          child: TextField(
                            maxLength: 10,
                            onChanged: (value) {
                              setState(
                                    () {
                                  postNumber = value.trim();
                                },
                              );
                            },
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(10.0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: SizeHelper.heightMultiplier * 1,
                        horizontal: SizeHelper.widthMultiplier * 3.5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 30),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "${AppLocalizationHelper.of(context).translate("Tag")}",
                            style: GoogleFonts.lato(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: SizeHelper.textMultiplier*2.5),
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          margin: EdgeInsets.only(bottom: 30),
                          child: Wrap(spacing: 15, children: [
                            ChoiceChip(
                                label: Text("${AppLocalizationHelper.of(context).translate("Home")}"),
                                selected: _selectIndex == 1,
                                onSelected: (v) {
                                  setState(() {
                                    _selectIndex = 1;
                                  });
                                }),
                            ChoiceChip(
                                label: Text("${AppLocalizationHelper.of(context).translate("Work")}"),
                                selected: _selectIndex == 2,
                                onSelected: (v) {
                                  setState(() {
                                    _selectIndex = 2;
                                  });
                                }),
                            ChoiceChip(
                                label: Text("${AppLocalizationHelper.of(context).translate("School")}"),
                                selected: _selectIndex == 3,
                                onSelected: (v) {
                                  setState(() {
                                    _selectIndex = 3;
                                  });
                                }),
                          ]),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: SizeHelper.heightMultiplier * 1,
                        horizontal: SizeHelper.widthMultiplier * 3.5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 30),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "${AppLocalizationHelper.of(context).translate("Address Comment")}",
                            style: GoogleFonts.lato(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: SizeHelper.textMultiplier*2),
                          ),
                        ),
                        Container(
                          width: SizeHelper.widthMultiplier * 45,
                          child: TextField(
                            keyboardType: TextInputType.multiline,
                            maxLines: 3,
                            onChanged: (value) {
                              setState(
                                    () {
                                  addressComment = value.trim();
                                },
                              );
                            },
                            decoration: CustomTextBox(
                              context: context,
                              icon: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: ScreenUtil().setHeight(10),
                                ),
                                child: Text(
                                  "${AppLocalizationHelper.of(context).translate("OrderConfirmationNote")}",
                                  style: GoogleFonts.lato(
                                      fontSize: SizeHelper.textMultiplier*2,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xfff61a36),
                                      letterSpacing: 1),
                                ),
                              ),
                            ).getTextboxDecoration(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  VEmptyView(30),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: SizeHelper.heightMultiplier * 1,
                        horizontal: SizeHelper.widthMultiplier * 3.5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 30),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "${AppLocalizationHelper.of(context).translate("Contact Name")}",
                            style: GoogleFonts.lato(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: SizeHelper.textMultiplier*2.5),
                          ),
                        ),
                        Container(
                          width: SizeHelper.widthMultiplier * 50,
                          child: TextField(
                            maxLength: 15,
                            onChanged: (value) {
                              setState(
                                    () {
                                  contactName = value.trim();
                                },
                              );
                            },
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(10.0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                  VEmptyView(30),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: SizeHelper.heightMultiplier * 1,
                        horizontal: SizeHelper.widthMultiplier * 2.5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 30),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "${AppLocalizationHelper.of(context).translate("Contact Number")}",
                            style: GoogleFonts.lato(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: SizeHelper.textMultiplier*2.2),
                          ),
                        ),
                        Container(
                            width: SizeHelper.widthMultiplier * 55,
                            margin: EdgeInsets.only(bottom: 30),
                            alignment: Alignment.centerLeft,
                            child: IntlPhoneField(
                              // maxLength: 12,
                              keyboardType: TextInputType.phone,
                              initialCountryCode: 'AU',
                              onChanged: (value) {
                                setState(() {
                                  contactNumber = value.completeNumber.toString();
                                });
                              },
                            )),
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          elevation: 4,
                          onPressed: () {
                            if(checkValidations()){
                              addLocation();
                              Navigator.of(context).pop();
                            }
                          },
                          textColor: Colors.white,
                          color: Color(0xff5352ec),
                          padding: const EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: SizedBox(
                            child: Text(
                              "${AppLocalizationHelper.of(context).translate("deliveryAddressBtn")}",
                              style: TextStyle(
                                fontSize: SizeHelper.textMultiplier*2.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool checkValidations() {
    if(streetName==null){
      hlp.showToastError('Please choose your delivery address');
      return false;
    }
    if (doorNumber == null) {
      hlp.showToastError('Please enter Door Number');
      return false;
    }else if(RegExp(r"^[A-Za-z0-9]+$").firstMatch(doorNumber)==null){ //数字英文only
      hlp.showToastError("Only words and numbers allowed in door number!");
      return false;
    }
    if (postNumber == null) {
      hlp.showToastError('Please enter Postcode');
      return false;
    }else if(RegExp(r"^[0-9]*$").firstMatch(postNumber)==null){ //数字only
      hlp.showToastError("Only numbers allowed in postcode!");
      return false;
    }
    if (_selectIndex == 0) {
      hlp.showToastError('Please select your Tag');
      return false;
    }
    if (contactName == null) {
      hlp.showToastError('Please enter Contact Name');
      return false;
    }else if(RegExp(r"^[a-zA-Z0-9_ ]*$").firstMatch(contactName)==null){ //中文、英文、数字包括下划线
      hlp.showToastError("Only words, numbers and underline allowed in contact name!");
      return false;
    }
    if (contactNumber == null) {
      hlp.showToastError('Please enter Phone Number');
      return false;
    }
    return true;
  }

  Future<void> addLocation() async {
    if (FormValidateService().validateMobile(contactNumber)?.isNotEmpty ??
        false) {
      hlp.showToastError("Phone format is not valid!");
      return;
    }
    if (_selectIndex == 1) {
      tag = "home";
    } else if (_selectIndex == 2) {
      tag = "work";
    } else {
      tag = "school";
    }
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> data = {
      "tag": tag.trim(),
      "streetName": streetName,
      "streetNo": streetNumber,
      "unitNo": doorNumber?.trim() ?? "",
      "contactName": contactName.trim(),
      "contactNo": contactNumber.trim(),
      "deliveryNote": addressComment?.trim() ?? "",
      "postCode": postNumber?.trim() ?? "",
      "city": city,
      "state": "",
      "country": "",
      "isActive": true,
      "userId": userId.toString(),
      "coordinates": coordinate,
    };
    var response = await hlp.postData("api/users/addresses", data,
        context: context, hasAuth: true);
    if (response.isSuccess) {
      await Provider.of<UserAddressProvider>(context, listen: false)
          .getUserAddressByUserId(context, userId);
      hlp.showToastSuccess("Address added");
      return;
    } else {
      print("errr");
      hlp.showToastError(hlp.getLastError());
    }
  }
}
