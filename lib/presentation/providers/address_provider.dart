import 'package:flutter/material.dart';
import '../../data/models/address_model.dart';
import '../../data/services/address_service.dart';

class AddressProvider with ChangeNotifier {
  final AddressService _service = AddressService();

  List<AddressModel> _addresses = [];
  bool _isLoading = false;
  String? _error;

  List<AddressModel> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AddressModel? get defaultAddress {
    try {
      return _addresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }

  Future<void> fetchAddresses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _addresses = await _service.getAddresses();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addAddress(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.addAddress(data);
      await fetchAddresses();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAddress(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.updateAddress(id, data);
      await fetchAddresses();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAddress(int id) async {
    try {
      await _service.deleteAddress(id);
      _addresses.removeWhere((a) => a.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> setDefault(int id) async {
    try {
      await _service.updateAddress(id, {'is_default': 1});
      await fetchAddresses();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Location helpers
  Future<List<StateModel>> getStates() => _service.getStates();
  Future<List<CityModel>> getCities(int stateId) => _service.getCities(stateId);
}
