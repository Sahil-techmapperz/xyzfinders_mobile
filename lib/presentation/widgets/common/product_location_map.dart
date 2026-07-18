import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'google_location_picker.dart' show googleMapsApiKey;

class ProductLocationMap extends StatefulWidget {
  final String? locationName;
  final String? cityName;
  final String? stateName;
  final String? postalCode;
  final double height;

  const ProductLocationMap({
    super.key,
    this.locationName,
    this.cityName,
    this.stateName,
    this.postalCode,
    this.height = 200,
  });

  @override
  State<ProductLocationMap> createState() => _ProductLocationMapState();
}

class _ProductLocationMapState extends State<ProductLocationMap> {
  LatLng? _coordinates;
  bool _isLoading = true;
  final Dio _dio = Dio();
  
  // Cache to store resolved coordinates to avoid redundant API calls
  static final Map<String, LatLng> _geocodeCache = {};

  @override
  void initState() {
    super.initState();
    _geocodeLocation();
  }

  @override
  void didUpdateWidget(ProductLocationMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.locationName != oldWidget.locationName ||
        widget.cityName != oldWidget.cityName ||
        widget.stateName != oldWidget.stateName ||
        widget.postalCode != oldWidget.postalCode) {
      _geocodeLocation();
    }
  }

  Future<void> _geocodeLocation() async {
    final queryParts = [
      widget.locationName,
      widget.cityName,
      widget.stateName,
      widget.postalCode,
    ].whereType<String>().where((p) => p.trim().isNotEmpty).map((p) => p.trim()).toList();

    if (queryParts.isEmpty) {
      if (mounted) {
        setState(() {
          _coordinates = const LatLng(29.2104, 78.9619); // Default fallback (Kashipur)
          _isLoading = false;
        });
      }
      return;
    }

    final query = queryParts.join(', ');
    
    // Check cache first
    if (_geocodeCache.containsKey(query)) {
      if (mounted) {
        setState(() {
          _coordinates = _geocodeCache[query];
          _isLoading = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/geocode/json',
        queryParameters: {
          'address': query,
          'key': googleMapsApiKey,
        },
      );

      if (response.statusCode == 200 && response.data['status'] == 'OK') {
        final results = response.data['results'] as List;
        if (results.isNotEmpty) {
          final location = results[0]['geometry']['location'];
          final lat = location['lat'] as double;
          final lng = location['lng'] as double;
          final coords = LatLng(lat, lng);
          
          _geocodeCache[query] = coords;
          
          if (mounted) {
            setState(() {
              _coordinates = coords;
              _isLoading = false;
            });
          }
          return;
        }
      }
      
      final fallbackQueryParts = [
        widget.cityName,
        widget.stateName,
      ].whereType<String>().where((p) => p.trim().isNotEmpty).map((p) => p.trim()).toList();
      
      if (fallbackQueryParts.isNotEmpty) {
        final fallbackQuery = fallbackQueryParts.join(', ');
        if (_geocodeCache.containsKey(fallbackQuery)) {
          if (mounted) {
            setState(() {
              _coordinates = _geocodeCache[fallbackQuery];
              _isLoading = false;
            });
          }
          return;
        }
        
        final response = await _dio.get(
          'https://maps.googleapis.com/maps/api/geocode/json',
          queryParameters: {
            'address': fallbackQuery,
            'key': googleMapsApiKey,
          },
        );
        
        if (response.statusCode == 200 && response.data['status'] == 'OK') {
          final results = response.data['results'] as List;
          if (results.isNotEmpty) {
            final location = results[0]['geometry']['location'];
            final lat = location['lat'] as double;
            final lng = location['lng'] as double;
            final coords = LatLng(lat, lng);
            
            _geocodeCache[fallbackQuery] = coords;
            
            if (mounted) {
              setState(() {
                _coordinates = coords;
                _isLoading = false;
              });
            }
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }

    // Default fallback coordinate (Kashipur) if geocoding fails
    if (mounted) {
      setState(() {
        _coordinates = const LatLng(29.2104, 78.9619);
        _isLoading = false;
      });
    }
  }

  Future<void> _openInGoogleMaps(LatLng coords) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=${coords.latitude},${coords.longitude}';
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not launch maps URL');
      }
    } catch (e) {
      debugPrint('Error launching maps: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: widget.height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final coords = _coordinates ?? const LatLng(29.2104, 78.9619);

    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: coords,
                zoom: 14,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId("product_location_marker"),
                  position: coords,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                ),
              },
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Material(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                elevation: 3,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _openInGoogleMaps(coords),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.map_outlined,
                          color: Theme.of(context).primaryColor,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          "Open in Maps",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
