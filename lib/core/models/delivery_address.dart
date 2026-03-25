/// Saved delivery address for checkout.
class DeliveryAddress {
  final String id;
  final String label; // "Home", "Work", etc.
  final String line1;
  final String? line2;
  final String city;
  final String postcode;
  final bool isDefault;

  const DeliveryAddress({
    required this.id,
    required this.label,
    required this.line1,
    this.line2,
    required this.city,
    required this.postcode,
    this.isDefault = false,
  });

  String get fullAddress => [
    line1,
    if (line2 != null && line2!.isNotEmpty) line2,
    city,
    postcode,
  ].join(', ');

  static List<DeliveryAddress> get mockAddresses => [
    const DeliveryAddress(
      id: 'addr1',
      label: 'Home',
      line1: '3 Clarence Street',
      city: 'Paisley',
      postcode: 'PA1 1AD',
      isDefault: true,
    ),
    const DeliveryAddress(
      id: 'addr2',
      label: 'Work',
      line1: '45 George Square',
      city: 'Glasgow',
      postcode: 'G2 1AL',
    ),
  ];
}
