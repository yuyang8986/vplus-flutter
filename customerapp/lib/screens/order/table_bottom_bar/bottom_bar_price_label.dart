import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/screenHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/providers/current_order_provider.dart';

class TablePriceLabel extends StatelessWidget {
  final bool isCartEmpty = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentOrderProvider>(
      builder: (ctx, p, w) {
        var order = p.getOrder;
        if (order.userItems == null || order.userItems.length == 0) {
          return _getEmptyPriceLabel(context);
        }
        return _getPriceLabel(p.getTotal(), context);
      },
    );
  }

  _getEmptyPriceLabel(BuildContext context) {
    return Text(
      '\$0.00',
      style: GoogleFonts.lato(
        color: Color(0xff939da8),
        fontWeight: FontWeight.bold,
        fontSize: _getFontSize(context),
      ),
    );
  }

  _getPriceLabel(double price, BuildContext context) {
    return Text(
      '\$${price.toStringAsFixed(2)}',
      style: GoogleFonts.lato(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: _getFontSize(context),
      ),
    );
  }

  num _getFontSize(BuildContext context) {
    return ScreenUtil().setSp(
        ScreenHelper.isLandScape(context) ? SizeHelper.textMultiplier * 2 : 45);
  }
}
