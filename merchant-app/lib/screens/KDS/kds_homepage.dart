import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/signalrHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/Order.dart';
import 'package:vplus_merchant_app/models/OrderItemPrint.dart';
import 'package:vplus_merchant_app/providers/currentuser_provider.dart';
import 'package:vplus_merchant_app/providers/kds_provider.dart';
import 'package:vplus_merchant_app/screens/KDS/by_item/single_item_list_view.dart';
import 'package:vplus_merchant_app/screens/KDS/by_order/single_order_list_view.dart';
import 'package:vplus_merchant_app/screens/KDS/kds_type_bar.dart';
import 'package:vplus_merchant_app/styles/font.dart';
import 'package:vplus_merchant_app/widgets/customAppBar.dart';

class KDSHomePage extends StatefulWidget {
  @override
  createState() => KDSHomePageState();
}

class KDSHomePageState extends State<KDSHomePage> {
  List<OrderItemPrint> kdsByItemsList;
  List<Order> kdsByOrderList;
  KDSType _selectedType;
  String kitchenName;

  ScrollController scrollController;
  @override
  void initState() {
    _selectedType = KDSType.ByOrder;
    scrollController = new ScrollController();
    SignalrHelper.atKDSPage = true;
    kitchenName = Provider.of<CurrentUserProvider>(context, listen: false)
        .getloggedInUser
        .name;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Provider.of<KDSProvider>(context, listen: false)
          .updateKDSDataFromAPI(context);
    });
    super.initState();
  }

  @override
  void dispose() {
    SignalrHelper.atKDSPage = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        "${AppLocalizationHelper.of(context).translate('KDS')}: $kitchenName",
        true,
        showLogo: true,
        context: context,
        screenPage: CustomAppBar.kitchenPage,
      ),
      body: Consumer<KDSProvider>(
        builder: (context, p, w) {
          kdsByItemsList = p.getKDSByItemsList;
          kdsByOrderList = p.getKDSByOrderList;
          return Column(
            children: [
              KDSTypeBar(
                kdsTypeButton: KDSType.values.map((e) {
                  return ListTypeButton(
                    isSelectedType: _selectedType,
                    buttonType: e,
                    buttonEvent: () {
                      setState(() {
                        _selectedType = e;
                      });
                    },
                  );
                }).toList(),
              ),
              (_selectedType == KDSType.ByOrder)
                  ? kdsByOrderView()
                  : kdsByItemView(),
            ],
          );
        },
      ),
    );
  }

  Widget kdsByOrderView() {
    return (kdsByOrderList == null || kdsByOrderList.isEmpty)
        ? emptyDataNotice()
        : Expanded(
            child: Container(
              padding: EdgeInsets.all(SizeHelper.widthMultiplier * 2),
              child: GridView.builder(
                controller: scrollController,
                shrinkWrap: true,
                padding: EdgeInsets.all(SizeHelper.widthMultiplier * 2),
                itemCount: kdsByOrderList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: SizeHelper.heightMultiplier * 3,
                    crossAxisSpacing: SizeHelper.widthMultiplier * 3,
                    childAspectRatio: kdsGridViewTileAspectRatio),
                itemBuilder: (context, index) {
                  return KDSByOrderListView(
                    order: kdsByOrderList[index],
                  );
                },
              ),
            ),
          );
  }

  Widget kdsByItemView() {
    return (kdsByItemsList == null || kdsByItemsList.isEmpty)
        ? emptyDataNotice()
        : Expanded(
            child: Container(
              padding: EdgeInsets.all(SizeHelper.widthMultiplier * 2),
              child: GridView.builder(
                controller: scrollController,
                shrinkWrap: true,
                padding: EdgeInsets.all(SizeHelper.widthMultiplier * 2),
                itemCount: kdsByItemsList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: SizeHelper.heightMultiplier * 3,
                    crossAxisSpacing: SizeHelper.widthMultiplier * 3,
                    childAspectRatio: kdsGridViewTileAspectRatio),
                itemBuilder: (context, index) {
                  return KDSByItemListView(
                    orderItem: kdsByItemsList[index],
                  );
                },
              ),
            ),
          );
  }

  Widget emptyDataNotice() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: SizeHelper.heightMultiplier * 16),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.local_cafe, size: SizeHelper.textMultiplier * 4),
            Text(
                "${AppLocalizationHelper.of(context).translate('KDSNoDataNotice')}",
                style:
                    GoogleFonts.lato(fontSize: SizeHelper.textMultiplier * 1.5))
          ],
        ),
      ),
    );
  }
}
