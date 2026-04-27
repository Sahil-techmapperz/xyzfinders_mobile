class AddressModel {
  final int id;
  final int userId;
  final String name;
  final int? stateId;
  final int? cityId;
  final String? areaName;
  final String? pincode;
  final String? fullAddress;
  final bool isDefault;
  final String? stateName;
  final String? cityName;

  AddressModel({
    required this.id,
    required this.userId,
    required this.name,
    this.stateId,
    this.cityId,
    this.areaName,
    this.pincode,
    this.fullAddress,
    required this.isDefault,
    this.stateName,
    this.cityName,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      name: json['name'] as String? ?? 'Home',
      stateId: json['state_id'] as int?,
      cityId: json['city_id'] as int?,
      areaName: json['area_name'] as String?,
      pincode: json['pincode'] as String?,
      fullAddress: json['full_address'] as String?,
      isDefault: json['is_default'] == 1 || json['is_default'] == true,
      stateName: json['state_name'] as String?,
      cityName: json['city_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'state_id': stateId,
      'city_id': cityId,
      'area_name': areaName,
      'pincode': pincode,
      'full_address': fullAddress,
      'is_default': isDefault ? 1 : 0,
    };
  }
}

class StateModel {
  final int id;
  final String name;
  final String? code;

  StateModel({required this.id, required this.name, this.code});

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String?,
    );
  }
}

class CityModel {
  final int id;
  final int stateId;
  final String name;

  CityModel({required this.id, required this.stateId, required this.name});

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'] as int,
      stateId: json['state_id'] as int,
      name: json['name'] as String,
    );
  }
}
