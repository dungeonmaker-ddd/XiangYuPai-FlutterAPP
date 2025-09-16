// 🎨 Profile页面布局测试
// 用于验证布局修正效果

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/index.dart';
import 'pages/profile_main_page.dart';

/// 布局测试页面
class ProfileLayoutTestPage extends StatelessWidget {
  const ProfileLayoutTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Layout Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'PingFang SC',
      ),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProfileProvider()),
          ChangeNotifierProvider(create: (_) => TransactionStatsProvider()),
          ChangeNotifierProvider(create: (_) => WalletProvider()),
        ],
        child: const ProfileMainPage(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// 测试应用入口
void main() {
  runApp(const ProfileLayoutTestPage());
}
