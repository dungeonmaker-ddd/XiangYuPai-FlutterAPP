/// 🏠 首页模块配置
/// 管理首页相关的配置项

enum HomeDisplayMode {
  grid,
  list,
  card,
}

class HomeConfig {
  // 分类网格配置
  static const int categoryGridColumns = 5;
  static const double categoryItemHeight = 80.0;
  static const double categoryItemSpacing = 16.0;
  
  // 推荐卡片配置
  static const double recommendationCardHeight = 180.0;
  static const double recommendationCardSpacing = 12.0;
  static const int maxRecommendationItems = 10;
  
  // 搜索配置
  static const String defaultSearchHint = '搜索词';
  static const int maxSearchHistory = 10;
  static const Duration searchDebounceTime = Duration(milliseconds: 500);
  
  // 刷新配置
  static const Duration refreshTimeout = Duration(seconds: 30);
  static const Duration loadMoreTimeout = Duration(seconds: 15);
  
  // 用户位置
  static const String defaultLocationText = '深圳';
  static const double locationButtonHeight = 32.0;
  
  // UI颜色配置 - 根据设计图优化
  static const homeBackgroundColor = 0xFFF5F5F5; // 浅灰背景
  static const primaryPurple = 0xFF9C27B0; // 主紫色
  static const gradientStartColor = 0xFF8E24AA; // 渐变起始色
  static const gradientEndColor = 0xFF7B1FA2; // 渐变结束色
  static const searchBarColor = 0xFFE8E8E8; // 搜索栏背景
  static const cardBackgroundColor = 0xFFFFFFFF; // 卡片背景
  static const textPrimaryColor = 0xFF212121; // 主要文本色
  static const textSecondaryColor = 0xFF757575; // 次要文本色
  static const dividerColor = 0xFFE0E0E0; // 分割线颜色
  
  // 默认显示模式
  static const HomeDisplayMode defaultDisplayMode = HomeDisplayMode.card;
  
  // 是否启用调试模式
  static const bool enableDebugMode = true;
  static const bool useMockData = true; // 使用模拟数据
  
  /// 获取分类图标映射
  static const Map<String, String> categoryIcons = {
    '王者荣耀': '👑',
    '英雄联盟': '⚔️',
    '和平精英': '🎯',
    '荒野乱斗': '💥',
    '探店': '🏪',
    '私影': '📸',
    '台球': '🎱',
    'K歌': '🎤',
    '喝酒': '🍻',
    '按摩': '💆',
  };
  
  /// 获取分类颜色映射
  static const Map<String, int> categoryColors = {
    '王者荣耀': 0xFFFF6B35,
    '英雄联盟': 0xFF4A90E2,
    '和平精英': 0xFF50C878,
    '荒野乱斗': 0xFFFFD700,
    '探店': 0xFF9C27B0,
    '私影': 0xFFE91E63,
    '台球': 0xFF2E7D32,
    'K歌': 0xFFFF5722,
    '喝酒': 0xFFFFC107,
    '按摩': 0xFF795548,
  };
}
