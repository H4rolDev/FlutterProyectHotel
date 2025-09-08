import 'package:flutter/material.dart';
import 'package:hospedaje_f1/src/auth/screens/login_screen.dart';
import 'package:hospedaje_f1/src/cleaning/models/cleaning.dart';
import 'package:hospedaje_f1/src/cleaning/screens/cleaning_tips_screen.dart';
import 'package:hospedaje_f1/src/home/screens/home_screen.dart';
import 'package:hospedaje_f1/src/cleaning/screens/room_list_screen.dart';
import 'package:hospedaje_f1/src/cleaning/screens/cleaning_start_screen.dart'; 
import 'package:hospedaje_f1/src/cleaning/screens/cleaning_progress_screen.dart'; 
import 'package:hospedaje_f1/src/cleaning/screens/cleaning_history_screen.dart';
import 'package:hospedaje_f1/src/cleaning/screens/cleaning_history_view_screen.dart';
import 'package:hospedaje_f1/src/auth/screens/profile_screen.dart';
import 'package:hospedaje_f1/src/auth/screens/register_employee_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String roomList = '/room-list';
  static const String cleaningStart = '/cleaning-start';
  static const String cleaningProgress = '/cleaning-progress';
  static const String cleaningHistory = '/cleaning-history';
  static const String cleaningTips = '/cleaning-tips';
  static const String cleaningHistoryView = '/cleaning-history-view';
  static const String profile = '/profile';
  static const String registerEmployeeScreen='/register-employee';
  static const String chatbot = '/chatbot';
  static const String improvedRoomList = '/improved-room-list';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => LoginScreen(),
    home: (context) => HomeScreen(),
    roomList: (context) => RoomListScreen(),
    // Ahora pasamos roomId como parámetro directamente
    cleaningStart: (context) {
      final roomId = ModalRoute.of(context)!.settings.arguments as int;
      return CleaningStartScreen(roomId: roomId); // Pasamos roomId
    },
    cleaningProgress: (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, int>;
      final cleaningId = args['cleaningId']!;
      final roomId = args['roomId']!;
      return CleaningProgressScreen(
          cleaningId: cleaningId,
          roomId: roomId); // Pasamos ambos cleaningId y roomId
    },
    cleaningHistory: (context) => CleaningHistoryScreen(),
    cleaningHistoryView: (context) => CleaningHistoryViewScreen(),
    profile: (context) => ProfileScreen(),
    // registerEmployeeScreen : (context) => RegisterEmployeeScreen(),
    cleaningTips: (context) => CleaningTipsScreen(),
  };
}
