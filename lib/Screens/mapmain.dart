import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:usersapp/Screens/loginscreen.dart';
import 'package:usersapp/Screens/mainscreen.dart';
import 'package:usersapp/Screens/profilescreen.dart';
import 'package:usersapp/Screens/searchplacesscreen.dart';
import 'package:usersapp/map.dart';
import 'package:usersapp/model/activeavailabledrivers.dart';
import 'package:usersapp/widget/geofire_assistant.dart';

class Maps extends StatefulWidget {
  const Maps({super.key});

  @override
  State<Maps> createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  Location _locationController = Location();
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  static const LatLng _pGooglePlex = LatLng(37.4223, -122.0848);
  static const LatLng _pApplePark = LatLng(37.3346, -122.0091);
  LatLng? _currentP;
  BitmapDescriptor? activeNearbyDriverIcon;
  Map<PolylineId, Polyline> polylines = {};
  Set<Marker> driversMarkerSet = {};

  @override
  void initState() {
    super.initState();
    print("Initializing Map Screen...");
    createActiveNearbyDriverIconMarker();
    getLocationUpdates().then((value) {
      print("Location updates started.");
      getPolylinePoints().then((coordinates) {
        print("Polyline points received.");
        generatePolylineFromPoints(coordinates);
      });
    });
    initializeGeoFireListener();
  }

  Future<void> createActiveNearbyDriverIconMarker() async {
    try {
      BitmapDescriptor bitmapDescriptor = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(20, 20)), // Adjust size as needed
        'assets/images/car.jpg',
      );
      setState(() {
        activeNearbyDriverIcon = bitmapDescriptor;
      });
      print("Car icon created.");
    } catch (e) {
      print('Error loading car icon: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text("Map Screen", style: TextStyle(color: Colors.white)),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.grey),
              child: Text('About',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Search'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SearchPlacesScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.place),
              title: const Text('Place'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MainScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfileScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()));
              },
            ),
          ],
        ),
      ),
      body: _currentP == null
          ? const Center(child: Text("Loading.."))
          : GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController.complete(controller);
                print("Map created.");
              },
              initialCameraPosition:
                  const CameraPosition(target: _pGooglePlex, zoom: 13),
              markers: {
                Marker(
                  markerId: const MarkerId("currentLocation"),
                  icon: BitmapDescriptor.defaultMarker,
                  position: _currentP!,
                ),
                const Marker(
                  markerId: MarkerId("sourceLocation"),
                  icon: BitmapDescriptor.defaultMarker,
                  position: _pGooglePlex,
                ),
                const Marker(
                  markerId: MarkerId("destinationLocation"),
                  icon: BitmapDescriptor.defaultMarker,
                  position: _pApplePark,
                ),
              }.union(driversMarkerSet),
              polylines: Set<Polyline>.of(polylines.values),
            ),
    );
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition _newCameraPosition = CameraPosition(target: pos, zoom: 13);
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(_newCameraPosition));
  }

  Future<void> getLocationUpdates() async {
    bool _serviceEnabled = await _locationController.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    PermissionStatus _permissionGranted =
        await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationController.onLocationChanged
        .listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentP =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
        });
      }
    });
  }

  Future<List<LatLng>> getPolylinePoints() async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      mapKey, // Replace with your Google Maps API key
      PointLatLng(_pGooglePlex.latitude, _pGooglePlex.longitude),
      PointLatLng(_pApplePark.latitude, _pApplePark.longitude),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      for (PointLatLng point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    } else {
      print(result.errorMessage);
    }
    return polylineCoordinates;
  }

  void generatePolylineFromPoints(List<LatLng> polylineCoordinates) async {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.purple,
      points: polylineCoordinates,
      width: 8,
    );
    setState(() {
      polylines[id] = polyline;
    });
  }

  void initializeGeoFireListener() {
    Geofire.initialize("activeDrivers");
    Geofire.queryAtLocation(_pGooglePlex.latitude, _pGooglePlex.longitude, 10)!
        .listen((map) {
      if (map != null) {
        var callBack = map["callBack"];
        switch (callBack) {
          case Geofire.onKeyEntered:
            addDriverToList(map);
            break;
          case Geofire.onKeyExited:
            removeDriverFromList(map);
            break;
          case Geofire.onKeyMoved:
            updateDriverLocation(map);
            break;
        }
        setState(() {});
      }
    });
  }

  void addDriverToList(Map<String, dynamic> map) {
    if (map["latitude"] != null &&
        map["longitude"] != null &&
        map["key"] != null) {
      ActiveNearbyAvailableDrivers driver = ActiveNearbyAvailableDrivers(
        locationlatitude: map["latitude"],
        locationlongitude: map["longitude"],
        driverid: map["key"],
      );
      GeofireAssistant.activeNearbyAvailableDriversList.add(driver);
      displayActiveDriversOnUsersMap();
    }
  }

  void removeDriverFromList(Map<String, dynamic> map) {
    if (map["key"] != null) {
      GeofireAssistant.activeNearbyAvailableDriversList
          .removeWhere((driver) => driver.driverid == map["key"]);
      displayActiveDriversOnUsersMap();
    }
  }

  void updateDriverLocation(Map<String, dynamic> map) {
    if (map["latitude"] != null &&
        map["longitude"] != null &&
        map["key"] != null) {
      ActiveNearbyAvailableDrivers driver = ActiveNearbyAvailableDrivers(
        locationlatitude: map["latitude"],
        locationlongitude: map["longitude"],
        driverid: map["key"],
      );
      GeofireAssistant.updateActiveNearbyAvailableDriverLocation(driver);
      displayActiveDriversOnUsersMap();
    }
  }

  void displayActiveDriversOnUsersMap() {
    Set<Marker> newMarkers = {};
    for (ActiveNearbyAvailableDrivers driver
        in GeofireAssistant.activeNearbyAvailableDriversList) {
      LatLng position =
          LatLng(driver.locationlatitude!, driver.locationlongitude!);
      Marker marker = Marker(
        markerId: MarkerId(driver.driverid!),
        position: position,
        icon: activeNearbyDriverIcon ?? BitmapDescriptor.defaultMarker, //
      );
      newMarkers.add(marker);
    }
    setState(() {
      driversMarkerSet = newMarkers;
    });
  }
}
