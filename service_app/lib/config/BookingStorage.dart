import 'package:service_app/model/BookingModel.dart';

// ✅ SERVICE: BookingStorage - Global singleton for managing bookings
class BookingStorage {
  static final BookingStorage _instance = BookingStorage._internal();

  final List<BookingRecord> _bookings = [];

  factory BookingStorage() {
    return _instance;
  }

  BookingStorage._internal();

  // Add a booking
  // ✅ Added: Store booking to in-memory list
  void addBooking(BookingRecord booking) {
    _bookings.add(booking);
    print('✅ Booking added: ${booking.id}');
    print('📊 Total bookings: ${_bookings.length}');
  }

  // Get all bookings
  // ✅ Added: Retrieve all bookings
  List<BookingRecord> getAllBookings() {
    return List.unmodifiable(_bookings);
  }

  // Get bookings by user email
  // ✅ Added: Filter bookings by user
  List<BookingRecord> getBookingsByUser(String userEmail) {
    return _bookings
        .where((booking) => booking.userEmail == userEmail)
        .toList();
  }

  // Get bookings by payment status
  // ✅ Added: Filter bookings by payment status
  List<BookingRecord> getBookingsByStatus(String status) {
    return _bookings
        .where((booking) => booking.paymentStatus == status)
        .toList();
  }

  // Clear all bookings (for testing/reset)
  // ✅ Added: Clear storage
  void clearAll() {
    _bookings.clear();
    print('🗑️ All bookings cleared');
  }

  // Get booking count
  // ✅ Added: Get total count
  int getBookingCount() {
    return _bookings.length;
  }
}
