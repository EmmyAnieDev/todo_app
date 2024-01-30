import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/models/task.dart';
import 'package:collection/collection.dart';
import 'package:todo_app/widgets/weekDays.dart';
import 'package:todo_app/screens/add_task.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:todo_app/components/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Task> tasks = [];
  DateTime tappedDate = DateTime.now();
  Map<int, Set<int>> completedTasks = {};
  int? selectedTaskIndex;
  late AudioPlayer _audioPlayer;
  late Timer _audioCheckTimer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Set up a periodic timer to check for audio playback
    _audioCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkTaskAudio();
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _audioCheckTimer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void _checkTaskAudio() {
    DateTime currentTime = DateTime.now();

    Task? matchingTask = tasks.firstWhereOrNull((task) {
      DateTime taskTime = DateTime.parse('2001-01-01 ${task.time}');
      return currentTime.hour == taskTime.hour &&
          currentTime.minute == taskTime.minute;
    });

    if (matchingTask != null) {
      _playAudio(matchingTask.audioPath);
    }
  }

  void _playAudio(String audioPath) async {
    await _audioPlayer.play(AssetSource('sound.mp3'));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.green.shade50,
          title: Text('Task Reminder', style: kAlertTitle),
          content: Text(
              'It\'s time for your scheduled task. Would you like to stop and view the details?',
              style: kAlertContent),
          actions: [
            ElevatedButton(
              onPressed: () {
                _audioPlayer.stop();
                Navigator.pop(context);
              },
              child: Text('Stop', style: kAlertAction),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: kWhiteColor, size: 20.sp),
        leading: const Icon(Icons.menu),
        title: Text(
          'Task List',
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
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 15.h,
          ),
          child: Column(
            children: <Widget>[
              WeekDayList(onDateTap: (DateTime date) {
                setState(() {
                  tappedDate = date;
                });
              }),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 20.h,
                    right: 10.w,
                    left: 15.w,
                  ),
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      // Sort tasks based on time
                      tasks.sort((a, b) {
                        DateTime timeA = DateTime.parse('2001-01-01 ${a.time}');
                        DateTime timeB = DateTime.parse('2001-01-01 ${b.time}');
                        return timeA.compareTo(timeB);
                      });
                      Task task = tasks[index];
                      // Parse the dueDate from String to DateTime
                      DateTime dueDate;
                      try {
                        dueDate = DateFormat('dd-MM-yyyy').parse(task.dueDate);
                      } catch (e) {
                        dueDate = DateTime.now();
                      }

                      // Filter tasks based on the selected date and the dueDate to endDate
                      if (tappedDate.isAfter(dueDate) &&
                          tappedDate.isBefore(DateFormat('dd-MM-yyyy')
                              .parse(task.endDate)
                              .add(const Duration(days: 1)))) {
                        bool isTaskCompleted =
                            completedTasks.containsKey(index) &&
                                completedTasks[index]!.contains(tappedDate.day);
                        return Opacity(
                          opacity: isTaskCompleted ? 0.3 : 1.0,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.r),
                                    color: task.isUrgent
                                        ? Colors.red
                                        : kGreenColor,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(10.r),
                                    child: Column(
                                      children: [
                                        Text(
                                          task.time,
                                          style: kTextStyle4.copyWith(
                                            color: task.isUrgent
                                                ? kWhiteColor
                                                : null,
                                          ),
                                        ),
                                        Text(
                                          task.selectedTimeOfDay,
                                          style: kTextStyle4.copyWith(
                                            color: task.isUrgent
                                                ? kWhiteColor
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      _showTaskDetailsBottomSheet(task, index);
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15.w),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            task.title.length > 15
                                                ? '${task.title.substring(0, 15)}...'
                                                : task.title,
                                            style: kTextStyle1,
                                          ),
                                          Text(
                                            task.description.length > 18
                                                ? '${task.description.substring(0, 18)}...'
                                                : task.description,
                                            style: kTextStyle2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _toggleTaskCompletion(index);
                                        });
                                      },
                                      child: Container(
                                        width: 18.w,
                                        height: 18.h,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: kGreenColor,
                                            width: 2.w,
                                          ),
                                        ),
                                        child: isTaskCompleted
                                            ? Center(
                                                child: Container(
                                                  width: 9.w,
                                                  height: 9.h,
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: kGreenColor,
                                                  ),
                                                ),
                                              )
                                            : null,
                                      ),
                                    ),
                                    SizedBox(width: 13.w),
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Theme(
                                              data: ThemeData.light().copyWith(
                                                primaryColor: Colors.green,
                                                colorScheme:
                                                    const ColorScheme.light(
                                                        primary: kGreenColor,
                                                        secondary: kGreenColor),
                                                buttonTheme:
                                                    const ButtonThemeData(
                                                        textTheme:
                                                            ButtonTextTheme
                                                                .primary),
                                              ),
                                              child: AlertDialog(
                                                title:
                                                    const Text("Delete Task"),
                                                content: const Text(
                                                    'Are you sure you want to delete this task?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        tasks.removeAt(index);
                                                      });
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text(
                                                      'Delete',
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 25.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: REdgeInsets.only(bottom: 40, right: 8).r,
        child: FloatingActionButton(
          backgroundColor: kGreenColor,
          shape: const CircleBorder(),
          onPressed: () async {
            final result = await Navigator.push<Task?>(
              context,
              MaterialPageRoute(builder: (context) => const AddTask()),
            );

            if (result != null) {
              addTask(result);
            }
          },
          child: const Icon(
            Icons.add,
            color: kWhiteColor,
          ),
        ),
      ),
    );
  }

  void _toggleTaskCompletion(int taskIndex) {
    if (!completedTasks.containsKey(taskIndex)) {
      completedTasks[taskIndex] = {};
    }

    if (completedTasks[taskIndex]!.contains(tappedDate.day)) {
      completedTasks[taskIndex]!.remove(tappedDate.day);
    } else {
      completedTasks[taskIndex]!.add(tappedDate.day);
    }
  }

  void addTask(Task task) {
    setState(() {
      tasks.add(task);
    });
  }

  void _showTaskDetailsBottomSheet(Task task, int index) {
    final screenHeight = MediaQuery.of(context).size.height;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          width: double.infinity,
          height: screenHeight * 0.3,
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Task Details',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          selectedTaskIndex = index;
                        });
                        _editTask(task, selectedTaskIndex!);
                      },
                      icon: Icon(
                        Icons.edit,
                        size: 20.sp,
                        color: kGreenColor,
                      ))
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                'Name: ${task.title}',
                style: kTextStyle5,
              ),
              Text(
                'Description: ${task.description}',
                style: kTextStyle5,
              ),
              Text(
                'Due Date: ${task.dueDate}',
                style: kTextStyle5,
              ),
              Text(
                'Time: ${task.time} ${task.selectedTimeOfDay}',
                style: kTextStyle5,
              ),
              Text(
                'End Date: ${task.endDate}',
                style: kTextStyle5,
              ),
              Text(
                'Priority: ${task.isUrgent ? 'Urgent' : 'Normal'}',
                style: TextStyle(
                  fontSize: 15.sp,
                  color: task.isUrgent ? Colors.red : kGreenColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _editTask(Task task, int selectedTaskIndex) async {
    //  print('Editing task: $task');
    final result = await Navigator.push<Task?>(
      context,
      MaterialPageRoute(
        builder: (context) => AddTask(editTask: task),
      ),
    );

    if (result != null) {
      // Update the task in the list with the edited data
      setState(() {
        tasks[selectedTaskIndex] = result;
      });
    }
  }
}
