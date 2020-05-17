import 'package:flutter/material.dart';


import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_map_location_picker/generated/i18n.dart'
as location_picker;
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';



class MapSamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  LocationResult _pickedLocation;

  Completer<GoogleMapController> _controller = Completer();
  static const LatLng _center = const LatLng(45.521563, -122.677433);
  final Set<Marker> _markers = {};
  LatLng _lastMapPosition = _center;
  MapType _currentMapType = MapType.normal;
  static final CameraPosition _position = CameraPosition(
    bearing: 192.833,
    target: LatLng(45.531563,-122.677433),
    tilt: 59.440,
      zoom:11.0,
  );

  Future<void> _goToPosition1()async{
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_position));
  }

  _onMapCreated(GoogleMapController controller){
    _controller.complete(controller);

  }
  _onCameraMove(CameraPosition position){
    _lastMapPosition = position.target;
  }
  Widget button(Function function,IconData icon){
    return FloatingActionButton(
      onPressed: function,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      backgroundColor: Colors.blue,
      child: Icon(
        icon,
        size: 36.0,
      ),
    );
  }
  _onMapTypeButtonPressed(){
    setState(() {
      _currentMapType = _currentMapType == MapType.normal ?
          MapType.satellite
          : MapType.normal;
    });
  }

  _onAddMarkerButtonPressed(){
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(_lastMapPosition.toString()),
        position: _lastMapPosition,
        infoWindow: InfoWindow(
          title: 'this is a title',
          snippet: 'this is a snippet',
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'location picker',
//      localizationsDelegates: const [
//        location_picker.S.delegate,
//        location_picker.S.delegate,
//        GlobalMaterialLocalizations.delegate,
//        GlobalWidgetsLocalizations.delegate,
//        GlobalCupertinoLocalizations.delegate,
//      ],
      supportedLocales: const <Locale>[
        Locale('en', ''),
        Locale('ar', ''),
//        Locale('pt', ''),
//        Locale('tr', ''),
      ],
      home: Scaffold(
        appBar: AppBar(
          title: const Text('location picker'),
        ),
        body: Builder(builder: (context) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  onPressed: () async {
                    LocationResult result = await showLocationPicker(
                      context,
                      "AIzaSyAcLLyO1mEseiDhj7L1Yw2WRuBMRhKxQJo",
                      initialCenter: LatLng(31.1975844, 29.9598339),
                      automaticallyAnimateToCurrentLocation: true,
                      mapStylePath: 'assets/mapStyle.json',
                      myLocationButtonEnabled: true,
                      layersButtonEnabled: true,
                      resultCardAlignment: Alignment.bottomCenter,
                    );
                    print("result = $result +++++++++++++++++++++++++++++++++++++++++++++++++++++++");
                    setState(() {
                      _pickedLocation = result;


                    }
                    );
                  },
                  child: Text('Pick location'),
                ),
                Text(_pickedLocation.toString()),
              ],
            ),
          );
        }),
      ),
    );
  }
}

//MaterialApp(
//home: Scaffold(
//appBar: AppBar(title: Text('Maps'),
//backgroundColor: Colors.black,
//),
//body: Stack(
//children: <Widget>[
//GoogleMap(
//onMapCreated: _onMapCreated,
//initialCameraPosition: CameraPosition(target: _center,
//zoom: 11.0,
//),
//mapType: _currentMapType,
//markers: _markers,
//onCameraMove: _onCameraMove,
//),
//Padding(
//padding: EdgeInsets.all(16.0),
//child: Align(
//alignment: Alignment.topRight,
//child: Column(
//children: <Widget>[
////                    button(_onMapTypeButtonPressed, Icons.map),
////                    SizedBox(height: 16.0,),
////                    button(_onAddMarkerButtonPressed, Icons.add_location),
////                    SizedBox(height: 16.0,),
////                    button(_goToPosition1, Icons.location_searching),
//],
//),
//),
//),
//],
//),
//),
//);