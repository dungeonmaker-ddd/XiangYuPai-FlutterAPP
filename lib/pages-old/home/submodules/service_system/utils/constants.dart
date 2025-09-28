/// 🎯 服务系统常量定义文件
///
/// 包含服务系统模块的所有常量配置

import 'package:flutter/material.dart';

/// 🎨 服务系统常量
class ServiceSystemConstants {
  const ServiceSystemConstants._(); // 私有构造函数，防止实例化
  
  // ========== 颜色配置 ==========
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color backgroundGray = Color(0xFFF9FAFB);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color borderGray = Color(0xFFE5E7EB);
  static const Color starYellow = Color(0xFFFBBF24);
  
  // ========== 尺寸配置 ==========
  static const double cardBorderRadius = 12.0;
  static const double tagBorderRadius = 16.0;
  static const double cardMargin = 16.0;
  static const double cardPadding = 16.0;
  static const double sectionSpacing = 16.0;
  static const double avatarSize = 60.0;
  static const double bannerHeight = 200.0;
  static const double bottomBarHeight = 80.0;
  
  // ========== 动画配置 ==========
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration quickAnimationDuration = Duration(milliseconds: 150);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);
  
  // ========== 业务配置 ==========
  static const int defaultPageSize = 20;
  static const int maxReviewLength = 500;
  static const int passwordLength = 6;
  static const double filterSheetHeight = 0.8;
  static const double ratingStarSize = 32.0;
  
  // ========== 路由配置 ==========
  static const String serviceFilterRoute = '/service_filter';
  static const String serviceDetailRoute = '/service_detail';
  static const String orderConfirmRoute = '/order_confirm';
  static const String paymentFlowRoute = '/payment_flow';
  static const String reviewFeedbackRoute = '/review_feedback';
  
  // ========== 货币单位 ==========
  static const String coinSymbol = '金币';
  static const String currencySymbol = '元';
}

/// 🔤 文字常量
class ServiceSystemTexts {
  const ServiceSystemTexts._();
  
  // 页面标题
  static const String serviceFilterTitle = '服务筛选';
  static const String serviceDetailTitle = '服务详情';
  static const String orderConfirmTitle = '确认订单';
  static const String paymentFlowTitle = '支付';
  static const String reviewFeedbackTitle = '评价反馈';
  
  // 按钮文字
  static const String filterButton = '筛选';
  static const String orderButton = '下单';
  static const String payButton = '支付';
  static const String confirmButton = '确认';
  static const String cancelButton = '取消';
  static const String retryButton = '重试';
  static const String submitButton = '提交';
  static const String completeButton = '完成';
  
  // 状态文字
  static const String loading = '加载中...';
  static const String noData = '暂无数据';
  static const String noMoreData = '没有更多数据';
  static const String networkError = '网络错误，请重试';
  static const String submitSuccess = '提交成功';
  static const String submitFailed = '提交失败';
  
  // 筛选文字
  static const String smartSort = '智能排序';
  static const String qualitySort = '音质排序';
  static const String recentSort = '最近排序';
  static const String popularSort = '人气排序';
  static const String allGender = '不限性别';
  static const String onlyFemale = '只看女生';
  static const String onlyMale = '只看男生';
  static const String online = '在线';
  static const String offline = '离线';
}

/// 📊 服务筛选常量
class ServiceFilterConstants {
  const ServiceFilterConstants._();
  
  // 排序类型
  static const List<String> sortTypes = [
    ServiceSystemTexts.smartSort,
    ServiceSystemTexts.qualitySort,
    ServiceSystemTexts.recentSort,
    ServiceSystemTexts.popularSort,
  ];
  
  // 性别筛选
  static const List<String> genderFilters = [
    ServiceSystemTexts.allGender,
    ServiceSystemTexts.onlyFemale,
    ServiceSystemTexts.onlyMale,
  ];
  
  // 状态筛选
  static const List<String> statusFilters = [
    '不限',
    ServiceSystemTexts.online,
    ServiceSystemTexts.offline,
  ];
  
  // 价格范围
  static const List<String> priceRanges = [
    '不限',
    '4-9元',
    '10-19元',
    '20元以上',
  ];
  
  // 评价标签
  static const List<String> reviewTags = [
    '精选', '声音好听', '技术好', '服务态度好', '性价比高'
  ];
}

/// 💳 支付常量
class PaymentConstants {
  const PaymentConstants._();
  
  // 支付方式配置
  static const List<Map<String, dynamic>> paymentMethods = [
    {
      'method': 'coin',
      'name': '金币支付',
      'icon': 'monetization_on',
      'color': 0xFFFFD700,
      'description': '使用金币余额支付',
      'isDefault': true,
    },
    {
      'method': 'wechat',
      'name': '微信支付',
      'icon': 'chat',
      'color': 0xFF07C160,
      'description': '微信支付',
      'isDefault': false,
    },
    {
      'method': 'alipay',
      'name': '支付宝',
      'icon': 'account_balance_wallet',
      'color': 0xFF1677FF,
      'description': '支付宝',
      'isDefault': false,
    },
    {
      'method': 'apple',
      'name': 'Apple Pay',
      'icon': 'apple',
      'color': 0xFF000000,
      'description': 'Apple Pay',
      'isDefault': false,
    },
  ];
}

/// 📱 响应式设计断点
class ServiceSystemBreakpoints {
  const ServiceSystemBreakpoints._();
  
  static const double mobile = 480.0;
  static const double tablet = 768.0;
  static const double desktop = 1024.0;
}

/// 🎭 动画曲线
class ServiceSystemCurves {
  const ServiceSystemCurves._();
  
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounceIn = Curves.bounceIn;
  static const Curve elasticOut = Curves.elasticOut;
}
