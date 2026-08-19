import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};

  static const CameraPosition _initialCamera = CameraPosition(
    target: LatLng(37.4219999, -122.0840575),
    zoom: 12,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fleet Map')),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _initialCamera,
        markers: _markers,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _centerOnUser,
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Future<void> _centerOnUser() async {
    final controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(const CameraPosition(
      target: LatLng(37.4219999, -122.0840575),
      zoom: 14,
    )));
  }
}
