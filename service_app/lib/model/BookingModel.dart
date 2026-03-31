// ✅ MODEL: BookingRecord - Holds all booking information
class BookingRecord {
  final String id; // Unique booking ID
  final String userName;
  final String userEmail;
  final String userPhone;
  final String serviceBooked; // Property/Hotel name
  final String selectedSlot; // Duration (e.g., "3 Hrs", "6 Hrs")
  final int slotPrice;
  final DateTime bookingDateTime;
  final String paymentStatus; // 'pending', 'completed', 'failed'
  final double amountPaid;
  final String transactionId;
  final Map<String, dynamic> formData; // Complete form data

  BookingRecord({
    required this.id,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.serviceBooked,
    required this.selectedSlot,
    required this.slotPrice,
    required this.bookingDateTime,
    required this.paymentStatus,
    required this.amountPaid,
    required this.transactionId,
    required this.formData,
  });

  // Convert to JSON for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'serviceBooked': serviceBooked,
      'selectedSlot': selectedSlot,
      'slotPrice': slotPrice,
      'bookingDateTime': bookingDateTime.toIso8601String(),
      'paymentStatus': paymentStatus,
      'amountPaid': amountPaid,
      'transactionId': transactionId,
      'formData': formData,
    };
  }

  // Create from JSON
  factory BookingRecord.fromMap(Map<String, dynamic> map) {
    return BookingRecord(
      id: map['id'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      userPhone: map['userPhone'] ?? '',
      serviceBooked: map['serviceBooked'] ?? '',
      selectedSlot: map['selectedSlot'] ?? '',
      slotPrice: map['slotPrice'] ?? 0,
      bookingDateTime: DateTime.parse(map['bookingDateTime'] ?? DateTime.now().toIso8601String()),
      paymentStatus: map['paymentStatus'] ?? 'pending',
      amountPaid: (map['amountPaid'] ?? 0).toDouble(),
      transactionId: map['transactionId'] ?? '',
      formData: map['formData'] ?? {},
    );
  }

  @override
  String toString() {
    return 'Booking(id: $id, user: $userName, service: $serviceBooked, slot: $selectedSlot, status: $paymentStatus)';
  }
}
