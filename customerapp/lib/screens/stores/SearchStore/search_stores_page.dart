import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/appLocalizationHelper.dart';
import 'package:vplus/helper/screenHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/store.dart';
import 'package:vplus/providers/current_store_provider.dart';
import 'package:vplus/providers/storeList_provider.dart';
import 'package:vplus/screens/stores/StoreOrderPage/storeOrderPage.dart';
import 'package:vplus/screens/stores/store_listtile.dart';
import 'package:vplus/widgets/components.dart';
import 'package:vplus/widgets/emptyView.dart';

class SearchStoresPage extends StatefulWidget {
  @override
  _SearchStoresPageState createState() => _SearchStoresPageState();
}

class _SearchStoresPageState extends State<SearchStoresPage> {
  String searchInput;

  ScrollController resultScrollController;
  TextEditingController searchBarController;
  FocusNode searchBarFocus;

  @override
  void initState() {
    resultScrollController = new ScrollController();
    searchBarController = new TextEditingController();
    searchBarFocus = new FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    Provider.of<StoreListProvider>(context, listen: false).resetSearchResults();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        body: Container(
            color: Colors.white,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              VEmptyView(40),
              searchBar(),
              Expanded(child: searchResultListView()),
            ])),
      ),
    );
  }

  Widget searchBar() {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: ScreenHelper.isLandScape(context)
              ? 10
              : SizeHelper.widthMultiplier * 2,
          vertical: ScreenHelper.isLandScape(context)
              ? 20
              : SizeHelper.heightMultiplier * 2),
      child: Row(
        children: [
          Expanded(
            flex: 10,
            child: TextFieldRow(
              isReadOnly: false,
              context: context,
              textController: searchBarController,
              icon: Icon(Icons.search),
              isMandate: false,
              focusNode: searchBarFocus,
              hintText:
                  "${AppLocalizationHelper.of(context).translate("cravingsSearch")}",
              autofocus: true,
              onChanged: (v) async {
                if (v != null && v != "")
                  await Provider.of<StoreListProvider>(context, listen: false)
                      .searchByKeyword(context, v);
              },
            ).textFieldRow(),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    if (searchBarController.text != null &&
                        searchBarController.text.isNotEmpty) {
                      searchBarController.text = "";
                      Provider.of<StoreListProvider>(context, listen: false)
                          .resetSearchResults();
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(
                      "${AppLocalizationHelper.of(context).translate("Cancel")}",
                      style: GoogleFonts.lato(fontWeight: FontWeight.normal)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget searchResultListView() {
    return Consumer<StoreListProvider>(builder: (ctx, p, w) {
      List<Store> searchResult = p.getSearchResults;
      return (searchResult == null || searchResult.isEmpty)
          ? emptyResultNotice()
          : ListView.builder(
              controller: resultScrollController,
              shrinkWrap: true,
              itemCount: searchResult.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    Provider.of<CurrentStoreProvider>(context, listen: false)
                        .setCurrentStore = searchResult[index];
                    pushNewScreen(context,
                        screen: StoreOrderPage(),
                        withNavBar: false,
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino);
                  },
                  child: StoreListTile(
                    store: searchResult[index],
                  ),
                );
              });
    });
  }

  Widget emptyResultNotice() {
    return Container(
        padding: EdgeInsets.all(SizeHelper.widthMultiplier * 4),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: SizeHelper.textMultiplier * 6,
            ),
            Text("${AppLocalizationHelper.of(context).translate("No match")}",
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                    fontWeight: FontWeight.normal,
                    fontSize: SizeHelper.textMultiplier * 2)),
          ],
        ));
  }
}
