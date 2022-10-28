import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:googlemaps/constants.dart';
import 'package:location/location.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const double _defaultLat = 8.85577417427599;
  static const double _defaultLng = 38.81151398296511;

  static const CameraPosition _defaultLocation = CameraPosition(
    target: LatLng(_defaultLat, _defaultLng),
    zoom: 15,
  );
  Completer<GoogleMapController> _controller = Completer();

  MapType _currentMapType = MapType.normal;

  final Set<Marker> _markers = {};

  late final GoogleMapController _googleMapController;

  void _changeMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  void _addMarker() {
    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('defaultLocation'),
          position: _defaultLocation.target,
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: const InfoWindow(
            title: "Yeahh",
            snippet: "5 yıldız amunaa",
          ),
        ),
      );
    });
  }

  void _moveToNewLocation() async {
    const _newPosition = LatLng(40.7128, -74.0060);
    _googleMapController
        .animateCamera(CameraUpdate.newLatLngZoom(_newPosition, 15));
    setState(() {
      const marker = Marker(
        markerId: MarkerId('newLocation'),
        position: _newPosition,
        infoWindow: InfoWindow(title: "New York", snippet: "Thes best Place"),
      );

      _markers
        ..clear()
        ..add(marker);
    });
  }

  void _goToDefaultLocation() async {
    final _defaultLocation =
        LatLng(sourceLocation.latitude, sourceLocation.longitude);
    _googleMapController
        .animateCamera(CameraUpdate.newLatLngZoom(_defaultLocation, 15));
    setState(() {
      final marker = Marker(
        markerId: MarkerId('source'),
        position: _defaultLocation,
      );
      _markers
        ..clear()
        ..add(marker);
    });
  }

  static const LatLng sourceLocation = LatLng(39.753226, 30.493691);
  static const LatLng destination = LatLng(39.751031, 30.474830);

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  void getCurrentLocation() async {
    Location location = Location();

    GoogleMapController googleMapController = await _controller.future;

    await location.getLocation().then((value) {
      currentLocation = value;
    });

    location.onLocationChanged.listen((newLoc) {
      currentLocation = newLoc;

      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(newLoc.latitude!, newLoc.longitude!),
          ),
        ),
      );
    });

    setState(() {});
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      google_api_key,
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) =>
          polylineCoordinates.add(LatLng(point.latitude, point.longitude)));
      setState(() {});
    }
  }

  void setCustomMarkerIcon() {
    //BitmapDescriptor.fromAssetImage(configuration, assetName)
  }

  @override
  void initState() {
    getCurrentLocation();
    getPolyPoints();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google Maps"),
        centerTitle: true,
      ),
      body: currentLocation == null
          ? const Text("Loading")
          : Stack(
              children: [
                GoogleMap(
                  //mapType: _currentMapType,
                  //initialCameraPosition: _defaultLocation,
                  /*  initialCameraPosition:
                      const CameraPosition(target: sourceLocation, zoom: 16), */
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      currentLocation!.latitude!,
                      currentLocation!.longitude!,
                    ),
                    zoom: 16,
                  ),
                  //onMapCreated: (controller) => _googleMapController = controller,
                  onMapCreated: ((mapController) {
                    _controller.complete(mapController);
                  }),
                  //markers: _markers,
                  markers: {
                    Marker(
                      markerId: const MarkerId("currentLocation"),
                      position: LatLng(
                        currentLocation!.latitude!,
                        currentLocation!.longitude!,
                      ),
                    ),
                    const Marker(
                      markerId: MarkerId('source'),
                      position: sourceLocation,
                    ),
                    const Marker(
                      markerId: MarkerId('destination'),
                      position: destination,
                    ),
                  },
                  polylines: {
                    Polyline(
                        polylineId: const PolylineId("route"),
                        points: polylineCoordinates,
                        color: Colors.red,
                        width: 10),
                  },
                ),
                Container(
                  padding: const EdgeInsets.only(top: 24, right: 12),
                  alignment: Alignment.topRight,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        backgroundColor: Colors.green,
                        child: Icon(
                          Icons.map,
                          size: 30,
                        ),
                        onPressed: _changeMapType,
                      ),
                      const SizedBox(height: 20),
                      FloatingActionButton(
                        backgroundColor: Colors.deepPurpleAccent,
                        child: const Icon(
                          Icons.add_location,
                          size: 36,
                        ),
                        onPressed: _addMarker,
                      ),
                      const SizedBox(height: 20),
                      FloatingActionButton(
                        backgroundColor: Colors.indigoAccent,
                        child: const Icon(
                          Icons.location_city,
                          size: 36,
                        ),
                        onPressed: _moveToNewLocation,
                      ),
                      const SizedBox(height: 20),
                      FloatingActionButton(
                        backgroundColor: Colors.red,
                        child: const Icon(
                          Icons.home_rounded,
                          size: 36,
                        ),
                        onPressed: _goToDefaultLocation,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
