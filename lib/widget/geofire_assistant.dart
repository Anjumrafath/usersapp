import 'package:usersapp/model/activeavailabledrivers.dart';

class GeofireAssistant {
  static List<ActiveNearbyAvailableDrivers> activeNearbyAvailableDriversList =
      [];

  // static void deleteOffLineDriversFromList(String driverId) {
  //   int indexNumber = activeNearByAvailableDriversList
  //       .indexWhere((element) => element.driverId == driverId);
  // }

  static void updateActiveNearbyAvailableDriverLocation(
      ActiveNearbyAvailableDrivers driverWhoMove) {
    int indexNumber = activeNearbyAvailableDriversList
        .indexWhere((element) => element.driverid == driverWhoMove.driverid);

    activeNearbyAvailableDriversList[indexNumber].locationlatitude =
        driverWhoMove.locationlatitude;

    activeNearbyAvailableDriversList[indexNumber].locationlongitude =
        driverWhoMove.locationlongitude;
  }
}
