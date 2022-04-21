import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vplus/helper/appLocalizationHelper.dart';
import 'package:vplus/helper/screenHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';

class CustomDialog extends StatelessWidget {
  final Widget child;
  final title;

  final List<CustomDialogInsideButton> insideButtonList;
  final List<CustomDialogOutsideButton> outsideButtonList;

  CustomDialog({
    this.child,
    this.insideButtonList,
    this.outsideButtonList,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> listChild = [];
    //add title and child
    if (title != null) {
      listChild.add(Padding(
        padding: EdgeInsets.only(
            bottom: ScreenHelper.isLandScape(context)
                ? 10 * SizeHelper.widthMultiplier
                : 30),
        child: Text(
          title,
          style: GoogleFonts.lato(
            // fontSize: SizeHelper.isMobilePortrait?1.5*SizeHelper.textMultiplier:SizeHelper.textMultiplier,
            fontSize: ScreenHelper.isLandScape(context)
                ? 3 * SizeHelper.textMultiplier
                : 3 * SizeHelper.textMultiplier,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ));
    }

    //add body
    listChild.add(child);

    //add bottom button
    if (insideButtonList != null) {
      List<Widget> listButton = [];
      for (CustomDialogInsideButton b in insideButtonList) {
        listButton.add(b.getButton(context));
      }
      listChild.add(Padding(
        padding: EdgeInsets.only(
            top: ScreenUtil().setHeight(ScreenHelper.isLandScape(context)
                ? 10 * SizeHelper.widthMultiplier
                : 30)),
        child: Row(
          children: listButton,
        ),
      ));
    }

    //add outside button
    List<Widget> listOutsideButon = [];
    if (outsideButtonList != null) {
      for (CustomDialogOutsideButton b in outsideButtonList) {
        listOutsideButon.add(b.getButton());
      }
    }

    return Dialog(
      backgroundColor: Color.fromRGBO(0, 0, 0, 0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: ScreenHelper.isLandScape(context)
                  ? SizeHelper.heightMultiplier * 50
                  : SizeHelper.heightMultiplier * 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  width: 1,
                  color: Colors.grey,
                ),
                color: Colors.white,
              ),
              child: Padding(
                padding: EdgeInsets.all(ScreenUtil().setSp(50)),
                child: Column(
                  children: listChild,
                ),
              ),
            ),
            outsideButtonList != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: listOutsideButon,
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}

class CustomDialogOutsideButton {
  bool isCloseButton;
  Function buttonEvent;

  CustomDialogOutsideButton({this.isCloseButton, this.buttonEvent});

  Widget getButton() {
    return FlatButton(
      onPressed: buttonEvent,
      child: CircleAvatar(
        backgroundColor: Colors.black,
        child: isCloseButton
            ? Icon(
                Icons.close,
                color: Colors.white, //Color(0xff343f4b),
                // size: 35,
              )
            : Icon(
                Icons.check,
                color: Colors.white, //Color(0xff343f4b),
                // size: 35,
              ),
      ),
    );
  }
}

class CustomDialogInsideButton {
  String buttonName;
  Function buttonEvent;
  Color buttonColor;

  CustomDialogInsideButton(
      {this.buttonName, this.buttonEvent, this.buttonColor});

  Widget getButton(BuildContext context) {
    buttonColor ??= Color(0xff5352ec);
    return Expanded(
      // width: ScreenUtil().setWidth(800),
      // height: ScreenUtil().setHeight(96),
      child: Container(
        height: (ScreenHelper.isLandScape(context)
            ? MediaQuery.of(context).size.height * 0.05
            : MediaQuery.of(context).size.height * 0.05),
        width: (ScreenHelper.isLandScape(context)
            ? MediaQuery.of(context).size.height * 0.45
            : MediaQuery.of(context).size.height * 0.26),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: RaisedButton(
            onPressed: buttonEvent,
            textColor: Colors.white,
            color: buttonColor,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  buttonName,
                  style: GoogleFonts.lato(
                    fontSize: SizeHelper.isMobilePortrait
                        ? 2 * SizeHelper.textMultiplier
                        : 2 * SizeHelper.textMultiplier,
                    // fontSize: ScreenUtil().setSp(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.025:MediaQuery.of(context).size.height*0.025),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomDialogInsideCancelButton extends CustomDialogInsideButton {
  final Function callBack;
  CustomDialogInsideCancelButton({@required this.callBack});

  Widget getButton(BuildContext context) {
    return Expanded(
      // width: ScreenUtil().setWidth(800),
      // height: ScreenUtil().setHeight(96),
      child: Container(
        height: (ScreenHelper.isLandScape(context)
            ? MediaQuery.of(context).size.height * 0.05
            : MediaQuery.of(context).size.height * 0.05),
        width: (ScreenHelper.isLandScape(context)
            ? MediaQuery.of(context).size.height * 0.45
            : MediaQuery.of(context).size.height * 0.26),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: RaisedButton(
            onPressed: () {
              callBack();
            },
            textColor: Colors.white,
            color: Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "${AppLocalizationHelper.of(context).translate("Cancel")}",
                  style: GoogleFonts.lato(
                    fontSize: SizeHelper.isMobilePortrait
                        ? 2 * SizeHelper.textMultiplier
                        : 2 * SizeHelper.textMultiplier,
                    // fontSize: ScreenUtil().setSp(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.025:MediaQuery.of(context).size.height*0.025),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

////Example:
//showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return CustomDialog(
//         title: 'Test Title',
//         outsideButtonList: [
//           CustomDialogOutsideButton(
//               isCloseButton: true,
//               buttonEvent: () {
//                 Navigator.of(context).pop();
//               }),
//           CustomDialogOutsideButton(
//               isCloseButton: false,
//               buttonEvent: () {
//                 submit();
//                 Navigator.of(context).pop();
//               })
//         ],
//         insideButtonList: [
//           CustomDialogInsideButton(
//               buttonName: "Cancel",
//               buttonEvent: () {
//                 Navigator.of(context).pop();
//               }),
//           CustomDialogInsideButton(
//               buttonName: "Confirm",
//               buttonEvent: () {
//                 submit();
//                 Navigator.of(context).pop();
//               })
//         ],
//         child: Form(
//           key: this._orgProfileFormKey,
//           child: Column(
//             children: [
//               TextFieldRow(
//                 isReadOnly: false,
//                 textController: _orgNameCtrl,
//                 textGlobalKey: 'organizationName',
//                 context: context,
//                 isMandate: true,
//                 hintText: 'Organization Name',
//                 icon: Icon(
//                   Icons.home,
//                   color: Colors.blue,
//                   size: ScreenUtil().setSp(50),
//                 ),
//                 textValidator:
//                     _formValidateService.validateOrgName,
//                 onChanged: (value) {},
//               ).textFieldRow(),
//               VEmptyView(50),
//               TextFieldRow(
//                 isReadOnly: false,
//                 textController: _emailCtrl,
//                 textGlobalKey: 'email',
//                 context: context,
//                 // focusNode: emailFocusNode,
//                 keyboardType: TextInputType.emailAddress,
//                 hintText: 'Email',
//                 icon: Icon(
//                   Icons.ev_station,
//                   color: Colors.blueGrey,
//                   size: ScreenUtil().setSp(50),
//                 ),
//                 textValidator:
//                     _formValidateService.validateEmail,
//                 onChanged: (value) {},
//               ).textFieldRow(),
//             ],
//           ),
//         ),
//       );
//     });
