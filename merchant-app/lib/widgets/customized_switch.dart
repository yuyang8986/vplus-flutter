import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/menuItem.dart';
import 'package:vplus_merchant_app/providers/current_menu_provider.dart';
import 'package:loading_indicator/loading_indicator.dart';

class CustomizedSwitch extends StatefulWidget {
  final MenuItem menuItem;
  final Function(bool) onChanged;
  final Color activeColor;

  const CustomizedSwitch(
      {Key key, this.menuItem, this.onChanged, this.activeColor})
      : super(key: key);

  @override
  _CustomizedSwitchState createState() => _CustomizedSwitchState();
}

class _CustomizedSwitchState extends State<CustomizedSwitch>
    with SingleTickerProviderStateMixin {
  Animation _circleAnimation;
  AnimationController _animationController;

  bool isLoading = false;

  bool isSoldOut = false;
  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 60));
  }

  @override
  void didChangeDependencies() {
    isSoldOut = Provider.of<CurrentMenuProvider>(context, listen: false)
        .getStoreMenu
        .menuItems
        .firstWhere((e) => e.menuItemId == widget.menuItem.menuItemId)
        .isSoldOut;
    _circleAnimation = AlignmentTween(
            begin: isSoldOut ? Alignment.centerLeft : Alignment.centerRight,
            end: isSoldOut ? Alignment.centerRight : Alignment.centerLeft)
        .animate(CurvedAnimation(
            parent: _animationController, curve: Curves.linear));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    isSoldOut = Provider.of<CurrentMenuProvider>(context, listen: false)
        .getStoreMenu
        .menuItems
        .firstWhere((e) => e.menuItemId == widget.menuItem.menuItemId)
        .isSoldOut;
    _circleAnimation = AlignmentTween(
            begin: isSoldOut ? Alignment.centerLeft : Alignment.centerRight,
            end: isSoldOut ? Alignment.centerRight : Alignment.centerLeft)
        .animate(CurvedAnimation(
            parent: _animationController, curve: Curves.linear));
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return GestureDetector(
          onTap: () async {
            if (isLoading == false) {
              setState(() {
                isLoading = true;
              });

              if (_animationController.isCompleted) {
                _animationController.reverse();
              } else {
                _animationController.forward();
              }
              bool isApiFinished;

              isSoldOut == false
                  ? isApiFinished = await widget.onChanged(true)
                  : isApiFinished = await widget.onChanged(false);

              if (isApiFinished == true) {
                setState(() {
                  isLoading = false;
                });
              }
            }
          },
          child: Stack(
            children: [
              Container(
                width: ScreenHelper.isLargeScreen(context)
                    ? ScreenHelper.isLandScape(context)
                        ? 120
                        : 180
                    : 200,
                height: ScreenUtil()
                    .setHeight(ScreenHelper.isLandScape(context) ? 90 : 60),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: isSoldOut ? Colors.grey : widget.activeColor),
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 4.0, bottom: 4.0, right: 4.0, left: 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      // _circleAnimation.value == Alignment.centerRight
                      !isSoldOut
                          ? Padding(
                              padding: EdgeInsets.only(
                                  left: ScreenHelper.isLandScape(context)
                                      ? 1.1 * SizeHelper.widthMultiplier
                                      : 2.0,
                                  right: 0.0),
                              child: Text(
                                AppLocalizationHelper.of(context)
                                    .translate('InStock'),
                                style: GoogleFonts.lato(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w900,
                                    fontSize: SizeHelper.isMobilePortrait
                                        ? 1.3 * SizeHelper.textMultiplier
                                        : 1.5 * SizeHelper.textMultiplier),
                              ),
                            )
                          : Container(),
                      Align(
                        alignment: _circleAnimation.value,
                        child: Container(
                          width: 17.0,
                          height: 17.0,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.white),
                        ),
                      ),
                      isSoldOut
                          // _circleAnimation.value == Alignment.centerLeft
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(left: 1.0, right: 1.0),
                              child: Text(
                                AppLocalizationHelper.of(context)
                                    .translate('SoldOut'),
                                style: GoogleFonts.lato(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w900,
                                    fontSize: SizeHelper.isMobilePortrait
                                        ? 1.3 * SizeHelper.textMultiplier
                                        : 1.5 * SizeHelper.textMultiplier),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
              isLoading == true
                  ? Container(
                      width: 100.0,
                      height: 30.0,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: Colors.black54),
                      child: Center(
                        child: LoadingIndicator(
                          indicatorType: Indicator.ballClipRotate,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        );
      },
    );
  }
}
