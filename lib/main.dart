import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:buzz/collections/category.dart';
import 'package:buzz/collections/task.dart';
import 'package:buzz/const/const.dart';
import 'package:buzz/provider/preference_providers.dart';
import 'package:buzz/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Isar init
  final dir = await getApplicationSupportDirectory();
  final isar = await Isar.open(
    [
      TaskSchema,
      CategorySchema,
    ],
    directory: dir.path,
  );

  createIsarDefaultValues(isar);

  prefs = await SharedPreferences.getInstance();

  initProviders();

  // awesome notifications
  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelGroupKey: 'reminders_group',
        channelKey: 'reminders',
        channelName: 'Reminders',
        channelDescription: 'Notification channel for buzz reminders',
        defaultColor: Colors.amber,
        ledColor: Colors.white,
        importance: NotificationImportance.High,
      )
    ],
    debug: true,
  );

  runApp(
    //Riverpod init
    ProviderScope(
      child: ToDo(isar: isar),
    ),
  );
}

class ToDo extends StatefulWidget {
  final Isar isar;
  const ToDo({Key? key, required this.isar}) : super(key: key);

  @override
  State<ToDo> createState() => _ToDoState();
}

class _ToDoState extends State<ToDo> {
  @override
  void initState() {
    super.initState();

    // Notification permission request
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Theme
      themeMode: ThemeMode.light,
      theme: themeData,

      //App parameters
      title: "BUZZ",

      // Screens
      initialRoute: "/",
      routes: {
        "/": (context) => Home(isar: widget.isar),
      },
    );
  }
}
