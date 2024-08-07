import 'package:flutter/material.dart';
import 'package:usersapp/Screens/fare.dart';
import 'package:usersapp/Screens/forgotpasswordscreen.dart';
import 'package:usersapp/Screens/loginscreen.dart';
import 'package:usersapp/Screens/notification.dart';
import 'package:usersapp/Screens/profilescreen.dart';
import 'package:usersapp/Screens/searchplacesscreen.dart';
import 'package:usersapp/global.dart';

class ProfileMainWidget extends StatefulWidget {
  ProfileMainWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<ProfileMainWidget> createState() => _ProfileMainWidgetState();
}

class _ProfileMainWidgetState extends State<ProfileMainWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.red,
      appBar: AppBar(
        //  backgroundColor: Colors.red,
        title: Text(
          userModelCurrentInfo!.name!,
          style: TextStyle(color: Colors.blueGrey),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: InkWell(
                onTap: () {
                  _openBottomModalSheet(context);
                },
                child: Icon(
                  Icons.menu,
                  color: Colors.blueGrey,
                )),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.asset("assets/user.png"),
                  ),
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (c) => Fare()));
                },
                child: Column(
                  children: [
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      color: Colors.grey,
                      child: Center(
                        child: Text(
                          "Fare",
                          style: TextStyle(color: Colors.purple, fontSize: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (c) => ForgotPasswordScreen()));
                },
                child: Column(
                  children: [
                    Container(
                      color: Colors.grey,
                      child: Center(
                        child: Text(
                          "ChangePassword",
                          style: TextStyle(color: Colors.purple, fontSize: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => SearchPlacesScreen()));
                },
                child: Column(
                  children: [
                    Container(
                      color: Colors.grey,
                      child: Center(
                        child: Text(
                          "Search",
                          style: TextStyle(color: Colors.purple, fontSize: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => NotificationScreen()));
                },
                child: Column(
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      color: Colors.grey,
                      child: Center(
                        child: Text(
                          "Notifications",
                          style: TextStyle(color: Colors.purple, fontSize: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _openBottomModalSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: 150,
            decoration: BoxDecoration(color: Colors.white.withOpacity(.8)),
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        "More Options",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.blueGrey),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Divider(
                      thickness: 1,
                      color: Colors.blue,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => ProfileScreen()));
                        },
                        child: Text(
                          "Edit Profile",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.blueGrey),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Divider(
                      thickness: 1,
                      color: Colors.blue,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: InkWell(
                        onTap: () {
                          firebaseAuth.signOut();
                          Navigator.push(context,
                              MaterialPageRoute(builder: (c) => LoginScreen()));
                        },
                        child: Text(
                          "Logout",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.blueGrey),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
