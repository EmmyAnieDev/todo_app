import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/components/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WeekDayList extends StatefulWidget {
  const WeekDayList({super.key, required this.onDateTap});

  final Function(DateTime) onDateTap;

  @override
  State<WeekDayList> createState() => _WeekDayListState();
}

class _WeekDayListState extends State<WeekDayList> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const daysInRow = 14; // Show 14 days at a time

    return SizedBox(
      height: 80.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: daysInRow,
        itemBuilder: (context, index) {
          final currentDate =
              selectedDate.add(Duration(days: index - daysInRow ~/ 4));
          final dayOfWeek = DateFormat('E').format(currentDate)[0];
          final dayOfMonth = DateFormat('d').format(currentDate);
          bool isToday = currentDate.day == DateTime.now().day;
          bool isSelected = currentDate == selectedDate;

          return GestureDetector(
            onTap: () {
              setState(() {
                //  tappedDate = index; // Update the selected column index
                selectedDate = currentDate;
              });
              print('Date ${currentDate.toString()} tapped');
              widget.onDateTap(currentDate);
            },
            child: SizedBox(
              width: screenWidth / 7,
              child: Column(
                children: [
                  Container(
                    padding: isToday
                        ? EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h)
                        : EdgeInsets.only(top: 10.h),
                    decoration: isToday
                        ? BoxDecoration(
                            color: kGreenColor,
                            borderRadius: BorderRadius.circular(10.r))
                        : null,
                    child: Column(
                      children: [
                        Text(
                          dayOfWeek,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: isSelected && isToday
                                ? kWhiteColor
                                : isSelected
                                    ? Colors.red
                                    : isToday
                                        ? kWhiteColor
                                        : Colors.black54,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          dayOfMonth,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: (isSelected && isToday)
                                ? kWhiteColor
                                : isSelected
                                    ? Colors.red
                                    : isToday
                                        ? kWhiteColor
                                        : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
