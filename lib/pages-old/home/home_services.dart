// 🌐 首页共享服务层 - 8段式结构
// 所有首页相关的业务逻辑和数据服务

// ============== 1. IMPORTS ==============
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:developer' as developer;
import 'home_models.dart';

// ============== 2. CONSTANTS ==============
// 常量在 home_models.dart 中定义

// ============== 3. MODELS ==============
// 模型在 home_models.dart 中定义

// ============== 4. SERVICES ==============
/// 🌐 首页数据服务
class HomeService {
  /// 获取分类数据（2行5列功能网格）
  static Future<List<HomeCategoryModel>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return const [
      // 第一行功能图标（游戏类服务）
      HomeCategoryModel(
        categoryId: 'wangzhe',
        name: '王者荣耀',
        icon: Icons.videogame_asset,
        color: 0xFFFF6B35, // 橙红色（王者主色）
        sortOrder: 1,
      ),
      HomeCategoryModel(
        categoryId: 'lol',
        name: '英雄联盟',
        icon: Icons.shield,
        color: 0xFF1E90FF, // 蓝色（LOL主色）
        sortOrder: 2,
      ),
      HomeCategoryModel(
        categoryId: 'heping',
        name: '和平精英',
        icon: Icons.gps_fixed,
        color: 0xFFFFD700, // 金色
        sortOrder: 3,
      ),
      HomeCategoryModel(
        categoryId: 'huangye',
        name: '荒野乱斗',
        icon: Icons.whatshot,
        color: 0xFFFFA500, // 黄色
        sortOrder: 4,
      ),
      HomeCategoryModel(
        categoryId: 'tandian',
        name: '探店',
        icon: Icons.store,
        color: 0xFFFF7043, // 橙色系
        sortOrder: 5,
      ),
      
      // 第二行功能图标（娱乐与生活类）
      HomeCategoryModel(
        categoryId: 'siying',
        name: '私影',
        icon: Icons.movie,
        color: 0xFFE91E63, // 粉色
        sortOrder: 6,
      ),
      HomeCategoryModel(
        categoryId: 'taiqiu',
        name: '台球',
        icon: Icons.sports_baseball,
        color: 0xFF8BC34A, // 绿色
        sortOrder: 7,
      ),
      HomeCategoryModel(
        categoryId: 'kge',
        name: 'K歌',
        icon: Icons.mic,
        color: 0xFFFF9800, // 橙色
        sortOrder: 8,
      ),
      HomeCategoryModel(
        categoryId: 'hejiu',
        name: '喝酒',
        icon: Icons.local_bar,
        color: 0xFF4CAF50, // 绿色
        sortOrder: 9,
      ),
      HomeCategoryModel(
        categoryId: 'anmo',
        name: '按摩',
        icon: Icons.spa,
        color: 0xFFFFB74D, // 金黄色
        sortOrder: 10,
      ),
    ];
  }

  /// 获取推荐用户
  static Future<List<HomeUserModel>> getRecommendedUsers({int limit = 10}) async {
    await Future.delayed(const Duration(seconds: 1));
    return _generateMockUsers(limit: limit, isRecommended: true);
  }

  /// 获取附近用户
  static Future<List<HomeUserModel>> getNearbyUsers({
    int page = 1,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _generateMockUsers(limit: limit, nearby: true);
  }

  /// 生成模拟用户数据
  static List<HomeUserModel> _generateMockUsers({
    int limit = 20,
    bool nearby = false,
    bool isRecommended = false,
  }) {
    final List<HomeUserModel> users = [];
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
      users.add(HomeUserModel(
        userId: 'user_${i + 1}',
        nickname: '${nicknames[i % nicknames.length]}${(i % 99) + 1}',
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
}

/// 🌍 地区选择数据服务
class LocationService {
  /// 获取热门城市
  static Future<List<LocationRegionModel>> getHotCities() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return const [
      LocationRegionModel(
        regionId: 'shenzhen',
        name: '深圳',
        pinyin: 'shenzhen',
        firstLetter: 'S',
        isHot: true,
      ),
      LocationRegionModel(
        regionId: 'hangzhou',
        name: '杭州',
        pinyin: 'hangzhou',
        firstLetter: 'H',
        isHot: true,
      ),
      LocationRegionModel(
        regionId: 'beijing',
        name: '北京',
        pinyin: 'beijing',
        firstLetter: 'B',
        isHot: true,
      ),
      LocationRegionModel(
        regionId: 'shanghai',
        name: '上海',
        pinyin: 'shanghai',
        firstLetter: 'S',
        isHot: true,
      ),
      LocationRegionModel(
        regionId: 'guangzhou',
        name: '广州',
        pinyin: 'guangzhou',
        firstLetter: 'G',
        isHot: true,
      ),
      LocationRegionModel(
        regionId: 'chengdu',
        name: '成都',
        pinyin: 'chengdu',
        firstLetter: 'C',
        isHot: true,
      ),
      LocationRegionModel(
        regionId: 'wuhan',
        name: '武汉',
        pinyin: 'wuhan',
        firstLetter: 'W',
        isHot: true,
      ),
      LocationRegionModel(
        regionId: 'nanjing',
        name: '南京',
        pinyin: 'nanjing',
        firstLetter: 'N',
        isHot: true,
      ),
    ];
  }

  /// 获取所有地区数据（按字母分组）
  static Future<Map<String, List<LocationRegionModel>>> getAllRegions() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final regions = _generateMockRegions();
    final Map<String, List<LocationRegionModel>> groupedRegions = {};
    
    for (final region in regions) {
      final letter = region.firstLetter.toUpperCase();
      if (!groupedRegions.containsKey(letter)) {
        groupedRegions[letter] = [];
      }
      groupedRegions[letter]!.add(region);
    }
    
    // 按字母顺序排序
    final sortedKeys = groupedRegions.keys.toList()..sort();
    final sortedMap = <String, List<LocationRegionModel>>{};
    for (final key in sortedKeys) {
      sortedMap[key] = groupedRegions[key]!;
    }
    
    return sortedMap;
  }

  /// 搜索地区
  static Future<List<LocationRegionModel>> searchRegions(String keyword) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (keyword.isEmpty) return [];
    
    final regions = _generateMockRegions();
    return regions.where((region) {
      return region.name.contains(keyword) || 
             region.pinyin.contains(keyword.toLowerCase());
    }).toList();
  }

  /// 获取当前定位
  static Future<LocationRegionModel?> getCurrentLocation() async {
    await Future.delayed(const Duration(seconds: 1));
    
    // 模拟GPS定位获取当前位置
    return const LocationRegionModel(
      regionId: 'shenzhen',
      name: '深圳',
      pinyin: 'shenzhen',
      firstLetter: 'S',
      isCurrent: true,
    );
  }

  /// 生成模拟地区数据
  static List<LocationRegionModel> _generateMockRegions() {
    return const [
      // A
      LocationRegionModel(regionId: 'aba', name: '阿坝藏族羌族自治州', pinyin: 'aba', firstLetter: 'A'),
      LocationRegionModel(regionId: 'akesu', name: '阿克苏地区', pinyin: 'akesu', firstLetter: 'A'),
      LocationRegionModel(regionId: 'ali', name: '阿里地区', pinyin: 'ali', firstLetter: 'A'),
      LocationRegionModel(regionId: 'anshan', name: '鞍山市', pinyin: 'anshan', firstLetter: 'A'),
      LocationRegionModel(regionId: 'anyang', name: '安阳市', pinyin: 'anyang', firstLetter: 'A'),
      
      // B
      LocationRegionModel(regionId: 'beijing', name: '北京', pinyin: 'beijing', firstLetter: 'B', isHot: true),
      LocationRegionModel(regionId: 'baoding', name: '保定市', pinyin: 'baoding', firstLetter: 'B'),
      LocationRegionModel(regionId: 'baotou', name: '包头市', pinyin: 'baotou', firstLetter: 'B'),
      LocationRegionModel(regionId: 'bengbu', name: '蚌埠市', pinyin: 'bengbu', firstLetter: 'B'),
      LocationRegionModel(regionId: 'binzhou', name: '滨州市', pinyin: 'binzhou', firstLetter: 'B'),
      
      // C
      LocationRegionModel(regionId: 'chengdu', name: '成都', pinyin: 'chengdu', firstLetter: 'C', isHot: true),
      LocationRegionModel(regionId: 'changsha', name: '长沙市', pinyin: 'changsha', firstLetter: 'C'),
      LocationRegionModel(regionId: 'chongqing', name: '重庆', pinyin: 'chongqing', firstLetter: 'C'),
      LocationRegionModel(regionId: 'changchun', name: '长春市', pinyin: 'changchun', firstLetter: 'C'),
      LocationRegionModel(regionId: 'changzhou', name: '常州市', pinyin: 'changzhou', firstLetter: 'C'),
      
      // D
      LocationRegionModel(regionId: 'dalian', name: '大连市', pinyin: 'dalian', firstLetter: 'D'),
      LocationRegionModel(regionId: 'dongguan', name: '东莞市', pinyin: 'dongguan', firstLetter: 'D'),
      LocationRegionModel(regionId: 'dezhou', name: '德州市', pinyin: 'dezhou', firstLetter: 'D'),
      LocationRegionModel(regionId: 'daqing', name: '大庆市', pinyin: 'daqing', firstLetter: 'D'),
      
      // G
      LocationRegionModel(regionId: 'guangzhou', name: '广州', pinyin: 'guangzhou', firstLetter: 'G', isHot: true),
      LocationRegionModel(regionId: 'guiyang', name: '贵阳市', pinyin: 'guiyang', firstLetter: 'G'),
      LocationRegionModel(regionId: 'guilin', name: '桂林市', pinyin: 'guilin', firstLetter: 'G'),
      
      // H
      LocationRegionModel(regionId: 'hangzhou', name: '杭州', pinyin: 'hangzhou', firstLetter: 'H', isHot: true),
      LocationRegionModel(regionId: 'harbin', name: '哈尔滨市', pinyin: 'harbin', firstLetter: 'H'),
      LocationRegionModel(regionId: 'hefei', name: '合肥市', pinyin: 'hefei', firstLetter: 'H'),
      LocationRegionModel(regionId: 'haikou', name: '海口市', pinyin: 'haikou', firstLetter: 'H'),
      
      // N
      LocationRegionModel(regionId: 'nanjing', name: '南京', pinyin: 'nanjing', firstLetter: 'N', isHot: true),
      LocationRegionModel(regionId: 'nanning', name: '南宁市', pinyin: 'nanning', firstLetter: 'N'),
      LocationRegionModel(regionId: 'ningbo', name: '宁波市', pinyin: 'ningbo', firstLetter: 'N'),
      
      // S
      LocationRegionModel(regionId: 'shanghai', name: '上海', pinyin: 'shanghai', firstLetter: 'S', isHot: true),
      LocationRegionModel(regionId: 'shenzhen', name: '深圳', pinyin: 'shenzhen', firstLetter: 'S', isHot: true),
      LocationRegionModel(regionId: 'suzhou', name: '苏州市', pinyin: 'suzhou', firstLetter: 'S'),
      LocationRegionModel(regionId: 'shenyang', name: '沈阳市', pinyin: 'shenyang', firstLetter: 'S'),
      
      // T
      LocationRegionModel(regionId: 'tianjin', name: '天津', pinyin: 'tianjin', firstLetter: 'T'),
      LocationRegionModel(regionId: 'taiyuan', name: '太原市', pinyin: 'taiyuan', firstLetter: 'T'),
      
      // W
      LocationRegionModel(regionId: 'wuhan', name: '武汉', pinyin: 'wuhan', firstLetter: 'W', isHot: true),
      LocationRegionModel(regionId: 'wuxi', name: '无锡市', pinyin: 'wuxi', firstLetter: 'W'),
      LocationRegionModel(regionId: 'wenzhou', name: '温州市', pinyin: 'wenzhou', firstLetter: 'W'),
      
      // X
      LocationRegionModel(regionId: 'xian', name: '西安市', pinyin: 'xian', firstLetter: 'X'),
      LocationRegionModel(regionId: 'xiamen', name: '厦门市', pinyin: 'xiamen', firstLetter: 'X'),
      LocationRegionModel(regionId: 'xuzhou', name: '徐州市', pinyin: 'xuzhou', firstLetter: 'X'),
      
      // Z
      LocationRegionModel(regionId: 'zhengzhou', name: '郑州市', pinyin: 'zhengzhou', firstLetter: 'Z'),
      LocationRegionModel(regionId: 'zhuhai', name: '珠海市', pinyin: 'zhuhai', firstLetter: 'Z'),
      LocationRegionModel(regionId: 'zibo', name: '淄博市', pinyin: 'zibo', firstLetter: 'Z'),
    ];
  }
}

// ============== 5. CONTROLLERS ==============
// 控制器在各自页面文件中定义

// ============== 6. WIDGETS ==============
// UI组件在各自页面文件中定义

// ============== 7. PAGES ==============
// 页面在各自文件中定义

// ============== 8. EXPORTS ==============
// 导出所有服务供其他文件使用
// 无需显式导出，Dart会自动导出公共类
