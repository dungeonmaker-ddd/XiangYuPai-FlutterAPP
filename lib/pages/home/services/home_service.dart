/// 🏠 首页服务层
/// 统一管理所有首页相关的数据获取和API调用

import 'dart:convert';
import 'dart:developer' as developer;
import '../models/user_model.dart';
import '../models/store_model.dart';
import '../models/category_model.dart';
import '../config/home_config.dart';

/// 🌐 首页服务接口
abstract class IHomeService {
  /// 获取推荐用户列表
  Future<List<UserModel>> getRecommendedUsers({int page = 1, int limit = 20});
  
  /// 获取附近用户列表
  Future<List<UserModel>> getNearbyUsers({int page = 1, int limit = 20});
  
  /// 获取推荐店铺列表
  Future<List<StoreModel>> getRecommendedStores({int page = 1, int limit = 10});
  
  /// 获取分类列表
  Future<List<CategoryModel>> getCategories();
  
  /// 搜索用户
  Future<List<UserModel>> searchUsers(String keyword, {int page = 1, int limit = 20});
  
  /// 搜索店铺
  Future<List<StoreModel>> searchStores(String keyword, {int page = 1, int limit = 20});
}

/// 🔧 首页服务实现
class HomeService implements IHomeService {
  
  @override
  Future<List<UserModel>> getRecommendedUsers({int page = 1, int limit = 20}) async {
    try {
      // 模拟网络延迟
      await Future.delayed(const Duration(seconds: 1));
      
      if (HomeConfig.useMockData) {
        return _getMockUsers(limit: limit);
      }
      
      // TODO: 实现真实API调用
      throw UnimplementedError('真实API调用尚未实现');
    } catch (e) {
      developer.log('获取推荐用户失败: $e');
      rethrow;
    }
  }

  @override
  Future<List<UserModel>> getNearbyUsers({int page = 1, int limit = 20}) async {
    try {
      // 模拟网络延迟
      await Future.delayed(const Duration(milliseconds: 800));
      
      if (HomeConfig.useMockData) {
        return _getMockUsers(limit: limit, nearby: true);
      }
      
      // TODO: 实现真实API调用
      throw UnimplementedError('真实API调用尚未实现');
    } catch (e) {
      developer.log('获取附近用户失败: $e');
      rethrow;
    }
  }

  @override
  Future<List<StoreModel>> getRecommendedStores({int page = 1, int limit = 10}) async {
    try {
      // 模拟网络延迟
      await Future.delayed(const Duration(milliseconds: 600));
      
      if (HomeConfig.useMockData) {
        return _getMockStores(limit: limit);
      }
      
      // TODO: 实现真实API调用
      throw UnimplementedError('真实API调用尚未实现');
    } catch (e) {
      developer.log('获取推荐店铺失败: $e');
      rethrow;
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      // 模拟网络延迟
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (HomeConfig.useMockData) {
        return CategoryData.getEnabledCategories();
      }
      
      // TODO: 实现真实API调用
      throw UnimplementedError('真实API调用尚未实现');
    } catch (e) {
      developer.log('获取分类列表失败: $e');
      rethrow;
    }
  }

  @override
  Future<List<UserModel>> searchUsers(String keyword, {int page = 1, int limit = 20}) async {
    try {
      // 模拟网络延迟
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (HomeConfig.useMockData) {
        final users = _getMockUsers(limit: 50);
        return users.where((user) => 
          user.nickname.contains(keyword) || 
          user.bio?.contains(keyword) == true ||
          user.tags.any((tag) => tag.contains(keyword))
        ).take(limit).toList();
      }
      
      // TODO: 实现真实API调用
      throw UnimplementedError('真实API调用尚未实现');
    } catch (e) {
      developer.log('搜索用户失败: $e');
      rethrow;
    }
  }

  @override
  Future<List<StoreModel>> searchStores(String keyword, {int page = 1, int limit = 20}) async {
    try {
      // 模拟网络延迟
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (HomeConfig.useMockData) {
        final stores = _getMockStores(limit: 50);
        return stores.where((store) => 
          store.name.contains(keyword) || 
          store.description?.contains(keyword) == true ||
          store.tags.any((tag) => tag.contains(keyword))
        ).take(limit).toList();
      }
      
      // TODO: 实现真实API调用
      throw UnimplementedError('真实API调用尚未实现');
    } catch (e) {
      developer.log('搜索店铺失败: $e');
      rethrow;
    }
  }

  /// 🧪 生成模拟用户数据
  List<UserModel> _getMockUsers({int limit = 20, bool nearby = false}) {
    final List<UserModel> users = [];
    final nicknames = ['小可爱', '游戏高手', '甜心宝贝', '王者玩家', '探店达人', '音乐爱好者', '运动健将', '美食家'];
    final bios = ['这个家伙很神秘，没有留下简介', '爱生活，爱游戏', '寻找有趣的灵魂', '一起来玩游戏吧'];
    final cities = ['深圳', '广州', '北京', '上海', '杭州'];
    final tagsList = [
      ['王者荣耀', '高手'],
      ['探店', '美食'],
      ['K歌', '音乐'],
      ['台球', '运动'],
      ['游戏', '陪玩'],
    ];

    for (int i = 0; i < limit; i++) {
      users.add(UserModel(
        userId: 'user_${i + 1}',
        nickname: '用户名称${(i % nicknames.length) + 1}',
        avatarUrl: null, // 在实际应用中会有头像URL
        gender: (i % 3) + 1,
        age: 18 + (i % 20),
        bio: bios[i % bios.length],
        city: cities[i % cities.length],
        isOnline: i % 3 == 0,
        distance: nearby ? (100 + (i * 50).toDouble()) : (1000 + (i * 200).toDouble()),
        tags: tagsList[i % tagsList.length],
        isVerified: i % 4 == 0,
        lastActiveAt: DateTime.now().subtract(Duration(minutes: i * 5)),
      ));
    }

    return users;
  }

  /// 🧪 生成模拟店铺数据
  List<StoreModel> _getMockStores({int limit = 10}) {
    final List<StoreModel> stores = [];
    final storeNames = ['网咖天地', 'KTV欢乐颂', '台球俱乐部', '按摩养生馆', '私人影院', '游戏竞技馆', '酒吧夜场', '茶餐厅'];
    final descriptions = ['环境优雅，服务贴心', '设备齐全，价格实惠', '专业服务，口碑极佳', '舒适温馨的好去处'];
    final categories = CategoryData.getEnabledCategories();

    for (int i = 0; i < limit; i++) {
      stores.add(StoreModel(
        storeId: 'store_${i + 1}',
        name: storeNames[i % storeNames.length],
        coverUrl: null, // 在实际应用中会有封面URL
        description: descriptions[i % descriptions.length],
        categoryId: categories[i % categories.length].categoryId,
        location: '深圳市南山区',
        distance: (500 + (i * 100).toDouble()),
        rating: 3.5 + (i % 3) * 0.5,
        reviewCount: 10 + (i * 5),
        priceLevel: (i % 4) + 1,
        isOpen: i % 5 != 0,
        businessHours: '09:00-23:00',
        tags: ['热门', '推荐'],
        features: ['WiFi', '停车位'],
        createdAt: DateTime.now().subtract(Duration(days: i)),
        isRecommended: i % 3 == 0,
      ));
    }

    return stores;
  }
}

/// 🏭 首页服务工厂
class HomeServiceFactory {
  static IHomeService? _instance;
  
  /// 获取首页服务实例（单例模式）
  static IHomeService getInstance() {
    return _instance ??= HomeService();
  }
  
  /// 重置实例（主要用于测试）
  static void reset() {
    _instance = null;
  }
}
