import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/address_provider.dart';
import '../../../data/models/address_model.dart';
import '../../widgets/common/searchable_location_picker.dart';

class AddressManagementScreen extends StatefulWidget {
  const AddressManagementScreen({super.key});

  @override
  State<AddressManagementScreen> createState() => _AddressManagementScreenState();
}

class _AddressManagementScreenState extends State<AddressManagementScreen> {
  bool _isAddingNew = false;
  AddressModel? _editingAddress;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressProvider>().fetchAddresses();
    });
  }

  void _toggleForm({AddressModel? address}) {
    setState(() {
      _editingAddress = address;
      _isAddingNew = address != null || !_isAddingNew;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          _isAddingNew 
            ? (_editingAddress != null ? 'Edit Address' : 'Add New Address')
            : 'My Addresses',
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(_isAddingNew ? Icons.close : Icons.arrow_back),
          onPressed: () {
            if (_isAddingNew) {
              setState(() {
                _isAddingNew = false;
                _editingAddress = null;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: _isAddingNew 
          ? AddressForm(
              address: _editingAddress, 
              onSuccess: () => setState(() { _isAddingNew = false; _editingAddress = null; })
            )
          : const AddressList(),
      floatingActionButton: _isAddingNew ? null : FloatingActionButton.extended(
        onPressed: () => _toggleForm(),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Address', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class AddressList extends StatelessWidget {
  const AddressList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AddressProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.addresses.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.addresses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_off_outlined, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('No addresses saved', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: provider.fetchAddresses,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.addresses.length,
            itemBuilder: (context, index) {
              final address = provider.addresses[index];
              return AddressCard(address: address);
            },
          ),
        );
      },
    );
  }
}

class AddressCard extends StatelessWidget {
  final AddressModel address;

  const AddressCard({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: address.isDefault ? AppTheme.primaryColor : Colors.grey.shade200,
          width: address.isDefault ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          if (!address.isDefault) {
            context.read<AddressProvider>().setDefault(address.id);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (address.isDefault ? AppTheme.primaryColor : Colors.grey.shade100).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      address.name.toLowerCase() == 'home' ? Icons.home_outlined : Icons.work_outline,
                      color: address.isDefault ? AppTheme.primaryColor : Colors.grey.shade600,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    address.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Spacer(),
                  if (address.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'DEFAULT',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () {
                      final parent = context.findAncestorStateOfType<_AddressManagementScreenState>();
                      parent?._toggleForm(address: address);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${address.areaName}, ${address.cityName}',
                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                '${address.stateName} - ${address.pincode}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              if (address.fullAddress != null && address.fullAddress!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  address.fullAddress!,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showDeleteDialog(context, address),
                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    label: const Text('Delete', style: TextStyle(color: Colors.red, fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, AddressModel address) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<AddressProvider>().deleteAddress(address.id);
              Navigator.pop(ctx);
            }, 
            child: const Text('Delete', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }
}

class AddressForm extends StatefulWidget {
  final AddressModel? address;
  final VoidCallback onSuccess;

  const AddressForm({super.key, this.address, required this.onSuccess});

  @override
  State<AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _areaController;
  late TextEditingController _pincodeController;
  late TextEditingController _fullAddressController;
  
  List<StateModel> _states = [];
  List<CityModel> _cities = [];
  StateModel? _selectedState;
  CityModel? _selectedCity;
  bool _isLoadingLocations = false;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.address?.name ?? 'Home');
    _areaController = TextEditingController(text: widget.address?.areaName ?? '');
    _pincodeController = TextEditingController(text: widget.address?.pincode ?? '');
    _fullAddressController = TextEditingController(text: widget.address?.fullAddress ?? '');
    _isDefault = widget.address?.isDefault ?? false;
    _loadStates();
  }

  Future<void> _loadStates() async {
    if (!mounted) return;
    setState(() => _isLoadingLocations = true);
    try {
      debugPrint('Loading states...');
      final states = await context.read<AddressProvider>().getStates();
      if (!mounted) return;
      setState(() {
        _states = states;
        debugPrint('Loaded ${_states.length} states');
        if (widget.address?.stateId != null) {
          try {
            _selectedState = _states.firstWhere((s) => s.id == widget.address!.stateId);
            _loadCities(_selectedState!.id);
          } catch (e) {
            debugPrint('State ID ${widget.address!.stateId} not found in list');
          }
        }
      });
    } catch (e) {
      debugPrint('Error loading states: $e');
    } finally {
      if (mounted) setState(() => _isLoadingLocations = false);
    }
  }

  Future<void> _loadCities(int stateId) async {
    if (!mounted) return;
    setState(() => _isLoadingLocations = true);
    try {
      debugPrint('Loading cities for state $stateId...');
      final cities = await context.read<AddressProvider>().getCities(stateId);
      if (!mounted) return;
      setState(() {
        _cities = cities;
        debugPrint('Loaded ${_cities.length} cities');
        if (widget.address?.cityId != null && _selectedState?.id == widget.address?.stateId) {
          try {
            _selectedCity = _cities.firstWhere((c) => c.id == widget.address!.cityId);
          } catch (e) {
             debugPrint('City ID ${widget.address!.cityId} not found in list');
          }
        } else {
          _selectedCity = null;
        }
      });
    } catch (e) {
      debugPrint('Error loading cities: $e');
    } finally {
      if (mounted) setState(() => _isLoadingLocations = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AddressProvider>().isLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Address Type (e.g. Home, Office)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: _buildInputDecoration(Icons.label_outline, 'Home'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SearchableLocationPicker<StateModel>(
                        label: 'State *',
                        hint: 'Select State',
                        icon: Icons.map_outlined,
                        items: _states,
                        selectedItem: _selectedState,
                        itemLabel: (s) => s.name,
                        isLoading: _isLoadingLocations && _states.isEmpty,
                        onChanged: (s) {
                          setState(() {
                            _selectedState = s;
                            _selectedCity = null;
                            if (s != null) _loadCities(s.id);
                          });
                        },
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SearchableLocationPicker<CityModel>(
                        label: 'City *',
                        hint: 'Select City',
                        icon: Icons.location_city_outlined,
                        items: _cities,
                        selectedItem: _selectedCity,
                        itemLabel: (c) => c.name,
                        isLoading: _isLoadingLocations && _selectedState != null && _cities.isEmpty,
                        onChanged: (c) => setState(() => _selectedCity = c),
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Area / Location *'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _areaController,
                        decoration: _buildInputDecoration(Icons.place_outlined, 'Enter area name'),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Pincode *'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _pincodeController,
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration(Icons.pin_outlined, '6-digit pincode'),
                        validator: (v) => v == null || v.length < 6 ? 'Invalid pincode' : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildLabel('Full Address / Landmark (Optional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _fullAddressController,
              maxLines: 3,
              decoration: _buildInputDecoration(Icons.description_outlined, 'House no, Building, Street...'),
            ),
            const SizedBox(height: 20),

            SwitchListTile(
              title: const Text('Set as Default Address', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Use this address for all future orders'),
              value: _isDefault,
              activeColor: AppTheme.primaryColor,
              onChanged: (v) => setState(() => _isDefault = v),
            ),
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : Text(widget.address != null ? 'Update Address' : 'Save Address', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87));
  }

  InputDecoration _buildInputDecoration(IconData icon, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'name': _nameController.text,
      'state_id': _selectedState?.id,
      'city_id': _selectedCity?.id,
      'area_name': _areaController.text,
      'pincode': _pincodeController.text,
      'full_address': _fullAddressController.text,
      'is_default': _isDefault ? 1 : 0,
    };

    bool success;
    if (widget.address != null) {
      success = await context.read<AddressProvider>().updateAddress(widget.address!.id, data);
    } else {
      success = await context.read<AddressProvider>().addAddress(data);
    }

    if (success) {
      widget.onSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<AddressProvider>().error ?? 'An error occurred'), backgroundColor: Colors.red),
      );
    }
  }
}
