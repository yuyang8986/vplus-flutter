import 'package:flutter/material.dart';
import 'package:vplus/helper/appLocalizationHelper.dart';

class OffersListCard extends StatelessWidget {
  String address;
  String title;
  String description;
  String validity;

  OffersListCard({this.title, this.address, this.description, this.validity});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 40),
      elevation: 3,
      shadowColor: Color(0xfff3f3f3),
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 0, top: 20, bottom: 20),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 20),
              child: Row(
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    address,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    "${AppLocalizationHelper.of(context).translate('OFFER DESCRIPTION:')}"+" ",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Color(0xff979797),
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    description,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Text(
                            "${AppLocalizationHelper.of(context).translate('Valid TILL:')}"+" ",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Color(0xff979797),
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            validity,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//  Positioned(

//                         right: -20,
//                         child: RaisedButton(
//                           onPressed: () {},
//                           elevation: 0,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(5),
//                           ),
//                           padding:
//                               EdgeInsets.symmetric(horizontal: 5, vertical: 20),
//                           color: Color(0xffe6fafb),
//                           child: Icon(
//                             Icons.local_offer,
//                             size: 30,
//                           ),
//                         ),
//                       ),
