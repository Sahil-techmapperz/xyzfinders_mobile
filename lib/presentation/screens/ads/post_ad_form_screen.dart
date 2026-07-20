import 'dart:io';
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/product_provider.dart';
import '../../providers/address_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../data/models/address_model.dart';
import '../home/home_screen.dart';
import '../../widgets/common/searchable_location_picker.dart';
import '../../widgets/common/google_location_picker.dart';


class PostAdFormScreen extends StatefulWidget {
  final String category;
  const PostAdFormScreen({super.key, required this.category});

  @override
  State<PostAdFormScreen> createState() => _PostAdFormScreenState();
}

class _PostAdFormScreenState extends State<PostAdFormScreen> {
  int _currentStep = 0;
  final _formKeyBasic = GlobalKey<FormState>();
  final _formKeyDetails = GlobalKey<FormState>();
  final _formKeyLocation = GlobalKey<FormState>();
  
  // Generic Controllers
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _typeController = TextEditingController();
  String? _selectedSubCategory;
  
  // Property Specific Controllers
  final _roomTypeController = TextEditingController();
  final _securityDepositController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _balconyController = TextEditingController();
  final _areaController = TextEditingController();
  final _kitchenController = TextEditingController();
  final _attachedBathController = TextEditingController();

  // Gadgets & Electronics Specific Controllers
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _ageController = TextEditingController();
  final _colorController = TextEditingController();
  final _batteryLifeController = TextEditingController();
  final _connectivityController = TextEditingController();

  // Automobile Specific Controllers
  final _yearController = TextEditingController();
  final _kmDrivenController = TextEditingController();
  final _ownersController = TextEditingController();
  final _mileageController = TextEditingController();
  final _insuranceController = TextEditingController();
  final _bodyTypeController = TextEditingController();
  final _extColorController = TextEditingController();
  final _intColorController = TextEditingController();
  final _horsepowerController = TextEditingController();
  final _engineCapacityController = TextEditingController();
  final _seaterCapacityController = TextEditingController();
  final _doorsController = TextEditingController();

  // Mobiles & Tablets Specific Controllers
  final _storageController = TextEditingController();
  final _ramController = TextEditingController();
  final _batteryHealthController = TextEditingController();
  final _osVersionController = TextEditingController();
  final _damageController = TextEditingController();

  // Furniture Specific Controllers
  final _materialController = TextEditingController();
  final _dimensionsController = TextEditingController();

  // Fashion Specific Controllers
  final _sizeController = TextEditingController();

  // Education Specific Controllers
  final _subjectController = TextEditingController();
  final _levelController = TextEditingController();
  final _instituteController = TextEditingController();
  final _durationController = TextEditingController();
  final _batchSizeController = TextEditingController();

  // Beauty Specific Controllers
  final _productTypeController = TextEditingController();

  // Pets Specific Controllers
  final _breedController = TextEditingController();

  // Events Specific Controllers
  final _eventDateController = TextEditingController();
  final _eventTimeController = TextEditingController();
  final _venueController = TextEditingController();
  final _organizerController = TextEditingController();
  final _highlightsController = TextEditingController();

  // Events manual date selections
  String? _eventDay;
  String? _eventMonth;
  String? _eventYear;

  // Services Specific Controllers
  final _availabilityController = TextEditingController();

  // Services manual date selections
  String? _serviceDay;
  String? _serviceMonth;
  String? _serviceYear;

  // Jobs Specific Controllers
  final _companyController = TextEditingController();
  final _experienceController = TextEditingController();
  final _qualificationController = TextEditingController();

  // Location Controllers
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _locationAreaController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _landmarkController = TextEditingController();

  // Selections
  String _propertyType = 'Apartment';
  String _furnishedStatus = 'Unfurnished';
  String _tenantPreference = 'Any';
  final List<String> _selectedAmenities = [];
  
  String _condition = 'New';
  String _warranty = 'In Warranty';
  String _fuelType = 'Petrol';
  String _transmission = 'Manual';
  String _vehicleType = 'Car';
  String _jobType = 'Full-time';
  String _workMode = 'On-site';
  String _gender = 'Male';
  String _genderPref = 'Any';
  String _teachingMode = 'Online';
  String _selectedSavedAddress = '- Or enter manually below -';
  
  // Pet specific selections
  String _petCategory = 'Dog';
  String _vaccinated = 'Not Specified';
  String _kciRegistered = 'Not Specified';
  String _healthCert = 'Not Specified';
  String _dewormed = 'Not Specified';
  String _microchipped = 'Not Specified';
  
  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  // Location Data
  List<StateModel> _states = [];
  List<CityModel> _cities = [];
  StateModel? _selectedState;
  CityModel? _selectedCity;
  int? _selectedStateId;
  int? _selectedCityId;
  bool _isLoadingStates = false;
  bool _isLoadingCities = false;

  final List<Map<String, dynamic>> _amenitiesList = [
    {'name': 'Parking', 'icon': Icons.directions_car_outlined},
    {'name': 'Lift', 'icon': Icons.elevator_outlined},
    {'name': 'Power Backup', 'icon': Icons.battery_charging_full_outlined},
    {'name': 'Gym', 'icon': Icons.fitness_center_outlined},
    {'name': 'Swimming Pool', 'icon': Icons.pool_outlined},
    {'name': 'Security', 'icon': Icons.security_outlined},
    {'name': 'Garden', 'icon': Icons.park_outlined},
    {'name': 'Club House', 'icon': Icons.meeting_room_outlined},
    {'name': 'WiFi', 'icon': Icons.wifi_outlined},
    {'name': 'AC', 'icon': Icons.ac_unit_outlined},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressProvider>().fetchAddresses();
      _fetchStates();
      final auth = context.read<AuthProvider>();
      if (auth.user?.phone != null && auth.user!.phone!.isNotEmpty) {
        _phoneController.text = auth.user!.phone!;
      }
    });
  }

  Future<void> _fetchStates() async {
    setState(() => _isLoadingStates = true);
    try {
      final states = await context.read<AddressProvider>().getStates();
      setState(() {
        _states = states;
        _isLoadingStates = false;
      });
    } catch (e) {
      setState(() => _isLoadingStates = false);
    }
  }

  Future<void> _fetchCities(int stateId) async {
    setState(() {
      _isLoadingCities = true;
      _cities = [];
      _cityController.clear();
      _selectedCityId = null;
    });
    try {
      final cities = await context.read<AddressProvider>().getCities(stateId);
      setState(() {
        _cities = cities;
        _isLoadingCities = false;
      });
    } catch (e) {
      setState(() => _isLoadingCities = false);
    }
  }



  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _typeController.dispose();
    _roomTypeController.dispose();
    _securityDepositController.dispose();
    _bedroomsController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _bathroomsController.dispose();
    _balconyController.dispose();
    _areaController.dispose();
    _kitchenController.dispose();
    _attachedBathController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _ageController.dispose();
    _colorController.dispose();
    _batteryLifeController.dispose();
    _connectivityController.dispose();
    _yearController.dispose();
    _kmDrivenController.dispose();
    _ownersController.dispose();
    _mileageController.dispose();
    _insuranceController.dispose();
    _bodyTypeController.dispose();
    _extColorController.dispose();
    _intColorController.dispose();
    _horsepowerController.dispose();
    _engineCapacityController.dispose();
    _seaterCapacityController.dispose();
    _doorsController.dispose();
    _storageController.dispose();
    _ramController.dispose();
    _batteryHealthController.dispose();
    _osVersionController.dispose();
    _damageController.dispose();
    _materialController.dispose();
    _dimensionsController.dispose();
    _sizeController.dispose();
    _subjectController.dispose();
    _levelController.dispose();
    _instituteController.dispose();
    _durationController.dispose();
    _batchSizeController.dispose();
    _productTypeController.dispose();
    _breedController.dispose();
    _eventDateController.dispose();
    _eventTimeController.dispose();
    _venueController.dispose();
    _organizerController.dispose();
    _highlightsController.dispose();
    _availabilityController.dispose();
    _companyController.dispose();
    _experienceController.dispose();
    _qualificationController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _locationAreaController.dispose();
    _pincodeController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_images.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only upload up to 5 images')),
      );
      return;
    }
    
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _images.add(File(image.path));
      });
    }
  }

  bool _isSubmitting = false;

  String _getDbCategoryName(String categoryName) {
    switch (categoryName) {
      case 'Beauty & Wellness':
        return 'Beauty';
      case 'Gadgets & Electronics':
        return 'Electronics';
      case 'Furniture & Hardware':
        return 'Furniture';
      case 'Mobiles & Tablets':
        return 'Mobiles';
      default:
        return categoryName;
    }
  }

  void _submitForm() async {
    bool isExemptCategory = widget.category.toLowerCase().contains('job') || 
                            widget.category.toLowerCase().contains('education') || 
                            widget.category.toLowerCase().contains('learning') || 
                            widget.category.toLowerCase().contains('service');

    if (_images.isEmpty && !isExemptCategory) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload at least one image'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final data = {
      'title': _titleController.text,
      'price': _priceController.text,
      'phone': _phoneController.text,
      'description': _descriptionController.text,
      'category': _getDbCategoryName(widget.category),
      ..._getCategorySpecificData(),
      'state': _stateController.text,
      'city': _cityController.text,
      'locationArea': _locationAreaController.text,
      'pincode': _pincodeController.text,
      'landmark': _landmarkController.text,
    };

    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final success = await productProvider.createAd(data, _images);
    
    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ad published successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen(initialIndex: 1)),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(productProvider.error ?? 'Failed to publish ad'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Map<String, dynamic> _getCategorySpecificData() {
    final cat = widget.category.toLowerCase();
    Map<String, dynamic> data = {};

    if (cat.contains('property') || cat.contains('real estate')) {
      data = {
        'propertyType': _propertyType,
        'roomType': _roomTypeController.text,
        'securityDeposit': _securityDepositController.text,
        'bedrooms': _bedroomsController.text,
        'bathrooms': _bathroomsController.text,
        'balcony': _balconyController.text,
        'area': _areaController.text,
        'kitchen': _kitchenController.text,
        'attachedBathroom': _attachedBathController.text,
        'furnished': _furnishedStatus,
        'tenants': _tenantPreference,
        'amenities': _selectedAmenities,
        if (_propertyType == 'PG') 'minPrice': _minPriceController.text,
        if (_propertyType == 'PG') 'maxPrice': _maxPriceController.text,
      };
    } else if (cat.contains('gadget') || cat.contains('electronic')) {
      data = {
        'brand': _brandController.text,
        'model': _modelController.text,
        'condition': _condition,
        'warranty': _warranty,
        'age': _ageController.text,
        'color': _colorController.text,
        'batteryLife': _batteryLifeController.text,
        'connectivity': _connectivityController.text,
      };
    } else if (cat.contains('automobile') || cat.contains('car')) {
      data = {
        'vehicleType': _vehicleType,
        'brand': _brandController.text,
        'model': _modelController.text,
        'year': _yearController.text,
        'kmDriven': _kmDrivenController.text,
        'owners': _ownersController.text,
        'mileage': _mileageController.text,
        'insurance': _insuranceController.text,
        'fuelType': _fuelType,
        'transmission': _transmission,
        'condition': _condition,
        'warranty': _warranty,
        'bodyType': _bodyTypeController.text,
        'exteriorColor': _extColorController.text,
        'interiorColor': _intColorController.text,
        'horsepower': _horsepowerController.text,
        'engineCapacity': _engineCapacityController.text,
        'seaterCapacity': _seaterCapacityController.text,
        'doors': _doorsController.text,
      };
    } else if (cat.contains('mobile') || cat.contains('tablet')) {
      data = {
        'brand': _brandController.text,
        'model': _modelController.text,
        'storage': _storageController.text,
        'ram': _ramController.text,
        'condition': _condition,
        'color': _colorController.text,
        'age': _ageController.text,
        'batteryHealth': _batteryHealthController.text,
        'versionOS': _osVersionController.text,
        'physicalDamage': _damageController.text,
        'warranty': _warranty,
      };
    } else if (cat.contains('furniture')) {
      data = {
        'material': _materialController.text,
        'color': _colorController.text,
        'dimensions': _dimensionsController.text,
        'age': _ageController.text,
        'condition': _condition,
      };
    } else if (cat.contains('fashion') || cat.contains('lifestyle')) {
      data = {
        'size': _sizeController.text,
        'color': _colorController.text,
        'material': _materialController.text,
        'brand': _brandController.text,
        'condition': _condition,
      };
    } else if (cat.contains('pet') || cat.contains('animal')) {
      bool isAcc = _petCategory == 'Accessory' || _petCategory == 'Food';
      if (isAcc) {
        data = {
          'petCategory': _petCategory,
          'brand': _brandController.text,
          'model': _modelController.text,
          'age': _ageController.text,
          'color': _colorController.text,
          'condition': _condition,
        };
      } else {
        data = {
          'petCategory': _petCategory,
          'breed': _breedController.text,
          'age': _ageController.text,
          'color': _colorController.text,
          'gender': _gender,
          'vaccinated': _vaccinated,
          'kciRegistered': _kciRegistered,
          'healthCert': _healthCert,
          'dewormed': _dewormed,
          'microchipped': _microchipped,
        };
      }
    } else if (cat.contains('event')) {
      data = {
        'eventDate': _eventDateController.text,
        'eventTime': _eventTimeController.text,
        'venue': _venueController.text,
        'organizer': _organizerController.text,
        'highlights': _highlightsController.text,
      };
    } else if (cat.contains('beauty') || cat.contains('wellness')) {
      data = {
        'productType': _productTypeController.text,
        'duration': _durationController.text,
        'genderPreference': _gender,
      };
    } else if (cat.contains('education') || cat.contains('learning')) {
      data = {
        'subject': _subjectController.text,
        'level': _levelController.text,
        'institute': _instituteController.text,
        'duration': _durationController.text,
        'experience': _experienceController.text,
        'batchSize': _batchSizeController.text,
        'teachingMode': _teachingMode,
      };
    } else if (cat.contains('service')) {
      data = {
        'availability': _availabilityController.text,
        'experience': _experienceController.text,
      };
    } else if (cat.contains('job')) {
      data = {
        'companyName': _companyController.text,
        'experienceLevel': _experienceController.text,
        'workMode': _workMode,
        'genderPreference': _genderPref,
        'qualification': _qualificationController.text,
      };
    } else {
      data = {
        'brand': _brandController.text,
        'model': _modelController.text,
        'condition': _condition,
      };
    }
    if (_selectedSubCategory != null) {
      data['subCategory'] = _selectedSubCategory;
    } else {
      data['subCategory'] = _getSubcategories(widget.category.toLowerCase()).first;
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Post in ${widget.category}',
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildCurrentStepContent(),
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Basic', 'Details', 'Media', 'Location', 'Review'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      color: const Color(0xFFFFFDF5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(steps.length, (index) {
          final isActive = _currentStep == index;
          final isCompleted = _currentStep > index;
          
          return Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive 
                      ? AppTheme.secondaryColor
                      : isCompleted 
                          ? AppTheme.secondaryColor.withOpacity(0.6)
                          : Colors.grey.shade400,
                ),
                child: Center(
                  child: Text(
                    (index + 1).toString(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                steps[index],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.black : Colors.grey,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0: return _buildBasicStep();
      case 1: return _buildSpecsStep();
      case 2: return _buildPhotosStep();
      case 3: return _buildLocationStep();
      case 4: return _buildConfirmStep();
      default: return const SizedBox.shrink();
    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_formKeyBasic.currentState!.validate()) return;
    } else if (_currentStep == 1) {
      if (!_formKeyDetails.currentState!.validate()) return;
    } else if (_currentStep == 2) {
      bool isExemptCategory = widget.category.toLowerCase().contains('job') || 
                              widget.category.toLowerCase().contains('education') || 
                              widget.category.toLowerCase().contains('learning') || 
                              widget.category.toLowerCase().contains('service');
      if (_images.isEmpty && !isExemptCategory) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload at least one image'), backgroundColor: Colors.red),
        );
        return;
      }
    } else if (_currentStep == 3) {
      if (!_formKeyLocation.currentState!.validate()) return;
    }

    if (_currentStep < 4) {
      setState(() => _currentStep++);
    } else {
      _submitForm();
    }
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _currentStep--),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: const Text('Back', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  shadowColor: AppTheme.secondaryColor.withOpacity(0.3),
                ),
                child: _isSubmitting && _currentStep == 4 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : Text(_currentStep == 4 ? 'Publish Ad' : 'Next Step', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicStep() {
    return Form(
      key: _formKeyBasic,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Listing Title*'),
          _buildTextField(
            _titleController, 
            'e.g. Title of your ad',
            validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a title' : null,
          ),
          const SizedBox(height: 20),
          _buildLabel(widget.category.toLowerCase().contains('job') ? 'Salary (Monthly)*' : ((widget.category.toLowerCase().contains('property') || widget.category.toLowerCase().contains('real estate')) ? 'Price (₹) (Optional for PG)' : ((widget.category.toLowerCase().contains('education') || widget.category.toLowerCase().contains('learning')) ? 'Price (₹) (Optional)' : 'Price (₹)*'))),
          _buildTextField(
            _priceController, 
            'e.g. 5000 or Negotiable', 
            keyboardType: TextInputType.text,
            validator: (v) {
              if (widget.category.toLowerCase().contains('education') || widget.category.toLowerCase().contains('learning') || widget.category.toLowerCase().contains('property') || widget.category.toLowerCase().contains('real estate')) return null;
              return v == null || v.trim().isEmpty ? 'Please enter a price' : null;
            },
          ),
          const SizedBox(height: 20),
          _buildLabel('Contact Number*'),
          _buildTextField(
            _phoneController, 
            'e.g. 9876543210', 
            keyboardType: TextInputType.phone,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Please enter contact number';
              if (v.trim().length < 10) return 'Enter a valid 10-digit number';
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildLabel('Description*'),
          _buildTextField(
            _descriptionController, 
            'Provide details about your listing...', 
            maxLines: 4,
            validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a description' : null,
          ),
        ],
      ),
    );
  }

  List<String> _getSubcategories(String cat) {
    if (cat.contains('property') || cat.contains('real estate')) {
      return ['Apartment', 'House', 'Villa', 'Plot', 'PG', 'Other'];
    } else if (cat.contains('gadget') || cat.contains('electronic')) {
      return ['Laptops', 'Cameras', 'TVs', 'Audio', 'Accessories', 'Other'];
    } else if (cat.contains('automobile') || cat.contains('car')) {
      return ['Cars', 'Bikes', 'Scooters', 'Commercial Vehicles', 'Bicycles', 'Other'];
    } else if (cat.contains('mobile') || cat.contains('tablet')) {
      return ['Mobile Phones', 'Tablets', 'Accessories', 'Smartwatches', 'Other'];
    } else if (cat.contains('furniture')) {
      return ['Sofa', 'Bed', 'Wardrobe', 'Table', 'Chairs', 'Other'];
    } else if (cat.contains('fashion') || cat.contains('lifestyle')) {
      return ['Men', 'Women', 'Kids', 'Accessories', 'Footwear', 'Other'];
    } else if (cat.contains('pet') || cat.contains('animal')) {
      return ['Dogs', 'Cats', 'Fishes', 'Birds', 'Accessories', 'Food', 'Other'];
    } else if (cat.contains('event')) {
      return ['Weddings', 'Parties', 'Corporate', 'Concerts', 'Other'];
    } else if (cat.contains('beauty') || cat.contains('wellness')) {
      return ['Makeup', 'Skincare', 'Haircare', 'Fragrances', 'Other'];
    } else if (cat.contains('education') || cat.contains('learning')) {
      return ['Tutoring', 'Courses', 'Workshops', 'Books', 'Other'];
    } else if (cat.contains('service')) {
      return ['Cleaning', 'Plumbing', 'Electrical', 'Carpentry', 'Other'];
    } else if (cat.contains('job')) {
      return ['IT', 'BPO', 'Sales', 'Marketing', 'Finance', 'Other'];
    }
    return ['General', 'Other'];
  }

  Widget _buildSpecsStep() {
    final cat = widget.category.toLowerCase();
    final subcategories = _getSubcategories(cat);

    return Form(
      key: _formKeyDetails,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Category / Sub-Category*'),
          _buildDropdown(
            subcategories, 
            _selectedSubCategory ?? subcategories.first, 
            (val) => setState(() => _selectedSubCategory = val)
          ),
          const SizedBox(height: 24),
          _buildCategoryFields(cat),
        ],
      ),
    );
  }

  Widget _buildCategoryFields(String cat) {

    if (cat.contains('property') || cat.contains('real estate')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Property Type*'),
          _buildSelectionGroup(['Apartment', 'House', 'Villa', 'Plot', 'PG'], _propertyType, (val) => setState(() => _propertyType = val)),
          const SizedBox(height: 24),

          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Room Type'), _buildTextField(_roomTypeController, 'e.g., Master Bedroom')])),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Security Deposit'), _buildTextField(_securityDepositController, 'e.g., 50000', keyboardType: TextInputType.number)])),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel(_propertyType == 'PG' ? 'Bedrooms (Optional)' : 'Bedrooms*'), _buildTextField(_bedroomsController, 'e.g., 3', keyboardType: TextInputType.number)])),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Bathrooms (Opt)'), _buildTextField(_bathroomsController, 'e.g., 2', keyboardType: TextInputType.number)])),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Balcony (Opt)'), _buildTextField(_balconyController, 'e.g., 1', keyboardType: TextInputType.number)])),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel(_propertyType == 'PG' ? 'Area (sq ft) (Optional)' : 'Area (sq ft)*'), _buildTextField(_areaController, 'e.g., 1200', keyboardType: TextInputType.number)])),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Kitchen (Opt)'), _buildTextField(_kitchenController, 'e.g., Modular')])),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Attached Bath'), _buildTextField(_attachedBathController, 'e.g., Yes')])),
            ],
          ),
          const SizedBox(height: 24),
          _buildLabel('Furnished Status (Optional)'),
          _buildSelectionGroup(['Fully Furnished', 'Semi Furnished', 'Unfurnished'], _furnishedStatus, (val) => setState(() => _furnishedStatus = val)),
          const SizedBox(height: 24),
          _buildLabel('Tenant Preference'),
          _buildSelectionGroup(['Family', 'Bachelor', 'Company', 'Any'], _tenantPreference, (val) => setState(() => _tenantPreference = val)),
          const SizedBox(height: 24),
          _buildLabel('Amenities'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _amenitiesList.map((amenity) {
              final isSelected = _selectedAmenities.contains(amenity['name']);
              return InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedAmenities.remove(amenity['name']);
                    } else {
                      _selectedAmenities.add(amenity['name']);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.secondaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? AppTheme.secondaryColor : Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(amenity['icon'], size: 18, color: isSelected ? Colors.white : Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Text(amenity['name'], style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade800, fontSize: 12)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );
    }

    if (cat.contains('gadget') || cat.contains('electronic')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Brand*'), _buildTextField(_brandController, 'e.g., Sony, Nikon, Dell', validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null)])),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Model (Optional)'), _buildTextField(_modelController, 'e.g., WH-1000XM5, D5600')])),
            ],
          ),
          const SizedBox(height: 24),
          _buildLabel('Condition*'),
          _buildSelectionGroup(['New', 'Like New', 'Good', 'Fair'], _condition, (val) => setState(() => _condition = val)),
          const SizedBox(height: 24),
          _buildLabel('Warranty Status*'),
          _buildSelectionGroup(['In Warranty', 'Out of Warranty'], _warranty, (val) => setState(() => _warranty = val)),
          const SizedBox(height: 24),
          _buildLabel('Age (Optional)'),
          _buildTextField(_ageController, 'e.g., 6 months, 2 years'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Color (Optional)'), _buildTextField(_colorController, 'e.g., Black, Silver')])),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Battery Life (Opt)'), _buildTextField(_batteryLifeController, 'e.g., 24 Hours')])),
            ],
          ),
          const SizedBox(height: 20),
          _buildLabel('Connectivity (Optional)'),
          _buildTextField(_connectivityController, 'e.g., Bluetooth 5.0, Wi-Fi 6, USB-C'),
        ],
      );
    }

    if (cat.contains('automobile') || cat.contains('car')) {
      final isBicycle = _vehicleType == 'Bicycle';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Vehicle Type*'),
          _buildSelectionGroup(['Car', 'Bike', 'Scooter', 'Commercial Vehicle', 'Bicycle'], _vehicleType, (val) => setState(() => _vehicleType = val)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Brand*'), _buildTextField(_brandController, isBicycle ? 'e.g., Hero, Trek, Firefox' : 'e.g., Honda, Maruti, Hyundai', validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null)])),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Model (Optional)'), _buildTextField(_modelController, isBicycle ? 'e.g., Lectro, Ranger' : 'e.g., City, Swift, Creta')])),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel(isBicycle ? 'Year (Optional)' : 'Year*'), _buildTextField(_yearController, 'e.g., 2020', keyboardType: TextInputType.number, validator: isBicycle ? null : (v) => v == null || v.trim().isEmpty ? 'Required' : null)])),
              const SizedBox(width: 16),
              if (!isBicycle)
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('KM Driven*'), _buildTextField(_kmDrivenController, 'e.g., 25000', keyboardType: TextInputType.number, validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null)])),
              if (isBicycle)
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Gear System (Optional)'), _buildTextField(_bodyTypeController, 'e.g., 21-Speed, Single Speed')])),
            ],
          ),
          const SizedBox(height: 20),
          _buildLabel('No. of Owners (Optional)'),
          _buildTextField(_ownersController, 'e.g., 1st Owner, 2nd Owner'),
          const SizedBox(height: 24),
          _buildLabel('Condition*'),
          _buildSelectionGroup(['New', 'Used', 'Refurbished'], _condition, (val) => setState(() => _condition = val)),
          const SizedBox(height: 24),
          if (!isBicycle) ...[
            Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Mileage (Opt)'), _buildTextField(_mileageController, 'e.g., 18 kmpl')])),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Insurance (Opt)'), _buildTextField(_insuranceController, 'e.g., Valid until Dec 2025')])),
              ],
            ),
            const SizedBox(height: 24),
            _buildLabel('Warranty*'),
            _buildSelectionGroup(['Under Warranty', 'Expired', 'N/A'], _warranty, (val) => setState(() => _warranty = val)),
            const SizedBox(height: 24),
            _buildLabel('Fuel Type*'),
            _buildSelectionGroup(['Petrol', 'Diesel', 'Electric', 'CNG', 'Hybrid'], _fuelType, (val) => setState(() => _fuelType = val)),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Transmission*'), _buildSelectionGroup(['Manual', 'Automatic'], _transmission, (val) => setState(() => _transmission = val))])),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Body Type (Opt)'), _buildTextField(_bodyTypeController, 'e.g., SUV, Sedan, Hatchback')])),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Exterior Color'), _buildTextField(_extColorController, 'e.g., White, Black, Red')])),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Interior Color'), _buildTextField(_intColorController, 'e.g., Beige, Black, Tan')])),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Horsepower'), _buildTextField(_horsepowerController, 'e.g., 120 HP')])),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Engine Cap'), _buildTextField(_engineCapacityController, 'e.g., 1500 cc')])),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Seater Cap'), _buildTextField(_seaterCapacityController, 'e.g., 5, 7')])),
              ],
            ),
            const SizedBox(height: 20),
            _buildLabel('Doors'),
            _buildTextField(_doorsController, 'e.g., 4, 2'),
          ],
          if (isBicycle) ...[
            Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Frame Size (Optional)'), _buildTextField(_extColorController, 'e.g., 26 inch, 29 inch')])),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Color (Optional)'), _buildTextField(_intColorController, 'e.g., Red, Black, Blue')])),
              ],
            ),
            const SizedBox(height: 20),
            _buildLabel('Warranty (Optional)'),
            _buildSelectionGroup(['Under Warranty', 'Expired', 'N/A'], _warranty, (val) => setState(() => _warranty = val)),
          ],
        ],
      );
    }


    if (cat.contains('mobile') || cat.contains('tablet')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Brand*'), _buildTextField(_brandController, 'e.g., Apple, Samsung, OnePlus', validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null)])),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Model (Optional)'), _buildTextField(_modelController, 'e.g., iPhone 14 Pro, Galaxy S23')])),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Storage (Optional)'), _buildTextField(_storageController, 'e.g., 128GB, 256GB')])),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('RAM (Optional)'), _buildTextField(_ramController, 'e.g., 6GB, 8GB')])),
            ],
          ),
          const SizedBox(height: 24),
          _buildLabel('Condition*'),
          _buildSelectionGroup(['New', 'Like New', 'Good', 'Fair'], _condition, (val) => setState(() => _condition = val)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Colour'), _buildTextField(_colorController, 'e.g., Space Black, Deep Purple')])),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Age'), _buildTextField(_ageController, 'e.g., 1 Year, 6 Months')])),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Battery Health'), _buildTextField(_batteryHealthController, 'e.g., 90%, 100%')])),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Version/OS'), _buildTextField(_osVersionController, 'e.g., iOS 17, Android 14')])),
            ],
          ),
          const SizedBox(height: 20),
          _buildLabel('Physical Damage'),
          _buildTextField(_damageController, 'e.g., None, Minor scratches on screen'),
          const SizedBox(height: 24),
          _buildLabel('Warranty Status*'),
          _buildSelectionGroup(['In Warranty', 'Out of Warranty'], _warranty, (val) => setState(() => _warranty = val)),
        ],
      );
    }

    if (cat.contains('furniture')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Material*'),
          _buildTextField(_materialController, 'e.g., Teak Wood, Sheesham, Steel', validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Color (Optional)'), _buildTextField(_colorController, 'e.g., Brown, White, Black')])),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Dimensions (Opt)'), _buildTextField(_dimensionsController, 'e.g., 6x4 ft')])),
            ],
          ),
          const SizedBox(height: 20),
          _buildLabel('Age (Optional)'),
          _buildTextField(_ageController, 'e.g., 6 months, 2 years'),
          const SizedBox(height: 24),
          _buildLabel('Condition*'),
          _buildSelectionGroup(['New', 'Like New', 'Good', 'Fair'], _condition, (val) => setState(() => _condition = val)),
        ],
      );
    }

    if (cat.contains('fashion') || cat.contains('lifestyle')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Size (Optional)'), _buildTextField(_sizeController, 'e.g., M, L, XL, UK 8')])),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Color (Optional)'), _buildTextField(_colorController, 'e.g., Navy Blue, Red')])),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Material (Optional)'), _buildTextField(_materialController, 'e.g., Cotton, Silk, Leather')])),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Brand (Optional)'), _buildTextField(_brandController, 'e.g., Zara, H&M')])),
            ],
          ),
          const SizedBox(height: 24),
          _buildLabel('Condition*'),
          _buildSelectionGroup(['New', 'Like New', 'Good', 'Fair'], _condition, (val) => setState(() => _condition = val)),
        ],
      );
    }

    if (cat.contains('pet') || cat.contains('animal')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Category*'),
          _buildSelectionGroup(['Dog', 'Cat', 'Bird', 'Fish', 'Accessory', 'Food'], _petCategory, (val) => setState(() => _petCategory = val)),
          const SizedBox(height: 24),
          
          if (_petCategory == 'Accessory' || _petCategory == 'Food') ...[
            _buildLabel('Brand*'),
            _buildTextField(_brandController, 'e.g., Royal Canin, Pedigree, Whiskas', validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
            const SizedBox(height: 20),
            _buildLabel('Model / Type (Optional)'),
            _buildTextField(_modelController, 'e.g., Puppy Food, Adult Toy'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Age (Optional)'), _buildTextField(_ageController, 'e.g., 2 Months, New')])),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Color (Optional)'), _buildTextField(_colorController, 'e.g., Brown, White')])),
              ],
            ),
            const SizedBox(height: 24),
            _buildLabel('Condition*'),
            _buildSelectionGroup(['New', 'Used'], _condition, (val) => setState(() => _condition = val)),
          ] else ...[
            _buildLabel('Breed / Type (Optional)'),
            _buildTextField(_breedController, 'e.g., Labrador, Siamese, Goldfish'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Age (Optional)'), _buildTextField(_ageController, 'e.g., 2 months, 1 year')])),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Color (Optional)'), _buildTextField(_colorController, 'e.g., Golden, Black, Mixed')])),
              ],
            ),
            const SizedBox(height: 24),
            _buildLabel('Gender*'),
            _buildSelectionGroup(['Male', 'Female'], _gender, (val) => setState(() => _gender = val)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Vaccinated (Optional)'), _buildSelectionGroup(['Yes', 'No'], _vaccinated, (val) => setState(() => _vaccinated = val))])),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('KCI Registered (Optional)'), _buildSelectionGroup(['Yes', 'No'], _kciRegistered, (val) => setState(() => _kciRegistered = val))])),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Health Certificate'), _buildSelectionGroup(['Yes', 'No'], _healthCert, (val) => setState(() => _healthCert = val))])),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Dewormed'), _buildSelectionGroup(['Yes', 'No'], _dewormed, (val) => setState(() => _dewormed = val))])),
              ],
            ),
            const SizedBox(height: 24),
            _buildLabel('Microchipped'),
            _buildSelectionGroup(['Yes', 'No'], _microchipped, (val) => setState(() => _microchipped = val)),
          ],
        ],
      );
    }

    if (cat.contains('event')) {
      final months = ['January', 'February', 'March', 'April', 'May', 'June',
                      'July', 'August', 'September', 'October', 'November', 'December'];
      final currentYear = DateTime.now().year;
      final years = List.generate(4, (i) => (currentYear + i).toString());

      // Sync manual date selections into _eventDateController
      void syncEventDate() {
        final d = _eventDay ?? '';
        final m = _eventMonth != null ? (months.indexOf(_eventMonth!) + 1).toString().padLeft(2, '0') : '';
        final y = _eventYear ?? '';
        if (d.isNotEmpty && m.isNotEmpty && y.isNotEmpty) {
          _eventDateController.text = '$d-$m-$y';
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Event Date (Optional)'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Day
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Day', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextFormField(
                            initialValue: _eventDay,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'DD',
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.secondaryColor, width: 1.5)),
                            ),
                            onChanged: (v) { _eventDay = v; syncEventDate(); },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Month
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Month', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _eventMonth,
                                isExpanded: true,
                                hint: const Text('Month', style: TextStyle(color: Color(0xFFADB5BD), fontSize: 14)),
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                                style: const TextStyle(color: Colors.black87, fontSize: 14),
                                items: months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                                onChanged: (v) { setState(() { _eventMonth = v; syncEventDate(); }); },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Year
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Year', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _eventYear,
                                isExpanded: true,
                                hint: const Text('Year', style: TextStyle(color: Color(0xFFADB5BD), fontSize: 14)),
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                                style: const TextStyle(color: Colors.black87, fontSize: 14),
                                items: years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                                onChanged: (v) { setState(() { _eventYear = v; syncEventDate(); }); },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_eventDateController.text.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppTheme.secondaryColor, size: 16),
                      const SizedBox(width: 6),
                      Text('Date: ${_eventDateController.text}', style: const TextStyle(fontSize: 13, color: AppTheme.secondaryColor, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildLabel('Event Time (Optional)'),
          InkWell(
            onTap: () async {
              final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
              if (time != null) {
                setState(() => _eventTimeController.text = time.format(context));
              }
            },
            child: IgnorePointer(
              child: _buildTextField(_eventTimeController, 'Tap to select time', suffixIcon: Icons.access_time_outlined),
            ),
          ),
          const SizedBox(height: 20),
          _buildLabel('Venue Name / Address*'),
          _buildTextField(_venueController, 'e.g., City Convention Center, Bandra', validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
          const SizedBox(height: 20),
          _buildLabel('Organizer (Optional)'),
          _buildTextField(_organizerController, 'e.g., Global Events Ltd.'),
          const SizedBox(height: 20),
          _buildLabel('Event Highlights (Optional)'),
          _buildTextField(_highlightsController, 'Enter highlights (one per line) e.g., Live Music, Free Snacks...', maxLines: 4),
          const Text('Enter each highlight on a new line.', style: TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      );
    }

    if (cat.contains('beauty') || cat.contains('wellness')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Product Type*'),
          _buildTextField(_productTypeController, 'e.g., Facial, Haircut, Manicure', validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Duration (Optional)'), _buildTextField(_durationController, 'e.g., 45 mins, 1 hour')])),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Gender Preference*'), _buildSelectionGroup(['Female', 'Male', 'Unisex'], _gender, (val) => setState(() => _gender = val))])),
            ],
          ),
        ],
      );
    }

    if (cat.contains('education') || cat.contains('learning')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Subject / Course Name (Optional)'),
          _buildTextField(_subjectController, 'e.g., Mathematics, ReactJS, IELTS'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Level / Class (Opt)'), _buildTextField(_levelController, 'e.g., Beginner, Class 12')])),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Institute Name (Opt)'), _buildTextField(_instituteController, 'e.g., ABC Learning Center')])),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Duration (Opt)'), _buildTextField(_durationController, 'e.g., 3 Months')])),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Experience (Opt)'), _buildTextField(_experienceController, 'e.g., 5 Years')])),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Batch Size (Opt)'), _buildTextField(_batchSizeController, 'e.g., 10 Students')])),
            ],
          ),
          const SizedBox(height: 24),
          _buildLabel('Mode of Teaching*'),
          _buildSelectionGroup(['Online', 'Offline', 'Hybrid'], _teachingMode, (val) => setState(() => _teachingMode = val)),
        ],
      );
    }

    if (cat.contains('service')) {
      final months = ['January', 'February', 'March', 'April', 'May', 'June',
                      'July', 'August', 'September', 'October', 'November', 'December'];
      final currentYear = DateTime.now().year;
      final years = List.generate(4, (i) => (currentYear + i).toString());

      void syncServiceAvailability() {
        final d = _serviceDay ?? '';
        final m = _serviceMonth != null ? (months.indexOf(_serviceMonth!) + 1).toString().padLeft(2, '0') : '';
        final y = _serviceYear ?? '';
        if (d.isNotEmpty && m.isNotEmpty && y.isNotEmpty) {
          final timePart = _availabilityController.text.contains(' at ')
              ? _availabilityController.text.split(' at ').last
              : '';
          _availabilityController.text = '$d-$m-$y${timePart.isNotEmpty ? ' at $timePart' : ''}';
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Availability*'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Day
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Day', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextFormField(
                            initialValue: _serviceDay,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'DD',
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.secondaryColor, width: 1.5)),
                            ),
                            onChanged: (v) { _serviceDay = v; syncServiceAvailability(); },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Month
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Month', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _serviceMonth,
                                isExpanded: true,
                                hint: const Text('Month', style: TextStyle(color: Color(0xFFADB5BD), fontSize: 14)),
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                                style: const TextStyle(color: Colors.black87, fontSize: 14),
                                items: months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                                onChanged: (v) { setState(() { _serviceMonth = v; syncServiceAvailability(); }); },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Year
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Year', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _serviceYear,
                                isExpanded: true,
                                hint: const Text('Year', style: TextStyle(color: Color(0xFFADB5BD), fontSize: 14)),
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                                style: const TextStyle(color: Colors.black87, fontSize: 14),
                                items: years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                                onChanged: (v) { setState(() { _serviceYear = v; syncServiceAvailability(); }); },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Select Time', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (context, child) => Theme(
                        data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: AppTheme.secondaryColor)),
                        child: child!,
                      ),
                    );
                    if (time != null && mounted) {
                      setState(() {
                        final d = _serviceDay ?? '';
                        final mIdx = _serviceMonth != null ? (months.indexOf(_serviceMonth!) + 1).toString().padLeft(2, '0') : '';
                        final y = _serviceYear ?? '';
                        final datePart = (d.isNotEmpty && mIdx.isNotEmpty && y.isNotEmpty) ? '$d-$mIdx-$y' : '';
                        _availabilityController.text = datePart.isNotEmpty ? '$datePart at ${time.format(context)}' : time.format(context);
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time_outlined, size: 20, color: Colors.grey.shade500),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _availabilityController.text.contains(' at ')
                                ? _availabilityController.text.split(' at ').last
                                : 'Tap to select time',
                            style: TextStyle(
                              color: _availabilityController.text.contains(' at ')
                                  ? Colors.black87
                                  : Colors.grey.shade400,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade500),
                      ],
                    ),
                  ),
                ),
                if (_availabilityController.text.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppTheme.secondaryColor, size: 16),
                      const SizedBox(width: 6),
                      Expanded(child: Text('Availability: ${_availabilityController.text}', style: const TextStyle(fontSize: 13, color: AppTheme.secondaryColor, fontWeight: FontWeight.w600))),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildLabel('Experience (Optional)'),
          _buildTextField(_experienceController, 'e.g., 5 years, Certified Professional'),
        ],
      );
    }

    if (cat.contains('job')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Company Name*'),
          _buildTextField(_companyController, 'e.g., Tech Solutions Pvt. Ltd.', validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Experience Level*'),
                    _buildTextField(_experienceController, 'e.g., Fresher, 1-3 years', validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Work Mode*'),
                    _buildSelectionGroup(['On-site', 'Remote', 'Hybrid'], _workMode, (val) => setState(() => _workMode = val)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Gender Preference*'),
                    _buildDropdown(['Any', 'Male', 'Female'], _genderPref, (val) => setState(() => _genderPref = val!)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Qualification*'),
                    _buildTextField(_qualificationController, 'e.g., Any Graduate, B.Tech, MBA', validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Brand / Type*'),
        _buildTextField(_brandController, 'e.g. Item Brand', validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
        const SizedBox(height: 20),
        _buildLabel('Model / Style (Optional)'),
        _buildTextField(_modelController, 'e.g. Model Name'),
        const SizedBox(height: 20),
        _buildLabel('Condition*'),
        _buildSelectionGroup(['New', 'Like New', 'Used', 'Fair'], _condition, (val) => setState(() => _condition = val)),
      ],
    );
  }

  Widget _buildPhotosStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload up to 5 high-quality photos',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _images.length + 1,
          itemBuilder: (context, index) {
            if (index == _images.length) {
              return InkWell(
                onTap: _pickImage,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined, color: AppTheme.secondaryColor),
                      SizedBox(height: 4),
                      Text('Add Photo', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ),
              );
            }
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(_images[index], width: double.infinity, height: double.infinity, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: InkWell(
                    onTap: () => setState(() => _images.removeAt(index)),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.close, color: Colors.white, size: 14),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildLocationStep() {
    final addressProvider = context.watch<AddressProvider>();
    final addresses = addressProvider.addresses;
    
    List<String> dropdownItems = ['- Or enter manually below -'];
    dropdownItems.addAll(addresses.map((a) => '${a.name} (${a.cityName ?? a.areaName})'));

    return Form(
      key: _formKeyLocation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFEDD5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select from Saved Addresses', style: TextStyle(fontSize: 12, color: Colors.brown, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (addressProvider.isLoading)
                  const LinearProgressIndicator(minHeight: 2, backgroundColor: Colors.transparent, valueColor: AlwaysStoppedAnimation(Colors.brown))
                else
                  _buildDropdown(dropdownItems, _selectedSavedAddress, (val) {
                    if (val != null) {
                      setState(() {
                        _selectedSavedAddress = val;
                        if (val != '- Or enter manually below -') {
                          final selectedAddress = addresses.firstWhere((a) => '${a.name} (${a.cityName ?? a.areaName})' == val);
                          _stateController.text = selectedAddress.stateName ?? '';
                          _cityController.text = selectedAddress.cityName ?? '';
                          _selectedStateId = selectedAddress.stateId;
                          _selectedCityId = selectedAddress.cityId;
                          
                          // Sync with objects if lists are already loaded
                          if (_states.isNotEmpty && _selectedStateId != null) {
                            _selectedState = _states.firstWhereOrNull((s) => s.id == _selectedStateId);
                          }
                          
                          _locationAreaController.text = selectedAddress.areaName ?? '';
                          _pincodeController.text = selectedAddress.pincode ?? '';
                          _landmarkController.text = selectedAddress.fullAddress ?? '';
  
                          // If state is selected, fetch cities to sync city object later
                          if (_selectedStateId != null) {
                            _fetchCities(_selectedStateId!).then((_) {
                              if (_cities.isNotEmpty && _selectedCityId != null) {
                                setState(() {
                                  _selectedCity = _cities.firstWhereOrNull((c) => c.id == _selectedCityId);
                                });
                              }
                            });
                          }
                        }
                      });
                    }
                  }),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GoogleLocationPicker(
            label: 'Search Location *',
            hint: 'Search city, area, pincode...',
            icon: Icons.search,
            initialLocation: null,
            onChanged: (result) {
              if (result != null) {
                setState(() {
                  _stateController.text = result.state;
                  _cityController.text = result.city;
                  _locationAreaController.text = result.area;
                  _pincodeController.text = result.pincode;
                });
              }
            },
            validator: (v) => _cityController.text.isEmpty ? 'Please search and select a location' : null,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('State *'),
                    _buildTextField(_stateController, 'State', validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null, readOnly: true),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('City *'),
                    _buildTextField(_cityController, 'City', validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null, readOnly: true),
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
                    _buildTextField(
                      _locationAreaController, 
                      'e.g. Malad West',
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    _buildLabel('Pin Code *'), 
                    _buildTextField(
                      _pincodeController, 
                      'e.g. 400001', 
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildLabel('Landmark (Optional)'),
          _buildTextField(_landmarkController, 'e.g. Near HDFC Bank'),
        ],
      ),
    );
  }

  Widget _buildConfirmStep() {
    final specData = _getCategorySpecificData();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              _buildSummaryRow('Title', _titleController.text),
              const Divider(height: 24),
              _buildSummaryRow('Price', '₹${_priceController.text}'),
              const Divider(height: 24),
              _buildSummaryRow('Location', '${_locationAreaController.text}, ${_cityController.text}'),
              const Divider(height: 24),
              _buildSummaryRow('Category', widget.category),
              const Divider(height: 24),
              ...specData.entries.where((e) => e.value.toString().isNotEmpty && e.key != 'amenities').map((e) => Column(
                key: ValueKey('summary_${e.key}'),
                children: [
                  _buildSummaryRow(_formatKey(e.key), e.value.toString()),
                  const Divider(height: 24),
                ],
              )).toList(),
              if (_selectedAmenities.isNotEmpty) ...[
                _buildSummaryRow('AMENITIES', _selectedAmenities.join(', ')),
                const Divider(height: 24),
              ],
              _buildSummaryRow('Photos', '${_images.length} Selected'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.amber, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your ad will be reviewed and published within 24 hours.',
                  style: TextStyle(fontSize: 12, color: Colors.brown, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(width: 20),
        Flexible(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 14),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {TextInputType? keyboardType, int maxLines = 1, IconData? suffixIcon, bool readOnly = false, VoidCallback? onTap, String? Function(String?)? validator, List<TextInputFormatter>? inputFormatters}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: TextCapitalization.sentences,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Colors.grey.shade400, size: 20) : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.secondaryColor, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 1)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
      ),
    );
  }

  Widget _buildDropdown(List<String> options, String current, Function(String?) onSelect) {
    // Ensure the current value is in the options to avoid crashes
    String safeValue = options.contains(current) ? current : options.first;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeValue,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black54),
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          onChanged: onSelect,
          items: options.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSelectionGroup(List<String> options, String current, Function(String) onSelect) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options.map((opt) {
        final isSelected = current == opt;
        return InkWell(
          onTap: () => onSelect(opt),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.secondaryColor : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? AppTheme.secondaryColor : Colors.grey.shade200),
            ),
            child: Text(
              opt,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  String _formatKey(String key) {
    if (key == 'productType') return 'PRODUCT TYPE';
    if (key == 'jobType') return 'WORK MODE';
    if (key == 'teachingMode') return 'MODE OF TEACHING';
    
    // Convert camelCase to Space Separated and UpperCase
    String result = key.replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}');
    return result.toUpperCase().trim();
  }
}


