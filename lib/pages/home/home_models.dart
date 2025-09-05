// 🏠 首页共享数据模型 - 8段式结构
// 所有首页相关的数据模型定义

// ============== 1. IMPORTS ==============
import 'package:flutter/material.dart';
import 'dart:convert';

// ============== 2. CONSTANTS ==============
/// 🎨 首页常量配置
class HomeConstants {
  // UI尺寸配置
  static const double cardBorderRadius = 12.0;
  static const double itemSpacing = 16.0;
  static const double categoryItemHeight = 80.0;
  static const int categoryGridColumns = 5;
  
  // 分页配置
  static const int defaultPageSize = 20;
  static const int recommendedUserLimit = 10;
  static const double loadMoreThreshold = 200.0;
  
  // 动画时长
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration refreshTimeout = Duration(seconds: 30);
  
  // 颜色配置
  static const int homeBackgroundColor = 0xFFF5F5F5;
  static const int primaryPurple = 0xFF9C27B0;
  static const int gradientStartColor = 0xFF8E24AA;
  static const int gradientEndColor = 0xFF7B1FA2;
  static const int searchBarColor = 0xFFE8E8E8;
  static const int cardBackgroundColor = 0xFFFFFFFF;
  static const int textPrimaryColor = 0xFF212121;
  static const int textSecondaryColor = 0xFF757575;
  
  // 默认值
  static const String defaultLocationText = '深圳';
  static const String defaultSearchHint = '搜索词';
  static const bool useMockData = true;
}

// ============== 3. MODELS ==============
/// 👤 用户数据模型
class HomeUserModel {
  final String userId;
  final String nickname;
  final String? avatarUrl;
  final int gender; // 0: 未知, 1: 男, 2: 女
  final int? age;
  final String? bio;
  final String? city;
  final bool isOnline;
  final double? distance;
  final List<String> tags;
  final bool isVerified;
  final DateTime? lastActiveAt;

  const HomeUserModel({
    required this.userId,
    required this.nickname,
    this.avatarUrl,
    this.gender = 0,
    this.age,
    this.bio,
    this.city,
    this.isOnline = false,
    this.distance,
    this.tags = const [],
    this.isVerified = false,
    this.lastActiveAt,
  });

  String get genderText {
    switch (gender) {
      case 1: return '男';
      case 2: return '女';
      default: return '未知';
    }
  }

  String get distanceText {
    if (distance == null) return '';
    if (distance! < 1000) {
      return '${distance!.toInt()}m';
    } else {
      return '${(distance! / 1000).toStringAsFixed(1)}km';
    }
  }

  String get lastActiveText {
    if (lastActiveAt == null) return '很久以前';
    final now = DateTime.now();
    final diff = now.difference(lastActiveAt!);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '很久以前';
  }
}

/// 🏷️ 分类数据模型
class HomeCategoryModel {
  final String categoryId;
  final String name;
  final IconData icon;
  final int color;
  final int sortOrder;
  final bool isEnabled;

  const HomeCategoryModel({
    required this.categoryId,
    required this.name,
    required this.icon,
    required this.color,
    this.sortOrder = 0,
    this.isEnabled = true,
  });
}

/// 📍 位置数据模型
class HomeLocationModel {
  final String locationId;
  final String name;
  final bool isHot;

  const HomeLocationModel({
    required this.locationId,
    required this.name,
    this.isHot = false,
  });
}

/// 🌍 地区选择数据模型
class LocationRegionModel {
  final String regionId;
  final String name;
  final String pinyin;
  final String firstLetter;
  final bool isHot;
  final bool isCurrent;
  final DateTime? lastVisited;

  const LocationRegionModel({
    required this.regionId,
    required this.name,
    required this.pinyin,
    required this.firstLetter,
    this.isHot = false,
    this.isCurrent = false,
    this.lastVisited,
  });

  LocationRegionModel copyWith({
    String? regionId,
    String? name,
    String? pinyin,
    String? firstLetter,
    bool? isHot,
    bool? isCurrent,
    DateTime? lastVisited,
  }) {
    return LocationRegionModel(
      regionId: regionId ?? this.regionId,
      name: name ?? this.name,
      pinyin: pinyin ?? this.pinyin,
      firstLetter: firstLetter ?? this.firstLetter,
      isHot: isHot ?? this.isHot,
      isCurrent: isCurrent ?? this.isCurrent,
      lastVisited: lastVisited ?? this.lastVisited,
    );
  }
}

/// 📊 首页状态模型
class HomeState {
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final HomeLocationModel? currentLocation;
  final List<HomeCategoryModel> categories;
  final List<HomeUserModel> recommendedUsers;
  final List<HomeUserModel> nearbyUsers;
  final int currentPage;
  final bool hasMoreData;
  final String selectedTab; // 当前选中的筛选标签
  final DateTime? promoEndTime; // 限时专享结束时间
  final Map<String, dynamic>? filterCriteria; // 筛选条件（简化版）

  const HomeState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.currentLocation,
    this.categories = const [],
    this.recommendedUsers = const [],
    this.nearbyUsers = const [],
    this.currentPage = 1,
    this.hasMoreData = true,
    this.selectedTab = '附近',
    this.promoEndTime,
    this.filterCriteria,
  });

  HomeState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    HomeLocationModel? currentLocation,
    List<HomeCategoryModel>? categories,
    List<HomeUserModel>? recommendedUsers,
    List<HomeUserModel>? nearbyUsers,
    int? currentPage,
    bool? hasMoreData,
    String? selectedTab,
    DateTime? promoEndTime,
    Map<String, dynamic>? filterCriteria,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
      currentLocation: currentLocation ?? this.currentLocation,
      categories: categories ?? this.categories,
      recommendedUsers: recommendedUsers ?? this.recommendedUsers,
      nearbyUsers: nearbyUsers ?? this.nearbyUsers,
      currentPage: currentPage ?? this.currentPage,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      selectedTab: selectedTab ?? this.selectedTab,
      promoEndTime: promoEndTime ?? this.promoEndTime,
      filterCriteria: filterCriteria ?? this.filterCriteria,
    );
  }
}

/// 📋 地区选择状态模型
class LocationPickerState {
  final bool isLoading;
  final String? errorMessage;
  final LocationRegionModel? currentLocation;
  final List<LocationRegionModel> recentLocations;
  final List<LocationRegionModel> hotCities;
  final Map<String, List<LocationRegionModel>> regionsByLetter;
  final String? searchKeyword;
  final List<LocationRegionModel> searchResults;

  const LocationPickerState({
    this.isLoading = false,
    this.errorMessage,
    this.currentLocation,
    this.recentLocations = const [],
    this.hotCities = const [],
    this.regionsByLetter = const {},
    this.searchKeyword,
    this.searchResults = const [],
  });

  LocationPickerState copyWith({
    bool? isLoading,
    String? errorMessage,
    LocationRegionModel? currentLocation,
    List<LocationRegionModel>? recentLocations,
    List<LocationRegionModel>? hotCities,
    Map<String, List<LocationRegionModel>>? regionsByLetter,
    String? searchKeyword,
    List<LocationRegionModel>? searchResults,
  }) {
    return LocationPickerState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentLocation: currentLocation ?? this.currentLocation,
      recentLocations: recentLocations ?? this.recentLocations,
      hotCities: hotCities ?? this.hotCities,
      regionsByLetter: regionsByLetter ?? this.regionsByLetter,
      searchKeyword: searchKeyword ?? this.searchKeyword,
      searchResults: searchResults ?? this.searchResults,
    );
  }
}

// ============== 4. SERVICES ==============
// 服务接口定义，具体实现在 home_services.dart

// ============== 5. CONTROLLERS ==============
// 控制器在各自页面文件中定义

// ============== 6. WIDGETS ==============
// UI组件在各自页面文件中定义

// ============== 7. PAGES ==============
// 页面在各自文件中定义

// ============== 8. EXPORTS ==============
// 导出所有模型供其他文件使用
// 无需显式导出，Dart会自动导出公共类
