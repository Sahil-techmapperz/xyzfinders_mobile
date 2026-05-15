import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/address_provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/auth_modal.dart';

class LocationSearchSheet extends StatefulWidget {
  final List<dynamic> locations;
  final int? selectedLocationId;
  final String? selectedLocationName;
  final Function(int? id, String name) onSelect;

  const LocationSearchSheet({
    super.key,
    required this.locations,
    this.selectedLocationId,
    this.selectedLocationName,
    required this.onSelect,
  });

  @override
  State<LocationSearchSheet> createState() => _LocationSearchSheetState();
}

class _LocationSearchSheetState extends State<LocationSearchSheet> {
  late List<dynamic> _filteredLocations;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredLocations = widget.locations;
    if (widget.selectedLocationName != null && 
        widget.selectedLocationName != "All Locations" &&
        widget.selectedLocationId == null) {
      _searchController.text = widget.selectedLocationName!;
      _filterLocations(widget.selectedLocationName!);
    }

    // Fetch addresses if authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isAuthenticated) {
        context.read<AddressProvider>().fetchAddresses();
      }
    });
  }

  void _filterLocations(String query) {
    if (query.isEmpty) {
      setState(() => _filteredLocations = widget.locations);
      return;
    }
    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredLocations = widget.locations.where((loc) {
        final name = "${loc['name']}, ${loc['city_name']}".toLowerCase();
        final state = "${loc['state_name']}".toLowerCase();
        return name.contains(lowerQuery) || state.contains(lowerQuery);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();
    final isCustomQuery = query.isNotEmpty && 
        !widget.locations.any((loc) => "${loc['name']}, ${loc['city_name']}".toLowerCase() == query.toLowerCase());

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                "Select Location".text.xl2.bold.make(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            10.heightBox,
            
            // Search Input
            TextField(
              controller: _searchController,
              onChanged: _filterLocations,
              decoration: InputDecoration(
                hintText: "Search state, city, pincode...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterLocations('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            10.heightBox,

            // Results List
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  // Option to clear location completely
                  if (widget.selectedLocationId != null || (widget.selectedLocationName != null && widget.selectedLocationName != "All Locations"))
                    ListTile(
                      leading: const Icon(Icons.location_off, color: Colors.grey),
                      title: "Clear Location Filter".text.color(Colors.grey).make(),
                      onTap: () {
                        widget.onSelect(null, "All Locations");
                        Navigator.pop(context);
                      },
                    ),

                  const Divider(),
                  
                  // Saved Addresses Section
                  Consumer2<AuthProvider, AddressProvider>(
                    builder: (context, auth, addressProvider, child) {
                      if (!auth.isAuthenticated) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              "Login to see your saved addresses".text.semiBold.make(),
                              10.heightBox,
                              ElevatedButton(
                                onPressed: () => AuthModal.show(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.secondaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: "Login / Sign Up".text.make(),
                              ),
                            ],
                          ),
                        ).pSymmetric(v: 10);
                      }

                      if (addressProvider.isLoading) {
                        return const Center(child: CircularProgressIndicator()).p20();
                      }

                      if (addressProvider.addresses.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          child: "No saved addresses found".text.color(Colors.grey).make().centered(),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          "Saved Addresses".text.semiBold.gray600.make().pOnly(left: 16, bottom: 8, top: 8),
                          ...addressProvider.addresses.map((address) {
                            final isSelected = address.cityId == widget.selectedLocationId || address.id == widget.selectedLocationId;
                            return ListTile(
                              leading: Icon(
                                address.name.toLowerCase().contains('home') ? Icons.home : 
                                address.name.toLowerCase().contains('work') ? Icons.work : 
                                Icons.bookmark,
                                color: isSelected ? AppTheme.primaryColor : Colors.grey,
                              ),
                              title: address.name.text.semiBold.color(isSelected ? AppTheme.primaryColor : Colors.black).make(),
                              subtitle: address.displayName.text.xs.make(),
                              onTap: () {
                                widget.onSelect(null, address.displayName);
                                Navigator.pop(context);
                              },
                              trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primaryColor) : null,
                            );
                          }),
                          const Divider(),
                        ],
                      );
                    },
                  ),

                  // Option to search custom query
                  if (isCustomQuery)
                    ListTile(
                      leading: const Icon(Icons.search, color: AppTheme.primaryColor),
                      title: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black, fontSize: 16),
                          children: [
                            const TextSpan(text: "Search products near "),
                            TextSpan(text: "'$query'", style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                          ],
                        ),
                      ),
                      onTap: () {
                        widget.onSelect(null, query);
                        Navigator.pop(context);
                      },
                    ),
                  
                  // Filtered Location Items (Only show if searching)
                  if (query.isNotEmpty) ...[
                    if (isCustomQuery && _filteredLocations.isNotEmpty)
                      const Divider(),
                    ..._filteredLocations.map((loc) {
                      final name = "${loc['name']}, ${loc['city_name']}";
                      final isSelected = loc['id'] == widget.selectedLocationId;

                      return ListTile(
                        leading: Icon(
                          Icons.location_on,
                          color: isSelected ? AppTheme.primaryColor : Colors.grey,
                        ),
                        title: name.text.semiBold.color(isSelected ? AppTheme.primaryColor : Colors.black).make(),
                        subtitle: "${loc['state_name']}".text.xs.make(),
                        onTap: () {
                          widget.onSelect(loc['id'], name);
                          Navigator.pop(context);
                        },
                        trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primaryColor) : null,
                      );
                    }).toList(),
                  ],

                  if (query.isNotEmpty && _filteredLocations.isEmpty && !isCustomQuery)
                    "No locations found".text.color(Colors.grey).make().centered().p20(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
