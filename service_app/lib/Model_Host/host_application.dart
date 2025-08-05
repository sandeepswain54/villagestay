class HostApplication {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String serviceType;
  final String city;
  final String country;
  final String bio;
  final String profileImageUrl;
  final String govtId;
  final String govtIdImageUrl;
  final DateTime appliedOn;

  HostApplication({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.serviceType,
    required this.city,
    required this.country,
    required this.bio,
    required this.profileImageUrl,
    required this.govtId,
    required this.govtIdImageUrl,
    required this.appliedOn,
  });
}