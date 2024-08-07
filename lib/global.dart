import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:usersapp/model/usermodel.dart';
import 'package:usersapp/widget/directiondetailsinfo.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

User? currentUser;
UserModel? userModelCurrentInfo;
//String cloudMessagingServerToken=,

DirectionsDetailsInfo? tripDirectionDetailsInfo;
List driversList = [];
List onlineNearestDriversList = [];
String userDropOffAddress = "";
String driverCarDetails = '';
String driverName = '';
String driverPhone = '';
double countRatingStars = 0.0;
String titleStarsRating = '';
Future<void> fetchCurrentUserInfo() async {
  currentUser = firebaseAuth.currentUser;
  if (currentUser != null) {
    DatabaseReference userRef =
        FirebaseDatabase.instance.ref().child("users").child(currentUser!.uid);
    DataSnapshot snapshot = await userRef.get();
    if (snapshot.exists) {
      userModelCurrentInfo = UserModel.fromSnapshot(snapshot);
    }
  }
}
