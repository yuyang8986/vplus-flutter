import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/providers/current_order_provider.dart';

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
      var items = p.order.userItems;
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
                          fontSize: ScreenHelper.isLandScape(context)
                              ? SizeHelper.textMultiplier * 2
                              : SizeHelper.textMultiplier * 2),
                    ),
                  ),
                  _generateButton(Icons.add, () => _increment()),
                ],
              ),
            );
    });
  }

  void _increment() {
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
              .setSp(ScreenHelper.isLargeScreen(context) ? 40 : 60)),
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
