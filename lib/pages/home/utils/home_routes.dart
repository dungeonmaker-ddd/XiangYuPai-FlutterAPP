import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/location_picker_page.dart';
import '../models/location_model.dart';

/// 🧭 首页模块路由管理
/// 统一管理所有首页相关页面的路由跳转
class HomeRoutes {
  
  /// 🏠 跳转到首页
  static void toHomePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }
  
  /// 🔍 跳转到搜索页面
  static void toSearchPage(BuildContext context, {String? keyword}) {
    // TODO: 实现搜索页面
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('搜索功能即将上线${keyword != null ? ': $keyword' : ''}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  /// 🏷️ 跳转到分类页面
  static void toCategoryPage(BuildContext context, String categoryId) {
    // TODO: 实现分类页面
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('分类页面即将上线: $categoryId'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  /// 🏪 跳转到店铺详情页面
  static void toStoreDetailPage(BuildContext context, String storeId) {
    // TODO: 实现店铺详情页面
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('店铺详情页面即将上线: $storeId'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  /// 👤 跳转到用户详情页面
  static void toUserProfilePage(BuildContext context, String userId) {
    // TODO: 实现用户详情页面
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('用户详情页面即将上线: $userId'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  /// 📍 跳转到位置选择页面
  static Future<LocationModel?> toLocationPickerPage(
    BuildContext context, {
    LocationModel? selectedLocation,
  }) async {
    return await Navigator.push<LocationModel>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerPage(
          selectedLocation: selectedLocation,
        ),
      ),
    );
  }
  
  /// 🎮 跳转到游戏大厅页面
  static void toGameHallPage(BuildContext context) {
    // TODO: 实现游戏大厅页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('游戏大厅页面即将上线'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  /// 👥 跳转到组队聚会页面
  static void toTeamUpPage(BuildContext context) {
    // TODO: 实现组队聚会页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('组队聚会页面即将上线'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  /// 📋 跳转到附近推荐页面
  static void toNearbyPage(BuildContext context) {
    // TODO: 实现附近推荐页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('附近推荐页面即将上线'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}