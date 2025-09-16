// 🎭 我的页面演示
// 展示完整的Profile模块功能

import 'package:flutter/material.dart';
import 'profile/index.dart' as profile;

/// 🎭 我的页面演示页面
class ProfileDemoPage extends StatelessWidget {
  const ProfileDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的页面演示'),
        backgroundColor: const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: profile.ProfilePageFactory.createMainPageWithWrapper(),
    );
  }
}

/// 🚀 演示应用
class ProfileDemoApp extends StatelessWidget {
  const ProfileDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '享语拍 - 我的页面',
      theme: ThemeData(
        primarySwatch: _createMaterialColor(const Color(0xFF8B5CF6)),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'PingFang SC',
      ),
      home: const ProfileDemoPage(),
      debugShowCheckedModeBanner: false,
    );
  }

  /// 创建MaterialColor
  MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}
