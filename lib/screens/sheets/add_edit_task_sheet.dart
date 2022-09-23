import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:buzz/collections/category.dart';
import 'package:buzz/collections/task.dart';
import 'package:buzz/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

// TextField controllers
final _titleController = TextEditingController();
final _categoryController = TextEditingController();
final _timeController = TextEditingController();
// Focus node
final FocusNode _focusNode = FocusNode();

// List of categories
late List<Category> _categories;

// Selected category
Category? _slectedCategory;

// Initial DateTime
DateTime _date = DateTime.now().add(const Duration(minutes: 1));
late DateTime dtNow;
late TimeOfDay tdNow;

class AddEditTaskSheet extends StatefulWidget {
  final Task? task;
  final Isar isar;
  const AddEditTaskSheet({
    Key? key,
    required this.isar,
    this.task,
  }) : super(key: key);

  @override
  State<AddEditTaskSheet> createState() => _AddEditTaskSheetState();
}

class _AddEditTaskSheetState extends State<AddEditTaskSheet> {
  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    dtNow = DateTime(now.year, now.month, now.day, now.minute, now.hour)
        .add(const Duration(minutes: 1));
    tdNow = TimeOfDay.fromDateTime(dtNow);

    _titleController.clear();

    // Load selected task
    if (widget.task != null) {
      print(widget.task!.reminder);
      _titleController.text = widget.task!.title;
      _categoryController.text = widget.task!.category.value!.name;
      if (widget.task?.reminder != "") {
        final List<String> dateAndTime = widget.task!.reminder.split(" – ");
        final List<String> date = dateAndTime[0].split(".");
        final List<String> time = dateAndTime[1].split(":");
        _date = DateTime(
          int.parse(date[2]),
          int.parse(date[1]),
          int.parse(date[0]),
          int.parse(time[0]),
          int.parse(time[1]),
        );
      }
    } else {
      _categoryController.text = "Default";
    }
    _timeController.text = DateFormat('dd.MM.yyyy – HH:mm').format(_date);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadCategories(),
      builder: (context, snapshot) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title TextField
            TextField(
              // Parameters
              autofocus: true,
              focusNode: _focusNode,
              controller: _titleController,

              // Style
              decoration: textFieldBoder("Title"),

              // Action
              onEditingComplete: () {
                _focusNode.nextFocus();
              },
            ),
            const Gap(16),

            // Category TextField
            TextField(
              // Parameters
              focusNode: FocusNode(),
              controller: _categoryController,
              readOnly: true,

              // Style
              decoration: textFieldBoder("Category"),

              // Action
              onTap: () {
                showBottomActionSheet(
                  context,
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: ListView.builder(
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          // Parameters
                          title: Text(_categories[index].name),

                          // Actions
                          onTap: () {
                            _slectedCategory = _categories[index];
                            _categoryController.text = _slectedCategory!.name;
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            const Gap(16),
            TextField(
              // Parameters
              focusNode: FocusNode(),
              controller: _timeController,
              readOnly: true,

              // Style
              decoration: textFieldBoder('Reminder'),

              // Action
              onTap: () {
                _focusNode.unfocus();
                pickTime();
              },
            ),
            const Gap(24),

            // Save button
            FloatingActionButton.extended(
              // Parameters
              label: const Text("Save"),
              icon: const Icon(Icons.check_circle_outline_rounded),

              // Action
              onPressed: () {
                // Only save if the title is set
                if (_titleController.text.isNotEmpty) {
                  save();
                }
                setState(() {});

                // Clear the text fields
                _titleController.clear();
                _categoryController.clear();
                _timeController.clear();

                // Close the sheet
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Show TimePicker
  Future<void> pickTime() async {
    final DateTime date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        ) ??
        dtNow;

    final TimeOfDay time = await showTimePicker(
          context: context,
          initialTime: tdNow,
        ) ??
        tdNow;

    setState(() {
      _date = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      _timeController.text = DateFormat('dd.MM.yyyy – HH:mm').format(_date);
    });
  }

  // Save task
  Future<void> save() async {
    final id = widget.task?.id ?? Isar.autoIncrement;
    // Create the Task
    final Task task = Task()
      ..title = _titleController.text
      ..reminder = _timeController.text
      ..id = id
      ..category.value = _slectedCategory ?? _categories.first;

    // Save the task
    await widget.isar.writeTxn(() async {
      await widget.isar.tasks.put(task);
      await task.category.save();
    });

    await createNotification("Reminder", task.title, task.id);
  }

  Future<void> createNotification(
    String title,
    String body,
    int id,
  ) async {
    if (widget.task != null) {
      await AwesomeNotifications().cancel(id);
    }

    final DateTime notificationDate =
        DateTime(_date.year, _date.month, _date.day, _date.hour, _date.minute);

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'reminders',
        title: title,
        body: body,
        payload: {"ID": id.toString()},
        wakeUpScreen: true,
      ),
      schedule: NotificationCalendar.fromDate(
        date: notificationDate,
        preciseAlarm: true,
      ),
    );
  }

  Future<void> loadCategories() async {
    final List<Category> categories =
        await widget.isar.categorys.where().findAll();

    setState(() {
      _categories = categories;
    });
  }
}

// TextField decoration
InputDecoration textFieldBoder(String label) {
  return InputDecoration(
    border: const OutlineInputBorder(),
    labelText: label,
  );
}
