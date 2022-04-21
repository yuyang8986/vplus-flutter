import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/OrderItem.dart';

class CustomSwitchWithText extends StatefulWidget {
  // final bool value;
  final Function(bool) onChanged;
  final String disabledText;
  final String enabledText;
  final OrderItem orderItem;

  const CustomSwitchWithText(
      {Key key,
      // this.value,
      this.onChanged,
      this.disabledText,
      this.enabledText,
      this.orderItem})
      : super(key: key);

  @override
  _CustomSwitchWithTextState createState() => _CustomSwitchWithTextState();
}

class _CustomSwitchWithTextState extends State<CustomSwitchWithText>
    with SingleTickerProviderStateMixin {
  Animation _circleAnimation;
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 60));
  }

  @override
  void didChangeDependencies() {
    _circleAnimation = AlignmentTween(
            begin: widget.orderItem.isTakeAway
                ? Alignment.centerLeft
                : Alignment.centerRight,
            end: widget.orderItem.isTakeAway
                ? Alignment.centerRight
                : Alignment.centerLeft)
        .animate(CurvedAnimation(
            parent: _animationController, curve: Curves.linear));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // _circleAnimation = AlignmentTween(
    //         begin: widget.orderItem.isTakeAway
    //             ? Alignment.centerLeft
    //             : Alignment.centerRight,
    //         end: widget.orderItem.isTakeAway
    //             ? Alignment.centerRight
    //             : Alignment.centerLeft)
    //     .animate(CurvedAnimation(
    //         parent: _animationController, curve: Curves.linear));
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return GestureDetector(
          onTap: () async {
            if (_animationController.isCompleted) {
              _animationController.reverse();
            } else {
              _animationController.forward();
            }

            !widget.orderItem.isTakeAway
                ? widget.onChanged(true)
                : widget.onChanged(false);
          },
          child: SizedBox(
            // height:(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.01:MediaQuery.of(context).size.height*0.025),
            child: Container(
              height: SizeHelper.isMobilePortrait
                  ? 3 * SizeHelper.heightMultiplier
                  : 3.5 * SizeHelper.widthMultiplier,
              width: SizeHelper.isMobilePortrait
                  ? 17 * SizeHelper.widthMultiplier
                  : 10 * SizeHelper.heightMultiplier,
              // height:(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.05:MediaQuery.of(context).size.height*0.025),
              // width:(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.width*0.1:MediaQuery.of(context).size.width*0.1),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: !widget.orderItem.isTakeAway
                      ? Colors.grey
                      : Color(0xff5352ec)),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 4.0, bottom: 4.0, right: 4.0, left: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    widget.orderItem.isTakeAway
                        // _circleAnimation.value == Alignment.centerRight
                        ? Padding(
                            padding:
                                const EdgeInsets.only(left: 4.0, right: 4.0),
                            child: Text(
                              widget.enabledText,
                              style: GoogleFonts.lato(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w900,
                                  fontSize: SizeHelper.isMobilePortrait
                                      ? SizeHelper.textMultiplier
                                      : 1.5 * SizeHelper.textMultiplier
                                  // fontSize: ScreenUtil().setSp((ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.015:MediaQuery.of(context).size.height*0.01)),
                                  ),
                            ),
                          )
                        : Container(),
                    Align(
                      alignment: _circleAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                      ),
                    ),
                    !widget.orderItem.isTakeAway
                        // _circleAnimation.value == Alignment.centerLeft
                        ? Padding(
                            padding:
                                const EdgeInsets.only(left: 4.0, right: 5.0),
                            child: Text(
                              widget.disabledText,
                              style: GoogleFonts.lato(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w900,
                                  fontSize: SizeHelper.isMobilePortrait
                                      ? SizeHelper.textMultiplier
                                      : 1.5 * SizeHelper.textMultiplier
                                  // fontSize: ScreenUtil().setSp((ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.015:MediaQuery.of(context).size.height*0.01)),
                                  ),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
