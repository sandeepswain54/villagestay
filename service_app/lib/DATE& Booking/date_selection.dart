import 'package:flutter/material.dart';
import 'package:service_app/DATE&%20Booking/time_selection.dart';

class DateSelectionScreen extends StatefulWidget {
  final String locationId;
  final String locationName;
  final String locationType;
  final String state;

  const DateSelectionScreen({
    super.key,
    required this.locationId,
    required this.locationName,
    required this.locationType,
    required this.state, required String city,
  });

  @override
  State<DateSelectionScreen> createState() => _DateSelectionScreenState();
}

class _DateSelectionScreenState extends State<DateSelectionScreen> {
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.locationType == 'city'
              ? "Hotels in ${widget.locationName}, ${widget.state}"
              : "Hotels in ${widget.locationName} state",
        ),
      ),
      body: Column(
        children: [
          _buildCalendarMonth("July 2025", [
            [null, null, 1, 2, 3, 4, 5],
            [6, 7, 8, 9, 10, 11, 12],
            [13, 14, 15, 16, 17, 18, 19],
            [20, 21, 22, 23, 24, 25, 26],
            [27, 28, 29, 30, 31, null, null],
          ]),
          const Divider(),
          _buildCalendarMonth("August 2025", [
            [null, null, null, null, null, 1, 2],
            [3, 4, 5, 6, 7, 8, 9],
            [10, 11, 12, 13, 14, 15, 16],
            [17, 18, 19, 20, 21, 22, 23],
          ]),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.locationName, style: const TextStyle(fontSize: 16)),
                Text(
                  selectedDate != null
                      ? "${selectedDate!.day}th ${_getMonthName(selectedDate!.month)}, ${_getWeekdayName(selectedDate!.weekday)}"
                      : "Select Date",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: selectedDate != null
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TimeSelectionScreen(
                            city: widget.locationName,
                            date: selectedDate!,
                          ),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Continue"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarMonth(String month, List<List<int?>> weeks) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            month,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Table(
            children: [
              const TableRow(
                children: [
                  TableCell(child: Center(child: Text("S"))),
                  TableCell(child: Center(child: Text("M"))),
                  TableCell(child: Center(child: Text("T"))),
                  TableCell(child: Center(child: Text("W"))),
                  TableCell(child: Center(child: Text("T"))),
                  TableCell(child: Center(child: Text("F"))),
                  TableCell(child: Center(child: Text("S"))),
                ],
              ),
              ...weeks.map((week) {
                return TableRow(
                  children: week.map((day) {
                    if (day == null) {
                      return const TableCell(child: SizedBox());
                    }
                    return TableCell(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDate = DateTime(
                              2025,
                              month == "July 2025" ? 7 : 8,
                              day,
                            );
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: selectedDate != null &&
                                    selectedDate!.day == day &&
                                    selectedDate!.month ==
                                        (month == "July 2025" ? 7 : 8)
                                ? Colors.blue
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              day.toString(),
                              style: TextStyle(
                                color: selectedDate != null &&
                                        selectedDate!.day == day &&
                                        selectedDate!.month ==
                                            (month == "July 2025" ? 7 : 8)
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return "Jan";
      case 2:
        return "Feb";
      case 3:
        return "Mar";
      case 4:
        return "Apr";
      case 5:
        return "May";
      case 6:
        return "Jun";
      case 7:
        return "Jul";
      case 8:
        return "Aug";
      case 9:
        return "Sep";
      case 10:
        return "Oct";
      case 11:
        return "Nov";
      case 12:
        return "Dec";
      default:
        return "";
    }
  }

  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return "Mon";
      case 2:
        return "Tue";
      case 3:
        return "Wed";
      case 4:
        return "Thu";
      case 5:
        return "Fri";
      case 6:
        return "Sat";
      case 7:
        return "Sun";
      default:
        return "";
    }
  }
}