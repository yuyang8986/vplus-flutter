import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/helper.dart';
import 'package:vplus/models/user.dart';
import 'package:vplus/models/visitDetails.dart';
import 'package:vplus/providers/currentuser_provider.dart';
import 'package:vplus/widgets/appBar.dart';

class Details extends StatefulWidget {
  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  Map<String, dynamic> data;
  bool isLoading = true;
  var hlp = Helper();

  User user;

  void getData(int visitId) async {
    var visitData = await hlp.getData("api/visits/$visitId",
        hasAuth: true, context: context);
    var visitDetails = VisitDetails.fromJson(visitData);

    var visitDate = new DateFormat.yMMMd()
        .format(DateTime.parse(visitDetails.visitDateTime));
    var visitTime = new DateFormat('hh:mm aa')
        .format(DateTime.parse(visitDetails.visitDateTime));

    setState(() {
      data = {
        "user": user.name,
        "place": visitDetails.organizationName,
        "dt": visitDate,
        "time": visitTime,
        "address": visitDetails.organizationAddress,
        "description": visitDetails.rewardDescription == null
            ? ''
            : visitDetails.rewardDescription
      };
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<CurrentUserProvider>(context).getloggedInUser;
    var future = Future.delayed(Duration.zero, () {
      Map args = ModalRoute.of(context).settings.arguments;
      print(args);
      getData(args['visitId']);
    });
    return Scaffold(
      appBar: CustomAppBar.getAppBar('', false, context: context),
      body: isLoading == true
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              color: Color(0xFFfafafa),
              margin: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(
                        'Hello ${data['user']}!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 20, bottom: 20),
                          child: Column(
                            children: <Widget>[
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    height: 1.5,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: 'Thanks for visiting ',
                                    ),
                                    TextSpan(
                                      text:
                                          '${data['place']}, ${data['address'] ?? ""}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: ' on ',
                                    ),
                                  ],
                                ),
                              ),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    height: 1.5,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: ' ${data['dt']} ${data['time']}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                    ],
                  ),
                  // Column(
                  //   children: <Widget>[
                  //     Text(
                  //       'Please enjoy the offer:',
                  //       style: TextStyle(
                  //         fontSize: 18,
                  //       ),
                  //     ),
                  //     SizedBox(height: 10),
                  //     Text(
                  //       data['description'],
                  //       style: TextStyle(
                  //         fontSize: 18,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  Image.asset(
                    'assets/images/offerDetail.png',
                    fit: BoxFit.fill,
                  ),
                ],
              ),
            ),
    );
  }
}
