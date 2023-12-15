import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_to_venezia2/pages/homepage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Maps extends StatefulWidget {
  final DateTime date;
  Maps({required this.date});

  @override
  State<Maps> createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  final Completer<GoogleMapController> _controller = Completer();
  
  static const sourceLocation = LatLng(45.435, 12.325);   

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }


  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
  
    final stylemap = <TextStyle>[
      // stylenumber = 0
      TextStyle(
        color: theme.colorScheme.onPrimary,
        fontSize: 75,
      ),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        backgroundColor: Color.fromARGB(255, 155, 191, 244),
        appBar: mAppBar(context, 'Map', stylemap, widget.date),

        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: sourceLocation,
            zoom: 14,
          ),
        ),
      );
    });
  }
}

PreferredSize mAppBar(BuildContext context, String title, final stylemap, DateTime date) {
  return PreferredSize(
    preferredSize: Size.fromHeight(200),
    child: AppBar(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,

      leading: TextButton(
        child: Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => HomePage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            )
          );
        },
      ),

      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0, -1),
            end: Alignment(-1, 1),
            colors: <Color>[Color.fromARGB(255, 57, 210, 192), Color.fromARGB(255, 75, 57, 239)]
          ),
          boxShadow: [
            BoxShadow(blurRadius: 40)
          ],
          borderRadius: BorderRadius.vertical(
            bottom: Radius.elliptical(40, 40)
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 95),
            Center(
              child: Text(
                title,
                style: stylemap[0]),
            ),
          ],
        ),
      ),
      
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(40),
        )
      ),
    ),
  ); 
}