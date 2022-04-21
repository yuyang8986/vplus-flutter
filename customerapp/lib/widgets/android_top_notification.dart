import 'dart:io';

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
      body = message['userOrderId'];
    }
    return SafeArea(
      top: true,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4),
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
          title: Text("Your Order Status is Updated"),
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
