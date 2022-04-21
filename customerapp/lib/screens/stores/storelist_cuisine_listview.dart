import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/appLocalizationHelper.dart';
import 'package:vplus/helper/screenHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/storeBusinessType.dart';
import 'package:vplus/providers/storeList_provider.dart';
import 'package:vplus/widgets/emptyView.dart';
import 'package:vplus/widgets/network_error.dart';

import 'storelist_cuisine_listtile.dart';

class StoreListCuisineListView extends StatefulWidget {
  @override
  _StoreListCuisineListViewState createState() =>
      _StoreListCuisineListViewState();
}

class _StoreListCuisineListViewState extends State<StoreListCuisineListView> {
  ScrollController gridScrollController = new ScrollController();
  ScrollController listViewScrollController = new ScrollController();

  Future getBusinessTypeFromAPIFuture;

  List<StoreBusinessType> storeBusinessType;

  bool isLoading = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      setState(() {
        isLoading = true;
      });
      storeBusinessType =
          await Provider.of<StoreListProvider>(context, listen: false)
              .getAllBusinessTypes(context);
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.symmetric(
            horizontal: SizeHelper.heightMultiplier * 2.5,
          ),
          child: Text(
              "${AppLocalizationHelper.of(context).translate("Cuisine")}",
              style: GoogleFonts.lato(
                  fontWeight: FontWeight.w900,
                  fontSize: SizeHelper.textMultiplier * 2)),
        ),
        VEmptyView(40),
        Container(
          margin: EdgeInsets.only(left: SizeHelper.widthMultiplier * 2),
          child: ModalProgressHUD(
            inAsyncCall: isLoading,
            progressIndicator: CircularProgressIndicator(),
            child: SingleChildScrollView(
              controller: listViewScrollController,
              child: (storeBusinessType != null)
                  ? Container(
                      constraints: BoxConstraints(
                          maxHeight: SizeHelper.heightMultiplier * 18),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (ctx, index) {
                          return StoreListCuisineListTile(
                            cuisineType: storeBusinessType[index],
                          );
                        },
                        itemCount: storeBusinessType.length,
                      ),
                    )
                  : Container(),
            ),
          ),
        ),
      ],
    );
  }
}
