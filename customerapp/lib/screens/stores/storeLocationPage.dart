
import 'package:vplus/styles/color.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vplus/models/store.dart';
import 'package:vplus/providers/current_store_provider.dart';

class storeLocationPage extends StatefulWidget {
  @override
  _storeLocationPageState createState() => _storeLocationPageState();
}

class _storeLocationPageState extends State<storeLocationPage>{
  Store store;
  List<Marker> markers = [];
  GoogleMapController mapController;



  @override
  void initState() {
    store = Provider.of<CurrentStoreProvider>(context, listen: false)
        .getCurrentStore;
    markers.add(
      Marker(
          markerId: MarkerId(store.storeName),
          position: LatLng(store.coordinate[0], store.coordinate[1]),
          onTap: (){
            print("我被点了");
          },
          infoWindow: InfoWindow(
            title: store.storeName,
            snippet: store.location,
          )
      )
    );
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appThemeColor,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        title: Text("Store Location"),
        centerTitle: true,
      ),
        body: GoogleMap(
          // onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
          target: LatLng(store.coordinate[0], store.coordinate[1]),
          zoom: 15.0,
        ),
          myLocationEnabled: true,
          markers: Set.from(markers),
        ),
    );
  }
  @override
  void dispose() {
    // webDispose();
    super.dispose();
  }

}