import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:usersapp/global.dart';
import 'package:usersapp/info/app_info.dart';
import 'package:usersapp/map.dart';
import 'package:usersapp/model/usermodel.dart';
import 'package:usersapp/widget/directions.dart';
import 'package:usersapp/widget/request.dart';

class Methods {
  static void readCurrentOnlineUserInfo() {
    currentUser = firebaseAuth.currentUser;
    DatabaseReference userRef =
        FirebaseDatabase.instance.ref().child("users").child(currentUser!.uid);
    userRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
      }
    });
  }

  static Future<String> searchAddressForGeographicCoordinates(
      Position position, context) async {
    String apiUrl =
        "http://maps.googleapis.com/maps/api/geocode/json?latlng= ${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress = "";
    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);
    if (requestResponse != "Error occured, No Response") {
      humanReadableAddress = requestResponse["results"][0]["formatted address"];
      Directions userDropOffAddress = Directions();
      userDropOffAddress.locationLatitude = position.latitude;
      userDropOffAddress.locationLongitude = position.longitude;
      userDropOffAddress.locationName = humanReadableAddress;
      Provider.of<AppInfo>(context, listen: false)
          .updateDropOffLocationAddress(userDropOffAddress);
    }
    return humanReadableAddress;
  }
}
