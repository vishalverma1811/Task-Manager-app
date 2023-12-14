import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:task_management/core/models/category_model.dart';
import 'package:task_management/core/widgets/category_provider.dart';
import 'package:task_management/services/notification_service.dart';
import 'package:task_management/task_list.dart';
import 'core/models/task_model.dart';
import 'core/widgets/task_provider.dart';
late final tasksBox;
late final categoriesBox;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationManager().initNotification();
  await AndroidAlarmManager.initialize();
  NotificationManager notificationManager = NotificationManager();
  var directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  Hive.registerAdapter(TaskAdapter());
  tasksBox = await Hive.openBox<Task>('Tasks');
  List<Task> tasks = tasksBox.values.toList();
  await notificationManager.schedulePeriodicNotification(tasks);
  Hive.registerAdapter(CategoryAdapter());
  categoriesBox = await Hive.openBox<Category>('Categories');
  runApp(
    RootRestorationScope(restorationId: 'myApp', child: MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TaskProvider()),
        ChangeNotifierProvider(create: (context) => CategoryProvider()),
      ],
      child: MyApp(),
    ),)
  );
}



class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with RestorationMixin {
  // Add a RestorationBucket to hold the state for MyApp.
  final RestorableInt _counter = RestorableInt(0);

  @override
  String get restorationId => 'myApp';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    // Register the state to be restored using the restorationId.
    registerForRestoration(_counter, 'counter');
  }

  @override
  void dispose() {
    _counter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RootRestorationScope(
      restorationId: 'root',
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF3AA8C1)),
          useMaterial3: true,
        ),
        home: TaskList(),
      ),
    );
  }
}


// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         title: 'Flutter Demo',
//         theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF3AA8C1)),
//           useMaterial3: true,
//     ),
//     home: TaskList(),
//     );
//   }
// }




