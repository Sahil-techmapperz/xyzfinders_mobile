import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/app_theme.dart';

// Use the API key provided from the environment or constant
const String googleMapsApiKey = 'AIzaSyBczrz8SxUUXpTp6kLVahP2_YnaQj0F4AU';

class LocationResult {
  final String state;
  final String city;
  final String pincode;
  final String area;
  final String fullAddress;

  LocationResult({
    required this.state,
    required this.city,
    required this.pincode,
    required this.area,
    required this.fullAddress,
  });
}

class GoogleLocationPicker extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final LocationResult? initialLocation;
  final Function(LocationResult?) onChanged;
  final String? Function(String?)? validator;

  const GoogleLocationPicker({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.initialLocation,
    required this.onChanged,
    this.validator,
  });

  @override
  State<GoogleLocationPicker> createState() => _GoogleLocationPickerState();
}

class _GoogleLocationPickerState extends State<GoogleLocationPicker> {
  LocationResult? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showSearchSheet(context),
          borderRadius: BorderRadius.circular(12),
          child: FormField<String>(
            initialValue: _selectedLocation?.fullAddress,
            validator: widget.validator,
            builder: (state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: state.hasError ? Colors.red : Colors.grey.shade200,
                        width: state.hasError ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(widget.icon, color: Colors.grey.shade400, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedLocation?.fullAddress ?? widget.hint,
                            style: TextStyle(
                              color: _selectedLocation != null ? Colors.black87 : Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.search, color: Colors.grey.shade400),
                      ],
                    ),
                  ),
                  if (state.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 12),
                      child: Text(
                        state.errorText!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  void _showSearchSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _GoogleLocationSearchSheet(
        title: widget.label,
        onSelected: (result) {
          setState(() {
            _selectedLocation = result;
          });
          widget.onChanged(result);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _GoogleLocationSearchSheet extends StatefulWidget {
  final String title;
  final Function(LocationResult) onSelected;

  const _GoogleLocationSearchSheet({
    required this.title,
    required this.onSelected,
  });

  @override
  State<_GoogleLocationSearchSheet> createState() => _GoogleLocationSearchSheetState();
}

class _GoogleLocationSearchSheetState extends State<_GoogleLocationSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  final Dio _dio = Dio();
  List<dynamic> _suggestions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void _searchPlaces(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json',
        queryParameters: {
          'input': query,
          'key': googleMapsApiKey,
          'components': 'country:in',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _suggestions = response.data['predictions'];
        });
      }
    } catch (e) {
      print('Error fetching places: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _getPlaceDetails(String placeId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/details/json',
        queryParameters: {
          'place_id': placeId,
          'key': googleMapsApiKey,
        },
      );

      if (response.statusCode == 200) {
        final result = response.data['result'];
        final addressComponents = result['address_components'] as List<dynamic>?;
        
        String state = '';
        String city = '';
        String pincode = '';
        String area = '';

        if (addressComponents != null) {
          for (var component in addressComponents) {
            final types = component['types'] as List<dynamic>;
            if (types.contains('administrative_area_level_1')) {
              state = component['long_name'];
            } else if (types.contains('locality')) {
              city = component['long_name'];
            } else if (types.contains('postal_code')) {
              pincode = component['long_name'];
            } else if (types.contains('sublocality_level_1') || types.contains('sublocality')) {
              area = component['long_name'];
            }
          }
        }
        
        // Fallback for area if sublocality not found but neighborhood exists
        if (area.isEmpty && addressComponents != null) {
           for (var component in addressComponents) {
             final types = component['types'] as List<dynamic>;
             if (types.contains('neighborhood')) {
               area = component['long_name'];
             }
           }
        }

        widget.onSelected(LocationResult(
          state: state,
          city: city,
          pincode: pincode,
          area: area,
          fullAddress: result['formatted_address'] ?? result['name'],
        ));
      }
    } catch (e) {
      print('Error fetching place details: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (val) {
                 // Simple debounce
                 Future.delayed(const Duration(milliseconds: 500), () {
                   if (_searchController.text == val) {
                     _searchPlaces(val);
                   }
                 });
              },
              decoration: InputDecoration(
                hintText: 'Search city, area, pincode...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isLoading ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                ) : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.grey),
                  title: Text(suggestion['structured_formatting']?['main_text'] ?? suggestion['description']),
                  subtitle: Text(suggestion['structured_formatting']?['secondary_text'] ?? '', style: const TextStyle(fontSize: 12)),
                  onTap: () => _getPlaceDetails(suggestion['place_id']),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class GoogleLocationInlineField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;
  final Function(String address)? onSelected;

  const GoogleLocationInlineField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.validator,
    this.onSelected,
  });

  @override
  State<GoogleLocationInlineField> createState() => _GoogleLocationInlineFieldState();
}

class _GoogleLocationInlineFieldState extends State<GoogleLocationInlineField> {
  final Dio _dio = Dio();
  List<dynamic> _suggestions = [];
  bool _isLoading = false;
  bool _showSuggestions = false;

  void _onTextChanged(String query) async {
    if (query.trim().length < 2) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _showSuggestions = false;
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _showSuggestions = true;
    });

    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json',
        queryParameters: {
          'input': query,
          'key': googleMapsApiKey,
          'components': 'country:in',
        },
      );

      if (response.statusCode == 200 && mounted) {
        final predictions = response.data['predictions'] as List<dynamic>? ?? [];
        setState(() {
          _suggestions = predictions;
        });
      }
    } catch (e) {
      debugPrint('Error fetching Google place suggestions: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
          child: Text(
            widget.label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
          ),
        ),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          onChanged: _onTextChanged,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: Icon(widget.icon, color: Colors.grey, size: 20),
            suffixIcon: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : (widget.controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                        onPressed: () {
                          widget.controller.clear();
                          setState(() {
                            _suggestions = [];
                            _showSuggestions = false;
                          });
                        },
                      )
                    : null),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.secondaryColor, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
        if (_showSuggestions && _suggestions.isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            constraints: const BoxConstraints(maxHeight: 220),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: _suggestions.length,
                      separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
                      itemBuilder: (context, index) {
                        final item = _suggestions[index];
                        final mainText = item['structured_formatting']?['main_text'] ?? item['description'] ?? '';
                        final secondaryText = item['structured_formatting']?['secondary_text'] ?? '';

                        return ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                          leading: Icon(Icons.location_on, color: Colors.grey.shade400, size: 20),
                          title: RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Colors.black87, fontSize: 13),
                              children: [
                                TextSpan(text: mainText, style: const TextStyle(fontWeight: FontWeight.bold)),
                                if (secondaryText.isNotEmpty)
                                  TextSpan(text: ' $secondaryText', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.normal, fontSize: 12)),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            final fullAddress = item['description'] as String;
                            widget.controller.text = fullAddress;
                            widget.onSelected?.call(fullAddress);
                            setState(() {
                              _suggestions = [];
                              _showSuggestions = false;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    color: const Color(0xFFF8FAFC),
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('powered by ', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                        const Text('Google', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
