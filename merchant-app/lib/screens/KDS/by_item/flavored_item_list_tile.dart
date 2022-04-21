import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/OrderItemPrint.dart';
import 'package:vplus_merchant_app/screens/KDS/by_item/table_info_list_tile.dart';
import 'package:vplus_merchant_app/styles/font.dart';
import 'package:vplus_merchant_app/widgets/components.dart';

class KDSByItemFlavoredItem extends StatelessWidget {
  final FlavoredOrderItem flavoredItem;
  KDSByItemFlavoredItem({this.flavoredItem});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          showAddOnReceipt(context),
          ListView.builder(
            // controller: scrollController,
            physics: ClampingScrollPhysics(),
            shrinkWrap: true,
            itemCount: flavoredItem.tableInfoList.length,
            itemBuilder: (ctx, index) {
              FlavoredItemTableInfo tableInfo =
                  flavoredItem.tableInfoList[index];
              return KDSByItemTableInfo(
                tableInfo: tableInfo,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget showAddOnReceipt(BuildContext context) {
    return Container(
      // show addon recetipt
      padding: EdgeInsets.symmetric(vertical: SizeHelper.heightMultiplier * 1),
      child: (flavoredItem.addOnReceipt != null &&
              flavoredItem.addOnReceipt.isNotEmpty)
          ? ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: flavoredItem.addOnReceipt.length,
              itemBuilder: (context, index) {
                return Text(
                  flavoredItem.addOnReceipt[index],
                  style: GoogleFonts.lato(
                      fontSize: kdsAddOnReceiptFontSize,
                      fontWeight: FontWeight.bold),
                );
              },
            )
          : Text(
              "${AppLocalizationHelper.of(context).translate('PrintPreviewPageNoAddOnNote')}",
              style: GoogleFonts.lato(
                  fontSize: kdsAddOnReceiptFontSize,
                  fontWeight: FontWeight.bold),
            ),
    );
  }
}
