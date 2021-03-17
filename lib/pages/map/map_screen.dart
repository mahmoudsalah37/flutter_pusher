import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/model.dart';
import 'package:latlong/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const String ACCESS_TOKEN =
      'pk.eyJ1IjoiYWhtZWRuYXNzZXI3NCIsImEiOiJja2t6cHJzdXIwc3Z0Mm9wMGFubDZoYXp4In0.gWJ-bQnLWcaVPoWBPFuoYg';
  static const String urlTemplate =
      'https://api.mapbox.com/styles/v1/ahmednasser74/ckl4yg3sg3u3l18p3rwqpmbyc/tiles/256/{z}/{x}/{y}@2x?access_token=$ACCESS_TOKEN';
  static const String ID = 'mapbox.mapbox-streets-v11';

  var points = <LatLng>[
    LatLng(29.990927, 31.149495),
    LatLng(30.009407, 31.203696),
    LatLng(30.014286, 31.201750),
    LatLng(29.993787, 31.147937),
    LatLng(29.990927, 31.149495),
  ];

  double lat = 0;
  double long = 0;
  Position _position;
  StreamSubscription<Position> streamSubscription;
  Address _address;
  bool addressIsInside = false;
  LatLng point = LatLng(0.0, 0.0);

  getCurrentLocation() async {
    final geoPosition = await Geolocator.getCurrentPosition();
    try {
      setState(() {
        lat = geoPosition.latitude;
        long = geoPosition.longitude;
        var coordinates = new Coordinates(lat, long);
//      Geocoder.local.findAddressesFromCoordinates(coordinates);
        convertToAddress(coordinates);
        print('address is : ${convertToAddress(coordinates)}');
      });
    } on PlatformException catch (e) {
      print(e);
    }
    print('lat is : $lat');
    print('long is : $long');
  }

//  MapController mapController;
//  StatefulMapController statefulMapController;
//  StreamSubscription<StatefulMapControllerStateChange> sub;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();

//    mapController = MapController();
//    statefulMapController = StatefulMapController(mapController: mapController);
//    statefulMapController.changeFeed.listen((change) {
//      print('Change in statefulMapController ${change.name}');
//    });

//    var locationOption = LocationOptions(distanceFilter: 10);
    streamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
          setState(() {
            _position = position;
            print('position is $_position');
          });
          lat = position.latitude;
          long = position.longitude;
          var coordinates = new Coordinates(position.latitude, position.longitude);
          convertToAddress(coordinates).then((value) => _address = value);
//      print('address is $_address');
        });
  }

  Future<Address> convertToAddress(Coordinates coordinates) async {
    var address =
    await Geocoder.local.findAddressesFromCoordinates(coordinates);
    return address.first;
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MapController mapController;
    return Scaffold(
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
            center: LatLng(29.990927, 31.149495),
            zoom: 12,
            minZoom: 6,
            maxZoom: 18,
            onTap: (value) {
              setState(() {
                point = LatLng(value.latitude, value.longitude);
                addressIsInside = _checkIfValidMarker(point, points);
                addressIsInside ? print('is inside') : print('is outside');
                Fluttertoast.showToast(
                    msg: addressIsInside
                        ? 'your location is INSIDE'
                        : 'your location is OUTSIDE',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 16.0);
              });
            }),
        layers: [
          TileLayerOptions(urlTemplate: urlTemplate, additionalOptions: {
            'accessToken': ACCESS_TOKEN,
            'id': ID,
          }),
          PolylineLayerOptions(
            polylines: [
              Polyline(
                  points: points,
                  strokeWidth: 2,
                  color: Colors.green,
                  borderStrokeWidth: 10,
                  borderColor: Colors.black26)
            ],
          ),
          MarkerLayerOptions(markers: [
            Marker(
              height: 80,
              width: 80,
              point: LatLng(lat, long),
              builder: (context) => Container(
                child: IconButton(
                    icon: Icon(Icons.location_on),
                    color: Colors.red,
                    iconSize: 50,
                    onPressed: () {
                      setState(() {
                        addressIsInside
                            ? print('is inside')
                            : print('is outside');
                      });
                    }),
              ),
            ),
            Marker(
              height: 80,
              width: 80,
              point: LatLng(30.008784, 31.189789),
              builder: (context) => Container(
                child: IconButton(
                    icon: Icon(Icons.location_on),
                    color: Colors.black,
                    iconSize: 50,
                    onPressed: () {
                      setState(() {
                        addressIsInside
                            ? print('is inside')
                            : print('is outside');
                      });
                    }),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  bool _checkIfValidMarker(LatLng tap, List<LatLng> vertices) {
    int intersectCount = 0;
    for (int j = 0; j < vertices.length - 1; j++) {
      if (rayCastIntersect(tap, vertices[j], vertices[j + 1])) {
        intersectCount++;
      }
    }

    return ((intersectCount % 2) == 1);
  }

  bool rayCastIntersect(LatLng tap, LatLng vertA, LatLng vertB) {
    double aY = vertA.latitude;
    double bY = vertB.latitude;
    double aX = vertA.longitude;
    double bX = vertB.longitude;
    double pY = tap.latitude;
    double pX = tap.longitude;

    if ((aY > pY && bY > pY) || (aY < pY && bY < pY) || (aX < pX && bX < pX)) {
      return false; // a and b can't both be above or below pt.y, and a or
      // b must be east of pt.x
    }

    double m = (aY - bY) / (aX - bX); // Rise over run
    double bee = (-aX) * m + aY; // y = mx + b
    double x = (pY - bee) / m; // algebra is neat!

    return x > pX;
  }
}
