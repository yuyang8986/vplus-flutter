import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/models/campaign.dart';
import 'package:vplus_merchant_app/providers/campaign_provider.dart';
import 'package:vplus_merchant_app/widgets/components.dart';
import 'package:vplus_merchant_app/widgets/custom_dialog.dart';
import 'package:vplus_merchant_app/widgets/emptyView.dart';

showNewCampaignDialog(BuildContext context, CampaignType campaignType) {
  Key formKey = new Key("newCampaignForm");
  TextEditingController campaignName = new TextEditingController();
  TextEditingController campaignDescription = new TextEditingController();
  TextEditingController percentage = new TextEditingController();
  TextEditingController discountTarget = new TextEditingController();
  TextEditingController discountOff = new TextEditingController();

  List<Widget> percentageWidgets = <Widget>[
    TextFieldRow(
      isReadOnly: false,
      textController: percentage,
      textGlobalKey: 'Percentage',
      context: context,
      hintText: 'Percentage',
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      icon: Icon(
        Icons.local_offer,
        color: Colors.blueGrey,
        size: ScreenUtil().setSp(50),
      ),
      onChanged: (value) {},
    ).textFieldRow(),
  ];

  List<Widget> discountWidgets = <Widget>[
    TextFieldRow(
      isReadOnly: false,
      textController: discountTarget,
      textGlobalKey: 'Discount Target',
      context: context,
      hintText: 'Discount Target',
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      icon: Icon(
        Icons.local_offer,
        color: Colors.blueGrey,
        size: ScreenUtil().setSp(50),
      ),
      onChanged: (value) {},
    ).textFieldRow(),
    VEmptyView(50),
    TextFieldRow(
      isReadOnly: false,
      textController: discountOff,
      textGlobalKey: 'Discount Off',
      context: context,
      hintText: 'Discount Off',
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      icon: Icon(
        Icons.local_offer,
        color: Colors.blueGrey,
        size: ScreenUtil().setSp(50),
      ),
      onChanged: (value) {},
    ).textFieldRow(),
  ];

  showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          title: "New campaign",
          insideButtonList: [
            CustomDialogInsideButton(
                buttonName: "Cancel",
                buttonEvent: () {
                  Navigator.of(context).pop();
                }),
            CustomDialogInsideButton(
                buttonName: "Confirm",
                buttonEvent: () async {
                  bool hasSubmitted = await Provider.of<CampaignProvider>(
                          context,
                          listen: false)
                      .createCampaign(
                          context,
                          campaignName.text,
                          campaignDescription.text,
                          campaignType,
                          double.parse(
                              percentage.text == "" ? "0" : percentage.text),
                          double.parse(discountTarget.text == ""
                              ? "0"
                              : percentage.text),
                          double.parse(
                              discountOff.text == "" ? "0" : percentage.text));
                  if (hasSubmitted) Navigator.of(context).pop();
                })
          ],
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                TextFieldRow(
                  isReadOnly: false,
                  textController: campaignName,
                  textGlobalKey: 'Campaign Name',
                  context: context,
                  isMandate: true,
                  hintText: 'Campaign Name',
                  icon: Icon(
                    Icons.home,
                    color: Colors.blue,
                    size: ScreenUtil().setSp(50),
                  ),
                  onChanged: (value) {},
                ).textFieldRow(),
                VEmptyView(50),
                TextFieldRow(
                  isReadOnly: false,
                  textController: campaignDescription,
                  textGlobalKey: 'Campaign Description',
                  context: context,
                  hintText: 'Campaign Description',
                  icon: Icon(
                    Icons.description,
                    color: Colors.blueGrey,
                    size: ScreenUtil().setSp(50),
                  ),
                  onChanged: (value) {},
                ).textFieldRow(),
                VEmptyView(50),
                // DateRangeSelector((startDate, endDate) {
                //   print(startDate);
                //   print(endDate);
                // }),
                // VEmptyView(50),
                if (campaignType == CampaignType.Discount) ...discountWidgets,
                if (campaignType == CampaignType.Percentage)
                  ...percentageWidgets
              ],
            ),
          ),
        );
      });
}
