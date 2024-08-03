import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'Home-pages/home.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'Settings/notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Always initialize Awesome Notifications
  await NotificationController.initializeLocalNotifications();
  await NotificationController.initializeIsolateReceivePort();
  runApp(const MyApp());
  // Start listening for notification events
  NotificationController.startListeningNotificationEvents();
}
///  *********************************************
///     NOTIFICATION CONTROLLER
///  *********************************************
///
class NotificationController {
  static ReceivedAction? initialAction;
  ///  *********************************************
  ///     INITIALIZATIONS
  ///  *********************************************
  ///
  static Future<void> initializeLocalNotifications() async {
    try {
      await AwesomeNotifications().initialize(
          null, //'resource://drawable/res_app_icon',//
          [
            NotificationChannel(
                channelKey: 'alerts',
                channelName: 'Alerts',
                channelDescription: 'Notification tests as alerts',
                playSound: true,
                onlyAlertOnce: true,
                groupAlertBehavior: GroupAlertBehavior.Children,
                importance: NotificationImportance.High,
                defaultPrivacy: NotificationPrivacy.Private,
                defaultColor: Colors.deepPurple,
                ledColor: Colors.deepPurple)
          ],
          debug: true);
      // Get initial notification action is optional
      initialAction = await AwesomeNotifications()
          .getInitialNotificationAction(removeFromActionEvents: false);
    } catch (e) {
      print("Error initializing notifications: $e");
    }
  }
  static ReceivePort? receivePort;
  static Future<void> initializeIsolateReceivePort() async {
    receivePort = ReceivePort('Notification action port in main isolate')
      ..listen(
              (silentData) => onActionReceivedImplementationMethod(silentData));
    // This initialization only happens on main isolate
    IsolateNameServer.registerPortWithName(
        receivePort!.sendPort, 'notification_action_port');
  }
  ///  *********************************************
  ///     NOTIFICATION EVENTS LISTENER
  ///  *********************************************
  ///  Notifications events are only delivered after call this method
  static Future<void> startListeningNotificationEvents() async {
    AwesomeNotifications()
        .setListeners(onActionReceivedMethod: onActionReceivedMethod);
  }
  ///  *********************************************
  ///     NOTIFICATION EVENTS
  ///  *********************************************
  ///
  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (receivedAction.actionType == ActionType.SilentAction ||
        receivedAction.actionType == ActionType.SilentBackgroundAction) {
      // For background actions, you must hold the execution until the end
      print(
          'Message sent via notification input: "${receivedAction.buttonKeyInput}"');
      // await executeLongTaskInBackground();
    } else {
      // this process is only necessary when you need to redirect the user
      // to a new page or use a valid context, since parallel isolates do not
      // have valid context, so you need redirect the execution to main isolate
      if (receivePort == null) {
        print(
            'onActionReceivedMethod was called inside a parallel dart isolate.');
        SendPort? sendPort =
        IsolateNameServer.lookupPortByName('notification_action_port');
        if (sendPort != null) {
          print('Redirecting the execution to main isolate process.');
          sendPort.send(receivedAction);
          return;
        }
      }
      return onActionReceivedImplementationMethod(receivedAction);
    }
  }
  static Future<void> onActionReceivedImplementationMethod(
      ReceivedAction receivedAction) async {
    MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/notification',
            (route) =>
        (route.settings.name != '/notification') || route.isFirst,
        arguments: receivedAction);
  }
  ///  *********************************************
  ///     REQUESTING NOTIFICATION PERMISSIONS
  ///  *********************************************
  ///
  static Future<bool> displayNotificationRationale() async {
    bool userAuthorized = false;
    BuildContext context = MyApp.navigatorKey.currentContext!;
    await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('Get Notified!',
                style: Theme.of(context).textTheme.titleLarge),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Image.asset(
                        'assets/animated-bell.png',
                        height: MediaQuery.of(context).size.height * 0.3,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                    'Allow Masery Shopping Notifications to send you beautiful notifications!'),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'Deny',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.red),
                  )),
              TextButton(
                  onPressed: () async {
                    userAuthorized = true;
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'Allow',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.deepPurple),
                  )),
            ],
          );
        });
    return userAuthorized &&
        await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  // ///  *********************************************
  // ///     BACKGROUND TASKS TEST
  // ///  *********************************************
  // static Future<void> executeLongTaskInBackground() async {
  //   print("starting long task");
  //   await Future.delayed(const Duration(seconds: 4));
  //   final url = Uri.parse("http://google.com");
  //   final re = await http.get(url);
  //   print(re.body);
  //   print("long task done");
  // }

  ///  *********************************************
  ///     NOTIFICATION CREATION METHODS
  ///  *********************************************
  ///
  static Future<void> createNewNotification(String title, String body,id) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) isAllowed = await displayNotificationRationale();
    if (!isAllowed) return;
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: -1, // -1 is replaced by a random number
          channelKey: 'alerts',
          title: title,
          body: body,
          notificationLayout: NotificationLayout.BigPicture,
          payload: {'notificationId': '1234567890'}),
    );
    String ipAddress = await getLocalIpAddress();
    //print("IP Address: $ipAddress");
    NotificationRecivedAction(ipAddress,id);
  }
  static Future<void> cancelNotifications() async {
    await AwesomeNotifications().cancelAll();
  }
  static Future<String> getLocalIpAddress() async {
    try {
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4) {
            print('local_ip');
            print(addr.address);
            return addr.address;
          }
        }
      }
      return 'No IPv4 address found';
    } catch (e) {
      return 'Error: $e';
    }
  }
  static Future<void> NotificationRecivedAction(ipAddress,id) async {
    print('true');
    final url = 'https://sgitjobs.com/MaseryShoppingNew/public/api/updatenotification/$ipAddress';
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept':'application/json'
      },
      body: jsonEncode({
        'ip_address': ipAddress,
        'id': id,
      }),
    );
    print('ipAddress');
    print(ipAddress);
    print(response.body);
    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON.
      print('Response body: ${response.body}');
    } else {
      // If the server did not return a 200 OK response, throw an exception.
      print('Failed to update notification. Status code: ${response.statusCode}');
    }
  }
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});
  // The navigator key is necessary to navigate using static methods
  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();
  static Color mainColor = const Color(0xFF9D50DD);
  @override
  State<MyApp> createState() => _AppState();
}
class _AppState extends State<MyApp> {
  // This widget is the root of your application.
  Timer? _timer;
  static const String routeHome = '/', routeNotification = '/notification';
  @override
  initState() {
    //fetchAndNotify();
    super.initState();
    _checkAndStoreIpAddress();
    //fetchAndNotify();
    _timer = Timer.periodic(Duration(seconds: 4), (Timer t) => fetchAndNotify());
  }
  // @override
  // void dispose() {
  //   // Cancel the timer when the widget is disposed
  //   _timer?.cancel();
  //   super.dispose();
  // }
  List<Route<dynamic>> onGenerateInitialRoutes(String initialRouteName) {
    List<Route<dynamic>> pageStack = [];
    pageStack.add(MaterialPageRoute(
        builder: (_) => const HomePage()));
    if (initialRouteName == routeNotification &&
        NotificationController.initialAction != null) {
      pageStack.add(MaterialPageRoute(
          builder: (_) => NotificationPage(
              receivedAction: NotificationController.initialAction!)));
    }
    return pageStack;
  }
  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case routeHome:
        return MaterialPageRoute(
            builder: (_) => const HomePage());
      case routeNotification:
        ReceivedAction receivedAction = settings.arguments as ReceivedAction;
        return MaterialPageRoute(
            builder: (_) => NotificationPage(receivedAction: receivedAction));
    }
    return null;
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Masery Shop',
      navigatorKey: MyApp.navigatorKey,
      onGenerateInitialRoutes: onGenerateInitialRoutes,
      onGenerateRoute: onGenerateRoute,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
    );
  }
  Future<void> fetchAndNotify() async {
    String ipAddress = await getLocalIpAddress();
    final url = 'https://sgitjobs.com/MaseryShoppingNew/public/api/recentnotification';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      print(response.body);
      final responseData = jsonDecode(response.body);

      if (responseData['success'] != false) {
        if (responseData.containsKey('data') && responseData['data'] != null) {
          final data = responseData['data'];

          // Check if 'data' is a List
          if (data is List) {
            for (var item in data) {
              if (item.containsKey('title') && item.containsKey('message')) {
                final title = item['title'];
                final body = item['message'];
                final id = item['id'];
                final ip_address = item['ip_address'];

                if (ipAddress == ip_address) {
                  NotificationController.createNewNotification(title, body, id);
                }
              } else {
                print('Notification data does not contain title and/or message');
              }
            }
          }
          // Check if 'data' is a Map (in case only one notification is returned)
          else if (data is Map) {
            if (data.containsKey('title') && data.containsKey('message')) {
              final title = data['title'];
              final body = data['message'];
              final id = data['id'];
              final ip_address = data['ip_address'];

              if (ipAddress == ip_address) {
                NotificationController.createNewNotification(title, body, id);
              }
            } else {
              print('Notification data does not contain title and/or message');
            }
          } else {
            print('Unexpected data format');
          }
        } else {
          print('No notification data found');
        }
      } else {
        print('No notifications found');
      }
    } else {
      print('Failed to fetch notifications');
    }
  }

  static Future<void> getIpAddress() async {
    try {
      String ipAddress = 'No IPv4 address found';
      bool found = false;
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4) {
            ipAddress = addr.address;
            found = true;
            break;
          }
        }
        if (found) break;
      }
      if (!found) {
        print('No IPv4 address found');
        return;
      }
      // Send the IP address to the server
      try {
        final response = await http.post(
          Uri.parse('https://sgitjobs.com/MaseryShoppingNew/public/api/store/temp/users'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'ip_address': ipAddress,
          }),
        );

        print(response.body);
        if (response.statusCode == 200) {
          print('IP address saved successfully');
        } else {
          print('Failed to save IP address');
        }
      } catch (e) {
        print('Error: $e');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
  Future<void> _checkAndStoreIpAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isIpAddressStored = prefs.getBool('isIpAddressStored');

    if (isIpAddressStored == null || !isIpAddressStored) {
      await getIpAddress();
      prefs.setBool('isIpAddressStored', true);
    }
  }
  static Future<String> getLocalIpAddress() async {
    try {
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4) {
            return addr.address;
          }
        }
      }
      return 'No IPv4 address found';
    } catch (e) {
      return 'Error: $e';
    }
  }
}
