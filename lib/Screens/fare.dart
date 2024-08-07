import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:location/location.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:usersapp/Screens/destiplace.dart';
import 'package:usersapp/global.dart';
import 'package:usersapp/info/app_info.dart';
import 'package:usersapp/map.dart';
import 'package:usersapp/model/activeavailabledrivers.dart';
import 'package:usersapp/widget/directiondetailsinfo.dart';
import 'package:usersapp/widget/directions.dart';
import 'package:usersapp/widget/geofire_assistant.dart';

class Fare extends StatefulWidget {
  Fare({super.key});

  @override
  State<Fare> createState() => _FareState();
}

class _FareState extends State<Fare> {
  LatLng userPickUpLocation = LatLng(37.4223, -122.0848);
  LatLng userDropOfLocation = LatLng(37.3346, -122.0091);

  String? _address;
  LatLng? pickLocation;
  double searchingForDriverContainerHeight = 0;
  String? selectedVehicleType = '';
  double suggestedRidesContainerHeight = 0;
  double bottomPaddingOfMap = 0;
  DatabaseReference? referenceRideRequest;
  String driverRideStatus = "Driver is Coming";
  String userRideRequestStatus = '';
  StreamSubscription<DatabaseEvent>? tripRideRequstInfoStreamSubscription;
  List<ActiveNearbyAvailableDrivers> onlineNearByAvailableDriversList = [];
  bool requestPositioInfo = true;

  saveRideRequestInformation(String selectedVehicleType) {
//save the ride request inf
    referenceRideRequest =
        FirebaseDatabase.instance.ref().child("All Ride Request").push();
    var originLocation =
        Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationLocation =
        Provider.of<AppInfo>(context, listen: false).userDropOffLocation;
    Map originLocationMap = {
      //key:value
      "latitude": originLocation!.locationLatitude.toString(),
      "longitude": originLocation.locationLongitude.toString(),
    };
    Map destinationLocationMap = {
      //key:value
      "latitude": destinationLocation!.locationLatitude.toString(),
      "longitude": destinationLocation.locationLongitude.toString(),
    };
    Map userInformationMap = {
      "origin": originLocationMap,
      "destination": destinationLocationMap,
      "time": DateTime.now().toString(),
      "userName": userModelCurrentInfo!.name,
      "userPhone": userModelCurrentInfo!.phone,
      "originAddress": originLocation.locationName,
      "destinationAddress": destinationLocation.locationName,
      "driverId": "waiting",
    };
    referenceRideRequest!.set(userInformationMap);
    tripRideRequstInfoStreamSubscription =
        referenceRideRequest!.onValue.listen((eventSnap) async {
      if (eventSnap.snapshot.value == null) {
        return;
      }
      if ((eventSnap.snapshot.value as Map)["car_details"] != null) {
        setState(() {
          driverCarDetails =
              (eventSnap.snapshot.value as Map)["car_details"].toString();
        });
      }
      if ((eventSnap.snapshot.value as Map)["driverphone"] != null) {
        setState(() {
          driverCarDetails =
              (eventSnap.snapshot.value as Map)["driverPhone"].toString();
        });
      }
      if ((eventSnap.snapshot.value as Map)["driverName"] != null) {
        setState(() {
          driverCarDetails =
              (eventSnap.snapshot.value as Map)["driverName"].toString();
        });
      }
      if ((eventSnap.snapshot.value as Map)["Status"] != null) {
        setState(() {
          userRideRequestStatus =
              (eventSnap.snapshot.value as Map)["Status"].toString();
        });
      }
      if ((eventSnap.snapshot.value as Map)["driverLocation"] != null) {
        double driverCurrentPositionLat = double.parse(
            (eventSnap.snapshot.value as Map)["driverLocation"]["latitude"]
                .toString());
        double driverCurrentPositionLng = double.parse(
            (eventSnap.snapshot.value as Map)["driverLocation"]["longitude"]
                .toString());
        LatLng driverCurrentPositionLatLng =
            LatLng(driverCurrentPositionLat, driverCurrentPositionLng);
        //status=accepted
        if (userRideRequestStatus == "accepted") {
          updateArrivalTimeToUserPickUpLocation(driverCurrentPositionLatLng);
        }
        //status=arrived
        if (userRideRequestStatus == "arrived") {
          setState(() {
            driverRideStatus = "Diver has arrived";
          });
        }
        //status=onTrip
        if (userRideRequestStatus == "onTrip") {
          updateReachingTimeToUserDropOffLocation(driverCurrentPositionLatLng);
        }
        if (userRideRequestStatus == "ended") {
          if ((eventSnap.snapshot.value as Map)["fareAmount"] != null) {
            double fareAmount = double.parse(
                (eventSnap.snapshot.value as Map)["fareAmount"].toString());
            // var response = await showDialog(
            //     context: context,
            //     builder: (BuildContext context) => PayFareAmountDialog(
            //           fareAmount: fareAmount,
            //         ));
            // if (response == "Cash paid") {
            //   //user can rate the driver now
            //   if ((eventSnap.snapshot.value as Map)["driverId"] != null) {
            //     String assaignedDriverId =
            //         (eventSnap.snapshot.value as Map)["driverId"].toString();
            //     // Navigator.push(context,
            //     //     MaterialPageRoute(builder: (c) => RateDriverScreen()));
            //     referenceRideRequest!.onDisconnect();
            //     tripRideRequstInfoStreamSubscription!.cancel();
            //   }
            // }
          }
        }
      }
    });
    onlineNearByAvailableDriversList =
        GeofireAssistant.activeNearbyAvailableDriversList;
    searchNearestOnlineDrivers(selectedVehicleType);
  }

  void showSuggestedRidesContainer() {
    setState(() {
      suggestedRidesContainerHeight = 400;
      bottomPaddingOfMap = 400;
    });
  }

  getAddressFromLatLng() async {
    try {
      GeoData data = await Geocoder2.getDataFromCoordinates(
          latitude: pickLocation!.latitude,
          longitude: pickLocation!.longitude,
          googleMapApiKey: mapKey);
      setState(() {
        Directions userPickUpAddress = Directions();
        userPickUpAddress.locationLatitude = pickLocation!.latitude;
        userPickUpAddress.locationLongitude = pickLocation!.longitude;
        userPickUpAddress.locationName = data.address;

        Provider.of<AppInfo>(context, listen: false)
            .updatePickUpLocationAddress(userPickUpAddress);
        // _address = data.address;
      });
    } catch (e) {
      print(e);
    }
  }

  static double calculateFareAmountFromoriginToDestination(
      DirectionsDetailsInfo directionsdetailinfo) {
    double timeTraveledFareAmountPerMinute =
        (directionsdetailinfo.duration_value! / 60) * 0.1;
    double distanceTraveledFareAmountPerKilometer =
        (directionsdetailinfo.duration_value! / 1000) * 0.1;
    //usd
    double totalFareAmount = timeTraveledFareAmountPerMinute =
        distanceTraveledFareAmountPerKilometer;
    return double.parse(totalFareAmount.toStringAsFixed(1));
  }

  updateArrivalTimeToUserPickUpLocation(driverCurrentPositionLatLng) async {
    if (requestPositioInfo == true) {
      requestPositioInfo = false;
      LatLng userPickUpPosition =
          LatLng(userPickUpLocation.latitude, userPickUpLocation.longitude);
      //  var directionDetailsInfo=await obtainOriginalToDestinationDirectionDetails
      if (DirectionsDetailsInfo == null) {
        return;
      }
      setState(() {
        var directionDetailsInfo;
        driverRideStatus = "Driver is coming.." +
            directionDetailsInfo.duration_text.toString();
      });
      requestPositioInfo = true;
    }
  }

  updateReachingTimeToUserDropOffLocation(driverCurrentPositionLatLng) {
    if (requestPositioInfo == true) {
      requestPositioInfo = false;
      var dropOffLocation =
          Provider.of<AppInfo>(context, listen: false).userDropOffLocation;
      LatLng userDestinationPosition = LatLng(
          dropOffLocation!.locationLatitude!,
          dropOffLocation!.locationLongitude!);
      // var direction details
    }
  }

  searchNearestOnlineDrivers(selectedVehicleType) async {
    if (onlineNearByAvailableDriversList.length == 0) {
      referenceRideRequest!.remove();
      setState(() {
        //PolylineSet!.clear();
      });
      Fluttertoast.showToast(msg: "no online nearest drivers");
      Future.delayed(Duration(milliseconds: 4000), () {
        referenceRideRequest!.remove();
      });
      return;
    }
    await retrieveOnlineDriversInformation(onlineNearByAvailableDriversList);
    print("Drivers list" + driversList.toString());
    for (int i = 0; i < driversList.length; i++) {
      // if (driversList[i]["car_details"]["type"] == selectedVehicleType) {
      //   Methods.sendNotificationToDriverNow(
      //       driversList[i]["token"], referenceRideRequest!.key!, context);
      // }
    }
    Fluttertoast.showToast(msg: "Notifications sent successfully");
    showSearchingForDriverContainer();
    await FirebaseDatabase.instance
        .ref()
        .child("All ride request")
        .child(referenceRideRequest!.key!)
        .child("driverId")
        .onValue
        .listen((eventRideRequestSnapshot) {
      print("EventSnapshot:${eventRideRequestSnapshot.snapshot.value}");

      if (eventRideRequestSnapshot.snapshot.value != null) {
        if (eventRideRequestSnapshot.snapshot.value != 'waiting') {
          showUiForAssaingedDriverInfo();
        }
      }
    });
  }

  retrieveOnlineDriversInformation(List onlineNearDriversList) async {
    driversList.clear();
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("drivers");
    for (int i = 0; i < onlineNearestDriversList.length; i++) {
      await ref
          .child(onlineNearDriversList[i].driverId.toString())
          .once()
          .then((dataSnapshot) {
        var driverKeyInfo = dataSnapshot.snapshot.value;
        driversList.add(driverKeyInfo);
        print("driver key information" + driversList.toString());
      });
    }
  }

  showSearchingForDriverContainer() {
    setState(() {
      searchingForDriverContainerHeight = 200;
    });
  }

  showUiForAssaingedDriverInfo() {
    var waitingResponsefromDriverContainerHeight = 0;
    var searchLocationContainerHeight = 0;
    var assignedDriverInfoContainerHeight = 200;
    suggestedRidesContainerHeight = 0;
    bottomPaddingOfMap = 200;
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              )),
        ),
        backgroundColor: Colors.grey.shade200,
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                Image.asset("assets/money.png", height: 300, width: 200),
                GestureDetector(
                  onTap: () {
                    showSuggestedRidesContainer();
                  },
                  child: Container(
                    height: 50,
                    width: 150,
                    color: Colors.blue, // Change color as needed
                    child: Center(
                      child: Text(
                        "Show Suggestions",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                // AnimatedContainer(
                //   duration: Duration(milliseconds: 300),
                //   height: suggestedRidesContainerHeight,
                //   decoration: BoxDecoration(
                //     color: selectedVehicleType == "car"
                //         ? Colors.amber
                //         : Colors
                //             .transparent, // Change to another color or set to transparent based on your design
                //     borderRadius: BorderRadius.only(
                //       topLeft: Radius.circular(12),
                //       topRight: Radius.circular(12),
                //     ),
                //   ),SingleChildScrollView(
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Icon(Icons.star, color: Colors.white),
                          ),
                          SizedBox(width: 15),
                          // getAddressFromLatLng(),
                          Text(
                              Provider.of<AppInfo>(context)
                                          .userPickUpLocation !=
                                      null
                                  ? (Provider.of<AppInfo>(context)
                                              .userPickUpLocation!
                                              .locationName!)
                                          .substring(0, 20) +
                                      ''
                                  : "_pgooglePlex",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  color: Colors.black45)),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Icon(Icons.star, color: Colors.white),
                          ),
                          SizedBox(width: 15),
                          //getAddressFromLatLng(),
                          Text(
                              Provider.of<AppInfo>(context)
                                          .userDropOffLocation !=
                                      null
                                  ? (Provider.of<AppInfo>(context)
                                              .userDropOffLocation!
                                              .locationName!)
                                          .substring(0, 20) +
                                      ''
                                  : "_pApplePark",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  color: Colors.black45)),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text("Suggested Rides",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.grey,
                          )),
                    ],
                  ),
                ),

                // Add more widgets as needed
                SizedBox(height: 5),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedVehicleType = "Car";
                        });
                      },
                      child: Container(
                          decoration: BoxDecoration(
                            color: selectedVehicleType == "Car"
                                ? (darkTheme ? Colors.amber : Colors.blue)
                                : (darkTheme ? Colors.white : Colors.black),
                            //color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                              padding: EdgeInsets.all(25),
                              child: Column(
                                children: [
                                  Image.asset("assets/car1.png",
                                      height: 100, width: 100, scale: 2),
                                  SizedBox(height: 8),
                                  Text(
                                    "Car",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: selectedVehicleType == "Car"
                                          ? (darkTheme
                                              ? Colors.black
                                              : Colors.white)
                                          : (darkTheme
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    tripDirectionDetailsInfo != null
                                        ? ' ${((calculateFareAmountFromoriginToDestination(tripDirectionDetailsInfo!) * 2) * 107).toStringAsFixed(1)}'
                                        : "null",
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ))),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedVehicleType = "CNG";
                        });
                      },
                      child: Container(
                          decoration: BoxDecoration(
                            color: selectedVehicleType == "CNG"
                                ? (darkTheme ? Colors.amber : Colors.blue)
                                : (darkTheme ? Colors.white : Colors.black),
                            //color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                              padding: EdgeInsets.all(25),
                              child: Column(
                                children: [
                                  Image.asset("assets/cng.png",
                                      height: 100, width: 100, scale: 2),
                                  SizedBox(height: 8),
                                  Text(
                                    "CNG",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: selectedVehicleType == "CNG"
                                          ? (darkTheme
                                              ? Colors.black
                                              : Colors.white)
                                          : (darkTheme
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    tripDirectionDetailsInfo != null
                                        ? ' ${((calculateFareAmountFromoriginToDestination(tripDirectionDetailsInfo!) * 1.5) * 107).toStringAsFixed(1)}'
                                        : "null",
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ))),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedVehicleType = "Bike";
                        });
                      },
                      child: Container(
                          decoration: BoxDecoration(
                            color: selectedVehicleType == "Bike"
                                ? (darkTheme ? Colors.amber : Colors.blue)
                                : (darkTheme ? Colors.white : Colors.black),
                            //color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                              padding: EdgeInsets.all(25),
                              child: Column(
                                children: [
                                  Image.asset("assets/bike.png",
                                      height: 100, width: 100, scale: 2),
                                  SizedBox(height: 8),
                                  Text(
                                    "Bike",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: selectedVehicleType == "Bike"
                                          ? (darkTheme
                                              ? Colors.black
                                              : Colors.white)
                                          : (darkTheme
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    tripDirectionDetailsInfo != null
                                        ? ' ${((calculateFareAmountFromoriginToDestination(tripDirectionDetailsInfo!) * 0.8) * 107).toStringAsFixed(1)}'
                                        : "null",
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ))),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: GestureDetector(
                        onTap: () {
                          if (selectedVehicleType != '') {
                            saveRideRequestInformation(selectedVehicleType!);
                          } else {
                            Fluttertoast.showToast(
                                msg: "Please select vehicle to ride");
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                darkTheme ? Colors.amber.shade300 : Colors.blue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text("Request a Ride",
                                style: TextStyle(
                                  color:
                                      darkTheme ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                )),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
