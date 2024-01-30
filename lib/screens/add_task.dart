import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_app/components/constants.dart';
import 'package:todo_app/widgets/radio.dart';
import 'package:todo_app/widgets/textField.dart';
import 'package:todo_app/widgets/calender.dart';
import 'package:todo_app/models/task.dart';

class AddTask extends StatefulWidget {
  const AddTask({super.key, this.editTask});

  final Task? editTask;

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  String selectedTimeOfDay = 'AM';
  final TextEditingController titleController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  int priorityValue = 0; // 0 for Normal, 1 for Urgent
  String selectedStartDate =
      DateFormat('dd-MM-yyyy').format(DateTime.now()).toString();
  String selectedEndDate =
      DateFormat('dd-MM-yyyy').format(DateTime.now()).toString();

  @override
  void initState() {
    super.initState();

    if (widget.editTask != null) {
      titleController.text = widget.editTask!.title;
      descriptionController.text = widget.editTask!.description;
      priorityValue = widget.editTask!.isUrgent ? 1 : 0;
      selectedStartDate = widget.editTask!.dueDate;
      selectedEndDate = widget.editTask!.endDate;
      timeController.text = widget.editTask?.time ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        iconTheme: IconThemeData(color: kWhiteColor, size: 20.sp),
        title: Text(
          'Add Task',
          style: TextStyle(color: kWhiteColor, fontSize: 23.sp),
        ),
        actions: [
          const Icon(Icons.notifications),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.r),
            child: const Icon(Icons.search),
          ),
          const Icon(Icons.more_vert),
          SizedBox(width: 7.w)
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 23.h, horizontal: 15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Title', style: kTextStyle1),
              SizedBox(height: 4.h),
              TextFieldWidget(
                hintText: 'Add Title',
                controller: titleController,
              ),
              Padding(
                padding: EdgeInsets.only(top: 20.h),
                child: Text('Description', style: kTextStyle1),
              ),
              SizedBox(height: 4.h),
              TextFieldWidget(
                hintText: 'Write Description',
                maxLine: 3,
                controller: descriptionController,
              ),
              Padding(
                padding: EdgeInsets.only(top: 20.h),
                child: Text('Due Date', style: kTextStyle1),
              ),
              SizedBox(height: 4.h),
              CalenderWidget(
                selectedDate: selectedStartDate,
                onDateSelected: (date) {
                  setState(() {
                    selectedStartDate = date;
                  });
                },
                editDueDate: widget.editTask?.dueDate,
              ),
              Padding(
                padding: EdgeInsets.only(top: 20.h),
                child: Text('Time', style: kTextStyle1),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: kGreenColor,
                                onPrimary: Colors.white,
                              ),
                              buttonTheme: const ButtonThemeData(
                                  textTheme: ButtonTextTheme.primary),
                            ),
                            child: child!,
                          );
                        },
                      );

                      if (pickedTime != null) {
                        // Format the selected time and update the controller
                        final formattedTime = DateFormat('hh:mm').format(
                            DateTime(DateTime.now().year, 1, 1, pickedTime.hour,
                                pickedTime.minute));
                        timeController.text = formattedTime;
                      }
                    },
                    child: Text(
                      'Select Time',
                      style: kAlertContent,
                    ),
                  ),
                  SizedBox(width: 20.w),
                  DropdownButton<String>(
                    value: selectedTimeOfDay,
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() {
                          selectedTimeOfDay = value;
                        });
                      }
                    },
                    items: ['AM', 'PM']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: kAlertContent,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Text('Set Task Priority', style: kTextStyle1),
              ),
              RadioWidget(
                value: priorityValue,
                onChanged: (value) {
                  setState(() {
                    priorityValue = value;
                  });
                },
              ),
              Padding(
                padding: EdgeInsets.only(top: 18.h),
                child: Text('End Date', style: kTextStyle1),
              ),
              SizedBox(height: 4.h),
              CalenderWidget(
                selectedDate: selectedEndDate,
                onDateSelected: (date) {
                  setState(() {
                    selectedEndDate = date;
                  });
                },
                editEndDate: widget.editTask?.endDate,
              ),
              SizedBox(height: 30.h),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.r),
                  color: kGreenColor,
                ),
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    if (titleController.text.isEmpty) {
                      showErrorDialog('Title cannot be empty.');
                    } else if (timeController.text.isEmpty) {
                      showErrorDialog('Please select a time.');
                    } else if (isEndDateBeforeDueDate()) {
                      showErrorDialog('End date cannot be before due date.');
                    } else {
                      Task newTask = Task(
                        time: timeController.text,
                        selectedTimeOfDay: selectedTimeOfDay,
                        title: titleController.text,
                        description: descriptionController.text,
                        isUrgent: priorityValue == 1,
                        dueDate: selectedStartDate,
                        endDate: selectedEndDate,
                        creationDate: DateTime.now(),
                        audioPath: 'assets/assets/sound.mp3',
                      );
                      Navigator.pop(context, newTask);
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Text(
                      'ADD TASK',
                      style: kTextStyle4,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void showErrorDialog(String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.red.shade100,
          title: Text('Error', style: kAlertTitle),
          content: Text(content, style: kAlertContent),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: kAlertAction,
              ),
            ),
          ],
        );
      },
    );
  }

  bool isEndDateBeforeDueDate() {
    DateTime endDate = DateFormat('dd-MM-yyyy').parse(selectedEndDate);
    DateTime dueDate = DateFormat('dd-MM-yyyy').parse(selectedStartDate);

    // Check if endDate is before dueDate
    return endDate.isBefore(dueDate);
  }
}
