import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/screenHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/store.dart';
import 'package:vplus/providers/current_store_provider.dart';
import 'package:vplus/screens/stores/StoreOrderPage/storeOrderPage.dart';
import 'package:vplus/widgets/components.dart';
import 'package:vplus/widgets/emptyView.dart';
import 'package:vplus/widgets/primary_card.dart';

class StoreListCampaignListTile extends StatefulWidget {
  final Store store;

  StoreListCampaignListTile({Key key, this.store}) : super(key: key);

  @override
  _StoreListCampaignListTileState createState() =>
      _StoreListCampaignListTileState();
}

class _StoreListCampaignListTileState extends State<StoreListCampaignListTile> {
  Store store;
  @override
  void initState() {
    super.initState();
    store = this.widget.store;
  }

  onPress() async {
    await Provider.of<CurrentStoreProvider>(context, listen: false)
        .getSingleStoreById(context, store.storeId);

    pushNewScreen(context,
        screen: StoreOrderPage(),
        withNavBar: false,
        pageTransitionAnimation: PageTransitionAnimation.cupertino);
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      //TODO put coverImage
      imageUrl: null,
      onTap: onPress,
      title: store.storeName,
      islarge: true,
    );

    //InkWell(
    //onTap: () async {

    // },
    // child:
    //  Container(
    //   child: Column(
    //     children: [
    //       SizedBox(
    //           width: SizeHelper.widthMultiplier * 18,
    //           height: SizeHelper.heightMultiplier * 10,
    //           child: StoreLogoOrBackground(store: store)),
    //       VEmptyView(20),
    //       Text("${store.storeName}",
    //           style: GoogleFonts.lato(
    //               fontStyle: FontStyle.italic, fontWeight: FontWeight.w700,fontSize:
    //               SizeHelper.textMultiplier*2))
    //     ],
    //   ),
    // ),
    // );
  }
}
