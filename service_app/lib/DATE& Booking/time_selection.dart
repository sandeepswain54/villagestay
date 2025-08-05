import 'package:flutter/material.dart';
import 'package:service_app/Hotel_Model%202/hotel_list_screen.dart';
import 'package:service_app/Posting_Village/home_village.dart';

class TimeSelectionScreen extends StatefulWidget {
  final String city;
  final DateTime date;
  const TimeSelectionScreen({super.key, required this.city, required this.date});

  @override
  State<TimeSelectionScreen> createState() => _TimeSelectionScreenState();
}

class _TimeSelectionScreenState extends State<TimeSelectionScreen> {
  String? selectedTime;
  final List<String> amTimes = [
    "12:00 AM", "1:00 AM", "2:00 AM", "3:00 AM", "4:00 AM", "5:00 AM",
    "6:00 AM", "7:00 AM", "8:00 AM", "9:00 AM", "10:00 AM", "11:00 AM"
  ];
  final List<String> pmTimes = [
    "12:00 PM", "1:00 PM", "2:00 PM", "3:00 PM", "4:00 PM", "5:00 PM",
    "6:00 PM", "7:00 PM", "8:00 PM", "9:00 PM", "10:00 PM", "11:00 PM"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Check-in Time")),
      body: Column(
        children: [
          DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(tabs: [
                  Tab(text: "AM"),
                  Tab(text: "PM"),
                ]),
                SizedBox(
                  height: 300,
                  child: TabBarView(
                    children: [
                      _buildTimeGrid(amTimes),
                      _buildTimeGrid(pmTimes),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.city, style: const TextStyle(fontSize: 16)),
                Text(
                  "${widget.date.day}th ${_getMonthName(widget.date.month)}, "
                  "${_getWeekdayName(widget.date.weekday)} | ${selectedTime ?? "Select Time"}",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              // In the _TimeSelectionScreenState, update the Search button onPressed:
onPressed: selectedTime != null ? () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => HotelListScreen(
        city: widget.city,
        date: widget.date,
        time: selectedTime!,
      ),
    ),
  );
} : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Search"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeGrid(List<String> times) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2,
      ),
      itemCount: times.length,
      itemBuilder: (context, index) => ElevatedButton(
        onPressed: () => setState(() => selectedTime = times[index]),
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedTime == times[index] ? Colors.blue : Colors.grey[200],
          foregroundColor: selectedTime == times[index] ? Colors.white : Colors.black,
        ),
        child: Text(times[index]),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
    return months[month - 1];
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"];
    return weekdays[weekday - 1];
  }
}