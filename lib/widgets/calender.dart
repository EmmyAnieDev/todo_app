import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/components/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CalenderWidget extends StatefulWidget {
  final String selectedDate;
  final Function(String) onDateSelected;
  final String? editDueDate;
  final String? editEndDate;

  const CalenderWidget(
      {super.key,
      required this.selectedDate,
      required this.onDateSelected,
      this.editDueDate,
      this.editEndDate});

  @override
  State<CalenderWidget> createState() => _CalenderWidgetState();
}

class _CalenderWidgetState extends State<CalenderWidget> {
  String selectedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    // Initialize selectedDate based on dueDate or endDate
    selectedDate =
        widget.editEndDate ?? widget.editDueDate ?? widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 45.h,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 2.w),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10.w),
            child: Text(
              selectedDate,
              style: kTextStyle2,
            ),
          ),
          IconButton(
            onPressed: () async {
              DateTime currentDate = DateTime.now();
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: currentDate,
                firstDate: DateTime(2001),
                lastDate: DateTime(2101),
                selectableDayPredicate: (DateTime date) {
                  return !date
                      .isBefore(currentDate.subtract(const Duration(days: 1)));
                },
                builder: (BuildContext context, Widget? child) {
                  return Theme(
                    data: ThemeData.light().copyWith(
                      primaryColor: Colors.green,
                      colorScheme: const ColorScheme.light(
                          primary: kGreenColor, secondary: kGreenColor),
                      buttonTheme: const ButtonThemeData(
                          textTheme: ButtonTextTheme.primary),
                    ),
                    child: child!,
                  );
                },
              );

              if (pickedDate != null) {
                final formattedDate =
                    DateFormat('dd-MM-yyyy').format(pickedDate);
                widget
                    .onDateSelected(formattedDate); // Update the selected date
                setState(() {
                  selectedDate = formattedDate;
                });
              }
            },
            icon: Icon(
              Icons.calendar_month,
              size: 20.sp,
            ),
          )
        ],
      ),
    );
  }
}
