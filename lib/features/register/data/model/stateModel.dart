// models/address_model.dart
class StateModel {
  final String id;
  final String name;
  final List<DistrictModel> districts;

  StateModel({
    required this.id,
    required this.name,
    required this.districts,
  });
}

class DistrictModel {
  final String id;
  final String name;
  final List<CityModel> cities;

  DistrictModel({
    required this.id,
    required this.name,
    required this.cities,
  });
}

class CityModel {
  final String id;
  final String name;

  CityModel({
    required this.id,
    required this.name,
  });
}