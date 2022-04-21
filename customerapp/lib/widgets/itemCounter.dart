import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/screenHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/providers/current_order_provider.dart';
import 'package:vplus/providers/currentuser_provider.dart';
import 'package:vplus/screens/auth/signin.dart';
import 'package:vplus/widgets/custom_dialog.dart';
import 'package:vplus/widgets/emptyView.dart';

class ItemCounter extends StatefulWidget {
  final int initNumber;
  final Function(int) counterCallback;
  bool isFirstVisit;
  ItemCounter({
    this.initNumber,
    this.counterCallback,
    this.isFirstVisit = false,
  });

  @override
  _ItemCounterState createState() => _ItemCounterState();
}

class _ItemCounterState extends State<ItemCounter> {
  int _currentCount;
  Function _counterCallback;

  @override
  void initState() {
    _currentCount = widget.initNumber ?? 0;
    _counterCallback = widget.counterCallback ?? (int number) {};

    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    _currentCount = widget.initNumber;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _currentCount = widget.initNumber ?? 0;
    return Consumer<CurrentOrderProvider>(builder: (ctx, p, w) {
      var items = p.order?.userItems;
      if (items?.length == 0 && widget.isFirstVisit == false) {
        _currentCount = 0;
      }
      return _currentCount == 0
          ? Container(
              child: _generateButton(Icons.add, () => _increment()),
            )
          : Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _generateButton(Icons.remove, () => _dicrement()),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setSp(10)),
                    child: Text(
                      _currentCount.toString(),
                      style: GoogleFonts.lato(
                          fontSize: ScreenUtil().setSp(
                              ScreenHelper.isLandScape(context)
                                  ? SizeHelper.textMultiplier * 1.5
                                  : SizeHelper.textMultiplier * 6)),
                    ),
                  ),
                  _generateButton(Icons.add, () => _increment()),
                ],
              ),
            );
    });
  }

  void _increment() {
    if (Provider.of<CurrentUserProvider>(context, listen: false)
            .getloggedInUser ==
        null) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialog(
                insideButtonList: [
                  CustomDialogInsideCancelButton(callBack: () {
                    Navigator.of(context).pop();
                  }),
                  CustomDialogInsideButton(
                      buttonName: "Sign Up",
                      buttonEvent: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          CupertinoPageRoute(
                            builder: (BuildContext context) {
                              return SignInPage();
                            },
                          ),
                          (_) => false,
                        );
                      }),
                ],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sign Up To Checkout',
                        style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold,
                            fontSize: ScreenUtil().setSp(
                                ScreenHelper.isLandScape(context)
                                    ? SizeHelper.textMultiplier * 1.5
                                    : 50))),
                    VEmptyView(50),
                    Text('Limited Time Offers:',
                        style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold,
                            fontSize: ScreenUtil().setSp(
                                ScreenHelper.isLandScape(context)
                                    ? SizeHelper.textMultiplier * 1.5
                                    : 50))),
                    VEmptyView(50),
                    Text('- \$1 Deliver To Your Door Now',
                        style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold,
                            fontSize: ScreenUtil().setSp(
                                ScreenHelper.isLandScape(context)
                                    ? SizeHelper.textMultiplier * 1.5
                                    : 40))),
                    Text('- Get Up To\$12 Off For Your Orders',
                        style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold,
                            fontSize: ScreenUtil().setSp(
                                ScreenHelper.isLandScape(context)
                                    ? SizeHelper.textMultiplier * 1.5
                                    : 40))),
                    Text('- More Than 2,000 Items To Shop and Updating',
                        style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold,
                            fontSize: ScreenUtil().setSp(
                                ScreenHelper.isLandScape(context)
                                    ? SizeHelper.textMultiplier * 1.5
                                    : 40))),
                  ],
                ));
          });
      return;
    }
    setState(() {
      _currentCount += 1;
      _counterCallback(_currentCount);
    });
  }

  void _dicrement() {
    setState(() {
      if (_currentCount > 0) {
        _currentCount -= 1;
        _counterCallback(_currentCount);
      }
    });
  }

  Widget _generateButton(IconData icon, Function onPressed) {
    return RawMaterialButton(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      constraints: BoxConstraints(
          minWidth: ScreenUtil().setSp(64),
          minHeight: ScreenUtil()
              .setSp(ScreenHelper.isLargeScreen(context) ? 20 : 60)),
      onPressed: onPressed,
      fillColor: Color(0xFF5352EC),
      child: Icon(
        icon,
        color: Colors.white,
        size: ScreenUtil().setSp(40),
      ),
      shape: CircleBorder(),
    );
  }
}

// Usage Example:
// ItemCounter(
//             initNumber: 0,
//             counterCallback: (v) {
//               print(v);
//             },
//           )
