import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pay/pay.dart';
import 'package:service_app/Payment_Gateway/payment_config.dart';
import 'package:service_app/model/app_constant.dart';
import 'package:service_app/model/posting_model.dart';
import 'package:service_app/views/Widgets/calender_ui.dart';
import 'package:service_app/views/host_home.dart';

class BookListingScreen extends StatefulWidget {
  final PostingModel? posting;
  final String? hostID;

  const BookListingScreen({super.key, this.posting, this.hostID});

  @override
  State<BookListingScreen> createState() => _BookListingScreenState();
}

class _BookListingScreenState extends State<BookListingScreen> {
  PostingModel? posting;
  List<DateTime> bookedDates = [];
  List<DateTime> selectedDates = [];
  List<CalenderUi> calendarWidgets = [];
  double bookingPrice = 0.0;
  String paymentResult = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    posting = widget.posting;
    _loadBookedDates();
  }




  void _buildCalendarWidgets() {
    calendarWidgets = List.generate(12, (index) => CalenderUi(
      monthIndex: index,
      bookedDates: bookedDates,
      selectDate: _selectDate,
      getSelectedDates: _getSelectedDates,
    ));
    setState(() {});
  }

  List<DateTime> _getSelectedDates() => selectedDates;

  void _selectDate(DateTime date) {
    setState(() {
      if (selectedDates.any((d) => _isSameDate(d, date))) {
        selectedDates.removeWhere((d) => _isSameDate(d, date));
      } else {
        selectedDates.add(date);
      }
      selectedDates.sort();
    });
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _loadBookedDates() async {
    setState(() => isLoading = true);
    try {
      await posting!.getAllBookingFromFirestore();
      bookedDates = posting!.getAllBookedDates();
      _buildCalendarWidgets();
    } catch (e) {
      Get.snackbar("Error", "Failed to load booked dates: ${e.toString()}");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _makeBooking() async {
    if (selectedDates.isEmpty) {
      Get.snackbar("Error", "Please select at least one date");
      return;
    }
    
    setState(() => isLoading = true);
    try {
      if (widget.hostID == null || widget.hostID!.isEmpty) {
        throw Exception("Host information is missing");
      }
      
      await posting!.makeNewBooking(selectedDates, context, widget.hostID!);
      Get.back();
      Get.snackbar("Success", "Booking created successfully");
    } catch (e) {
      Get.snackbar("Booking Error", e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  void calculateAmountForOverallStay() {
    if (selectedDates.isEmpty) return;
    setState(() {
      bookingPrice = selectedDates.length * (posting?.price ?? 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
             colors: [Color(0xFF4A6CF7), Color(0xFF82C3FF)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: Text(
          "Book ${posting?.name ?? ''}",
          style: const TextStyle(color: Colors.white, fontSize: 26),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.fromLTRB(25, 25, 25, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text("Sun"), Text("Mon"), Text("Tue"),
                      Text("Wed"), Text("Thu"), Text("Fri"), Text("Sat"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 2,
                    child: calendarWidgets.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : PageView.builder(
                            itemCount: calendarWidgets.length,
                            itemBuilder: (context, index) => calendarWidgets[index],
                          ),
                  ),
                  if (bookingPrice == 0.0)
                    MaterialButton(
                      onPressed: calculateAmountForOverallStay,
                      minWidth: double.infinity,
                      height: MediaQuery.of(context).size.height / 14,
                      color: Colors.green,
                      child: const Text(
                        "Calculate Total Price",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  if (paymentResult.isNotEmpty)
                    MaterialButton(
                      onPressed: () {
                        Get.to(HostHomeScreen());
                        setState(() => paymentResult = "");
                      },
                      minWidth: double.infinity,
                      height: MediaQuery.of(context).size.height / 14,
                      color: Colors.green,
                      child: const Text(
                        "Proceed",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  if (bookingPrice > 0.0 && paymentResult.isEmpty)
                    Platform.isIOS
                        ? ApplePayButton(
                            paymentConfiguration:
                                PaymentConfiguration.fromJsonString(defaultApplePay),
                            paymentItems: [
                              PaymentItem(
                                amount: bookingPrice.toStringAsFixed(2),
                                label: "Booking Amount",
                                status: PaymentItemStatus.final_price,
                              ),
                            ],
                            style: ApplePayButtonStyle.black,
                            width: double.infinity,
                            height: 50,
                            type: ApplePayButtonType.buy,
                            margin: const EdgeInsets.only(top: 15),
                            onPaymentResult: (result) {
                              setState(() => paymentResult = result.toString());
                              _makeBooking();
                            },
                            loadingIndicator: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : GooglePayButton(
                            paymentConfiguration:
                                PaymentConfiguration.fromJsonString(defaultGooglePay),
                            paymentItems: [
                              PaymentItem(
                                label: "Total",
                                amount: bookingPrice.toStringAsFixed(2),
                                status: PaymentItemStatus.final_price,
                              ),
                            ],
                            type: GooglePayButtonType.pay,
                            margin: const EdgeInsets.only(top: 15),
                            onPaymentResult: (result) {
                              setState(() => paymentResult = result.toString());
                              _makeBooking();
                            },
                            loadingIndicator: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                ],
              ),
            ),
    );
  }
}