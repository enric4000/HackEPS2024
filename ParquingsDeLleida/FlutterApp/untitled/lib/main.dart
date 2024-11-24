import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Import para Google Maps
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF165d4f)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Parquings de Lleida'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int plazLib = 0;
  int plazOcup = 0;
  int plazTotal = 0;

  late GoogleMapController _mapController;

  final LatLng _initialPosition = const LatLng(41.60686667118134, 0.6254122464744745); // Coordenadas del parquing de la UDL :3
  final Set<Marker> _markers = {};

  //Conexio amb el server Django que retorna un JSON
  Future<void> fetchData(String type) async {
    final url = Uri.parse('http://192.168.43.52:8000/aparcaments/API/1/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          plazOcup = data['places_ocupades'];
          plazTotal = data['places_totals'];
          plazLib = data['plazas_libres'];
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al realizar la solicitud: $e');
    }
  }

  //Conexio amb el server Django per disminuir una plaza
  Future<void> registrarEntrada() async {
    final url = Uri.parse('http://192.168.43.52:8000/aparcaments/1/update/');
    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        print('Entrada registrada: ${response.body}');
      } else {
        print('Error al registrar entrada: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al realizar la solicitud: $e');
    }
    fetchData("libre");
  }

  //Conexio amb el server Django per augmentar una plaza lliure
  Future<void> registrarSalida() async {
    final url = Uri.parse('http://192.168.43.52:8000/aparcaments/1/update/');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        print('Salida registrada: ${response.body}');
      } else {
        print('Error al registrar salida: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al realizar la solicitud: $e');
    }
    fetchData("libre");
  }

  @override
  void initState() {
    super.initState();
    fetchData("libre");

    _markers.add(
      Marker(
        markerId: const MarkerId('initial_location'),
        position: _initialPosition,
        infoWindow: const InfoWindow(
          title: 'Aparcament Públic Gratuït UdL',
          snippet: 'Parkings en Lleida',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 350,
                  child: TextButton(
                    onPressed: () {
                      fetchData('libre');
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Plazas libres: $plazLib'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 350,
                  child: TextButton(
                    onPressed: () {
                      fetchData('ocupada');
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Plazas ocupadas: $plazOcup'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 350,
                  child: TextButton(
                    onPressed: () {
                      fetchData('total');
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Total de plazas: $plazTotal'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onVerticalDragUpdate: (_) {},
              child: SizedBox(
                height: 400,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _initialPosition,
                    zoom: 16,
                  ),
                  markers: _markers,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  myLocationEnabled: true,
                  zoomControlsEnabled: true,
                  scrollGesturesEnabled: true,
                  zoomGesturesEnabled: true,
                  tiltGesturesEnabled: true,
                  rotateGesturesEnabled: true,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 150,
                  child: TextButton(
                    onPressed: registrarEntrada,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Registrar entrada'),
                  ),
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: 150,
                  child: TextButton(
                    onPressed: registrarSalida,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Registrar salida'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
