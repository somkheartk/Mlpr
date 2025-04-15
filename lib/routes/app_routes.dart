import 'package:flutter/material.dart';
import 'package:mlpr/screens/capture_screen.dart';
import 'package:mlpr/screens/home_screen.dart';
import 'package:mlpr/screens/login_screen.dart';
import 'package:mlpr/screens/settings_screen.dart';

class AppRoutes {
  static const String login = '/';
  static const String home = '/home';
  static const String capture = '/capture';
  static const String settings = '/settings';

  static final Map<String, WidgetBuilder> routes = {
    login: (context) => LoginScreen(),
    home: (context) => HomeScreen(),
    capture: (context) => CaptureScreen(),
    settings: (context) => SettingsScreen(),
  };
}
