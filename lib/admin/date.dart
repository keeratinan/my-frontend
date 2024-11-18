import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomDatePicker extends StatefulWidget {
  @override
  _CustomDatePickerState createState() => _CustomDatePickerState();
}


class _CustomDatePickerState extends State<CustomDatePicker> {
  DateTime selectedDate = DateTime.now();
  bool isCalendarView = true;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // ขอบมุมโค้งมนแบบสวยงาม
      ),
      child: SingleChildScrollView( // เพิ่ม SingleChildScrollView
        child: Container(
          padding: EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxHeight: 400,
            maxWidth: 320,
          ),
          color: Colors.white, // พื้นหลังขาว
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ส่วนหัวที่มีปุ่มเปลี่ยนเดือน
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(FontAwesomeIcons.chevronLeft, color: Colors.amber[700]),
                    onPressed: () {
                      setState(() {
                        selectedDate = DateTime(
                          selectedDate.year,
                          selectedDate.month - 1,
                        );
                      });
                    },
                  ),
                  Text(
                    "${selectedDate.year} - ${selectedDate.month.toString().padLeft(2, '0')}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[700],
                    ),
                  ),
                  IconButton(
                    icon: Icon(FontAwesomeIcons.chevronRight, color: Colors.amber[700]),
                    onPressed: () {
                      setState(() {
                        selectedDate = DateTime(
                          selectedDate.year,
                          selectedDate.month + 1,
                        );
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              // สลับระหว่าง Calendar กับ Input View
              isCalendarView
                  ? CalendarDatePicker(
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                      onDateChanged: (newDate) {
                        setState(() {
                          selectedDate = newDate;
                        });
                      },
                    )
                  : TextField(
                      decoration: InputDecoration(
                        hintText: "Enter date (YYYY-MM-DD)",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.amber[700]!),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      keyboardType: TextInputType.datetime,
                      onSubmitted: (value) {
                        setState(() {
                          final parts = value.split('-');
                          if (parts.length == 3) {
                            selectedDate = DateTime(
                              int.parse(parts[0]),
                              int.parse(parts[1]),
                              int.parse(parts[2]),
                            );
                          }
                        });
                      },
                    ),
              SizedBox(height: 10),
              // ปุ่ม Switch to Input / Calendar View
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isCalendarView = !isCalendarView;
                      });
                    },
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      backgroundColor: Colors.amber[700],
                    ),
                    child: Text(
                      isCalendarView ? "Switch to Input" : "Switch to Calendar",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              // ปุ่มยืนยันและยกเลิก
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      backgroundColor: Colors.grey[300],
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ),
                  SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(selectedDate);
                    },
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      backgroundColor: Colors.amber[700],
                    ),
                    child: Text(
                      "OK",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
