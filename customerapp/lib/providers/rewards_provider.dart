import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/helper.dart';
import 'package:vplus/models/rewards.dart';

import 'currentuser_provider.dart';

class RewardsProvider with ChangeNotifier {
  List<Offer> rewards;

  Future<List<Offer>> getRewards(BuildContext context) async {
    Helper hlp = Helper();
    var user = Provider.of<CurrentUserProvider>(context).getloggedInUser;

    List<dynamic> rewardsList = await hlp.getData(
        "api/Users/${user.id}/rewards",
        hasAuth: true,
        context: context);
    List<Offer> list = [];
    if (rewardsList != null) {
      rewardsList.forEach((element) {
        list.add(Offer.fromJson(element));
      });
    }
    rewards = list;
    return list;
  }
}
