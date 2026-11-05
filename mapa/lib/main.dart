import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mapa/controllers/gps_controller.dart';

void main() {
  runApp(
    const MaterialApp(
      home: Inicialize(),
    )
  );
}


class Inicialize extends StatefulWidget {
  const new({super.key});

  @override
  State<Inicialize> createState() => _InicializeState();
}

class _InicializeState extends State<Inicialize> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GpsController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: 'mapa',
        routes: {
          'mapa': (context) => const HomeSreen()
        },
      )
    );
  }
}