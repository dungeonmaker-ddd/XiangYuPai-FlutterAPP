// 🧪 Profile模块测试页面
// 用于单独测试Profile页面功能

import 'package:flutter/material.dart';
import 'index.dart' as profile;

/// 🧪 Profile测试应用
class ProfileTestApp extends StatelessWidget {
  const ProfileTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Test',
      theme: ThemeData(
        primaryColor: const Color(0xFF8B5CF6),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: profile.ProfilePageFactory.createMainPageWithWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// 🚀 启动Profile测试
void main() {
  runApp(const ProfileTestApp());
}
