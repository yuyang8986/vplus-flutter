import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:vplus_merchant_app/helpers/address_search__helper.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/models/geo/place.dart';
import 'package:vplus_merchant_app/widgets/components.dart';

class AddressSearch extends StatefulWidget {
  final Function(String, String) onSetAddress; //Address Coordinate
  final String initValue;
  AddressSearch(this.onSetAddress, {this.initValue});
  @override
  _AddressSearchState createState() => _AddressSearchState();
}

class _AddressSearchState extends State<AddressSearch> {
  TextEditingController addressController = new TextEditingController();
  String _streetNumber = '';
  String _street = '';
  String _city = '';
  String _zipCode = '';

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.initValue != null) addressController.text = widget.initValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
        textAlign: TextAlign.center,
        //  controller: _storeAddressCtrl,
        textAlignVertical: TextAlignVertical.center,
        textInputAction: TextInputAction.done,
        onEditingComplete: () {
          FocusScope.of(context).nextFocus();
        },
        decoration: CustomTextBox(
                context: context,
                mandate: true,
                hint: AppLocalizationHelper.of(context).translate("Address"))
            .getTextboxDecoration(),

        // decoration: InputDecoration(
        //   icon: Container(
        //     margin: EdgeInsets.only(left: 20),
        //     width: 10,
        //     height: 10,
        //     child: Icon(
        //       Icons.home,
        //       color: Colors.black,
        //     ),
        //   ),
        //   hintText: "Enter your address",
        //   border: InputBorder.none,
        //   contentPadding: EdgeInsets.only(left: 8.0, top: 16.0),
        // ),
        controller: addressController,
        readOnly: true,
        onTap: () async {
          // generate a new token here
          final sessionToken = Uuid().v4();
          final Suggestion result = await showSearch(
            context: context,
            delegate: AddressSearchDelegate(sessionToken),
          );
          // result with no input
          if (result == null) {
            widget.onSetAddress(' ', null);
          }
          // This will change the text displayed in the TextField
          // result with auto suggest
          else if (result?.placeId != "") {
            final Place placeDetails = await PlaceApiHelper(sessionToken)
                .getPlaceDetailFromId(result.placeId);
            setState(() {
              //addressController.text = result.description;
              // street number can be null, allow store address correct to street
              _streetNumber = placeDetails.streetNumber ?? "";
              _street = placeDetails.street ?? "";
              _city = placeDetails.city ?? "";
              _zipCode = placeDetails.zipCode ??
                  ""; // zip code could also be null for api resp
              try {
                addressController.text = _streetNumber +
                    " " +
                    _street +
                    " " +
                    _city +
                    " " +
                    _zipCode;
              } catch (e) {
                addressController.text = "";
                Helper().showToastError(AppLocalizationHelper.of(context)
                    .translate('FailedToGetStoreAddressNote'));
              }
            });

            widget.onSetAddress(addressController.text,
                "${placeDetails.lat},${placeDetails.lng}");
          }
          // no auto suggest, use user input result
          else if (result.placeId == "") {
            setState(() {
              addressController.text = result.description;
              widget.onSetAddress(addressController.text, null);
            });
          }
        },
      ),
    );
  }
}

class AddressSearchDelegate extends SearchDelegate<Suggestion> {
  AddressSearchDelegate(this.sessionToken) {
    apiClient = PlaceApiHelper(sessionToken);
  }

  final sessionToken;
  PlaceApiHelper apiClient;
  List<Suggestion> _data;
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        // we will display the data returned from our future here
        title: Text((_data[index] as Suggestion).description),
        onTap: () {
          close(context, _data[index] as Suggestion);
        },
      ),
      itemCount: _data.length,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
        // We will put the api call here
        future: query == ""
            ? null
            : apiClient.fetchSuggestions(
                query, Localizations.localeOf(context).languageCode),
        builder: (context, snapshot) {
          if (query == '') {
            return Container(
              padding: EdgeInsets.all(16.0),
              child: Text('Enter your address'),
            );
          }
          if (snapshot.hasData) {
            _data = snapshot.data;
            return ListView.builder(
              itemBuilder: (context, index) => ListTile(
                // we will display the data returned from our future here
                title: Text((snapshot.data[index] as Suggestion).description),
                onTap: () {
                  close(context, snapshot.data[index] as Suggestion);
                },
              ),
              itemCount: snapshot.data.length,
            );
          }
          return Container(child: Text('Loading...'));
        });
  }
}
