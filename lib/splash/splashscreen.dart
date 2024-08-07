import 'dart:async';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:usersapp/Screens/mapmain.dart';
import 'package:usersapp/Screens/mapscreen.dart';
import 'package:usersapp/global.dart';
import 'package:usersapp/Screens/loginscreen.dart';
import 'package:usersapp/Screens/mainscreen.dart';
import 'package:usersapp/widget/methods.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  startTimer() {
    Timer(Duration(seconds: 5), () async {
      if (await firebaseAuth.currentUser != null) {
        firebaseAuth.currentUser != null
            ? Methods.readCurrentOnlineUserInfo()
            : null;
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Center(
            //   child: LottieBuilder.asset(
            //       'assets/animation/Animation - 1718795529371 .json '),
            // ),
            Center(
              child: Text(
                "Rider",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Center(
                child: Image.asset(
              "assets/cars.png",
            )),
          ],
        ),
      ),
      nextScreen: LoginScreen(),
      splashIconSize: 500,
      backgroundColor: Colors.white,
    );
  }
}
