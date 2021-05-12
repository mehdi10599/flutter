import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:working_with_map/screens/location_list.dart';

class HomeScreen extends StatefulWidget {
  static String id = 'home_screen';
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LatLng myCurrentLocation = LatLng(51.5, -0.08);
  DatabaseReference dbRef = FirebaseDatabase.instance.reference().child('Locations');

  MapController mapController;

  @override
  void initState() {
    // initialize the controllers
    mapController = MapController();
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('Location'),
        leading:
        IconButton(
          icon: Icon(Icons.list),
          onPressed: () {
            Navigator.pushNamed(context, LocationList.id);
          },
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.my_location_sharp),
            onPressed: () async{
              Position position = await _determinePosition();
              myCurrentLocation = LatLng(position.latitude,position.longitude);
              mapController.move(myCurrentLocation, 16);
              uploadToDatabase(position.latitude.toString(),position.longitude.toString());
              setState(() {});
            },
            color: Colors.white,
          ),
        ],
      ),
      body: customMap(),
    );
  }

  uploadToDatabase(String latitude,String longitude) async{
    DateTime dateTime = DateTime.now();
    String dateTimeStr = dateTime.toString().substring(0,19);
    await dbRef.child(dateTimeStr).set({
      'dateTime':dateTimeStr,
      'latitude':latitude,
      'longitude':longitude,
    });
  }


  Widget customMap() {
    return FlutterMap(
      options: MapOptions(
        center: myCurrentLocation,
        zoom: 15.0,
        maxZoom: 18,
      ),
      mapController: mapController,
      layers: [
        TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c']),
        MarkerLayerOptions(
          markers: [
            Marker(
              width: 180.0,
              height: 100.0,
              point: myCurrentLocation,
              builder: (ctx) => Container(
                child: Column(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: Colors.blue,
                      size: 55,
                    ),
                    Text('latitude: ${myCurrentLocation.latitude} '),
                    Text('longitude: ${myCurrentLocation.longitude} '),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}