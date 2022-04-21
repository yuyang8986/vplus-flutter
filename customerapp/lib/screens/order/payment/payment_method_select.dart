import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/styles/color.dart';
import 'package:vplus/widgets/emptyView.dart';

class PaymentMethodSelect extends StatefulWidget {
  final List<String> userPaymentMethods;
  final ScrollController scrollController;
  final Function(int) onItemSelected;
  PaymentMethodSelect({
    Key key,
    @required this.userPaymentMethods,
    @required this.onItemSelected,
    this.scrollController,
  }) : super(key: key);

  _PaymentMethodSelectState createState() => _PaymentMethodSelectState();
}

class _PaymentMethodSelectState extends State<PaymentMethodSelect> {
  List<String> userPaymentMethods;
  int selectedIdx;
  ScrollController scrollController;
  @override
  void initState() {
    userPaymentMethods = this.widget.userPaymentMethods;
    scrollController = this.widget.scrollController;
    selectedIdx = -1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.all(SizeHelper.widthMultiplier * 2),
      child: ListView.builder(
          controller: scrollController,
          shrinkWrap: true,
          itemCount: userPaymentMethods.length,
          itemBuilder: (ctx, idx) {
            return CheckboxListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  userPaymentMethods[idx] == "Google Pay"
                      ? Image.asset(
                          'assets/images/gpay.png',
                          width: SizeHelper.imageSizeMultiplier * 15,
                        )
                      : userPaymentMethods[idx] == "Apple Pay"
                          ? Image.asset(
                              'assets/images/apay.png',
                              width: SizeHelper.imageSizeMultiplier * 17,
                            )
                          : Padding(
                              padding: EdgeInsets.only(
                                  left: SizeHelper.textMultiplier * 1.1,
                                  right: SizeHelper.textMultiplier * 2.2),
                              child: Icon(
                                FontAwesomeIcons.creditCard,
                                size: SizeHelper.textMultiplier * 4.5,
                                color: Colors.cyan,
                              ),
                            ),
                  WEmptyView(40),
                  Text("${userPaymentMethods[idx]}",
                      style: GoogleFonts.lato(
                          fontSize: SizeHelper.textMultiplier * 2.3)),
                ],
              ),
              activeColor: appThemeColor,
              value: idx == selectedIdx,
              onChanged: (v) {
                setState(() {
                  selectedIdx = idx;
                });
                this.widget.onItemSelected(selectedIdx);
              },
            );
          }),
    );
  }
}
