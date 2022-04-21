import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

class TopNotication extends StatelessWidget {
  final Map message;
  TopNotication(this.message);
  @override
  Widget build(BuildContext context) {
    var body;
    if (Platform.isAndroid) {
      body = message['userOrderId'];
    } else if (Platform.isIOS) {
      body = message['aps']['alert']['body'];
    }
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: SafeArea(
        child: ListTile(
          leading: SizedBox.fromSize(
              size: const Size(40, 40),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/vm-icon.png',
                  fit: BoxFit.contain,
                  height: 32,
                  width: 48,
                ),
              )),
          title: Text("You have a new order placed - Vplus Food Online Ordering"),
          subtitle: Text(body),
          trailing: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                OverlaySupportEntry.of(context).dismiss();
              }),
        ),
      ),
    );
  }
}
