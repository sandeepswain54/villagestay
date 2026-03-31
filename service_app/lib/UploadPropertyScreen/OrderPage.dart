import 'package:flutter/material.dart';
import 'package:service_app/model/BookingModel.dart';
import 'package:service_app/config/BookingStorage.dart';

// ✅ NEW SCREEN: OrderPage - Displays booking records and handles payment
class OrderPage extends StatefulWidget {
  // ✅ Added: Parameter for new booking to show as first item
  final BookingRecord? newBooking;

  const OrderPage({super.key, this.newBooking});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  bool _isProcessingPayment = false;
  String? _paymentMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings & Orders'),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: _buildBookingsList(),
    );
  }

  // ✅ Added: Display all booking records in a clean list UI
  Widget _buildBookingsList() {
    final bookingStorage = BookingStorage();
    final allBookings = bookingStorage.getAllBookings();

    if (allBookings.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📊 Summary Statistics
          // ✅ Added: Show booking summary at top
          _buildSummaryCards(allBookings),
          const SizedBox(height: 24),

          // 📋 Booking List Header
          const Text(
            'Your Bookings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // 🎫 Booking Cards
          // ✅ Added: Display each booking as a card with all details
          ...allBookings.map((booking) => _buildBookingCard(booking)).toList(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ✅ Added: Build summary cards showing booking statistics
  Widget _buildSummaryCards(List<BookingRecord> bookings) {
    int totalBookings = bookings.length;
    double totalAmount = bookings
        .where((b) => b.paymentStatus == 'completed')
        .fold(0, (sum, b) => sum + b.amountPaid);

    return Row(
      children: [
        Expanded(
          child: _buildStatsCard(
            'Total Bookings',
            totalBookings.toString(),
            Colors.blue,
            Icons.receipt,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatsCard(
            'Paid',
            '₹${totalAmount.toStringAsFixed(0)}',
            Colors.green,
            Icons.check_circle,
          ),
        ),
      ],
    );
  }

  // ✅ Added: Individual stats card widget
  Widget _buildStatsCard(String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Added: Build individual booking card with all details
  Widget _buildBookingCard(BookingRecord booking) {
    final isCompleted = booking.paymentStatus == 'completed';
    final isPending = booking.paymentStatus == 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted ? Colors.green : Colors.orange,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Booking ID: ${booking.id}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking.serviceBooked,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ✅ Added: Status badge
                  _buildStatusBadge(booking.paymentStatus),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // ✅ Added: User Information Section
              _buildInfoSection(
                'User Information',
                Icons.person,
                [
                  ('Name', booking.userName),
                  ('Email', booking.userEmail),
                  ('Phone', booking.userPhone),
                ],
              ),

              const SizedBox(height: 16),

              // ✅ Added: Booking Information Section
              _buildInfoSection(
                'Booking Details',
                Icons.info,
                [
                  ('Duration', booking.selectedSlot),
                  ('Amount', '₹${booking.slotPrice}'),
                  ('Date & Time', _formatDateTime(booking.bookingDateTime)),
                ],
              ),

              // ✅ Added: Payment Information Section (if payment completed)
              if (isCompleted) ...[
                const SizedBox(height: 16),
                _buildInfoSection(
                  'Payment Information',
                  Icons.payment,
                  [
                    ('Transaction ID', booking.transactionId),
                    ('Amount Paid', '₹${booking.amountPaid.toStringAsFixed(0)}'),
                  ],
                ),
              ],

              const SizedBox(height: 16),

              // ✅ Added: Action Buttons based on payment status
              if (isPending) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: _isProcessingPayment
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                        : const Icon(Icons.payment),
                    label: Text(
                      _isProcessingPayment ? 'Processing...' : 'Pay Now',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onPressed: _isProcessingPayment
                        ? null
                        : () => _processPayment(booking),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ] else if (isCompleted) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text(
                          'Payment Completed',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // ✅ Added: Error/Success message display
              if (_paymentMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _paymentMessage!.contains('success')
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _paymentMessage!,
                    style: TextStyle(
                      color: _paymentMessage!.contains('success')
                          ? Colors.green
                          : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Added: Build info section with icon and details
  Widget _buildInfoSection(
    String title,
    IconData icon,
    List<(String label, String value)> details,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.purple, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...details.map((detail) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  detail.$1,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  detail.$2,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  // ✅ Added: Payment status badge
  Widget _buildStatusBadge(String status) {
    final isCompleted = status == 'completed';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
        border: Border.all(
          color: isCompleted ? Colors.green : Colors.orange,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.pending,
            color: isCompleted ? Colors.green : Colors.orange,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            isCompleted ? 'PAID' : 'PENDING',
            style: TextStyle(
              color: isCompleted ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Modified: Use dummy payment instead of Stripe
  Future<void> _processPayment(BookingRecord booking) async {
    setState(() => _isProcessingPayment = true);

    try {
      debugPrint('💳 Processing dummy payment for booking: ${booking.id}');
      debugPrint('💰 Amount: ₹${booking.slotPrice}');
      debugPrint('👤 User: ${booking.userName}');

      // ✅ Modified: Simulate payment processing with delay
      await Future.delayed(const Duration(seconds: 2));

      // ✅ Modified: Generate transaction ID for dummy payment
      final transactionId = 'DUMMY_TXN_${DateTime.now().millisecondsSinceEpoch}';
      
      debugPrint('✅ Dummy payment successful!');
      debugPrint('📝 Transaction ID: $transactionId');
      debugPrint('👤 User Name: ${booking.userName}');
      debugPrint('🆔 Booking ID: ${booking.id}');

      setState(() {
        _paymentMessage = '✅ Payment successful! Booking ID: ${booking.id.substring(0, 8)}';
      });

      // ✅ Added: Show success snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Payment successful!\nUser: ${booking.userName}\nBooking ID: ${booking.id}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }

      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('❌ Payment failed: $e');

      setState(() {
        _paymentMessage = '❌ Payment failed. Please try again.';
      });

      // ✅ Added: Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Payment failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
      }
    }
  }

  // ✅ Added: Format DateTime for display
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // ✅ Added: Build empty state when no bookings exist
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No Bookings Yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You haven\'t made any bookings yet.\nStart by booking a service!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go Back'),
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
