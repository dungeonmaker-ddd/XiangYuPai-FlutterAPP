// 🎯 发布组局页面 - 基于架构设计文档的完整实现
// 实现6种活动类型选择、完整表单验证、约定项配置、支付确认流程

// ============== 1. IMPORTS ==============
// Flutter核心库
import 'package:flutter/material.dart';

// 项目内部文件
import 'create_team_page_enhanced.dart'; // 增强版页面实现

// ============== 2. CONSTANTS ==============
/// 🎨 发布组局页面常量（兼容性保持）
class _CreateTeamPageConstants {
  const _CreateTeamPageConstants._();
  
  static const String pageTitle = '发布组局';
  static const String routeName = '/create_team';
}

// ============== 3. PAGES ==============
/// 📱 发布组局页面 - 重定向到增强版实现
/// 
/// 这个类保持与现有代码的兼容性，同时使用增强版的功能实现
class CreateTeamPage extends StatelessWidget {
  const CreateTeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 直接使用增强版的发布页面
    return const CreateTeamPageEnhanced();
  }
}

// ============== 8. EXPORTS ==============
/// 📤 导出定义
/// 
/// 本文件自动导出的公共类：
/// - CreateTeamPage: 发布组局页面（public class）
///
/// 使用方式：
/// ```dart
/// import 'create_team_page.dart';
/// 
/// // 在路由中使用
/// MaterialPageRoute(builder: (context) => const CreateTeamPage())
/// ```
