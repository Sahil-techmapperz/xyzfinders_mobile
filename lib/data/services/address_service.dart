import 'package:dio/dio.dart';
import '../../core/config/api_service.dart';
import '../models/address_model.dart';

class AddressService {
  final ApiService _apiService = ApiService();

  Future<List<AddressModel>> getAddresses() async {
    final response = await _apiService.get('/user/addresses');
    final List<dynamic> data = response.data['data'];
    return data.map((json) => AddressModel.fromJson(json)).toList();
  }

  Future<void> addAddress(Map<String, dynamic> addressData) async {
    await _apiService.post('/user/addresses', data: addressData);
  }

  Future<void> updateAddress(int id, Map<String, dynamic> addressData) async {
    await _apiService.put('/user/addresses/$id', data: addressData);
  }

  Future<void> deleteAddress(int id) async {
    await _apiService.delete('/user/addresses/$id');
  }

  Future<List<StateModel>> getStates() async {
    final response = await _apiService.get('/locations/states');
    final List<dynamic> data = response.data['data'];
    return data.map((json) => StateModel.fromJson(json)).toList();
  }

  Future<List<CityModel>> getCities(int stateId) async {
    final response = await _apiService.get('/locations/cities', queryParameters: {'state_id': stateId});
    final List<dynamic> data = response.data['data'];
    return data.map((json) => CityModel.fromJson(json)).toList();
  }
}
