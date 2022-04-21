import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vplus/providers/rewards_provider.dart';
import 'package:vplus/styles/color.dart';
import 'package:vplus/widgets/components.dart';
import 'package:vplus/models/rewards.dart';
import 'package:vplus/widgets/listCard.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({Key key}) : super(key: key);
  @override
  RewardsScreenState createState() => RewardsScreenState();
}

class RewardsScreenState extends State<RewardsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: bodyColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Row(
            children: <Widget>[
              Image.asset(
                'assets/images/logo-small.png',
                fit: BoxFit.contain,
                height: 32,
              ),
              Expanded(
                child: Text(
                  'Rewards',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
              Image.asset(
                'assets/images/profile.png',
                fit: BoxFit.contain,
                height: 32,
              )
            ],
          ),
          elevation: 0,
          bottom: TabBar(
            labelColor: Colors.black,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            indicatorColor: Color(0xff23bdbd),
            onTap: (value) {
              // print(value);
              // if (value == 0) {
              //   loadRewards();
              // }
            },
            tabs: [
              Tab(
                child: Text('REWARDS'),
              ),
              Tab(
                child: Text('LOYALTIES'),
              ),
            ],
          ),
        ),
        body: Container(
          child: TabBarView(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 20, left: 20, right: 20, bottom: 1),
                child: FutureBuilder(
                  future: Provider.of<RewardsProvider>(context, listen: false)
                      .getRewards(context),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      var data = Provider.of<RewardsProvider>(context).rewards;
                      return Container(
                        child: ListView.builder(
                          itemCount: data.length,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (BuildContext context, int index) {
                            Offer item = data[index];
                            print(item.validTo);

                            var validity = new DateFormat.yMMMd()
                                .format(DateTime.parse(item.validTo));
                            // return Container();

                            return OffersListCard(
                              title: item.organizationName,
                              address: item.organizationAddress,
                              description: item.rewardDescription,
                              validity: validity,
                            );
                          },
                        ),
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
              Icon(Icons.directions_transit),
            ],
          ),
        ),
      ),
    );
  }
}
