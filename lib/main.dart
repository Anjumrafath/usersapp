import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:usersapp/Screens/dashboard.dart';
import 'package:usersapp/Screens/fare.dart';
import 'package:usersapp/Screens/mapmain.dart';
import 'package:usersapp/Screens/mapscreen.dart';
import 'package:usersapp/firebase_options.dart';
import 'package:usersapp/Screens/loginscreen.dart';
import 'package:usersapp/Screens/mainscreen.dart';
import 'package:usersapp/Screens/registerscreen.dart';
import 'package:usersapp/global.dart';
import 'package:usersapp/info/app_info.dart';
import 'package:usersapp/splash/splashscreen.dart';
import 'package:usersapp/themes/themeprovider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await fetchCurrentUserInfo();
  await Permission.locationWhenInUse.isDenied.then((valueOfPermission) {
    if (valueOfPermission) {
      Permission.locationWhenInUse.request();
    }
  });
  await AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelGroupKey: "basic_channel_group",
      channelKey: "Basic channel",
      channelName: "Basic Notifications",
      channelDescription: "Basic Notification Channel",
    )
  ], channelGroups: [
    NotificationChannelGroup(
        channelGroupKey: "basic_channel_group",
        channelGroupName: "Basic group"),
  ]);
  bool isAllowedToSendNotification =
      await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowedToSendNotification) {
    AwesomeNotifications().requestPermissionToSendNotifications();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppInfo(),
      child: MaterialApp(
        title: 'Uber',
        themeMode: ThemeMode.system,
        theme: MyThemes.lightTheme,
        darkTheme: MyThemes.darkTheme,
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}
