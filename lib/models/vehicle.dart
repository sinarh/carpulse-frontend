class Vehicle {
  final int id;
  final String make;
  final String model;
  final int year;
  final int mileage;
  final String? nickname;
  final String? fuelType;
  final String? transmission;
  final String? purchaseDate;
  final String? notes;
  final String? createdAt;

  Vehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.mileage,
    this.nickname,
    this.fuelType,
    this.transmission,
    this.purchaseDate,
    this.notes,
    this.createdAt,
  });

  String get displayTitle {
    final nick = (nickname != null && nickname!.trim().isNotEmpty)
        ? '$nickname • '
        : '';
    return '$nick$year $make $model';
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as int,
      make: json['make'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      mileage: json['mileage'] as int,
      nickname: json['nickname'] as String?,
      fuelType: json['fuel_type'] as String?,
      transmission: json['transmission'] as String?,
      purchaseDate: json['purchase_date'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'year': year,
      'mileage': mileage,
      'nickname': nickname,
      'fuel_type': fuelType,
      'transmission': transmission,
      'purchase_date': purchaseDate,
      'notes': notes,
      'created_at': createdAt,
    };
  }
}