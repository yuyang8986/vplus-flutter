import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:vplus/helper/screenHelper.dart';
import 'dart:math' as math;

import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/store.dart';
import 'package:vplus/styles/color.dart';

import 'emptyView.dart';

// const Color footerColor = Color(0xff999999);
// const Color borderFocusColor = Color(0xff999999);
// const Color generalColor = Color(0xffe5e5e5);
// const Color borderColor = Color(0xffe6e6e6);
// const Color bodyColor = Color(0xFFf0f0f0);

/// Decoration for TextFormField.
class CustomTextBox {
  Widget icon;
  String hint;
  bool mandate;
  bool isEditable;
  Widget suffixIcon;
  BuildContext context;

  CustomTextBox(
      {this.hint,
      this.icon,
      this.mandate = false,
      this.suffixIcon,
      this.isEditable = true,
      @required this.context});
  InputDecoration getTextboxDecoration() {
    return InputDecoration(
      contentPadding: EdgeInsets.all(5),
      filled: !isEditable,
      fillColor: isEditable ? Colors.white : greyoutAreaColor,
      hintText: hint,
      hintStyle: GoogleFonts.lato(
          textStyle: GoogleFonts.lato(
              color: Colors.grey[500],
              fontSize: ScreenUtil().setSp(ScreenHelper.isLandScape(context)
                  ? SizeHelper.textMultiplier * 2
                  : ScreenHelper.getResponsiveTextFieldFontSize(context))),
          fontWeight: FontWeight.w800),
      suffixText: mandate ? '*' : '',
      suffixStyle:
          GoogleFonts.lato(color: Colors.red, fontWeight: FontWeight.bold),
      prefixIcon: icon,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
          color: borderColor,
          width: 1.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
          color: borderColor,
          width: 2.0,
        ),
      ),
      focusedBorder: new OutlineInputBorder(
        borderRadius: new BorderRadius.circular(10.0),
        borderSide: BorderSide(
          width: 1.0,
          color: borderFocusColor,
        ),
      ),
      // errorBorder: new OutlineInputBorder(
      //   borderRadius: new BorderRadius.circular(10.0),
      //   borderSide: BorderSide(
      //     width: 1.0,
      //     color: Colors.red,
      //   ),
      // ),
      // focusedErrorBorder: new OutlineInputBorder(
      //   borderRadius: new BorderRadius.circular(10.0),
      //   borderSide: BorderSide(
      //     width: 1.0,
      //     color: Colors.red,
      //   ),
      // ),
    );
  }
}

class SlideFromRightRoute extends PageRouteBuilder {
  final Widget page;
  SlideFromRightRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
}

class AlertMessageDialog {
  String title;
  String content;
  String buttonTitle;
  Function buttonEvent;
  BuildContext context;

  AlertMessageDialog({
    this.title,
    this.content,
    this.buttonTitle,
    this.buttonEvent,
    this.context,
  });

  dynamic showAlert() {
    // set up the AlertDialog
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          // title: title != null
          //     ? Text(title)
          //     : Container(
          //         color: Colors.red,
          //       ),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            title != null
                ? Text(
                    title,
                    style: GoogleFonts.lato(
                        fontSize: ScreenUtil().setSp(50),
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  )
                : Container(),
            VEmptyView(30),
            Text(
              content,
              style: GoogleFonts.lato(fontSize: ScreenUtil().setSp(40)),
              textAlign: TextAlign.center,
            ),
            VEmptyView(30),
            RaisedButton(
              onPressed: () {
                buttonEvent();
              },
              textColor: Colors.white,
              color: Color(0xff5352ec),
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    buttonTitle,
                    // textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ]),
        );
      },
    );
  }
}

class TextFieldRow {
  bool isReadOnly;
  TextEditingController textController;
  BuildContext context;
  FormFieldValidator<String> textValidator;
  bool isMandate;
  String hintText;
  Widget icon;
  IconButton suffixIcon;
  String textGlobalKey;
  TextInputType keyboardType;
  FocusNode focusNode;
  Function onChanged;
  bool obscureText;
  Function onEditingComplete;
  List<TextInputFormatter> inputFormatters;
  bool autofocus;

  TextFieldRow({
    this.isReadOnly = false,
    this.textController,
    this.context,
    this.textValidator,
    this.isMandate = false,
    this.hintText,
    this.icon,
    this.suffixIcon,
    this.textGlobalKey,
    this.keyboardType = TextInputType.text,
    this.focusNode,
    this.onChanged,
    this.obscureText = false,
    this.onEditingComplete,
    this.inputFormatters,
    this.autofocus = false,
  });

  StatelessWidget textFieldRow() {
    return Container(
      // constraints: BoxConstraints(minHeight: ScreenUtil().setHeight(140)),
      child: TextFormField(
        autofocus: autofocus,
        readOnly: isReadOnly,
        controller: textController != null ? textController : null,
        textAlignVertical: TextAlignVertical.center,
        key: Key(textGlobalKey),
        inputFormatters: inputFormatters,
        keyboardType: keyboardType,
        obscureText: obscureText,
        focusNode: focusNode != null ? focusNode : FocusNode(),
        textInputAction: TextInputAction.next,
        onEditingComplete: () {
          onEditingComplete != null
              ? onEditingComplete()
              : FocusScope.of(context).nextFocus();
        },
        decoration: CustomTextBox(
          context: context,
          mandate: isMandate,
          hint: hintText,
          icon: icon != null ? icon : Icon(null),
          suffixIcon: suffixIcon != null ? suffixIcon : null,
          isEditable: !isReadOnly,
        ).getTextboxDecoration(),
        validator: textValidator,
        onChanged: onChanged,
      ),
    );
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({this.decimalRange})
      : assert(decimalRange == null || decimalRange > 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    if (decimalRange != null) {
      String value = newValue.text;

      if (value.contains(".") &&
          value.substring(value.indexOf(".") + 1).length > decimalRange) {
        truncated = oldValue.text;
        newSelection = oldValue.selection;
      } else if (value == ".") {
        truncated = "0.";

        newSelection = newValue.selection.copyWith(
          baseOffset: math.min(truncated.length, truncated.length + 1),
          extentOffset: math.min(truncated.length, truncated.length + 1),
        );
      }

      return TextEditingValue(
        text: truncated,
        selection: newSelection,
        composing: TextRange.empty,
      );
    }
    return newValue;
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text?.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 30),
      child: Text(
        'For the benefit of the community',
        textAlign: TextAlign.center,
        style: GoogleFonts.lato(
          fontSize: 18,
          fontStyle: FontStyle.italic,
          color: footerColor,
        ),
      ),
    );
  }
}

class BottomNav extends StatelessWidget {
  int selectedTab;
  final Function(int) customOnTap;

  BottomNav(int selected, this.customOnTap) {
    selectedTab = selected;
  }
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      iconSize: 40,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home,
          ),
          title: Text(
            'Home',
            style: GoogleFonts.lato(),
          ),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.attach_money),
          title: Text(
            'Rewards',
            style: GoogleFonts.lato(),
          ),
        ),
      ],
      currentIndex: selectedTab,
      selectedItemColor: Colors.black,
      onTap: (value) {
        customOnTap(value);
      },
    );
  }
}

class ContainerGreenBorder extends StatelessWidget {
  ContainerGreenBorder({@required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.green),
          borderRadius: BorderRadius.circular(3)),
      child: child,
    );
  }
}

class RoundFadeInImage extends StatelessWidget {
  RoundFadeInImage(this.imageUrl);
  final imageUrl;

  @override
  Widget build(BuildContext context) {
    double widgetWidth = ScreenHelper.isLandScape(context)
        ? 15 * SizeHelper.widthMultiplier
        : 10 * SizeHelper.heightMultiplier;
    double widgetHeight = widgetWidth;
    return ClipRRect(
      borderRadius: BorderRadius.circular(ScreenUtil().setSp(20)),
      child: CachedNetworkImage(
        placeholder: (context, url) => Padding(
          child: Center(
              child: Container(
                  height: widgetHeight,
                  width: widgetWidth,
                  child: CircularProgressIndicator())),
          padding: EdgeInsets.all(2),
        ),
        height: widgetHeight,
        width: widgetWidth,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: ScreenHelper.isLandScape(context)
                  ? BoxFit.cover
                  : BoxFit.cover,
            ),
          ),
        ),
        imageUrl: imageUrl,
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
      // FadeInImage(
      //     fadeInDuration: Duration(milliseconds: 50),
      //     fit: BoxFit.fill,
      //     placeholder: AssetImage("assets/images/loading.gif"),
      //     image: NetworkImage(imageUrl)),
    );
  }
}

class SquareFadeInImage extends StatelessWidget {
  SquareFadeInImage(this.imageUrl);
  final imageUrl;
  @override
  Widget build(BuildContext context) {
    double widgetWidth = ScreenHelper.isLandScape(context)
        ? 15 * SizeHelper.widthMultiplier
        : 20 * SizeHelper.widthMultiplier;
    double widgetHeight = widgetWidth;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14.0),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        height: widgetHeight,
        width: widgetWidth,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: ScreenHelper.isLandScape(context)
                  ? BoxFit.cover
                  : BoxFit.fitWidth,
            ),
          ),
        ),
        placeholder: (context, url) => Padding(
          child: Center(
            child: Container(
              color: Colors.grey,
              height: widgetHeight,
              width: widgetWidth,
            ),
          ),
          padding: EdgeInsets.all(2),
        ),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
      // FadeInImage(
      //     fadeInDuration: Duration(milliseconds: 50),
      //     fit: BoxFit.fill,
      //     placeholder: AssetImage("assets/images/loading.gif"),
      //     image: NetworkImage(imageUrl)),
    );
  }
}

class RoundedVplusButton extends StatelessWidget {
  final Function callBack;
  RoundedVplusButton({@required this.callBack});
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: () {
        callBack();
      },
      textColor: Colors.white,
      color: Color(0xff5352ec),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Confirm',
            style: GoogleFonts.lato(
              fontWeight: FontWeight.bold,
              fontSize: ScreenUtil().setSp(50),
            ),
          ),
        ],
      ),
    );
  }
}

class RoundedVplusLongButton extends StatelessWidget {
  final String text;
  final Function callBack;
  final Color color;
  RoundedVplusLongButton(
      {@required this.callBack, @required this.text, this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      // height:SizeHelper.isMobilePortrait?1.5*SizeHelper.heightMultiplier:5*SizeHelper.widthMultiplier,
      child: Row(
        children: [
          WEmptyView(80),
          Expanded(
            child: RaisedButton(
              onPressed: () {
                callBack();
              },
              textColor: Colors.white,
              color: color ?? Color(0xff5352ec),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: 2 * SizeHelper.textMultiplier,
                    ),
                  ),
                ],
              ),
            ),
          ),
          WEmptyView(80),
        ],
      ),
    );
  }
}

class StoreLogoOrBackground extends StatelessWidget {
  final Store store;
  StoreLogoOrBackground({@required this.store});

  @override
  Widget build(BuildContext context) {
    double widgetWidth = ScreenHelper.isLandScape(context)
        ? 15 * SizeHelper.widthMultiplier
        : 20 * SizeHelper.widthMultiplier;
    // double widgetHeight = widgetWidth;
    return store.logoUrl == null
        ? Container(
            // height: widgetHeight,
            width: widgetWidth,
            child: CircleAvatar(
              child: Center(
                child: Text(
                  "${store.storeName.substring(0, 1)}",
                  style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: ScreenHelper.isLandScape(context)
                          ? SizeHelper.textMultiplier * 8
                          : SizeHelper.textMultiplier * 5),
                ),
              ),
              radius: ScreenHelper.isLandScape(context)
                  ? 50
                  : SizeHelper.imageSizeMultiplier * 11,
              backgroundColor: Color((store.backgroundColorHex == null)
                  ? Colors.grey.value
                  : int.tryParse(store.backgroundColorHex)),
            ),
          )
        : SquareFadeInImage(store.logoUrl);
  }
}
