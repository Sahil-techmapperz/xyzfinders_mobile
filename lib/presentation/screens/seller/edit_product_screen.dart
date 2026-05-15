import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/product_service.dart';
import '../../../core/utils/toast_utils.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/category_model.dart';
import '../../../data/services/category_service.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/address_provider.dart';
import '../home/home_screen.dart';

class EditProductScreen extends StatefulWidget {
  final ProductModel product;

  const EditProductScreen({
    super.key,
    required this.product,
  });

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  
  // Generic Controllers
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _phoneController;
  late TextEditingController _descriptionController;
  
  // Property Specific Controllers
  final _roomTypeController = TextEditingController();
  final _securityDepositController = TextEditingController();
  final _bedroomsController = TextEditingController();
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
  final _serviceTypeController = TextEditingController();

  // Pets Specific Controllers
  final _breedController = TextEditingController();

  // Events Specific Controllers
  final _eventDateController = TextEditingController();
  final _eventTimeController = TextEditingController();
  final _venueController = TextEditingController();
  final _organizerController = TextEditingController();
  final _highlightsController = TextEditingController();

  // Services Specific Controllers
  final _availabilityController = TextEditingController();

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
  String _jobType = 'Full-time';
  String _workMode = 'On-site';
  String _gender = 'Male';
  String _genderPref = 'Any';
  String _teachingMode = 'Online';
  
  // Pet specific selections
  String _petCategory = 'Dog';
  String _vaccinated = 'Not Specified';
  String _kciRegistered = 'Not Specified';
  String _healthCert = 'Not Specified';
  String _dewormed = 'Not Specified';
  String _microchipped = 'Not Specified';
  
  String _selectedSavedAddress = '- Or enter manually below -';
  
  final List<File> _newImages = [];
  final ImagePicker _picker = ImagePicker();
  
  bool _isSubmitting = false;
  bool _isLoadingDetails = true;
  late ProductModel _currentProduct;

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
    _currentProduct = widget.product;
    _initializeControllers();
    _fetchFullDetails();
    
    // Fetch saved addresses for the location tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressProvider>().fetchAddresses();
    });
  }

  void _initializeControllers() {
    _titleController = TextEditingController(text: _currentProduct.title);
    _descriptionController = TextEditingController(text: _currentProduct.description);
    _priceController = TextEditingController(text: _currentProduct.price.toString());
    _phoneController = TextEditingController(text: _currentProduct.sellerPhone ?? '');
    
    // Pre-fill location
    _stateController.text = _currentProduct.stateName ?? '';
    _cityController.text = _currentProduct.cityName ?? '';
    _locationAreaController.text = _currentProduct.locationName ?? '';
    _pincodeController.text = _currentProduct.postalCode ?? '';
    
    // Condition handling with safety check for dropdown
    final conditionValue = _currentProduct.condition.toLowerCase();
    final validConditions = ['new', 'used', 'refurbished', 'like new', 'good', 'fair'];
    if (validConditions.contains(conditionValue)) {
      _condition = conditionValue[0].toUpperCase() + conditionValue.substring(1);
    } else {
      _condition = 'Used'; 
    }

    _prefillAttributes();
  }

  Future<void> _fetchFullDetails() async {
    try {
      final fullProduct = await ProductService().getProductById(widget.product.id);
      
      if (mounted) {
        setState(() {
          _currentProduct = fullProduct;
          _initializeControllers();
          _isLoadingDetails = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingDetails = false);
      }
    }
  }

  void _prefillAttributes() {
    final attrs = _currentProduct.productAttributes;
    if (attrs == null) return;

    final cat = (_currentProduct.categoryName ?? '').toLowerCase();

    // Mapping attributes to controllers/selections
    if (cat.contains('property')) {
      _propertyType = attrs['propertyType']?.toString() ?? 'Apartment';
      _roomTypeController.text = attrs['roomType']?.toString() ?? '';
      _securityDepositController.text = attrs['securityDeposit']?.toString() ?? '';
      _bedroomsController.text = attrs['bedrooms']?.toString() ?? '';
      _bathroomsController.text = attrs['bathrooms']?.toString() ?? '';
      _balconyController.text = attrs['balcony']?.toString() ?? '';
      _areaController.text = attrs['area']?.toString() ?? '';
      _kitchenController.text = attrs['kitchen']?.toString() ?? '';
      _attachedBathController.text = attrs['attachedBathroom']?.toString() ?? '';
      _furnishedStatus = attrs['furnished']?.toString() ?? 'Unfurnished';
      _tenantPreference = attrs['tenants']?.toString() ?? 'Any';
      if (attrs['amenities'] is List) {
        _selectedAmenities.addAll(List<String>.from(attrs['amenities']));
      }
    } else if (cat.contains('gadget') || cat.contains('electronic')) {
      _brandController.text = attrs['brand']?.toString() ?? '';
      _modelController.text = attrs['model']?.toString() ?? '';
      _warranty = attrs['warranty']?.toString() ?? 'In Warranty';
      _ageController.text = attrs['age']?.toString() ?? '';
      _colorController.text = attrs['color']?.toString() ?? '';
      _batteryLifeController.text = attrs['batteryLife']?.toString() ?? '';
      _connectivityController.text = attrs['connectivity']?.toString() ?? '';
    } else if (cat.contains('automobile') || cat.contains('car')) {
      _brandController.text = attrs['brand']?.toString() ?? '';
      _modelController.text = attrs['model']?.toString() ?? '';
      _yearController.text = attrs['year']?.toString() ?? '';
      _kmDrivenController.text = attrs['kmDriven']?.toString() ?? '';
      _ownersController.text = attrs['owners']?.toString() ?? '';
      _mileageController.text = attrs['mileage']?.toString() ?? '';
      _insuranceController.text = attrs['insurance']?.toString() ?? '';
      _fuelType = attrs['fuelType']?.toString() ?? 'Petrol';
      _transmission = attrs['transmission']?.toString() ?? 'Manual';
      _warranty = attrs['warranty']?.toString() ?? 'Under Warranty';
      _bodyTypeController.text = attrs['bodyType']?.toString() ?? '';
      _extColorController.text = attrs['exteriorColor']?.toString() ?? '';
      _intColorController.text = attrs['interiorColor']?.toString() ?? '';
      _horsepowerController.text = attrs['horsepower']?.toString() ?? '';
      _engineCapacityController.text = attrs['engineCapacity']?.toString() ?? '';
      _seaterCapacityController.text = attrs['seaterCapacity']?.toString() ?? '';
      _doorsController.text = attrs['doors']?.toString() ?? '';
    } else if (cat.contains('mobile') || cat.contains('tablet')) {
      _brandController.text = attrs['brand']?.toString() ?? '';
      _modelController.text = attrs['model']?.toString() ?? '';
      _storageController.text = attrs['storage']?.toString() ?? '';
      _ramController.text = attrs['ram']?.toString() ?? '';
      _colorController.text = attrs['color']?.toString() ?? '';
      _ageController.text = attrs['age']?.toString() ?? '';
      _batteryHealthController.text = attrs['batteryHealth']?.toString() ?? '';
      _osVersionController.text = attrs['versionOS']?.toString() ?? '';
      _damageController.text = attrs['physicalDamage']?.toString() ?? '';
      _warranty = attrs['warranty']?.toString() ?? 'In Warranty';
    } else if (cat.contains('furniture')) {
      _materialController.text = attrs['material']?.toString() ?? '';
      _colorController.text = attrs['color']?.toString() ?? '';
      _dimensionsController.text = attrs['dimensions']?.toString() ?? '';
      _ageController.text = attrs['age']?.toString() ?? '';
    } else if (cat.contains('fashion')) {
      _sizeController.text = attrs['size']?.toString() ?? '';
      _colorController.text = attrs['color']?.toString() ?? '';
      _materialController.text = attrs['material']?.toString() ?? '';
      _brandController.text = attrs['brand']?.toString() ?? '';
    } else if (cat.contains('pet')) {
      _petCategory = attrs['petCategory']?.toString() ?? 'Dog';
      _breedController.text = attrs['breed']?.toString() ?? '';
      _ageController.text = attrs['age']?.toString() ?? '';
      _colorController.text = attrs['color']?.toString() ?? '';
      _gender = attrs['gender']?.toString() ?? 'Male';
      _vaccinated = attrs['vaccinated']?.toString() ?? 'Not Specified';
      _kciRegistered = attrs['kciRegistered']?.toString() ?? 'Not Specified';
      _healthCert = attrs['healthCert']?.toString() ?? 'Not Specified';
      _dewormed = attrs['dewormed']?.toString() ?? 'Not Specified';
      _microchipped = attrs['microchipped']?.toString() ?? 'Not Specified';
    } else if (cat.contains('job')) {
      _companyController.text = attrs['companyName']?.toString() ?? '';
      _experienceController.text = attrs['experienceLevel']?.toString() ?? '';
      _workMode = attrs['workMode']?.toString() ?? 'On-site';
      _genderPref = attrs['genderPreference']?.toString() ?? 'Any';
      _qualificationController.text = attrs['qualification']?.toString() ?? '';
    } else if (cat.contains('education')) {
      _subjectController.text = attrs['subject']?.toString() ?? '';
      _levelController.text = attrs['level']?.toString() ?? '';
      _instituteController.text = attrs['institute']?.toString() ?? '';
      _durationController.text = attrs['duration']?.toString() ?? '';
      _experienceController.text = attrs['experience']?.toString() ?? '';
      _batchSizeController.text = attrs['batchSize']?.toString() ?? '';
      _teachingMode = attrs['teachingMode']?.toString() ?? 'Online';
    } else if (cat.contains('service')) {
      _availabilityController.text = attrs['availability']?.toString() ?? '';
      _experienceController.text = attrs['experience']?.toString() ?? '';
    }

    // Common fallbacks for catch-all
    if (_brandController.text.isEmpty) {
      _brandController.text = attrs['brand']?.toString() ?? attrs['make']?.toString() ?? '';
    }
    if (_modelController.text.isEmpty) {
      _modelController.text = attrs['model']?.toString() ?? '';
    }
    if (_colorController.text.isEmpty) {
      _colorController.text = attrs['color']?.toString() ?? '';
    }
    if (_ageController.text.isEmpty) {
      _ageController.text = attrs['age']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _roomTypeController.dispose();
    _securityDepositController.dispose();
    _bedroomsController.dispose();
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
    _serviceTypeController.dispose();
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
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _newImages.add(File(image.path));
      });
    }
  }

  void _submitForm() async {
    setState(() => _isSubmitting = true);

    final data = {
      'title': _titleController.text,
      'price': _priceController.text,
      'phone': _phoneController.text,
      'description': _descriptionController.text,
      'category_id': _currentProduct.categoryId,
      ..._getCategorySpecificData(),
      'state': _stateController.text,
      'city': _cityController.text,
      'locationArea': _locationAreaController.text,
      'pincode': _pincodeController.text,
      'landmark': _landmarkController.text,
    };

    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final success = await productProvider.updateAd(_currentProduct.id, data, _newImages);
    
    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        ToastUtils.showSuccess('Ad updated successfully!');
        Navigator.pop(context, true);
      } else {
        ToastUtils.showError(productProvider.error ?? 'Failed to update ad');
      }
    }
  }

  Map<String, dynamic> _getCategorySpecificData() {
    final cat = (_currentProduct.categoryName ?? '').toLowerCase();
    Map<String, dynamic> data = {};

    if (cat.contains('property')) {
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
    } else if (cat.contains('fashion')) {
      data = {
        'size': _sizeController.text,
        'color': _colorController.text,
        'material': _materialController.text,
        'brand': _brandController.text,
        'condition': _condition,
      };
    } else if (cat.contains('pet')) {
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
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          "Edit Ad",
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: _isLoadingDetails 
        ? const Center(child: CircularProgressIndicator())
        : Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppTheme.secondaryColor),
            ),
            child: Stepper(
          type: StepperType.horizontal,
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 4) {
              setState(() => _currentStep++);
            } else {
              _submitForm();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            }
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 32.0, bottom: 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      child: _isSubmitting && _currentStep == 4 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                        : Text(_currentStep == 4 ? 'Update Ad' : 'Next Step', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: details.onStepCancel,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: const Text('Back', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text('Basic', style: TextStyle(fontSize: 10)),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: _buildBasicStep(),
            ),
            Step(
              title: const Text('Details', style: TextStyle(fontSize: 10)),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: _buildSpecsStep(),
            ),
            Step(
              title: const Text('Media', style: TextStyle(fontSize: 10)),
              isActive: _currentStep >= 2,
              state: _currentStep > 2 ? StepState.complete : StepState.indexed,
              content: _buildPhotosStep(),
            ),
            Step(
              title: const Text('Location', style: TextStyle(fontSize: 10)),
              isActive: _currentStep >= 3,
              state: _currentStep > 3 ? StepState.complete : StepState.indexed,
              content: _buildLocationStep(),
            ),
            Step(
              title: const Text('Review', style: TextStyle(fontSize: 10)),
              isActive: _currentStep >= 4,
              state: _currentStep > 4 ? StepState.complete : StepState.indexed,
              content: _buildConfirmStep(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Listing Title*'),
        _buildTextField(_titleController, 'e.g. Title of your ad'),
        const SizedBox(height: 20),
        _buildLabel('Price (₹)*'),
        _buildTextField(_priceController, 'e.g. 5000', keyboardType: TextInputType.number),
        const SizedBox(height: 20),
        _buildLabel('Contact Number*'),
        _buildTextField(_phoneController, 'e.g. 9876543210', keyboardType: TextInputType.phone),
        const SizedBox(height: 20),
        _buildLabel('Description*'),
        _buildTextField(_descriptionController, 'Provide details about your listing...', maxLines: 4),
      ],
    );
  }

  Widget _buildSpecsStep() {
    final cat = (_currentProduct.categoryName ?? '').toLowerCase();

    // Reusing logic from PostAdFormScreen but pre-filling
    if (cat.contains('property')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Property Type*'),
          _buildSelectionGroup(['Apartment', 'House', 'Villa', 'Plot'], _propertyType, (val) => setState(() => _propertyType = val)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Room Type'), _buildTextField(_roomTypeController, 'e.g., Master Bedroom')])),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Security Deposit'), _buildTextField(_securityDepositController, 'e.g., 50000', keyboardType: TextInputType.number)])),
            ],
          ),
          const SizedBox(height: 20),
          _buildLabel('Furnished Status'),
          _buildSelectionGroup(['Fully Furnished', 'Semi Furnished', 'Unfurnished'], _furnishedStatus, (val) => setState(() => _furnishedStatus = val)),
        ],
      );
    }

    if (cat.contains('education')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Institute/School Name (Optional)'),
          _buildTextField(_instituteController, 'e.g., Bluebird Academy'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Subject'), _buildTextField(_subjectController, 'e.g., Mathematics')])),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Level'), _buildTextField(_levelController, 'e.g., Primary, High School')])),
            ],
          ),
          const SizedBox(height: 20),
          _buildLabel('Teaching Mode'),
          _buildSelectionGroup(['Online', 'Offline', 'Hybrid'], _teachingMode, (val) => setState(() => _teachingMode = val)),
          const SizedBox(height: 20),
          _buildLabel('Experience (Optional)'),
          _buildTextField(_experienceController, 'e.g., 5 years'),
        ],
      );
    }

    if (cat.contains('service')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Experience*'),
          _buildTextField(_experienceController, 'e.g., 3 years of experience'),
          const SizedBox(height: 20),
          _buildLabel('Availability'),
          _buildTextField(_availabilityController, 'e.g., Mon-Fri, 9am-6pm'),
        ],
      );
    }

    // Default Specs for most categories (Brand/Model/Condition)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Brand'), _buildTextField(_brandController, 'e.g., Sony, Apple')])),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Model'), _buildTextField(_modelController, 'e.g., PS5, iPhone 14')])),
          ],
        ),
        const SizedBox(height: 24),
        _buildLabel('Condition*'),
        _buildSelectionGroup(['New', 'Used', 'Refurbished'], _condition, (val) => setState(() => _condition = val)),
        const SizedBox(height: 24),
        _buildLabel('Warranty Status'),
        _buildSelectionGroup(['In Warranty', 'Out of Warranty'], _warranty, (val) => setState(() => _warranty = val)),
      ],
    );
  }

  Widget _buildPhotosStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Current Images'),
        if (_currentProduct.images != null && _currentProduct.images!.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _currentProduct.images!.length,
              itemBuilder: (context, index) {
                final img = _currentProduct.images![index];
                final url = img['image']?.toString() ?? '';
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(url.startsWith('http') ? url : 'https://xyzfinders.com/storage/$url'),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          )
        else
          const Text('No existing images').p8(),
        const SizedBox(height: 20),
        _buildLabel('Add New Images'),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ..._newImages.asMap().entries.map((entry) {
              return Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(image: FileImage(entry.value), fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    top: -5,
                    right: -5,
                    child: IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () => setState(() => _newImages.removeAt(entry.key)),
                    ),
                  ),
                ],
              );
            }),
            if (_newImages.length < 5)
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300, style: BorderStyle.none),
                  ),
                  child: const Icon(Icons.add_a_photo, color: Colors.grey),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationStep() {
    final addressProvider = context.watch<AddressProvider>();
    final addresses = addressProvider.addresses;
    
    List<String> dropdownItems = ['- Or enter manually below -'];
    dropdownItems.addAll(addresses.map((a) => '${a.name} (${a.cityName ?? a.areaName})'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (addresses.isNotEmpty) ...[
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
                          _locationAreaController.text = selectedAddress.areaName ?? '';
                          _pincodeController.text = selectedAddress.pincode ?? '';
                        }
                      });
                    }
                  }),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
        _buildLabel('State*'),
        _buildTextField(_stateController, 'e.g. Maharashtra'),
        const SizedBox(height: 20),
        _buildLabel('City*'),
        _buildTextField(_cityController, 'e.g. Mumbai'),
        const SizedBox(height: 20),
        _buildLabel('Area/Landmark'),
        _buildTextField(_locationAreaController, 'e.g. Bandra West'),
        const SizedBox(height: 20),
        _buildLabel('Pincode'),
        _buildTextField(_pincodeController, 'e.g. 400050', keyboardType: TextInputType.number),
      ],
    );
  }

  Widget _buildConfirmStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Review your changes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildReviewRow('Title', _titleController.text),
        _buildReviewRow('Price', '₹ ${_priceController.text}'),
        _buildReviewRow('Category', _currentProduct.categoryName ?? 'Other'),
        _buildReviewRow('Condition', _condition),
        _buildReviewRow('Location', '${_cityController.text}, ${_stateController.text}'),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue),
              const SizedBox(width: 12),
              const Expanded(child: Text('Please ensure all information is accurate before updating.', style: TextStyle(color: Colors.blue, fontSize: 12))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      ),
    );
  }

  Widget _buildSelectionGroup(List<String> options, String current, Function(String) onSelected) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options.map((option) {
        final isSelected = current == option;
        return InkWell(
          onTap: () => onSelected(option),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.secondaryColor : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? AppTheme.secondaryColor : Colors.grey.shade200),
            ),
            child: Text(option, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDropdown(List<String> items, String current, Function(String?) onChanged) {
    // Ensure current value is in items to avoid crash
    String initialValue = items.contains(current) ? current : items.first;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: initialValue,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
