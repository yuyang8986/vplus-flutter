import 'package:flutter/material.dart';
import 'package:vplus/helper/apiHelper.dart';
import 'package:vplus/models/carousel.dart';

class CarouselProvider extends ChangeNotifier {
  List<String> carousels;
  getCarouselsImageUrls(context) async {
    var hlp = new Helper();
    var response =
        await hlp.getData('api/Ad/carousels', context: context, hasAuth: false);
    if (response.isSuccess) {
      carousels = (response.data as List)
          .map((e) => Carousel.fromJson(e).imageUrl)
          .toList();
      notifyListeners();
    }
  }
}
