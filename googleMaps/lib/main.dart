import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  static const CameraPosition _defaultLocation = CameraPosition(target: LatLng(_defaultLat, _defaultLng), zoom: 15,);
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
        Marker(markerId: MarkerId('defaultLocation'),
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
    _googleMapController.animateCamera(CameraUpdate.newLatLngZoom(_newPosition, 15));
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
    const _defaultLocation = LatLng(_defaultLat, _defaultLng);
    _googleMapController.animateCamera(CameraUpdate.newLatLngZoom(_defaultLocation, 15));
    setState(() {
      const marker = Marker(
        markerId: MarkerId('defaultLocation'),
        position: _defaultLocation,
        infoWindow: InfoWindow(title: "Home", snippet: "Baby"),
      );
      _markers
        ..clear()
        ..add(marker);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google Maps"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: _currentMapType,
            initialCameraPosition: _defaultLocation,
            onMapCreated: (controller) => _googleMapController = controller,
            markers: _markers,
          ),
          Container(
            padding: const EdgeInsets.only(top: 24, right: 12),
            alignment: Alignment.topRight,
            child: Column(
              children: [
                FloatingActionButton(
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.map, size: 30,),
                  onPressed: _changeMapType,
                ),
                const SizedBox(height: 20),
                FloatingActionButton(
                  backgroundColor: Colors.deepPurpleAccent,
                  child: const Icon(Icons.add_location, size: 36,),
                  onPressed: _addMarker,
                ),
                const SizedBox(height: 20),
                FloatingActionButton(
                  backgroundColor: Colors.indigoAccent,
                  child: const Icon(Icons.location_city, size: 36,),
                  onPressed: _moveToNewLocation,
                ),
                const SizedBox(height: 20),
                FloatingActionButton(
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.home_rounded, size: 36,),
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
