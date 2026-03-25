/// Delivery driver information synced from the delivery document.
class DriverInfo {
  final String id;
  final String name;
  final String phone;
  final String? photo;
  final String? vehicle;
  final double? rating;

  const DriverInfo({
    required this.id,
    required this.name,
    required this.phone,
    this.photo,
    this.vehicle,
    this.rating,
  });

  factory DriverInfo.fromMap(Map<String, dynamic> map) {
    return DriverInfo(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Driver',
      phone: map['phone'] as String? ?? '',
      photo: map['photo'] as String?,
      vehicle: map['vehicle'] as String?,
      rating: (map['rating'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        if (photo != null) 'photo': photo,
        if (vehicle != null) 'vehicle': vehicle,
        if (rating != null) 'rating': rating,
      };

  String get initials => name.isNotEmpty ? name[0].toUpperCase() : 'D';
}
