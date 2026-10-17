import 'package:flutter/material.dart';

import 'routes/app_router.dart';
import 'theme/app_theme.dart';

class ILocateApp extends StatelessWidget {
  const ILocateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iLOcate',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      initialRoute: AppRoutes.home,
      onGenerateRoute: onGenerateRoute,
    );
  }
}
