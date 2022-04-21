import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/appLocalizationHelper.dart';
import 'package:vplus/models/storeBusinessType.dart';
import 'package:vplus/providers/storeList_provider.dart';
import 'package:vplus/screens/stores/store_cuisine_detail_page.dart';
import 'package:vplus/widgets/primary_card.dart';

class StoreListCuisineListTile extends StatelessWidget {
  final StoreBusinessType cuisineType;

  StoreListCuisineListTile({this.cuisineType});

  onPress(context) {
    Provider.of<StoreListProvider>(context, listen: false).setSelectedCuisine(cuisineType);
    pushNewScreen(context,
        screen: StoreCuisineDetailPage(cuisineType: cuisineType),
        withNavBar: false);
  }

  @override
  Widget build(BuildContext context) {
    //TODO replace image Url
    return PrimaryCard(
      onTap: () {
        onPress(context);
      },
      title:
          "${AppLocalizationHelper.of(context).translate("${cuisineType.catName}")}",
      subtitle: null,
      imageUrl:
          cuisineType.imageUrl,
    );
  }
}
