// 🚀 XiangYuPai Flutter App 主入口文件
// 基于Flutter单文件架构规范的应用程序入口点
// 集成发现模块、集合展示页面与其他主要页面的导航系统

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 项目模块导入
import 'pages/discovery/index.dart'; // 发现模块统一导入
import 'pages/showcase_page_unified.dart'; // 集合展示页面
import 'pages/main_tab_page.dart'; // 主Tab页面（新架构）

/// 🎨 应用程序全局常量
class AppConstants {
  static const String appName = 'XiangYuPai';
  static const Color primaryColor = Color(0xFF8B5CF6);
  static const Color backgroundColor = Color(0xFFF9FAFB);
  
  // 路由名称
  static const String homeRoute = '/';
  static const String discoveryRoute = '/discovery';
  static const String publishRoute = '/publish';
  static const String detailRoute = '/detail';
  static const String showcaseRoute = '/showcase'; // 集合展示页面
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const XiangYuPaiApp());
}

/// 📱 XiangYuPai应用程序主类
class XiangYuPaiApp extends StatelessWidget {
  const XiangYuPaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppConstants.primaryColor,
        colorScheme: ColorScheme.fromSeed(seedColor: AppConstants.primaryColor),
        scaffoldBackgroundColor: AppConstants.backgroundColor,
        useMaterial3: true,
      ),
      initialRoute: AppConstants.showcaseRoute, // 直接进入集合展示页面
      routes: {
        AppConstants.homeRoute: (context) => const MainTabPage(), // 使用新的MainTabPage
        AppConstants.discoveryRoute: (context) => const DiscoveryMainPage(),
        AppConstants.publishRoute: (context) => const PublishContentPage(),
        AppConstants.showcaseRoute: (context) => const ShowcasePageUnified(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == AppConstants.detailRoute) {
          final contentId = settings.arguments as String?;
          if (contentId != null) {
            return MaterialPageRoute(
              builder: (context) => ContentDetailPage(contentId: contentId),
            );
          }
        }
        return null;
      },
    );
  }
}

// 📝 注意：MainTabPage现在在pages/main_tab_page.dart中定义
// 使用IndexedStack架构实现类似Vue的父子组件机制，保持页面状态避免重复加载