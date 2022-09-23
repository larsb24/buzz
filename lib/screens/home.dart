import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:buzz/collections/task.dart';
import 'package:buzz/screens/sheets/add_edit_task_sheet.dart';
import 'package:buzz/screens/sheets/categories_sheet.dart';
import 'package:buzz/screens/sheets/settings_sheet.dart';
import 'package:buzz/widgets/background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:isar/isar.dart';

class Home extends StatefulWidget {
  final Isar isar;
  const Home({Key? key, required this.isar}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (val) async {
        final List<Task> tasks = await widget.isar.tasks.where().findAll();
        showBottomActionSheet(
          context,
          AddEditTaskSheet(
            isar: widget.isar,
            task: tasks.firstWhere((task) => task.id == val.id),
          ),
        );
      },
    );
  }

  List<int> selectedTasks = List.empty(growable: true);
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Background(isar: widget.isar),
        Scaffold(
          //Scaffold parameters
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,

          //AppBar
          appBar: AppBar(
            // Parameters
            title: appBarTitle(),
            centerTitle: true,

            // Style
            shape: const Border(
              bottom: BorderSide(color: Colors.white, width: 2.0),
            ),
            backgroundColor: Colors.black.withOpacity(0.75),
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
            ),

            // Actions
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => showBottomActionSheet(
                  context,
                  SettingsSheet(isar: widget.isar),
                ),
              ),
            ],
          ),

          //Body
          body: RefreshIndicator(
            triggerMode: RefreshIndicatorTriggerMode.anywhere,
            onRefresh: () async {
              await loadTasks();
              setState(() {});
            },
            child: FutureBuilder(
              future: tasksList(),
              builder: (context, AsyncSnapshot<Widget> snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return snapshot.data!;
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),

          //FloatingActionButton
          floatingActionButton: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              categoriesFloatingActionButton(),
              Gap(selectedTasks.isEmpty ? 12 : 0),
              floatingActionButton(context, selectedTasks),
            ],
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        ),
      ],
    );
  }

  // Task list future
  Future<List<Task>> loadTasks() async {
    return widget.isar.tasks.where().findAll();
  }

  // Task list widget
  Future<Widget> tasksList() async {
    // load list of tasks
    final List<Task> tasks = await loadTasks();
    setState(() {});

    // build list of tasks
    return ListView.builder(
      itemCount: tasks.length,
      padding: const EdgeInsets.only(top: 12.0, bottom: 72),
      itemBuilder: (context, index) {
        return Card(
          clipBehavior: Clip.antiAlias,
          margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          color: Colors.black.withOpacity(0.75),
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: ListTile(
            // ListTile parameters
            title: Text(tasks[index].title),
            subtitle: Text(
              "${tasks[index].category.value?.name}\nReminder: ${tasks[index].reminder}",
            ),
            leading: taskIcon(tasks, index),
            isThreeLine: true,

            // Actions
            onLongPress: () {
              // Toggle task selection
              toggleSelected(tasks, index);
            },
            onTap: () async {
              // Check if any tasks are selected
              if (selectedTasks.isEmpty) {
                showBottomActionSheet(
                  context,
                  AddEditTaskSheet(
                    isar: widget.isar,
                    task: tasks[index],
                  ),
                );
                return;
              }
              // Toggle task selection
              toggleSelected(tasks, index);
            },
          ),
        );
      },
    );
  }

  // toggle selected task
  void toggleSelected(List<Task> tasks, int index) {
    return setState(() {
      if (selectedTasks.contains(tasks[index].id)) {
        selectedTasks.remove(tasks[index].id);
      } else {
        selectedTasks.add(tasks[index].id);
      }
    });
  }

  // task icon based on the toggle status
  Icon taskIcon(List<Task> tasks, int index) {
    return Icon(
      selectedTasks.contains(tasks[index].id)
          ? Icons.check_circle_outline
          : Icons.circle_outlined,
    );
  }

  // Switches between the app name and the amount of selected tasks
  Text appBarTitle() {
    return Text(
      selectedTasks.isEmpty
          ? "Buzz - ToDo"
          : "${selectedTasks.length.toString()} selected",
    );
  }

  // FloatingActionButton for the category list
  Offstage categoriesFloatingActionButton() {
    return Offstage(
      offstage: selectedTasks.isNotEmpty,
      child: FloatingActionButton.extended(
        // Parameters
        label: const Text("Categories"),
        icon: const Icon(Icons.auto_awesome_mosaic_outlined),

        // Style
        backgroundColor: Colors.black.withOpacity(0.75),
        foregroundColor: Colors.white,
        shape: floatingActionButtonShape(),

        //Action
        onPressed: () =>
            showBottomActionSheet(context, CategoriesSheet(isar: widget.isar)),
      ),
    );
  }

  // Shape and border for the FloatingActionButtons
  RoundedRectangleBorder floatingActionButtonShape() {
    return RoundedRectangleBorder(
      side: const BorderSide(color: Colors.white, width: 2.0),
      borderRadius: BorderRadius.circular(32.0),
    );
  }

  // FloatingActionButton
  FloatingActionButton floatingActionButton(
    BuildContext context,
    List<int> selectedTasks,
  ) {
    // Delete selected tasks
    if (selectedTasks.isNotEmpty) {
      return FloatingActionButton.extended(
        // Parameters
        label: const Text("Delete selected"),
        icon: const Icon(Icons.delete_outline_rounded),

        // Style
        backgroundColor: Colors.black.withOpacity(0.75),
        foregroundColor: Colors.white,
        shape: floatingActionButtonShape(),

        // Action
        onPressed: () async {
          await widget.isar.writeTxn(() async {
            await widget.isar.tasks.deleteAll(selectedTasks);
          });
          for (final element in selectedTasks) {
            AwesomeNotifications().cancel(element);
          }
          selectedTasks.clear();
          setState(() {});
        },
      );
    }

    // Add new task
    return FloatingActionButton.extended(
      // Parameters
      label: const Text("Add Task"),
      icon: const Icon(Icons.add_rounded),

      // Style
      backgroundColor: Colors.black.withOpacity(0.75),
      foregroundColor: Colors.white,
      shape: floatingActionButtonShape(),

      // Action
      onPressed: () => showBottomActionSheet(
        context,
        AddEditTaskSheet(isar: widget.isar),
      ),
    );
  }
}

// Show custom ModalBottomSheet
Future<void> showBottomActionSheet(BuildContext context, Widget sheet) {
  return showModalBottomSheet(
    // Parameters
    context: context,
    isScrollControlled: true,

    // Style
    elevation: 0.0,
    backgroundColor: Colors.black.withOpacity(0.5),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
    ),

    // Builder
    builder: (context) {
      return Padding(
        // Bottom sheet padding + keyboard height
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),

        // Clip with 16px radius
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(16)),

          // Blur the background
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 20.0,
              sigmaY: 20.0,
            ),
            child: Container(
              // Style
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 24.0,
              ),

              // Sheet contents
              child: sheet,
            ),
          ),
        ),
      );
    },
  );
}
