import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        width: 1080, height: 1920, allowFontScaling: false);
    return SafeArea(
      bottom: false,
      top: true,
      child: Scaffold(
        //appBar: CustomAppBar.getAppBar('', false),
        backgroundColor: Color(0xFFfafafa),
        body: Container(
          margin: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Welcome to Vplus',
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
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
                      'LOGIN',
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        //bottomNavigationBar: Footer(),
      ),
    );
  }
}
