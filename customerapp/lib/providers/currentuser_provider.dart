import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:vplus/config/config.dart';
import 'package:vplus/helper/apiHelper.dart';
import 'package:vplus/helper/locationHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/user.dart';
import 'package:vplus/models/userPaymentMethod.dart';
import 'package:vplus/widgets/custom_dialog.dart';

class CurrentUserProvider with ChangeNotifier {
  Future<dynamic> checkExistingLoginFuture;
  User _loggedInUser;
  Coordinates currentUserCoord;
  String currentUserAddress;
  String signUpMobileNumber;
  bool showedLocationNotify = false;

  CurrentUserProvider() {
    checkExistingLoginFuture = checkExistingLogin();
  }

  User get getloggedInUser => _loggedInUser;

  Coordinates get getUserCoord => currentUserCoord;

  void setUserCoord(Coordinates data) {
    this.currentUserCoord = data;
    persistentSaveUserCoord(data);
    notifyListeners();
  }

  String get getSignUpMobileNumber => signUpMobileNumber;

  set setSignUpMobileNumber(String mobileNumber) {
    signUpMobileNumber = mobileNumber;
  }

  String get getUserAddress => currentUserAddress;

  void setUserAddress(String address) async {
    this.currentUserAddress = address;
    persisentSaveUserAddr(address);
    notifyListeners();
  }

  //This method is used to get user current address
  Future<String> getUserCurrentAddressFromSensor() async {
    Coordinates currentLocation = await getUserCurrentCoordFromSensor();
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(currentLocation);
    return addresses[0].addressLine.toString();
  }

  //This method is used to get user current coordinates
  Future<Coordinates> getUserCurrentCoordFromSensor() async {
    var locationHelper = LocationHelper();
    LocationData currentLocation =
        await locationHelper.getCurrentUserLocation();
    return new Coordinates(currentLocation.latitude, currentLocation.longitude);
  }

  //This method is used to init user current location
  Future<void> initUserCurrentLocation(Coordinates currentLocation) async {
    this.currentUserCoord = currentLocation;
    currentUserAddress = await getAddressByCoord(currentLocation);
    persistentSaveUserCoord(currentLocation);
    persisentSaveUserAddr(currentUserAddress);
    notifyListeners();
  }

  Future<String> getAddressByCoord(Coordinates coord) async {
    var addresses = await Geocoder.local.findAddressesFromCoordinates(coord);
    String currentUserAddress = addresses[0].addressLine.toString();
    return currentUserAddress;
  }

  Future<void> persistentSaveUserCoord(Coordinates coord) async {
    var hiveBox = await Hive.openBox('testBox');
    await hiveBox.put("userCoord", coord.toMap());
  }

  Future<void> persisentSaveUserAddr(String userAddr) async {
    var hiveBox = await Hive.openBox('testBox');
    await hiveBox.put("userAddr", userAddr);
  }

  Future<String> getSavedUserAddr() async {
    var hiveBox = await Hive.openBox('testBox');
    String savedAddr = await hiveBox.get("userAddr");
    return savedAddr;
  }

  Future<Coordinates> getPrevSavedUserLocation() async {
    var hiveBox = await Hive.openBox('testBox');
    Coordinates prevCoord = (hiveBox.get("userCoord") == null)
        ? null
        : Coordinates.fromMap(hiveBox.get("userCoord"));
    return prevCoord;
  }

  updateUserGeoInfo(Coordinates coord, String userAddr) async {
    currentUserCoord = coord;
    currentUserAddress = userAddr;
    persistentSaveUserCoord(coord);
    persisentSaveUserAddr(userAddr);
    notifyListeners();
  }

  setCurrentUser(User user) async {
    _loggedInUser = user;
    var hiveBox = await Hive.openBox('testBox');
    hiveBox.put("user", user.toJson());
    notifyListeners();
  }

  Future<bool> checkExistingLogin() async {
    var hiveBox = await Hive.openBox('testBox');
    var user = hiveBox.get('user');
    if (user != null) {
      _loggedInUser = new User();
      _loggedInUser.address = user['address'];
      _loggedInUser.name = user['name'];
      _loggedInUser.userId = user['userId'];
      _loggedInUser.id = user['id'];
      _loggedInUser.mobile = user['mobile'];
      _loggedInUser.email = user['email'];
      _loggedInUser.api_token = user['token'];
      _loggedInUser.username = user['name'];
      _loggedInUser.role_name = user['roleNames'];
      _loggedInUser.userPaymentMethod = user['userPaymentMethod'] != null
          ? new UserPaymentMethod.fromJson(
              Map<String, dynamic>.from(user['userPaymentMethod']))
          : null;
      _loggedInUser.driverId = user['driverId'];
      return true;
    }
    return false;
  }

  Future<bool> updateCustomerInfoByUserId(
      BuildContext context, int userId) async {
    var hlp = Helper();
    var response =
        await hlp.getData("api/Users/$userId", context: context, hasAuth: true);
    if (response.isSuccess && response.data != null) {
      User customer = User.fromJson(response.data);
      _loggedInUser.userPaymentMethod = customer.userPaymentMethod;
      setCurrentUser(_loggedInUser);
      return true;
    } else
      return false;
  }

  Future<bool> registrationCustomer(
      BuildContext context, String mobile, String password) async {
    var hlp = Helper();
    var data = {
      "name": "vplusCustomer",
      "mobile": mobile,
      "password": password,
      "postCode": null
    };
    var response = await hlp.postData("api/Token/registration-customer", data,
        context: context, hasAuth: false);
    if (response.isSuccess) {
      User user = User.fromJson(response.data);
      setCurrentUser(user);
    } else {
      hlp.showToastError("Failed to create user, please try again");
    }
    return response.isSuccess;
  }

  Future<Coordinates> initUserGeoInto(BuildContext context) async {
    /// initialize user geometry information when loading the home page
    /// Check if there is previous location saved in the application
    /// if so, measure the distance between the saved location and the device location
    /// if greater than the COORD_RELOCATE_THRESHOLD, pop up a location check dialog
    Coordinates currentLocation =
        await Provider.of<CurrentUserProvider>(context, listen: false)
            .getUserCurrentCoordFromSensor();

    Coordinates prevLocation =
        await Provider.of<CurrentUserProvider>(context, listen: false)
            .getPrevSavedUserLocation();

    if (prevLocation != null &&
        !showedLocationNotify &&
        LocationHelper.calcualteDistanceInMeter(
                currentLocation.latitude,
                currentLocation.longitude,
                prevLocation.latitude,
                prevLocation.longitude) >
            COORD_RELOCATE_THRESHOLD) {
      String prevAddress = await getSavedUserAddr();
      String currentAddress = await getAddressByCoord(currentLocation);
      showedLocationNotify = true;
      // different with previous location
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialog(
                title: "Location changed",
                insideButtonList: [
                  CustomDialogInsideButton(
                      buttonName: "No",
                      buttonEvent: () async {
                        currentLocation = prevLocation;
                        await updateUserGeoInfo(prevLocation, prevAddress);
                        Navigator.of(context).pop();
                      }),
                  CustomDialogInsideButton(
                      buttonName: "Confirm",
                      buttonEvent: () async {
                        await updateUserGeoInfo(
                            currentLocation, currentAddress);
                        Navigator.of(context).pop();
                      })
                ],
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: SizeHelper.heightMultiplier * 2),
                        child: Text(
                            "You location changed since your last log in.",
                            style: GoogleFonts.lato()),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: SizeHelper.heightMultiplier * 2),
                        child: Text("Saved location: $prevAddress",
                            style: GoogleFonts.lato()),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: SizeHelper.heightMultiplier * 2),
                        child: Text("Your current location: $currentAddress",
                            style: GoogleFonts.lato()),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: SizeHelper.heightMultiplier * 2),
                        child: Text(
                            "Do you want to change your address to your current location?",
                            style: GoogleFonts.lato()),
                      ),
                    ],
                  ),
                ));
          });
    } else {
      currentLocation =
          await Provider.of<CurrentUserProvider>(context, listen: false)
              .getUserCurrentCoordFromSensor();

      await Provider.of<CurrentUserProvider>(context, listen: false)
          .initUserCurrentLocation(currentLocation);
    }

    return currentLocation;
  }
}
