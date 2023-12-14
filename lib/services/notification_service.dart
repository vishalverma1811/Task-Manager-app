import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../core/models/task_model.dart';


class NotificationManager{
  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    AndroidInitializationSettings initializationSettingsAndroid =
    const AndroidInitializationSettings('credex_logo');

    DarwinInitializationSettings initializationIos =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) {},
    );
    InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationIos);
    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {},
    );
  }
  //
  // Future<void> simpleNotificationShow(String title, String Category, DateTime dueDate) async {
  //   AndroidNotificationDetails androidNotificationDetails =
  //   const AndroidNotificationDetails('Channel_id', 'Channel_title',
  //       priority: Priority.high,
  //       importance: Importance.max,
  //       icon: 'credex_logo',
  //       channelShowBadge: true,
  //       largeIcon: DrawableResourceAndroidBitmap('credex_logo'));
  //
  //   NotificationDetails notificationDetails =
  //   NotificationDetails(android: androidNotificationDetails);
  //   await notificationsPlugin.show(
  //       0,title, Category, notificationDetails);
  // }
//simple notification
  Future<void> simpleNotificationShow(Task task) async {

    AndroidNotificationDetails androidNotificationDetails = const AndroidNotificationDetails(
      'Channel_id',
      'Channel_title',
      priority: Priority.high,
      importance: Importance.max,
      icon: 'credex_logo',
      channelShowBadge: true,
      largeIcon: DrawableResourceAndroidBitmap('credex_logo'),
    );

    NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

    DateTime duedate = task.dueDate;
    String date = duedate.toString();
    String notificationTitle = task.title;
    String notificationBody = 'Category:'+task.category + '\nDue Date:' + date;

    await notificationsPlugin.show(0, notificationTitle, notificationBody, notificationDetails);
  }

//big notification
  Future<void> bigPictureNotificationShow() async {
    BigPictureStyleInformation bigPictureStyleInformation =
    const BigPictureStyleInformation(
        DrawableResourceAndroidBitmap('credex_logo'),
        contentTitle: 'Code Compilee',
        largeIcon: DrawableResourceAndroidBitmap('credex_logo'));

    AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails('big_picture_id', 'big_picture_title',
        priority: Priority.high,
        importance: Importance.max,
        styleInformation: bigPictureStyleInformation);

    NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
    await notificationsPlugin.show(
        1, 'Big Picture Notification', 'New Message', notificationDetails);
  }

//multiple notification
  Future<void> multipleTaskNotifications(List<Task> tasks) async {
    AndroidNotificationDetails androidNotificationDetails =
    const AndroidNotificationDetails(
      'Channel_id',
      'Channel_title',
      priority: Priority.high,
      importance: Importance.max,
      groupKey: 'taskMessages',
    );

    NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);

    for (int i = 0; i < tasks.length; i++) {
      Task task = tasks[i];
      await Future.delayed(
        Duration(milliseconds: i * 1000),
            () {
          simpleNotificationShow(task);
        },
      );
    }

    List<String> lines = tasks.map((task) => task.title).toList();

    InboxStyleInformation inboxStyleInformation = InboxStyleInformation(
      lines,
      contentTitle: '${lines.length} tasks due',
      summaryText: 'Task Notification',
    );

    AndroidNotificationDetails androidNotificationSpecific =
    AndroidNotificationDetails(
      'groupChannelId',
      'groupChannelTitle',
      styleInformation: inboxStyleInformation,
      groupKey: 'taskMessages',
      setAsGroupSummary: true,
    );

    NotificationDetails platformChannelSpecific =
    NotificationDetails(android: androidNotificationSpecific);

    await Future.delayed(
      Duration(hours: 4),
          () async {
            await notificationsPlugin.show(
              tasks.length + 1,
              'Task Notifications',
              '${lines.length} tasks due',
              platformChannelSpecific,
            );
      },
    );
  }



  // Future<void> multipleNotificationShow() async {
  //   AndroidNotificationDetails androidNotificationDetails =
  //   const AndroidNotificationDetails('Channel_id', 'Channel_title',
  //       priority: Priority.high,
  //       importance: Importance.max,
  //       groupKey: 'commonMessage');
  //
  //   NotificationDetails notificationDetails =
  //   NotificationDetails(android: androidNotificationDetails);
  //   notificationsPlugin.show(
  //       0, 'New Notification', 'User 1 send message', notificationDetails);
  //
  //   Future.delayed(
  //     const Duration(milliseconds: 1000),
  //         () {
  //       notificationsPlugin.show(
  //           1, 'New Notification', 'User 2 send message', notificationDetails);
  //     },
  //   );
  //
  //   Future.delayed(
  //     const Duration(milliseconds: 1500),
  //         () {
  //       notificationsPlugin.show(
  //           2, 'New Notification', 'User 3 send message', notificationDetails);
  //     },
  //   );
  //
  //   List<String> lines = ['user1', 'user2', 'user3'];
  //
  //   InboxStyleInformation inboxStyleInformation =
  //   InboxStyleInformation(lines, contentTitle: '${lines.length} messages',summaryText: 'Code Compilee');
  //
  //   AndroidNotificationDetails androidNotificationSpesific=AndroidNotificationDetails(
  //       'groupChennelId',
  //       'groupChennelTitle',
  //       styleInformation: inboxStyleInformation,
  //       groupKey: 'commonMessage',
  //       setAsGroupSummary: true
  //   );
  //   NotificationDetails platformChannelSpe=NotificationDetails(android: androidNotificationSpesific);
  //   await notificationsPlugin.show(3, 'Attention', '${lines.length} messages', platformChannelSpe);
  // }

  // Future<void> scheduleNotification(String title, String body, DateTime scheduledDate) async {
  //   AndroidNotificationDetails androidNotificationDetails = const AndroidNotificationDetails(
  //     'Channel_id',
  //     'Channel_title',
  //     priority: Priority.high,
  //     importance: Importance.max,
  //     icon: 'credex_logo',
  //     channelShowBadge: true,
  //     largeIcon: DrawableResourceAndroidBitmap('credex_logo'),
  //   );
  //
  //   NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
  //
  //   await notificationsPlugin.zonedSchedule(
  //     0,
  //     title,
  //     body,
  //     tz.TZDateTime.from(scheduledDate, tz.local),
  //     notificationDetails,
  //     androidAllowWhileIdle: true,
  //     uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
  //   );
  // }
  Future<void> schedulePeriodicNotification(List<Task> tasks) async {
    DateTime currentDate = DateTime.now();
    List<Task> todayTasks = tasks.where((task) {
      return task.dueDate.year == currentDate.year &&
          task.dueDate.month == currentDate.month &&
          task.dueDate.day == currentDate.day &&
          task.category != 'Completed';

    }).toList();

    multipleTaskNotifications(todayTasks);
    // for (Task task in todayTasks) {
    //   await simpleNotificationShow(task);
    // }
  }

  // Future<void> scheduleTaskNotification(Task task) async {
  //   //String uniqueId = '${task.title}_${task.dueDate.toString()}';
  //   int randomAlarmId = Random().nextInt(pow(2, 31).toInt());
  //
  //   await AndroidAlarmManager.periodic(
  //     const Duration(hours: 1),
  //     randomAlarmId,
  //     _showTaskNotification(task, randomAlarmId) as Function,
  //     startAt: DateTime.now(),
  //     exact: true,
  //     wakeup: true,
  //   );
  // }
  //
  // void _showTaskNotification(Task task, int randomAlarmId) {
  //   NotificationManager().simpleNotificationShow(task.title, task.category, task.dueDate);
  // }
}