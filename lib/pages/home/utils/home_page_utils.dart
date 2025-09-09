// 🔧 首页工具函数 - 页面级工具函数和辅助方法
// 从unified_home_page.dart中提取的工具函数

import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import '../home_models.dart';
import '../search/index.dart';
import '../submodules/service_system/index.dart';
import '../submodules/filter_system/filter_page.dart';

/// 首页工具函数类
class HomePageUtils {
  /// 获取服务映射 - 将分类名称映射到服务类型
  static Map<String, dynamic>? getServiceMapping(String categoryName) {
    switch (categoryName) {
      // 游戏服务
      case '王者荣耀':
        return {
          'serviceType': ServiceType.game,
          'serviceName': '王者荣耀陪练',
        };
      case '英雄联盟':
        return {
          'serviceType': ServiceType.game,
          'serviceName': '英雄联盟陪练',
        };
      case '和平精英':
        return {
          'serviceType': ServiceType.game,
          'serviceName': '和平精英陪练',
        };
      case '荒野乱斗':
        return {
          'serviceType': ServiceType.game,
          'serviceName': '荒野乱斗陪练',
        };
        
      // 娱乐服务
      case 'K歌':
        return {
          'serviceType': ServiceType.entertainment,
          'serviceName': 'K歌服务',
        };
      case '台球':
        return {
          'serviceType': ServiceType.entertainment,
          'serviceName': '台球服务',
        };
      case '私影':
        return {
          'serviceType': ServiceType.entertainment,
          'serviceName': '私影服务',
        };
      case '按摩':
        return {
          'serviceType': ServiceType.lifestyle,
          'serviceName': '按摩服务',
        };
      case '喝酒':
        return {
          'serviceType': ServiceType.entertainment,
          'serviceName': '喝酒陪伴',
        };
        
      // 生活服务  
      case '探店':
        return {
          'serviceType': ServiceType.lifestyle,
          'serviceName': '探店服务',
        };
        
      default:
        return null; // 不支持的分类，使用默认搜索
    }
  }

  /// 转换位置模型
  static LocationRegionModel? convertToLocationRegion(HomeLocationModel? homeLocation) {
    if (homeLocation == null) return null;
    
    return LocationRegionModel(
      regionId: homeLocation.locationId,
      name: homeLocation.name,
      pinyin: homeLocation.name.toLowerCase(),
      firstLetter: homeLocation.name.isNotEmpty ? homeLocation.name[0].toUpperCase() : 'A',
      isHot: homeLocation.isHot,
      isCurrent: true,
    );
  }

  /// 构建筛选条件摘要
  static String buildFilterSummary(FilterCriteria criteria) {
    List<String> summaryParts = [];

    // 年龄范围
    if (criteria.ageRange.start > 18 || criteria.ageRange.end < 99) {
      summaryParts.add('年龄${criteria.ageRange.start.round()}-${criteria.ageRange.end.round()}岁');
    }

    // 性别
    if (criteria.gender != '全部') {
      summaryParts.add('性别${criteria.gender}');
    }

    // 状态
    if (criteria.status != '在线') {
      summaryParts.add('状态${criteria.status}');
    }

    // 类型
    if (criteria.type != '线上') {
      summaryParts.add('类型${criteria.type}');
    }

    // 技能
    if (criteria.skills.isNotEmpty) {
      summaryParts.add('技能${criteria.skills.length}项');
    }

    // 价格
    if (criteria.price.isNotEmpty) {
      summaryParts.add('价格${criteria.price}');
    }

    // 位置
    if (criteria.positions.isNotEmpty) {
      summaryParts.add('位置${criteria.positions.length}项');
    }

    // 标签
    if (criteria.tags.isNotEmpty) {
      summaryParts.add('标签${criteria.tags.length}项');
    }

    return summaryParts.join('、');
  }

  /// 将FilterCriteria转换为Map
  static Map<String, dynamic> convertFilterCriteriaToMap(FilterCriteria criteria) {
    return {
      'ageRange': {
        'start': criteria.ageRange.start,
        'end': criteria.ageRange.end,
      },
      'gender': criteria.gender,
      'status': criteria.status,
      'type': criteria.type,
      'skills': criteria.skills,
      'price': criteria.price,
      'positions': criteria.positions,
      'tags': criteria.tags,
    };
  }

  /// 显示敬请期待对话框
  static void showComingSoonDialog(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('敬请期待'),
        content: Text('$featureName正在开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 处理分类点击导航
  static void handleCategoryNavigation(
    BuildContext context, 
    HomeCategoryModel category,
    void Function(HomeCategoryModel) onSelectCategory,
  ) {
    developer.log('首页: 点击分类，名称: ${category.name}');
    
    // 调用选择分类回调
    onSelectCategory(category);
    
    // 根据分类名称映射到服务类型和具体服务
    final serviceMapping = getServiceMapping(category.name);
    
    if (serviceMapping != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ServiceFilterPage(
            serviceType: serviceMapping['serviceType'],
            serviceName: serviceMapping['serviceName'],
          ),
        ),
      );
    } else {
      // 默认跳转到搜索结果页面
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultsPage(initialKeyword: category.name),
        ),
      );
    }
  }

  /// 获取当前筛选状态摘要
  static String getFilterSummary(HomeState state) {
    final filters = state.activeFilters;
    final region = state.selectedRegion;

    List<String> summaryParts = [];

    if (region != null && region != '全深圳') {
      summaryParts.add('区域: $region');
    }

    if (filters != null && filters.isNotEmpty) {
      summaryParts.add('筛选: ${filters.length}项');
    }

    return summaryParts.isEmpty ? '无筛选' : summaryParts.join(' | ');
  }

  /// 验证用户输入
  static bool validateSearchKeyword(String keyword) {
    return keyword.trim().isNotEmpty && keyword.trim().length <= 50;
  }

  /// 格式化距离显示
  static String formatDistance(double? distance) {
    if (distance == null) return '';
    
    if (distance < 1000) {
      return '${distance.round()}m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km';
    }
  }

  /// 格式化时间显示
  static String formatLastActiveTime(DateTime? lastActiveTime) {
    if (lastActiveTime == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(lastActiveTime);
    
    if (difference.inMinutes < 1) {
      return '刚刚活跃';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前活跃';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前活跃';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前活跃';
    } else {
      return '很久前活跃';
    }
  }

  /// 日志记录辅助方法
  static void logUserAction(String action, {Map<String, dynamic>? params}) {
    String logMessage = '首页用户操作: $action';
    if (params != null && params.isNotEmpty) {
      logMessage += ' | 参数: $params';
    }
    developer.log(logMessage);
  }

  /// 检查网络连接状态
  static Future<bool> checkNetworkConnection() async {
    // TODO: 实现网络连接检查
    // 这里可以使用 connectivity_plus 包检查网络状态
    return true; // 临时返回true
  }

  /// 显示错误提示
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '确定',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// 显示成功提示
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(HomeConstants.primaryPurple),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
