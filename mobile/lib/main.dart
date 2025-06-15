import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rsi_rest/viewModels/EventViewModel.dart';
import 'package:rsi_rest/viewModels/LoginViewModel.dart';
import 'package:rsi_rest/viewModels/RegisterViewModel.dart';
import 'package:rsi_rest/views/Login.dart';
import 'package:rsi_rest/views/ResponsiveLoginPage.dart';
import 'package:intl/date_symbol_data_local.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => EventViewModel()),
        ChangeNotifierProvider(create: (_) => RegisterviewModel()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(411, 707),
        minTextAdapt: true,
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: const LoginPage(),
          );
        },
      ),
    ),
  );
}

