import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:geocoder/model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/apiHelper.dart';
import 'package:vplus/helper/appLocalizationHelper.dart';
import 'package:vplus/helper/screenHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/providers/carousel_provider.dart';
import 'package:vplus/providers/current_order_provider.dart';
import 'package:vplus/providers/currentuser_provider.dart';
import 'package:vplus/providers/groceries_item_provider.dart';
import 'package:vplus/providers/storeList_provider.dart';
import 'package:vplus/styles/color.dart';
import 'package:vplus/main.dart';
import 'package:vplus/widgets/appBar.dart';

class LanguageSettingPage extends StatefulWidget {
  @override
  _LanguageSettingPageState createState() => _LanguageSettingPageState();
}

class _LanguageSettingPageState extends State<LanguageSettingPage> {
  String currentLanguageCode;
  String newLocation;
  Coordinates newCoord;
  bool isLoading;
  List<String> supportedLanguages = ['en', 'zh'];

  Map<String, String> languageCodeMap = {
    "en": "English",
    "zh": "Simplified Chinese"
  };

  String languageSelected;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var hive = await Hive.openBox("languageSetting");
      var languageCodeMap = hive.get("currentLangugaeCode");
      currentLanguageCode = languageCodeMap['languageCode'];
    });
    super.initState();
  }

  Widget supportedLanguagesListTile(String item) {
    return Container(
      // margin: ScreenHelper.isLandScape(context)
      //     ? EdgeInsets.fromLTRB(0, SizeHelper.heightMultiplier * 5, 0, 0)
      //     : EdgeInsets.fromLTRB(0, 0, 0, 0),
      padding: EdgeInsets.symmetric(
          horizontal: ScreenHelper.isLandScape(context)
              ? SizeHelper.heightMultiplier * 10
              : SizeHelper.widthMultiplier * 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
              "${AppLocalizationHelper.of(context).translate(languageCodeMap['$item'].toString())}  ",
              style: GoogleFonts.lato(
                  fontSize: ScreenHelper.isLandScape(context)
                      ? SizeHelper.textMultiplier * 2
                      : SizeHelper.textMultiplier * 2)),
          InkWell(
            onTap: () {
              print('Select this langugae');
              setState(() {
                languageSelected = item;
                print(languageSelected);
              });
            },
            child: Container(
                constraints: BoxConstraints(
                  minWidth: ScreenHelper.isLandScape(context)
                      ? SizeHelper.heightMultiplier * 15
                      : SizeHelper.widthMultiplier * 30,
                  minHeight: ScreenHelper.isLandScape(context)
                      ? SizeHelper.widthMultiplier * 5
                      : SizeHelper.widthMultiplier * 10,
                ),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    color: (languageSelected == item)
                        ? Colors.green
                        : appThemeColor),
                child: Center(
                  child: Text(
                      (languageSelected == item)
                          ? "${AppLocalizationHelper.of(context).translate('Selected')}"
                          : "${AppLocalizationHelper.of(context).translate('SelectThis')}",
                      style: GoogleFonts.lato(
                          color: Colors.white,
                          fontSize: ScreenHelper.isLandScape(context)
                              ? SizeHelper.textMultiplier * 2
                              : SizeHelper.textMultiplier * 2)),
                )),
          )
        ],
      ),
    );
  }

  Widget currentSupportLanguageListView() {
    return Container(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: supportedLanguages
                .map((item) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Divider(),
                        Center(child: supportedLanguagesListTile(item)),
                        Divider(),
                      ],
                    ))
                .toList()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              size: SizeHelper.isMobilePortrait
                  ? 3 * SizeHelper.textMultiplier
                  : 3 * SizeHelper.textMultiplier,
            ),
          ),
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          title: Text(
            '${AppLocalizationHelper.of(context).translate('LanguageSettingLabel')}',
            style: GoogleFonts.lato(
                fontSize: ScreenUtil().setSp(40),
                fontWeight: FontWeight.bold,
                color: Colors.black),
          ),
          centerTitle: true,
          backgroundColor: Colors.grey[50],
        ),
        body: OrientationBuilder(builder: (context, orientation) {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: ScreenHelper.isLandScape(context)
                      ? EdgeInsets.fromLTRB(0, SizeHelper.widthMultiplier * 5,
                          0, SizeHelper.widthMultiplier * 5)
                      : EdgeInsets.fromLTRB(0, SizeHelper.heightMultiplier * 5,
                          0, SizeHelper.heightMultiplier * 5),
                  child: Center(
                    child: Text(
                      "${AppLocalizationHelper.of(context).translate('CurrentSupportLanguages')}:",
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: SizeHelper.isMobilePortrait
                            ? 2 * SizeHelper.textMultiplier
                            : 2 * SizeHelper.textMultiplier,
                      ),
                    ),
                  ),
                ),
                currentSupportLanguageListView(),
                if (languageSelected != null)
                  InkWell(
                    onTap: () async {
                      print('Confirm Change');
                      bool result = await AppLocalizationHelper.of(context)
                          .reLoadLanguage(languageSelected);
                      if (result == true) {
                        await AppLocalizationHelper.of(context).loadLanguage();
                        await updateUserLocation();
                        Phoenix.rebirth(context);
                        Navigator.pop(context);
                      } else {
                        var helper = Helper();
                        helper.showToastError(
                            '${AppLocalizationHelper.of(context).translate('FailedChangeLangugaeAlert')}');
                      }
                    },
                    child: Container(
                        margin: ScreenHelper.isLandScape(context)
                            ? EdgeInsets.fromLTRB(
                                SizeHelper.widthMultiplier * 5,
                                SizeHelper.heightMultiplier * 5,
                                SizeHelper.widthMultiplier * 5,
                                SizeHelper.heightMultiplier * 5)
                            : EdgeInsets.fromLTRB(
                                SizeHelper.widthMultiplier * 5,
                                SizeHelper.heightMultiplier * 5,
                                SizeHelper.widthMultiplier * 5,
                                SizeHelper.heightMultiplier * 5),
                        constraints: BoxConstraints(
                          minWidth: ScreenHelper.isLandScape(context)
                              ? 10
                              : SizeHelper.widthMultiplier * 20,
                          minHeight: ScreenHelper.isLandScape(context)
                              ? SizeHelper.widthMultiplier * 5
                              : SizeHelper.widthMultiplier * 10,
                        ),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            color: appThemeColor),
                        child: Center(
                          child: Text(
                              "${AppLocalizationHelper.of(context).translate('Confirm')}",
                              style: GoogleFonts.lato(
                                  color: Colors.white,
                                  fontSize: ScreenHelper.isLandScape(context)
                                      ? SizeHelper.textMultiplier * 2
                                      : SizeHelper.textMultiplier * 2)),
                        )),
                  )
              ],
            ),
          );
        }));
  }

  Future updateUserLocation() async {
    var deviceCoordinates =
        await Provider.of<CurrentUserProvider>(context, listen: false)
            .initUserGeoInto(context);

    await Provider.of<GroceriesItemProvider>(context, listen: false)
        .getGroceriesItemListByCoordinates(
            context,
            deviceCoordinates.latitude.toString() +
                "," +
                deviceCoordinates.longitude.toString());
    await Provider.of<CarouselProvider>(context, listen: false)
        .getCarouselsImageUrls(context);
  }
}
