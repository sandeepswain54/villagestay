class Hotel {
  final String id;
  final String name;
  final String city;
  final String location;
  final double rating;
  final int reviews;
  final List<String> images;
  final bool coupleFriendly;
  final bool acceptsLocalId;
  final bool payAtHotel;
  final Map<String, int> pricing;

  Hotel({
    required this.id,
    required this.name,
    required this.city,
    required this.location,
    required this.rating,
    required this.reviews,
    required this.images,
    required this.coupleFriendly,
    required this.acceptsLocalId,
    required this.payAtHotel,
    required this.pricing,
  });

  

}