import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/screenHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/store.dart';
import 'package:vplus/models/storeBusinessType.dart';
import 'package:vplus/providers/storeList_provider.dart';
import 'package:vplus/screens/stores/StoreCampaignsList/storelist_campaign_listtile.dart';

class StoreListCampaignListView extends StatefulWidget {
  List<Store> campaignStores;
  StoreListCampaignListView({Key key, this.campaignStores}) : super(key: key);
  _StoreListCampaignListViewState createState() =>
      _StoreListCampaignListViewState();
}

class _StoreListCampaignListViewState extends State<StoreListCampaignListView> {
  ScrollController listViewScrollController;
  List<Store> campaignStores;

  @override
  void initState() {
    super.initState();
    listViewScrollController = new ScrollController();
    campaignStores = this.widget.campaignStores;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: SizeHelper.heightMultiplier * 24),
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setSp(20)),
      child: (campaignStores != null)
          ? ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: campaignStores.length,
              shrinkWrap: true,
              itemBuilder: (ctx, index) {
                return StoreListCampaignListTile(
                  store: campaignStores[index],
                );
              },
            )
          : Container(),
    );
  }
}
