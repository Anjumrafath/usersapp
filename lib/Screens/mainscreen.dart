import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:usersapp/Screens/dropscreen.dart';
import 'package:usersapp/Screens/searchplacesscreen.dart';
import 'package:usersapp/global.dart';
import 'package:usersapp/info/app_info.dart';
import 'package:usersapp/map.dart';
import 'package:usersapp/widget/directiondetailsinfo.dart';
import 'package:usersapp/widget/directions.dart';
import 'package:usersapp/widget/methods.dart';
import 'package:usersapp/widget/progressdialog.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  LatLng? pickLocation;
  loc.Location location = loc.Location();
  String? _address;
  late Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  double searchLocationContainerHeight = 220;
  double waitingResponsefromDriverContainerHeight = 0;
  double assaignedDriverInfoContainerHeight = 0;
  Position? userCurrentPosition;
  var geoLocation = Geolocator();
  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;
  List<LatLng> PLineCoordinatedList = [];
  Set<Polyline> polylineSet = {};
  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};
  String userName = "";
  String userEmail = "";
  bool openNavigationDrawer = true;
  bool activeNearbyDriverKeysLoaded = false;
  BitmapDescriptor? activeNearbyIcon;
  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;
    LatLng latlngPosition =
        LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latlngPosition, zoom: 15);
    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress =
        await Methods.searchAddressForGeographicCoordinates(
            userCurrentPosition!, context);
    print("This is our address =" + humanReadableAddress);
    userName = userModelCurrentInfo!.name!;
    userEmail = userModelCurrentInfo!.email!;

    //initializeGeoFireListenter();
    // Methods.readTripsKeysForOnlineUser(context);
  }

  Future<void> drawPolyLineFromOriginToDestination(bool darkTheme) async {
    var originPosition =
        Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationPosition =
        Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    var originLatLng = LatLng(
        originPosition!.locationLatitude!, originPosition!.locationLongitude!);
    var destinationLatLng = LatLng(destinationPosition!.locationLatitude!,
        destinationPosition!.locationLongitude!);
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            ProgressDialog(message: "Please wait..."));
    var directionDetailsInfo =
        await Methods.obtainOriginToDestinationDirectionDetails(
            originLatLng, destinationLatLng);
    setState(() {
      tripDirectionDetailsInfo = directionDetailsInfo;
    });

    Navigator.pop(context);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodePolyLinePointResultList =
        pPoints.decodePolyline(directionDetailsInfo.e_points!);

    PLineCoordinatedList.clear();
    if (decodePolyLinePointResultList.isEmpty) {
      decodePolyLinePointResultList.forEach((PointLatLng pointLatLng) {
        PLineCoordinatedList.add(
            LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }
    polylineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
        color: darkTheme ? Colors.amberAccent : Colors.black,
        polylineId: PolylineId("PolineId"),
        jointType: JointType.round,
        points: PLineCoordinatedList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 5,
      );
      polylineSet.add(polyline);
    });
    // LatLngBounds boundsLatLng;
    // if (originLatLng.latitude > destinationLatLng.latitude &&
    //     originLatLng.longitude > destinationLatLng.longitude) {
    //   boundsLatLng =
    //       LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    // } else if (originLatLng.longitude > destinationLatLng.longitude) {
    //   boundsLatLng = LatLngBounds(
    //     southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
    //     northeast: LatLng(originLatLng.longitude, destinationLatLng.longitude),
    //   );
    // } else if (originLatLng.latitude > destinationLatLng.latitude) {
    //   boundsLatLng = LatLngBounds(
    //     southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
    //     northeast: LatLng(originLatLng.longitude, destinationLatLng.longitude),
    //   );
    // } else {
    //   boundsLatLng =
    //       LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    // }
    // newGoogleMapController!
    //     .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));
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

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIfLocationPermissionAllowed();
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          body: Stack(
            children: [
              GoogleMap(
                mapType: MapType.normal,
                myLocationEnabled: true,
                zoomGesturesEnabled: true,
                zoomControlsEnabled: true,
                initialCameraPosition: _kGooglePlex,
                polylines: polylineSet,
                markers: markersSet,
                circles: circlesSet,
                onMapCreated: (GoogleMapController controller) {
                  _controllerGoogleMap.complete(controller);
                  newGoogleMapController = controller;
                  setState(() {});
                  locateUserPosition();
                },
                onCameraMove: (CameraPosition? position) {
                  if (pickLocation != position!.target) {
                    setState(() {
                      pickLocation = position.target;
                    });
                  }
                },
                onCameraIdle: () {
                  getAddressFromLatLng();
                },
              ),
              // Align(
              //   alignment: Alignment.center,
              //   child: Padding(
              //     padding: EdgeInsets.only(bottom: 35.0),
              //     child: Image.asset("assets/images/pick.jpg",
              //         height: 45, width: 45),
              //   ),
              // ),

              //ui for searching location
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: darkTheme ? Colors.black : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: darkTheme
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Row(
                                          children: [
                                            Icon(Icons.location_on_outlined,
                                                color: darkTheme
                                                    ? Colors.amber.shade400
                                                    : Colors.blue),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "from",
                                                  style: TextStyle(
                                                    color: darkTheme
                                                        ? Colors.amber.shade400
                                                        : Colors.blue,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  Provider.of<AppInfo>(context)
                                                              .userPickUpLocation !=
                                                          null
                                                      ? (Provider.of<AppInfo>(
                                                                      context)
                                                                  .userPickUpLocation!
                                                                  .locationName!)
                                                              .substring(
                                                                  0, 24) +
                                                          "..."
                                                      : "Not getting Address",
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Divider(
                                        height: 1,
                                        thickness: 2,
                                        color: darkTheme
                                            ? Colors.amber.shade400
                                            : Colors.blue,
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )),
                      ],
                    )),
              )
              // Positioned(
              //   top: 40,
              //   right: 20,
              //   left: 20,
              //   child: Container(
              //     decoration: BoxDecoration(
              //       border: Border.all(color: Colors.black),
              //       color: Colors.white,
              //     ),
              // //     padding: EdgeInsets.all(20),
              //     child: Text(
              //       Provider.of<AppInfo>(context).userPickUpLocation != null
              //           ? (Provider.of<AppInfo>(context)
              //                       .userPickUpLocation!
              //                       .locationName!)
              //                   .substring(0, 24) +
              //               "..."
              //           : "Not getting Address",
              //       overflow: TextOverflow.visible,
              //       softWrap: true,
              //  ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
