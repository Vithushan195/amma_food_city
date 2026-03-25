/// User profile model — maps to Firestore users/{uid} document.
class AppUser {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String? defaultAddressId;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.defaultAddressId,
    required this.createdAt,
  });

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  static AppUser get mockUser => AppUser(
        uid: 'user_001',
        name: 'Vithushan',
        email: 'vithushan@ammafoodcity.co.uk',
        phone: '+44 7700 900123',
        defaultAddressId: 'addr1',
        createdAt: DateTime(2024, 6, 15),
      );
}
