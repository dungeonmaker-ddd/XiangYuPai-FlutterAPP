/// 🎯 组局中心常量定义文件
///
/// 包含组局中心模块的所有常量配置

import 'package:flutter/material.dart';

/// 🎨 组局中心常量
class TeamCenterConstants {
  const TeamCenterConstants._(); // 私有构造函数，防止实例化
  
  // ========== 颜色配置 ==========
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color backgroundGray = Color(0xFFF5F5F7);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color borderGray = Color(0xFFE5E7EB);
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);
  
  // ========== 尺寸配置 ==========
  static const double cardBorderRadius = 16.0;
  static const double cardMargin = 16.0;
  static const double cardPadding = 16.0;
  static const double sectionSpacing = 20.0;
  static const double itemSpacing = 12.0;
  static const double avatarSize = 48.0;
  static const double iconSize = 24.0;
  
  // ========== 动画配置 ==========
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration quickAnimationDuration = Duration(milliseconds: 150);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);
  
  // ========== 业务配置 ==========
  static const String pageTitle = '组局中心';
  static const int defaultPageSize = 10;
  static const int maxParticipants = 50;
  static const int minTitleLength = 3;
  static const int maxTitleLength = 30;
  static const int maxContentLength = 200;
  static const double serviceFeeRate = 0.05; // 5%服务费

  // ========== 筛选选项配置 ==========
  // 价格筛选选项
  static const List<String> priceRanges = [
    '100以下',
    '100-200',
    '200-500',
    '500以上',
  ];

  // 距离筛选选项
  static const List<String> distanceRanges = [
    '1km内',
    '3km内',
    '5km内',
    '不限距离',
  ];

  // 时间筛选选项
  static const List<String> timeRanges = [
    '今天',
    '明天',
    '本周内',
    '下周内',
  ];
  
  // ========== 路由配置 ==========
  static const String teamCenterRoute = '/team_center';
  static const String createTeamRoute = '/create_team';
  static const String teamDetailRoute = '/team_detail';
  static const String joinConfirmRoute = '/join_confirm';
  static const String joinStatusRoute = '/join_status';
  
  // ========== 货币单位 ==========
  static const String coinSymbol = '金币';
  static const String currencySymbol = '元';
}

/// 🔤 文字常量
class TeamCenterTexts {
  const TeamCenterTexts._();
  
  // 页面标题
  static const String teamCenterTitle = '组局中心';
  static const String createTeamTitle = '发布组局';
  static const String teamDetailTitle = '组局详情';
  static const String joinConfirmTitle = '确认报名';
  
  // 按钮文字
  static const String createButton = '立即发布';
  static const String joinButton = '立即报名';
  static const String cancelButton = '取消';
  static const String confirmButton = '确认';
  static const String retryButton = '重试';
  
  // 状态文字
  static const String recruiting = '招募中';
  static const String waiting = '等待确认';
  static const String confirmed = '已确认';
  static const String completed = '已完成';
  static const String cancelled = '已取消';
  
  // 提示文字
  static const String loading = '加载中...';
  static const String noData = '暂无数据';
  static const String networkError = '网络错误，请重试';
  static const String submitSuccess = '提交成功';
  static const String submitFailed = '提交失败';
}

/// 📱 响应式设计断点
class TeamCenterBreakpoints {
  const TeamCenterBreakpoints._();
  
  static const double mobile = 480.0;
  static const double tablet = 768.0;
  static const double desktop = 1024.0;
}

/// 🎭 动画曲线
class TeamCenterCurves {
  const TeamCenterCurves._();
  
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounceIn = Curves.bounceIn;
  static const Curve elasticOut = Curves.elasticOut;
}
