import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/apiHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/carousel.dart';
import 'package:vplus/providers/carousel_provider.dart';

List getImageSliders(imgList) {
  return imgList
      .map<Widget>((item) => Container(
            child: Container(
              // margin: EdgeInsets.all(5.0),
              child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  child: Stack(
                    children: <Widget>[
                      Image.network(item,
                          fit: BoxFit.contain,
                          width: SizeHelper.widthMultiplier * 250,
                          height: SizeHelper.heightMultiplier * 200)
                    ],
                  )),
            ),
          ))
      .toList();
}

class CarouselWithIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CarouselProvider>(builder: (ctx, p, w) {
      var carousels = p.carousels;
      if (carousels == null || carousels?.length == 0) return Container();
      return CarouselSlider(
          options: CarouselOptions(
            autoPlay: true,
            // aspectRatio: 2.5,
            enlargeCenterPage: true,
          ),
          items: getImageSliders(carousels));
    });
  }
}
