/// 🎯 组局中心常量定义文件
/// 
/// 包含组局中心模块的所有常量配置

import 'package:flutter/material.dart';

/// 组局中心常量
class TeamCenterConstants {
  static const String pageTitle = '组局中心';
  static const int defaultPageSize = 10;
  static const double cardBorderRadius = 12.0;
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color backgroundGray = Color(0xFFF5F5F5);
  
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
}

/// UI常量
class TeamCenterUIConstants {
  // 间距
  static const double smallPadding = 8.0;
  static const double mediumPadding = 16.0;
  static const double largePadding = 24.0;
  
  // 圆角
  static const double smallRadius = 8.0;
  static const double mediumRadius = 12.0;
  static const double largeRadius = 16.0;
  
  // 字体大小
  static const double smallFontSize = 12.0;
  static const double mediumFontSize = 14.0;
  static const double largeFontSize = 16.0;
  static const double titleFontSize = 18.0;
}

/// 业务常量
class TeamCenterBusinessConstants {
  // 分页
  static const int maxPageSize = 50;
  static const int minPageSize = 5;
  
  // 价格限制
  static const double minPrice = 0.0;
  static const double maxPrice = 10000.0;
  
  // 距离限制（公里）
  static const double maxDistance = 100.0;
  
  // 时间限制（天）
  static const int maxAdvanceDays = 30;
}
