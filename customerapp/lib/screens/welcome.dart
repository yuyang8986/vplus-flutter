import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:vplus/helper/sizeHelper.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 1080, height: 1920, allowFontScaling: true);
    return Scaffold(
      //appBar: CustomAppBar.getAppBar('', false),
      backgroundColor: Color(0xFFfafafa),
      body: Container(
        margin: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Your Grocery Needs. Vplus to your door',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: SizeHelper.textMultiplier * 3.5,
              ),
            ),
            // Text(
            //   'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer porttitor dolor at tellus feugiat, vitae auctor lorem eleifend',
            //   textAlign: TextAlign.center,
            //   style: TextStyle(fontSize: 16),
            // ),
            Image.asset(
              'assets/images/welcome.png',
              width: MediaQuery.of(context).size.width,
            ),
            Container(
              width: double.infinity,
              child: RaisedButton(
                elevation: 4,
                onPressed: () {
                  Navigator.pushNamed(context, "SignInPage");
                },
                textColor: Colors.white,
                color: Color(0xff5352ec),
                padding: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: SizedBox(
                  child: Text(
                    'START',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    key: Key('welcomeLoginButton'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      //bottomNavigationBar: Footer(),
    );
  }
}
