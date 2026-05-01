import 'dart:io';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/agency_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/agency_models.dart';
import 'agency_add_post_images_screen.dart'; // We might integrate images into a step later

class AgencyPostAdWizardScreen extends StatefulWidget {
  final CategoryModel category;
  final AgencyAd? ad;
  const AgencyPostAdWizardScreen({super.key, required this.category, this.ad});

  @override
  State<AgencyPostAdWizardScreen> createState() => _AgencyPostAdWizardScreenState();
}

class _AgencyPostAdWizardScreenState extends State<AgencyPostAdWizardScreen> {
  int _currentStep = 1;
  final int _totalSteps = 5;

  final _formKeyBasic = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _contactController = TextEditingController(text: "8777507692"); // Placeholder from image
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<AgencyProvider>();
      
      if (widget.ad != null) {
        _titleController.text = widget.ad!.title;
        if (widget.ad!.price != null) {
          _priceController.text = widget.ad!.price!;
        }
        if (widget.ad!.phone != null) {
          _contactController.text = widget.ad!.phone!;
        }
        if (widget.ad!.description != null) {
          _descriptionController.text = widget.ad!.description!;
        }
        
        // Populate product attributes if available
        if (widget.ad!.productAttributes != null) {
          final attrs = widget.ad!.productAttributes!;
          
          setState(() {
            // Brand/Model (Shared across categories)
            if (attrs['brand'] != null) {
              final brand = attrs['brand'].toString();
              _brandController.text = brand;
              _mobBrandController.text = brand;
              _elecBrandController.text = brand;
              _fashionBrandController.text = brand;
              _petAccBrandController.text = brand;
            }
            if (attrs['model'] != null) {
              final model = attrs['model'].toString();
              _modelController.text = model;
              _mobModelController.text = model;
              _elecModelController.text = model;
            }
            
            // Vehicle specific
            if (attrs['year'] != null) _yearController.text = attrs['year'].toString();
            if (attrs['km_driven'] != null) _kmController.text = attrs['km_driven'].toString();
            if (attrs['owners'] != null) _ownersController.text = attrs['owners'].toString();
            if (attrs['mileage'] != null) _mileageController.text = attrs['mileage'].toString();
            if (attrs['insurance'] != null) _insuranceController.text = attrs['insurance'].toString();
            if (attrs['body_type'] != null) _bodyTypeController.text = attrs['body_type'].toString();
            if (attrs['exterior_color'] != null) _exteriorColorController.text = attrs['exterior_color'].toString();
            if (attrs['interior_color'] != null) _interiorColorController.text = attrs['interior_color'].toString();
            if (attrs['hp'] != null) _hpController.text = attrs['hp'].toString();
            if (attrs['engine'] != null) _engineController.text = attrs['engine'].toString();
            if (attrs['seater'] != null) _seaterController.text = attrs['seater'].toString();
            if (attrs['doors'] != null) _doorsController.text = attrs['doors'].toString();
            
            // Beauty/Service
            if (attrs['service_type'] != null) _serviceTypeController.text = attrs['service_type'].toString();
            if (attrs['duration'] != null) _durationController.text = attrs['duration'].toString();
            if (attrs['availability'] != null) _serviceAvailabilityController.text = attrs['availability'].toString();
            if (attrs['experience'] != null) _serviceExperienceController.text = attrs['experience'].toString();
            
            // Property
            if (attrs['room_type'] != null) _propRoomTypeController.text = attrs['room_type'].toString();
            if (attrs['deposit'] != null) _propDepositController.text = attrs['deposit'].toString();
            if (attrs['bedrooms'] != null) _propBedroomsController.text = attrs['bedrooms'].toString();
            if (attrs['bathrooms'] != null) _propBathroomsController.text = attrs['bathrooms'].toString();
            if (attrs['balconies'] != null) _propBalconyController.text = attrs['balconies'].toString();
            if (attrs['area'] != null) _propAreaController.text = attrs['area'].toString();
            if (attrs['kitchen'] != null) _propKitchenController.text = attrs['kitchen'].toString();
            if (attrs['attached_bath'] != null) _propAttachedBathController.text = attrs['attached_bath'].toString();
            
            // Mobile/Electronics
            if (attrs['storage'] != null) _mobStorageController.text = attrs['storage'].toString();
            if (attrs['ram'] != null) _mobRamController.text = attrs['ram'].toString();
            if (attrs['battery_health'] != null) _mobBatteryController.text = attrs['battery_health'].toString();
            if (attrs['os_version'] != null) _mobOsController.text = attrs['os_version'].toString();
            if (attrs['physical_damage'] != null) _mobDamageController.text = attrs['physical_damage'].toString();
            if (attrs['age'] != null) {
              final age = attrs['age'].toString();
              _mobAgeController.text = age;
              _elecAgeController.text = age;
              _furnAgeController.text = age;
            }
            if (attrs['color'] != null) {
              final color = attrs['color'].toString();
              _mobColorController.text = color;
              _elecColorController.text = color;
              _fashionColorController.text = color;
              _furnColorController.text = color;
            }
            
            // Update selection variables

            if (attrs['condition'] != null) {
              final cond = attrs['condition'].toString();
              _selectedCondition = cond;
              _selectedMobCondition = cond;
              _selectedElecCondition = cond;
              _selectedFashionCondition = cond;
              _selectedFurnCondition = cond;
              _selectedPetAccCondition = cond;
            }
            if (attrs['warranty'] != null) {
              final warranty = attrs['warranty'].toString();
              _selectedWarranty = warranty;
              _selectedMobWarranty = warranty;
              _selectedElecWarranty = warranty;
            }
            if (attrs['fuel_type'] != null) _selectedFuelType = attrs['fuel_type'].toString();
            if (attrs['transmission'] != null) _selectedTransmission = attrs['transmission'].toString();
            if (attrs['gender_preference'] != null) _selectedGenderPreference = attrs['gender_preference'].toString();
            if (attrs['property_type'] != null) _selectedPropType = attrs['property_type'].toString();
            if (attrs['furnishing'] != null) _selectedFurnishStatus = attrs['furnishing'].toString();
            if (attrs['tenant_preference'] != null) _selectedTenantPref = attrs['tenant_preference'].toString();
            if (attrs['amenities'] != null) {
               final amenities = attrs['amenities'].toString().split(',');
               _selectedAmenities.clear();
               _selectedAmenities.addAll(amenities.where((e) => e.isNotEmpty));
            }
          });
        }
        
        if (widget.ad!.images != null) {
          _existingImages.addAll(widget.ad!.images!);
        }
        
        // Populate basic location if available in profile
        if (provider.profile?.location != null) {
           // We might need a location controller later, but for now we follow original logic
        }
      } else {
        // Use existing user phone if available immediately
        if (provider.agencyUser?.phone != null) {
          _contactController.text = provider.agencyUser!.phone!;
        }
        
        // Fetch full profile and update if phone is different or was null
        await provider.fetchProfile();
        if (provider.profile?.phone != null) {
          _contactController.text = provider.profile!.phone!;
        }
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _contactController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 1) {
      if (!_formKeyBasic.currentState!.validate()) return;
    }
    
    if (_currentStep < _totalSteps) {
      setState(() => _currentStep++);
    } else {
      _submitAd();
    }
  }

  Future<void> _submitAd() async {
    final provider = context.read<AgencyProvider>();
    
    // Basic data
    final Map<String, dynamic> adData = {
      'title': _titleController.text,
      'price': _priceController.text,
      'phone': _contactController.text,
      'description': _descriptionController.text,
      'category_id': widget.category.id,
      'category': widget.category.name, // Send name for resolving if ID fails
      'location': provider.profile?.location ?? '',
      'condition': 'New', // Default condition
    };

    // Category specific data
    adData.addAll(_getCategorySpecificData());

    // Images
    if (_existingImages.isNotEmpty) {
      adData['existing_images'] = _existingImages;
    }
    
    if (_selectedImages.isNotEmpty) {
      adData['images'] = await Future.wait(_selectedImages.map((file) async {
        return await MultipartFile.fromFile(file.path, filename: file.path.split('/').last);
      }));
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF004D40))),
    );

    final success = widget.ad != null
        ? await provider.updateAd(widget.ad!.id, adData)
        : await provider.postAd(adData);
    
    // Close loading
    Navigator.pop(context);

    if (success) {
      VxToast.show(context, msg: widget.ad != null ? "Ad Updated Successfully!" : "Ad Published Successfully!", bgColor: const Color(0xFF004D40), textColor: Colors.white);
      Navigator.pop(context); // Close wizard
    } else {
      VxToast.show(context, msg: provider.error ?? "Failed to ${widget.ad != null ? 'update' : 'publish'} ad", bgColor: Colors.red);
    }
  }

  Map<String, dynamic> _getCategorySpecificData() {
    final name = widget.category.name.toLowerCase();
    final Map<String, dynamic> data = {};

    if (name.contains('auto') || name.contains('car') || name.contains('vehicle')) {
      data.addAll({
        'brand': _brandController.text,
        'model': _modelController.text,
        'year': _yearController.text,
        'km_driven': _kmController.text,
        'owners': _ownersController.text,
        'mileage': _mileageController.text,
        'insurance': _insuranceController.text,
        'body_type': _bodyTypeController.text,
        'exterior_color': _exteriorColorController.text,
        'interior_color': _interiorColorController.text,
        'hp': _hpController.text,
        'engine': _engineController.text,
        'seater': _seaterController.text,
        'doors': _doorsController.text,
        'condition': _selectedCondition,
        'warranty': _selectedWarranty,
        'fuel_type': _selectedFuelType,
        'transmission': _selectedTransmission,
      });
    } else if (name.contains('beauty') || name.contains('spa') || name.contains('salon')) {
      data.addAll({
        'service_type': _serviceTypeController.text,
        'duration': _durationController.text,
        'gender_preference': _selectedGenderPreference,
      });
    } else if (name.contains('property') || name.contains('estate') || name.contains('house') || name.contains('rent')) {
      data.addAll({
        'property_type': _selectedPropType,
        'room_type': _propRoomTypeController.text,
        'deposit': _propDepositController.text,
        'bedrooms': _propBedroomsController.text,
        'bathrooms': _propBathroomsController.text,
        'balconies': _propBalconyController.text,
        'area': _propAreaController.text,
        'kitchen': _propKitchenController.text,
        'attached_bath': _propAttachedBathController.text,
        'furnishing': _selectedFurnishStatus,
        'tenant_preference': _selectedTenantPref,
        'amenities': _selectedAmenities.join(','),
      });
    } else if (name.contains('mobile') || name.contains('phone') || name.contains('tablet')) {
      data.addAll({
        'brand': _mobBrandController.text,
        'model': _mobModelController.text,
        'storage': _mobStorageController.text,
        'ram': _mobRamController.text,
        'condition': _selectedMobCondition,
        'color': _mobColorController.text,
        'age': _mobAgeController.text,
        'battery_health': _mobBatteryController.text,
        'os_version': _mobOsController.text,
        'physical_damage': _mobDamageController.text,
        'warranty': _selectedMobWarranty,
      });
    } else if (name.contains('service')) {
      data.addAll({
        'availability': _serviceAvailabilityController.text,
        'experience': _serviceExperienceController.text,
      });
    } else if (name.contains('pet') || name.contains('animal')) {
      data.addAll({
        'brand': _petAccBrandController.text,
        'material': _petAccMaterialController.text,
        'category': _selectedPetAccCategory,
        'suitability': _selectedPetAccSuitability,
        'condition': _selectedPetAccCondition,
      });
    } else if (name.contains('electronic') || name.contains('gadget') || name.contains('laptop')) {
      data.addAll({
        'brand': _elecBrandController.text,
        'model': _elecModelController.text,
        'condition': _selectedElecCondition,
        'warranty': _selectedElecWarranty,
        'age': _elecAgeController.text,
        'color': _elecColorController.text,
        'battery_life': _elecBatteryController.text,
        'connectivity': _elecConnectivityController.text,
      });
    } else if (name.contains('fashion') || name.contains('cloth') || name.contains('wear')) {
      data.addAll({
        'size': _fashionSizeController.text,
        'color': _fashionColorController.text,
        'material': _fashionMaterialController.text,
        'brand': _fashionBrandController.text,
        'condition': _selectedFashionCondition,
      });
    } else if (name.contains('furnit') || name.contains('home') || name.contains('decor')) {
      data.addAll({
        'material': _furnMaterialController.text,
        'color': _furnColorController.text,
        'dimensions': _furnDimensionsController.text,
        'age': _furnAgeController.text,
        'condition': _selectedFurnCondition,
      });
    } else if (name.contains('job')) {
      data.addAll({
        'company_name': _jobCompanyController.text,
        'experience': _jobExpController.text,
        'work_mode': _selectedJobMode,
        'gender_preference': _selectedJobGender,
        'qualification': _jobQualController.text,
      });
    } else if (name.contains('educat') || name.contains('course') || name.contains('study') || name.contains('teach')) {
      data.addAll({
        'subject': _eduSubjectController.text,
        'level': _eduLevelController.text,
        'institute': _eduInstituteController.text,
        'duration': _eduDurationController.text,
        'experience': _eduExpController.text,
        'batch_size': _eduBatchController.text,
        'teaching_mode': _selectedEduMode,
      });
    } else if (name.contains('event') || name.contains('fest') || name.contains('party')) {
      data.addAll({
        'event_date': _eventDateController.text,
        'event_time': _eventTimeController.text,
        'venue': _eventVenueController.text,
        'organizer': _eventOrganizerController.text,
        'highlights': _eventHighlightsController.text,
      });
    }
    
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9), // Light cream background from image
      appBar: AppBar(
        title: (widget.ad != null ? "Edit in ${widget.category.name}" : "Post in ${widget.category.name}").text.bold.make(),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
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
          final stepNum = index + 1;
          final isActive = _currentStep == stepNum;
          final isCompleted = _currentStep > stepNum;
          
          return Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive 
                      ? const Color(0xFF004D40) // Dark teal
                      : isCompleted 
                          ? const Color(0xFF004D40).withOpacity(0.6)
                          : Colors.grey.shade400,
                ),
                child: Center(
                  child: stepNum.toString().text.white.bold.make(),
                ),
              ),
              const SizedBox(height: 8),
              steps[index].text.xs.color(isActive ? Colors.black : Colors.grey).make(),
            ],
          );
        }),
      ),
    );
  }

  // Beauty Details Fields
  final _serviceTypeController = TextEditingController();
  final _durationController = TextEditingController();
  String _selectedGenderPreference = 'Unisex';

  // Electronics Details Fields
  final _elecBrandController = TextEditingController();
  final _elecModelController = TextEditingController();
  final _elecAgeController = TextEditingController();
  final _elecColorController = TextEditingController();
  final _elecBatteryController = TextEditingController();
  final _elecConnectivityController = TextEditingController();
  String _selectedElecCondition = 'Good';
  String _selectedElecWarranty = 'Out of Warranty';

  // Fashion Details Fields
  final _fashionSizeController = TextEditingController();
  final _fashionColorController = TextEditingController();
  final _fashionMaterialController = TextEditingController();
  final _fashionBrandController = TextEditingController();
  String _selectedFashionCondition = 'New';

  // Furniture Details Fields
  final _furnMaterialController = TextEditingController();
  final _furnColorController = TextEditingController();
  final _furnDimensionsController = TextEditingController();
  final _furnAgeController = TextEditingController();
  String _selectedFurnCondition = 'Good';

  // Job Details Fields
  final _jobCompanyController = TextEditingController();
  final _jobExpController = TextEditingController();
  final _jobQualController = TextEditingController();
  String _selectedJobMode = 'On-site';
  String _selectedJobGender = 'Any';

  // Education Details Fields
  final _eduSubjectController = TextEditingController();
  final _eduLevelController = TextEditingController();
  final _eduInstituteController = TextEditingController();
  final _eduDurationController = TextEditingController();
  final _eduExpController = TextEditingController();
  final _eduBatchController = TextEditingController();
  String _selectedEduMode = 'Online';

  // Event Details Fields
  final _eventDateController = TextEditingController();
  final _eventTimeController = TextEditingController();
  final _eventVenueController = TextEditingController();
  final _eventOrganizerController = TextEditingController();
  final _eventHighlightsController = TextEditingController();

  // Mobile Details Fields
  final _mobBrandController = TextEditingController();
  final _mobModelController = TextEditingController();
  final _mobStorageController = TextEditingController();
  final _mobRamController = TextEditingController();
  final _mobColorController = TextEditingController();
  final _mobAgeController = TextEditingController();
  final _mobBatteryController = TextEditingController();
  final _mobOsController = TextEditingController();
  final _mobDamageController = TextEditingController();
  String _selectedMobCondition = 'Good';
  String _selectedMobWarranty = 'Out of Warranty';

  // Property Details Fields
  final _propRoomTypeController = TextEditingController();
  final _propDepositController = TextEditingController();
  final _propBedroomsController = TextEditingController();
  final _propBathroomsController = TextEditingController();
  final _propBalconyController = TextEditingController();
  final _propAreaController = TextEditingController();
  final _propKitchenController = TextEditingController();
  final _propAttachedBathController = TextEditingController();
  String _selectedPropType = 'Apartment';
  String _selectedFurnishStatus = 'Semi Furnished';
  String _selectedTenantPref = 'Any';
  final List<String> _selectedAmenities = [];

  final List<Map<String, dynamic>> _amenitiesList = [
    {'name': 'Parking', 'icon': Icons.local_parking},
    {'name': 'Lift', 'icon': Icons.elevator},
    {'name': 'Power Backup', 'icon': Icons.power},
    {'name': 'Gym', 'icon': Icons.fitness_center},
    {'name': 'Swimming Pool', 'icon': Icons.pool},
    {'name': 'Security', 'icon': Icons.security},
    {'name': 'Garden', 'icon': Icons.park},
    {'name': 'Club House', 'icon': Icons.meeting_room},
    {'name': 'WiFi', 'icon': Icons.wifi},
    {'name': 'AC', 'icon': Icons.ac_unit},
  ];

  // Service Details Fields
  final _serviceAvailabilityController = TextEditingController();
  final _serviceExperienceController = TextEditingController();

  // Pet & Animal Details Fields
  final _petBreedController = TextEditingController();
  final _petAgeController = TextEditingController();
  final _petMaterialController = TextEditingController(); // For accessories
  String _selectedPetGender = 'N/A';
  String _selectedPetCategory = 'Other'; // Food, Toy, Bedding, etc.
  String _selectedPetCondition = 'New';

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF004D40))), child: child!),
    );
    if (picked != null) {
      setState(() => _eventDateController.text = "${picked.day}-${picked.month}-${picked.year}");
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: const Color(0xFF004D40))), child: child!),
    );
    if (picked != null) {
      setState(() => _eventTimeController.text = picked.format(context));
    }
  }

  // Pet Accessory Details Fields
  final _petAccBrandController = TextEditingController();
  final _petAccMaterialController = TextEditingController();
  String _selectedPetAccCategory = 'Other'; 
  String _selectedPetAccSuitability = 'All';
  String _selectedPetAccCondition = 'New';

  Widget _buildDetailsStep() {
    // Check if category is automobile related
    final name = widget.category.name.toLowerCase();
    if (name.contains('auto') || name.contains('car') || name.contains('vehicle')) {
      return _buildVehicleDetails();
    } else if (name.contains('beauty') || name.contains('spa') || name.contains('salon')) {
      return _buildBeautyDetails();
    } else if (name.contains('property') || name.contains('estate') || name.contains('house') || name.contains('rent')) {
      return _buildPropertyDetails();
    } else if (name.contains('service')) {
      return _buildServiceDetails();
    } else if (name.contains('pet') || name.contains('animal')) {
      return _buildPetDetails();
    } else if (name.contains('mobile') || name.contains('phone') || name.contains('tablet')) {
      return _buildMobileDetails();
    } else if (name.contains('electronic') || name.contains('gadget') || name.contains('laptop')) {
      return _buildElectronicsDetails();
    } else if (name.contains('fashion') || name.contains('cloth') || name.contains('wear')) {
      return _buildFashionDetails();
    } else if (name.contains('furnit') || name.contains('home') || name.contains('decor')) {
      return _buildFurnitureDetails();
    } else if (name.contains('job')) {
      return _buildJobDetails();
    } else if (name.contains('educat') || name.contains('course') || name.contains('study') || name.contains('teach')) {
      return _buildEducationDetails();
    } else if (name.contains('event') || name.contains('fest') || name.contains('party')) {
      return _buildEventDetails();
    }
    return _buildPlaceholderStep("Details Section");
  }

  Widget _buildPetDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFFFF5722), shape: BoxShape.circle),
              child: const Icon(Icons.list, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            "Pet Accessory Details".text.xl2.bold.make(),
          ],
        ),
        const SizedBox(height: 24),
        
        Row(
          children: [
            Expanded(child: _buildField("Brand (Optional)", "e.g., Pedigree, Whiskas, Drools", _petAccBrandController)),
            const SizedBox(width: 16),
            Expanded(child: _buildField("Material (Optional)", "e.g., Nylon, Leather, Wood", _petAccMaterialController)),
          ],
        ),
        const SizedBox(height: 20),

        _buildLabel("Accessory Category*"),
        _buildSelectionRow(['Food', 'Toy', 'Bedding', 'Grooming', 'Other'], _selectedPetAccCategory, (v) => setState(() => _selectedPetAccCategory = v)),
        const SizedBox(height: 20),

        _buildLabel("Suitable For*"),
        _buildSelectionRow(['Dog', 'Cat', 'Bird', 'Fish', 'All'], _selectedPetAccSuitability, (v) => setState(() => _selectedPetAccSuitability = v)),
        const SizedBox(height: 20),

        _buildLabel("Condition*"),
        _buildSelectionRow(['New', 'Like New', 'Good', 'Fair'], _selectedPetAccCondition, (v) => setState(() => _selectedPetAccCondition = v)),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildServiceDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFFFF5722), shape: BoxShape.circle),
              child: const Icon(Icons.list, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            "Service Details".text.xl2.bold.make(),
          ],
        ),
        const SizedBox(height: 24),
        
        _buildField("Availability*", "e.g., Mon-Fri 9AM-6PM, Weekends", _serviceAvailabilityController),
        const SizedBox(height: 20),

        _buildField("Experience (Optional)", "e.g., 5 years, Certified Professional", _serviceExperienceController),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildEventDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFFFF5722), shape: BoxShape.circle),
              child: const Icon(Icons.list, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            "Event Details".text.xl2.bold.make(),
          ],
        ),
        const SizedBox(height: 24),
        
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Event Date*"),
                  TextFormField(
                    controller: _eventDateController,
                    readOnly: true,
                    onTap: _selectDate,
                    decoration: InputDecoration(
                      hintText: "dd-mm-yyyy",
                      suffixIcon: const Icon(Icons.calendar_today, size: 20),
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Event Time*"),
                  TextFormField(
                    controller: _eventTimeController,
                    readOnly: true,
                    onTap: _selectTime,
                    decoration: InputDecoration(
                      hintText: "-:- -",
                      suffixIcon: const Icon(Icons.access_time, size: 20),
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        _buildField("Venue Name / Address*", "e.g., City Convention Center, Bandra", _eventVenueController),
        const SizedBox(height: 20),

        _buildField("Organizer (Optional)", "e.g., Global Events Ltd.", _eventOrganizerController),
        const SizedBox(height: 20),

        _buildLabel("Event Highlights (Optional)"),
        TextFormField(
          controller: _eventHighlightsController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: "Enter highlights (one per line) e.g., Live Music, Free Snacks",
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
          ),
        ),
        const SizedBox(height: 8),
        "Enter each highlight on a new line.".text.xs.gray400.make(),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildEducationDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFFFF5722), shape: BoxShape.circle),
              child: const Icon(Icons.list, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            "Education Details".text.xl2.bold.make(),
          ],
        ),
        const SizedBox(height: 24),
        
        _buildField("Subject / Course Name*", "e.g., Mathematics, ReactJS, IELTS", _eduSubjectController),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(child: _buildField("Level / Class (Optional)", "e.g., Beginner, Class 12, Advanced", _eduLevelController)),
            const SizedBox(width: 16),
            Expanded(child: _buildField("Institute Name (Optional)", "e.g., ABC Learning Center", _eduInstituteController)),
          ],
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(child: _buildField("Duration (Optional)", "e.g., 3 Months", _eduDurationController)),
            const SizedBox(width: 8),
            Expanded(child: _buildField("Experience (Optional)", "e.g., 5 Years", _eduExpController)),
            const SizedBox(width: 8),
            Expanded(child: _buildField("Batch Size (Optional)", "e.g., 10 Students", _eduBatchController)),
          ],
        ),
        const SizedBox(height: 20),

        _buildLabel("Mode of Teaching*"),
        _buildSelectionRow(['Online', 'Offline', 'Hybrid'], _selectedEduMode, (v) => setState(() => _selectedEduMode = v)),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildJobDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFFFF5722), shape: BoxShape.circle),
              child: const Icon(Icons.list, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            "Job Details".text.xl2.bold.make(),
          ],
        ),
        const SizedBox(height: 24),
        
        _buildField("Company Name*", "e.g., Tech Solutions Pvt. Ltd.", _jobCompanyController),
        const SizedBox(height: 20),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildField("Experience Level (Optional)", "e.g., Fresher, 1-3 years", _jobExpController)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Work Mode*"),
                  _buildSelectionRow(['On-site', 'Remote', 'Hybrid'], _selectedJobMode, (v) => setState(() => _selectedJobMode = v)),
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
                  _buildLabel("Gender Preference (Optional)"),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedJobGender,
                        isExpanded: true,
                        items: ['Any', 'Male', 'Female'].map((String value) {
                          return DropdownMenuItem<String>(value: value, child: value.text.make());
                        }).toList(),
                        onChanged: (v) => setState(() => _selectedJobGender = v!),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(child: _buildField("Qualification (Optional)", "e.g., Any Graduate, B.Tech, MBA", _jobQualController)),
          ],
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildFurnitureDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFFFF5722), shape: BoxShape.circle),
              child: const Icon(Icons.list, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            "Item Details".text.xl2.bold.make(),
          ],
        ),
        const SizedBox(height: 24),
        
        _buildField("Material*", "e.g., Teak Wood, Sheesham, Steel", _furnMaterialController),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(child: _buildField("Color (Optional)", "e.g., Brown, White, Black", _furnColorController)),
            const SizedBox(width: 16),
            Expanded(child: _buildField("Dimensions (Optional)", "e.g., 6x4 ft", _furnDimensionsController)),
          ],
        ),
        const SizedBox(height: 20),

        _buildField("Age (Optional)", "e.g., 6 months, 2 years", _furnAgeController),
        const SizedBox(height: 20),

        _buildLabel("Condition*"),
        _buildSelectionRow(['New', 'Like New', 'Good', 'Fair'], _selectedFurnCondition, (v) => setState(() => _selectedFurnCondition = v)),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildFashionDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFFFF5722), shape: BoxShape.circle),
              child: const Icon(Icons.list, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            "Item Details".text.xl2.bold.make(),
          ],
        ),
        const SizedBox(height: 24),
        
        Row(
          children: [
            Expanded(child: _buildField("Size (Optional)", "e.g., M, L, XL, UK 8", _fashionSizeController)),
            const SizedBox(width: 16),
            Expanded(child: _buildField("Color (Optional)", "e.g., Navy Blue, Red", _fashionColorController)),
          ],
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(child: _buildField("Material (Optional)", "e.g., Cotton, Silk, Leather", _fashionMaterialController)),
            const SizedBox(width: 16),
            Expanded(child: _buildField("Brand (Optional)", "e.g., Zara, H&M", _fashionBrandController)),
          ],
        ),
        const SizedBox(height: 20),

        _buildLabel("Condition*"),
        _buildSelectionRow(['New', 'Like New', 'Good', 'Fair'], _selectedFashionCondition, (v) => setState(() => _selectedFashionCondition = v)),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildElectronicsDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFFFF5722), shape: BoxShape.circle),
              child: const Icon(Icons.list, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            "Product Details".text.xl2.bold.make(),
          ],
        ),
        const SizedBox(height: 24),
        
        Row(
          children: [
            Expanded(child: _buildField("Brand*", "e.g., Sony, Nikon, Dell", _elecBrandController)),
            const SizedBox(width: 16),
            Expanded(child: _buildField("Model*", "e.g., WH-1000XM5, D5600", _elecModelController)),
          ],
        ),
        const SizedBox(height: 20),

        _buildLabel("Condition*"),
        _buildSelectionRow(['New', 'Like New', 'Good', 'Fair'], _selectedElecCondition, (v) => setState(() => _selectedElecCondition = v)),
        const SizedBox(height: 20),

        _buildLabel("Warranty Status*"),
        _buildSelectionRow(['In Warranty', 'Out of Warranty'], _selectedElecWarranty, (v) => setState(() => _selectedElecWarranty = v)),
        const SizedBox(height: 20),

        _buildField("Age (Optional)", "e.g., 6 months, 2 years", _elecAgeController),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(child: _buildField("Color (Optional)", "e.g., Black, Silver", _elecColorController)),
            const SizedBox(width: 16),
            Expanded(child: _buildField("Battery Life (Optional)", "e.g., 24 Hours", _elecBatteryController)),
          ],
        ),
        const SizedBox(height: 20),

        _buildField("Connectivity (Optional)", "e.g., Bluetooth 5.0, Wi-Fi 6, USB-C", _elecConnectivityController),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildPropertyDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFFFF5722), shape: BoxShape.circle),
              child: const Icon(Icons.list, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            "Property Details".text.xl2.bold.make(),
          ],
        ),
        const SizedBox(height: 24),
        
        _buildLabel("Property Type*"),
        _buildSelectionRow(['Apartment', 'House', 'Villa', 'Plot'], _selectedPropType, (v) => setState(() => _selectedPropType = v)),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(child: _buildField("Room Type", "e.g., Master Bedroom", _propRoomTypeController)),
            const SizedBox(width: 16),
            Expanded(child: _buildField("Security Deposit", "e.g., 50000", _propDepositController)),
          ],
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(child: _buildField("Bedrooms*", "e.g., 3", _propBedroomsController)),
            const SizedBox(width: 8),
            Expanded(child: _buildField("Bathrooms (Optional)", "e.g., 2", _propBathroomsController)),
            const SizedBox(width: 8),
            Expanded(child: _buildField("Balcony (Optional)", "e.g., 1", _propBalconyController)),
          ],
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(child: _buildField("Area (sq ft)*", "e.g., 1200", _propAreaController)),
            const SizedBox(width: 8),
            Expanded(child: _buildField("Kitchen (Optional)", "e.g., Modular", _propKitchenController)),
            const SizedBox(width: 8),
            Expanded(child: _buildField("Attached Bath", "e.g., Yes", _propAttachedBathController)),
          ],
        ),
        const SizedBox(height: 20),

        _buildLabel("Furnished Status (Optional)"),
        _buildSelectionRow(['Fully Furnished', 'Semi Furnished', 'Unfurnished'], _selectedFurnishStatus, (v) => setState(() => _selectedFurnishStatus = v)),
        const SizedBox(height: 20),

        _buildLabel("Tenant Preference"),
        _buildSelectionRow(['Family', 'Bachelor', 'Company', 'Any'], _selectedTenantPref, (v) => setState(() => _selectedTenantPref = v)),
        const SizedBox(height: 20),

        _buildLabel("Amenities"),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _amenitiesList.map((amenity) {
            final isSelected = _selectedAmenities.contains(amenity['name']);
            return GestureDetector(
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
                width: (MediaQuery.of(context).size.width - 64) / 2,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isSelected ? const Color(0xFF004D40) : Colors.grey.shade200, width: isSelected ? 1.5 : 1),
                ),
                child: Row(
                  children: [
                    Icon(amenity['icon'], size: 18, color: isSelected ? const Color(0xFF004D40) : Colors.black87),
                    const SizedBox(width: 8),
                    amenity['name'].toString().text.xs.color(isSelected ? const Color(0xFF004D40) : Colors.black87).make(),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildMobileDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFFFF5722), shape: BoxShape.circle),
              child: const Icon(Icons.list, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            "Product Details".text.xl2.bold.make(),
          ],
        ),
        const SizedBox(height: 24),
        
        Row(
          children: [
            Expanded(child: _buildField("Brand*", "e.g., Apple, Samsung, OnePlus", _mobBrandController)),
            const SizedBox(width: 16),
            Expanded(child: _buildField("Model*", "e.g., iPhone 14 Pro, Galaxy S23", _mobModelController)),
          ],
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(child: _buildField("Storage (Optional)", "e.g., 128GB, 256GB", _mobStorageController)),
            const SizedBox(width: 16),
            Expanded(child: _buildField("RAM (Optional)", "e.g., 6GB, 8GB", _mobRamController)),
          ],
        ),
        const SizedBox(height: 20),

        _buildLabel("Condition*"),
        _buildSelectionRow(['New', 'Like New', 'Good', 'Fair'], _selectedMobCondition, (v) => setState(() => _selectedMobCondition = v)),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(child: _buildField("Colour", "e.g., Space Black, Deep Purple", _mobColorController)),
            const SizedBox(width: 16),
            Expanded(child: _buildField("Age", "e.g., 1 Year, 6 Months", _mobAgeController)),
          ],
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(child: _buildField("Battery Health", "e.g., 90%, 100%", _mobBatteryController)),
            const SizedBox(width: 16),
            Expanded(child: _buildField("Version/OS", "e.g., iOS 17, Android 14", _mobOsController)),
          ],
        ),
        const SizedBox(height: 20),

        _buildField("Physical Damage", "e.g., None, Minor scratches on screen", _mobDamageController),
        const SizedBox(height: 20),

        _buildLabel("Warranty Status*"),
        _buildSelectionRow(['In Warranty', 'Out of Warranty'], _selectedMobWarranty, (v) => setState(() => _selectedMobWarranty = v)),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildBeautyDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFFFF5722), shape: BoxShape.circle),
              child: const Icon(Icons.list, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            "Service Details".text.xl2.bold.make(),
          ],
        ),
        const SizedBox(height: 24),
        
        _buildField("Service Type*", "e.g., Facial, Haircut, Manicure", _serviceTypeController),
        const SizedBox(height: 20),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildField("Duration (Optional)", "e.g., 45 mins, 1 hour", _durationController)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Gender Preference*"),
                  _buildSelectionRow(['Female', 'Male', 'Unisex'], _selectedGenderPreference, (v) => setState(() => _selectedGenderPreference = v)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  // Vehicle Details Fields
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _kmController = TextEditingController();
  final _ownersController = TextEditingController();
  final _mileageController = TextEditingController();
  final _insuranceController = TextEditingController();
  final _bodyTypeController = TextEditingController();
  final _exteriorColorController = TextEditingController();
  final _interiorColorController = TextEditingController();
  final _hpController = TextEditingController();
  final _engineController = TextEditingController();
  final _seaterController = TextEditingController();
  final _doorsController = TextEditingController();

  String _selectedCondition = 'Used';
  String _selectedWarranty = 'N/A';
  String _selectedFuelType = 'Petrol';
  String _selectedTransmission = 'Manual';

  Widget _buildVehicleDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFFFF5722), shape: BoxShape.circle),
              child: const Icon(Icons.list_alt, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            "Vehicle Details".text.xl2.bold.make(),
          ],
        ),
        const SizedBox(height: 24),
        
        Row(
          children: [
            Expanded(child: _buildField("Brand*", "e.g., Honda, Maruti, Hyundai", _brandController)),
            const SizedBox(width: 16),
            Expanded(child: _buildField("Model*", "e.g., City, Swift, Creta", _modelController)),
          ],
        ),
        const SizedBox(height: 20),
        
        Row(
          children: [
            Expanded(child: _buildField("Year*", "e.g., 2020", _yearController)),
            const SizedBox(width: 16),
            Expanded(child: _buildField("KM Driven*", "e.g., 25000", _kmController)),
          ],
        ),
        const SizedBox(height: 20),

        _buildField("No. of Owners (Optional)", "e.g., 1st Owner, 2nd Owner", _ownersController),
        const SizedBox(height: 20),

        _buildLabel("Condition*"),
        _buildSelectionRow(['New', 'Used', 'Refurbished'], _selectedCondition, (v) => setState(() => _selectedCondition = v)),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(child: _buildField("Mileage (Optional)", "e.g., 18 kmpl", _mileageController)),
            const SizedBox(width: 16),
            Expanded(child: _buildField("Insurance (Optional)", "e.g., Valid until Dec 2025", _insuranceController)),
          ],
        ),
        const SizedBox(height: 20),

        _buildLabel("Warranty*"),
        _buildSelectionRow(['Under Warranty', 'Expired', 'N/A'], _selectedWarranty, (v) => setState(() => _selectedWarranty = v)),
        const SizedBox(height: 20),

        _buildLabel("Fuel Type*"),
        _buildSelectionRow(['Petrol', 'Diesel', 'Electric', 'CNG', 'Hybrid'], _selectedFuelType, (v) => setState(() => _selectedFuelType = v)),
        const SizedBox(height: 20),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Transmission*"),
                  _buildSelectionRow(['Manual', 'Automatic'], _selectedTransmission, (v) => setState(() => _selectedTransmission = v)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(child: _buildField("Body Type (Optional)", "e.g., SUV, Sedan, Hatchback", _bodyTypeController)),
          ],
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(child: _buildField("Exterior Color", "e.g., White, Black, Red", _exteriorColorController)),
            const SizedBox(width: 16),
            Expanded(child: _buildField("Interior Color", "e.g., Beige, Black, Tan", _interiorColorController)),
          ],
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(child: _buildField("Horsepower", "e.g., 120 HP", _hpController)),
            const SizedBox(width: 8),
            Expanded(child: _buildField("Engine Capacity", "e.g., 1500 cc", _engineController)),
            const SizedBox(width: 8),
            Expanded(child: _buildField("Seater Capacity", "e.g., 5, 7", _seaterController)),
          ],
        ),
        const SizedBox(height: 20),

        _buildField("Doors", "e.g., 4, 2", _doorsController),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionRow(List<String> options, String current, Function(String) onSelect) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((opt) {
          final isSelected = current == opt;
          return GestureDetector(
            onTap: () => onSelect(opt),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isSelected ? const Color(0xFF004D40) : Colors.grey.shade200, width: isSelected ? 2 : 1),
                boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF004D40).withOpacity(0.1), blurRadius: 4)] : null,
              ),
              child: opt.text.color(isSelected ? const Color(0xFF004D40) : Colors.black87).bold.make(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 1: return _buildBasicStep();
      case 2: return _buildDetailsStep();
      case 3: return _buildMediaStep();
      case 4: return _buildLocationStep();
      case 5: return _buildReviewStep();
      default: return const SizedBox.shrink();
    }
  }

  // Media Logic
  final List<File> _selectedImages = [];
  final List<String> _existingImages = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((image) => File(image.path)));
      });
    }
  }

  Widget _buildMediaStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFFFF5722), shape: BoxShape.circle),
              child: const Icon(Icons.image, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            "${widget.category.name} Images".text.xl2.bold.make(),
          ],
        ),
        const SizedBox(height: 24),

        // Tips Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2FE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBAE6FD)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: Color(0xFF0369A1), size: 20),
                  const SizedBox(width: 8),
                  "Tips for great photos".text.bold.color(const Color(0xFF0369A1)).make(),
                ],
              ),
              const SizedBox(height: 12),
              _buildTip("Capture all 4 angles (front, back, left, right)"),
              _buildTip("Include interior, dashboard, and engine photos"),
              _buildTip("Show any damages or scratches clearly"),
              _buildTip("First image will be the primary display"),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Upload Area
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 1.5, style: BorderStyle.solid), // Dashed not natively easy, solid for now
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Column(
              children: [
                const Icon(Icons.add_photo_alternate_outlined, size: 48, color: Color(0xFFFF5722)),
                const SizedBox(height: 12),
                "Upload images".text.bold.lg.make(),
                const SizedBox(height: 4),
                "Max 5 images, up to 10MB each".text.xs.gray500.make(),
              ],
            ),
          ),
        ),

        if (_existingImages.isNotEmpty || _selectedImages.isNotEmpty) ...[
          const SizedBox(height: 24),
          "Listing Images".text.bold.make(),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
            itemCount: _existingImages.length + _selectedImages.length,
            itemBuilder: (context, index) {
              final isExisting = index < _existingImages.length;
              
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: isExisting
                      ? CachedNetworkImage(
                          imageUrl: _existingImages[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          placeholder: (context, url) => Container(color: Colors.grey.shade100, child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
                          errorWidget: (context, url, error) => Container(color: Colors.grey.shade100, child: const Icon(Icons.error_outline)),
                        )
                      : Image.file(_selectedImages[index - _existingImages.length], fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isExisting) {
                            _existingImages.removeAt(index);
                          } else {
                            _selectedImages.removeAt(index - _existingImages.length);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: const Icon(Icons.close, color: Colors.white, size: 12),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          "• ".text.color(const Color(0xFF0369A1)).make(),
          Expanded(child: text.text.sm.color(const Color(0xFF0369A1)).make()),
        ],
      ),
    );
  }

  Widget _buildLocationStep() {
    final agencyProfile = context.watch<AgencyProvider>().profile;
    final address = agencyProfile?.location ?? "Address not set in profile";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFFFF5722), shape: BoxShape.circle),
              child: const Icon(Icons.location_on, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            "Location Details".text.xl2.bold.make(),
          ],
        ),
        const SizedBox(height: 24),
        
        "Your registered agency address will be used for this ad.".text.gray600.make(),
        const SizedBox(height: 20),
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.business, color: Color(0xFF004D40), size: 20),
                  const SizedBox(width: 8),
                  "Agency Address".text.bold.make(),
                ],
              ),
              const SizedBox(height: 12),
              address.text.lg.color(Colors.black87).make(),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {
                  // Navigate to profile settings to update address if needed
                },
                icon: const Icon(Icons.edit, size: 16),
                label: "Change Address in Profile".text.make(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF004D40),
                  side: const BorderSide(color: Color(0xFF004D40)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildReviewStep() {
    final Map<String, dynamic> categoryData = _getCategorySpecificData();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Center(
          child: Column(
            children: [
              const Icon(Icons.check_circle_outline, size: 80, color: Color(0xFF004D40)),
              const SizedBox(height: 16),
              "Ready to Publish!".text.xl3.bold.make(),
              const SizedBox(height: 8),
              "Review your listing details below".text.gray500.make(),
            ],
          ),
        ),
        const SizedBox(height: 40),

        // Summary Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReviewRow("Title", _titleController.text),
              _buildReviewRow("Price", "₹ ${_priceController.text}"),
              _buildReviewRow("Category", widget.category.name),
              _buildReviewRow("Contact", _contactController.text),
              const Divider(height: 32),
              
              // Dynamic Category Details
              ...categoryData.entries.map((e) {
                if (e.value == null || e.value.toString().isEmpty) return const SizedBox.shrink();
                // Format key: KM_Driven -> KM Driven
                final key = e.key.split('_').map((s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s).join(' ');
                return _buildReviewRow(key, e.value.toString());
              }).toList(),
              
              const Divider(height: 32),
              _buildReviewRow("Images", "${_existingImages.length + _selectedImages.length} images"),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          label.text.gray500.sm.make().box.width(100).make(),
          const SizedBox(width: 12),
          Expanded(child: value.text.bold.make()),
        ],
      ),
    );
  }

  Widget _buildBasicStep() {
    return Form(
      key: _formKeyBasic,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("Listing Title*"),
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: "e.g. Title of your ad",
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            ),
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 24),
          
          _buildLabel("Price (₹)*"),
          TextFormField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "e.g. 5000",
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            ),
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 24),

          _buildLabel("Contact Number*"),
          TextFormField(
            controller: _contactController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            ),
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 24),

          _buildLabel("Description*"),
          TextFormField(
            controller: _descriptionController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: "Provide details about your listing...",
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            ),
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderStep(String title) {
    return Column(
      children: [
        const SizedBox(height: 100),
        Icon(Icons.construction, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 24),
        title.text.xl.bold.gray600.make(),
        const SizedBox(height: 12),
        "Implementing this step based on the wizard flow...".text.gray400.center.make(),
      ],
    ).animate().fadeIn();
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: label.text.bold.lg.color(const Color(0xFF1E293B)).make(),
    );
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
            if (_currentStep > 1)
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => setState(() => _currentStep--),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF004D40), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: "Previous".text.bold.lg.color(const Color(0xFF004D40)).make(),
                  ),
                ),
              ),
            if (_currentStep > 1) const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004D40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: (_currentStep == _totalSteps ? "Submit Ad" : "Next Step").text.bold.lg.white.make(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
