import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<Map<String, dynamic>> properties = [];
  final MapController _mapController = MapController();
  static final LatLng _tunisCenter = LatLng(36.8065, 10.1815);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is List<Map<String, dynamic>>) {
      properties = args;

      if (properties.length == 1) {
        final p = properties.first;
        final lat = (p['lat'] ?? 36.8065).toDouble();
        final lng = (p['lng'] ?? 10.1815).toDouble();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.move(LatLng(lat, lng), 15.0);
        });
      }
      setState(() {});
    }
  }

  void _showPropertyDetails(Map<String, dynamic> property) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: const BoxDecoration(
          color: Color(0xFF2A2A2A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(16),
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey.shade800,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: property['imageUrl'] != null &&
                          property['imageUrl'].toString().isNotEmpty
                      ? Image.network(
                          property['imageUrl'],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                      : const Icon(Icons.home, color: Colors.yellow, size: 70),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            property['title'] ?? "Sans titre",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "${property['prix'] ?? 0} DT",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        final lat = (property['lat'] ?? 36.8065).toDouble();
                        final lng = (property['lng'] ?? 10.1815).toDouble();
                        _mapController.move(LatLng(lat, lng), 17.0);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3A3A3A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.yellow),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                property['localisation'] ?? "Localisation inconnue",
                                style: const TextStyle(color: Colors.white70, fontSize: 15),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios,
                                color: Colors.yellow, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context,
                            "/propertyDetail",
                            arguments: property,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          "Voir les détails",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Marker> markers = properties.map<Marker>((property) {
      final lat = (property['lat'] ?? 36.8065).toDouble();
      final lng = (property['lng'] ?? 10.1815).toDouble();
    return Marker(
  point: LatLng(lat, lng),
  width: 40,
  height: 40,
  child: GestureDetector(
    onTap: () => _showPropertyDetails(property),
    child: const Icon(
      Icons.location_on,
      color: Colors.orange,
      size: 30,
    ),
  ),
);


     
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Carte des Propriétés"),
        backgroundColor: Colors.orange,
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _tunisCenter,
          initialZoom: 12.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(markers: markers),
        ],
      ),
    );
  }
}
