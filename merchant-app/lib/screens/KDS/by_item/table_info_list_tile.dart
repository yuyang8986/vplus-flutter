import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/date_time_helper.dart';
import 'package:vplus_merchant_app/helpers/kdsHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/OrderItemPrint.dart';
import 'package:vplus_merchant_app/styles/color.dart';
import 'package:vplus_merchant_app/widgets/components.dart';

class KDSByItemTableInfo extends StatelessWidget {
  final FlavoredItemTableInfo tableInfo;
  KDSByItemTableInfo({this.tableInfo});
  final double fontSize = SizeHelper.textMultiplier * 1.2;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: SizeHelper.textMultiplier),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                    DateTimeHelper.parseDateTimeToDateHHMM(
                        tableInfo.date.toLocal()),
                    style: GoogleFonts.lato(fontSize: fontSize)),
                if (tableInfo != null &&
                    tableInfo.note != null &&
                    tableInfo.note.length > 0)
                  tableInfoOrderNote(context, tableInfo.note),
                Text("Table: ${tableInfo.table}",
                    style: GoogleFonts.lato(fontSize: fontSize)),
              ],
            ),
          ),
          Text("x${tableInfo.quantity}",
              style: GoogleFonts.lato(fontSize: fontSize)),
          RoundedSelectButton(
              "${AppLocalizationHelper.of(context).translate('KDSReadyButton')}",
              () async {
            await KDSHelper.setItemReady(
                context, tableInfo.userOrderItemId, tableInfo.userOrderId);
          },
              backgroundColor: confirmButtonBackgroundColor,
              textColor: Colors.white),
        ],
      ),
    );
  }

  Widget tableInfoOrderNote(BuildContext context, String note) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        color: orderNoteBackgroundColor,
      ),
      width: SizeHelper.widthMultiplier * 5,
      child: Text(
        '${AppLocalizationHelper.of(context).translate('Note')}: $note',
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.start,
        maxLines: 20,
        style: GoogleFonts.lato(
          fontSize: SizeHelper.textMultiplier * 1,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
