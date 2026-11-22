import 'controllers/gps_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeSreen extends StatefulWidget {
  const HomeSreen({super.key});

  @override
  State<HomeSreen> createState() => _HomeSreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(buildContext context) {
    return Consumer<GpsController>(
      builder: (context, gpsController, child) => Scaffold(
        body: SafeArea(
          top: true,
          bottom: true,
          child Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              gpsController.carregando 
              ? Center(child: CircularProgressIndicator())
              : gpsController.atual == null
              ? Center(child: Text("Não encontrado"))
              : Expanded(
                child:FlutterMap(
                  options: MapOptions(
                    initialZoom: 15.0,
                    initialCenter:gpsController.atual!
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.guiaturismo.maps',
                    ),
                    MarkerLayer(
                      markers: [
                        gpsController.pontos.map((ponto) => Marker(
                          alignment: Alignment.center,
                          width: 40,
                          height: 40,
                          point: ponto,
                          // builder: (context) => Icon(Icons.location_on, color: Colors.red, size: 40),
                          rotate: true
                        )).toList()
                      ]
                    )
                  ]
                )
              )
            ]
          )
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => gpsController.obterLocal(),
          child: Icon(Icons.person_pin_circle_rounded),
        ),
      ),
    );
  }
}