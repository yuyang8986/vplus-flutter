import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/date_time_helper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/OrderItemPrint.dart';
import 'package:vplus_merchant_app/providers/printer_order_list_provider.dart';
import 'package:vplus_merchant_app/screens/printer/printerItemStatus.dart';

class PrintByOrderListTile extends StatefulWidget {
  final PrintableItem printableItem;
  PrinterItemStatus tileStatus;
  ScrollController _receiptScrollController;

  PrintByOrderListTile(this.tileStatus, {Key key, this.printableItem})
      : super(key: key);

  @override
  _printByOrderListTile createState() => _printByOrderListTile();
}

class _printByOrderListTile extends State<PrintByOrderListTile> {
  bool hasPrinted;
  bool isSelected;
  List<PrintableItem> selectedPrintableItems;
  List<PrintableItem> printedPrintableItems;
  @override
  void initState() {
    // printedPrintableItems =
    //     Provider.of<PrinterOrderListProvider>(context, listen: false)
    //         .getPrintedPrintableItem;
    // selectedPrintableItems =
    //     Provider.of<PrinterOrderListProvider>(context, listen: false)
    //         .getSelectedPrintableItem();
    // hasPrinted = printedPrintableItems.contains(this.widget.printableItem);
    // isSelected = !hasPrinted;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final orderStatus = orderItem.itemStatus.index;
    return Container(
        height: ScreenHelper.isLandScape(context)
            ? SizeHelper.widthMultiplier * 12
            : 100,
        // width: ScreenUtil().setWidth(900),
        // key: ValueKey(orderItem.hashCode),
        child: ListTile(
            title: Container(
          child: Column(
            children: [
              // (this.widget.printableItem.note != null &&
              //         this.widget.printableItem.note.length > 0)
              //     ? Container(
              //         height: ScreenUtil().setHeight(40),
              //         child: Text(
              //           'this.widget.printableItem.note',
              //           style: GoogleFonts.lato(
              //             fontSize: ScreenUtil().setSp(35),
              //             decoration: TextDecoration.none,
              //             color: Colors.black,
              //           ),
              //         ),
              //       )
              //     : Container(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // if (ScreenHelper.isLandScape(context))
                  //   Container(
                  //     width: SizeHelper.widthMultiplier * 0.01,
                  //   ),
                  Text(
                    '${DateTimeHelper.parseDateTimeToDateHHMM(this.widget.printableItem.placedTime.toLocal())}',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: ScreenUtil().setSp(
                          ScreenHelper.isLandScape(context)
                              ? SizeHelper.textMultiplier * 2
                              : 32),
                      decoration: TextDecoration.none,
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    child: Text(
                      '${AppLocalizationHelper.of(context).translate('Table Name')} ${this.widget.printableItem.orderTable}',
                      style: GoogleFonts.lato(
                        fontSize: ScreenUtil().setSp(
                            ScreenHelper.isLandScape(context)
                                ? SizeHelper.textMultiplier * 2
                                : 32),
                        decoration: TextDecoration.none,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    child: Text(
                      'X ${this.widget.printableItem.quantity}',
                      style: GoogleFonts.lato(
                        fontSize: ScreenUtil().setSp(
                            ScreenHelper.isLandScape(context)
                                ? SizeHelper.textMultiplier * 2
                                : 32),
                        decoration: TextDecoration.none,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(
                      height: ScreenUtil().setHeight(
                          ScreenHelper.isLandScape(context)
                              ? SizeHelper.heightMultiplier * 7
                              : 40),
                      width: ScreenUtil().setWidth(120),
                      child: InkWell(onTap: () {
                        setState(() {
                          switch (widget.tileStatus) {
                            case PrinterItemStatus.printed:
                              {
                                widget.tileStatus = PrinterItemStatus.selected;
                                // do selected
                                Provider.of<PrinterOrderListProvider>(context,
                                        listen: false)
                                    .addSelectedPrintableItem(
                                        this.widget.printableItem);
                                break;
                              }
                            case PrinterItemStatus.selected:
                              {
                                widget.tileStatus =
                                    PrinterItemStatus.notSelected;
                                // do un-selected
                                Provider.of<PrinterOrderListProvider>(context,
                                        listen: false)
                                    .removeSelectedPrintableItem(
                                        this.widget.printableItem);
                                break;
                              }
                            case PrinterItemStatus.notSelected:
                              {
                                widget.tileStatus = PrinterItemStatus.selected;
                                // do selected
                                Provider.of<PrinterOrderListProvider>(context,
                                        listen: false)
                                    .addSelectedPrintableItem(
                                        this.widget.printableItem);
                                break;
                              }
                          }
                        });
                      }, child: Builder(
                        builder: (context) {
                          switch (widget.tileStatus) {
                            case PrinterItemStatus.printed:
                              {
                                return _showPrintedLabel();
                                break;
                              }
                            case PrinterItemStatus.selected:
                              {
                                return _showCheckBox();
                                break;
                              }
                            case PrinterItemStatus.notSelected:
                              {
                                return _showNotCheckBox();
                                break;
                              }
                          }
                        },
                      ))
                      //  (hasPrinted == true)
                      //     ? _showPrintedLabel()
                      //     : (isSelected == true)
                      //         ? _showCheckBox()
                      //         : _showNotCheckBox()),
                      ),
                ],
              ),
            ],
          ),
        )));
  }

  Widget _showPrintedLabel() {
    return Container(
      color: Colors.grey,
      child: Center(
        child: Text(
          'Printed',
          style: GoogleFonts.lato(
            fontSize: ScreenHelper.isLandScape(context)
                ? 2 * SizeHelper.imageSizeMultiplier
                : 7,
            decoration: TextDecoration.none,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _showCheckBox() {
    return Center(
      child: Container(
          child: Icon(
        Icons.check_box,
        size: ScreenHelper.isLandScape(context)
            ? 3 * SizeHelper.imageSizeMultiplier
            : 7 * SizeHelper.imageSizeMultiplier,
      )),
    );
  }

  Widget _showNotCheckBox() {
    return Center(
      child: Container(
          child: Icon(
        Icons.check_box_outline_blank,
        size: ScreenHelper.isLandScape(context)
            ? 3 * SizeHelper.imageSizeMultiplier
            : 7 * SizeHelper.imageSizeMultiplier,
      )),
    );
  }
}
