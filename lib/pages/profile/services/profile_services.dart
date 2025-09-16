// 🌐 个人信息模块服务层
// 提供用户数据、交易统计、钱包等API接口服务

import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

import '../models/index.dart';

// ============== 1. API服务接口 ==============

/// 📡 个人信息API服务
abstract class ProfileApiService {
  /// 获取用户个人信息
  Future<UserProfile> getUserProfile(String userId);
  
  /// 更新用户个人信息
  Future<UserProfile> updateUserProfile(String userId, ProfileUpdateRequest request);
  
  /// 上传用户头像
  Future<String> uploadAvatar(String userId, File imageFile);
  
  /// 获取交易统计数据
  Future<TransactionStats> getTransactionStats(String userId);
  
  /// 获取钱包信息
  Future<Wallet> getWallet(String userId);
  
  /// 获取功能配置列表
  Future<List<FeatureConfig>> getFeatureConfigs();
  
  /// 刷新用户数据
  Future<Map<String, dynamic>> refreshUserData(String userId);
}

// ============== 2. 模拟API服务实现 ==============

/// 🔧 模拟个人信息API服务
/// 用于开发阶段，提供模拟数据和API响应
class MockProfileApiService implements ProfileApiService {
  static const String _logTag = 'MockProfileApiService';
  
  // 模拟网络延迟
  static const Duration _networkDelay = Duration(milliseconds: 800);
  
  // 模拟用户数据
  static final UserProfile _mockUser = UserProfile(
    id: 'user_123456',
    username: 'user123',
    nickname: '享语拍用户',
    avatar: 'https://picsum.photos/200/200?random=1',
    bio: '这个家伙很懒惰，没有填写简介',
    phone: '138****8888',
    email: 'user@example.com',
    status: UserStatus.online,
    isVerified: true,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    updatedAt: DateTime.now(),
  );
  
  static final TransactionStats _mockStats = TransactionStats(
    publishCount: 12,
    orderCount: 8,
    purchaseCount: 15,
    enrollmentCount: 6,
    totalEarning: 1280.50,
    totalSpending: 890.30,
    updatedAt: DateTime.now(),
  );
  
  static final Wallet _mockWallet = Wallet(
    id: 'wallet_123',
    userId: 'user_123456',
    balance: 888.88,
    frozenBalance: 50.0,
    coinBalance: 1500,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    updatedAt: DateTime.now(),
  );
  
  static final List<FeatureConfig> _mockFeatures = [
    const FeatureConfig(
      key: 'personal_center',
      name: '个人中心',
      icon: 'person',
      description: '查看和编辑个人资料',
    ),
    const FeatureConfig(
      key: 'user_status',
      name: '状态',
      icon: 'radio_button_checked',
      description: '设置在线状态',
    ),
    const FeatureConfig(
      key: 'wallet',
      name: '钱包',
      icon: 'account_balance_wallet',
      description: '查看余额和交易记录',
    ),
    const FeatureConfig(
      key: 'coins',
      name: '金币',
      icon: 'monetization_on',
      description: '查看金币和兑换记录',
    ),
    const FeatureConfig(
      key: 'settings',
      name: '设置',
      icon: 'settings',
      description: '系统设置和隐私控制',
    ),
    const FeatureConfig(
      key: 'customer_service',
      name: '客服',
      icon: 'headset_mic',
      description: '联系客服获得帮助',
    ),
    const FeatureConfig(
      key: 'expert_verification',
      name: '达人认证',
      icon: 'verified',
      description: '申请成为认证达人',
    ),
  ];

  @override
  Future<UserProfile> getUserProfile(String userId) async {
    developer.log('$_logTag: 获取用户信息 - $userId');
    await Future.delayed(_networkDelay);
    
    // 模拟网络错误
    if (userId == 'error_user') {
      throw Exception('用户不存在');
    }
    
    return _mockUser;
  }

  @override
  Future<UserProfile> updateUserProfile(String userId, ProfileUpdateRequest request) async {
    developer.log('$_logTag: 更新用户信息 - $userId: $request');
    await Future.delayed(_networkDelay);
    
    // 模拟更新失败
    if (request.nickname == 'error') {
      throw Exception('昵称已被使用');
    }
    
    return _mockUser.copyWith(
      nickname: request.nickname ?? _mockUser.nickname,
      bio: request.bio ?? _mockUser.bio,
      avatar: request.avatar ?? _mockUser.avatar,
      status: request.status ?? _mockUser.status,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<String> uploadAvatar(String userId, File imageFile) async {
    developer.log('$_logTag: 上传头像 - $userId: ${imageFile.path}');
    await Future.delayed(const Duration(seconds: 2)); // 模拟上传时间
    
    // 模拟上传成功，返回图片URL
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'https://picsum.photos/200/200?random=$timestamp';
  }

  @override
  Future<TransactionStats> getTransactionStats(String userId) async {
    developer.log('$_logTag: 获取交易统计 - $userId');
    await Future.delayed(_networkDelay);
    
    return _mockStats;
  }

  @override
  Future<Wallet> getWallet(String userId) async {
    developer.log('$_logTag: 获取钱包信息 - $userId');
    await Future.delayed(_networkDelay);
    
    return _mockWallet;
  }

  @override
  Future<List<FeatureConfig>> getFeatureConfigs() async {
    developer.log('$_logTag: 获取功能配置列表');
    await Future.delayed(_networkDelay);
    
    return _mockFeatures;
  }

  @override
  Future<Map<String, dynamic>> refreshUserData(String userId) async {
    developer.log('$_logTag: 刷新用户数据 - $userId');
    
    // 并行获取所有数据
    final results = await Future.wait([
      getUserProfile(userId),
      getTransactionStats(userId),
      getWallet(userId),
      getFeatureConfigs(),
    ]);
    
    return {
      'profile': results[0] as UserProfile,
      'stats': results[1] as TransactionStats,
      'wallet': results[2] as Wallet,
      'features': results[3] as List<FeatureConfig>,
    };
  }
}

// ============== 3. 本地存储服务 ==============

/// 💾 个人信息本地存储服务
class ProfileStorageService {
  static const String _logTag = 'ProfileStorageService';
  
  // 缓存键名
  static const String _userProfileKey = 'user_profile';
  static const String _transactionStatsKey = 'transaction_stats';
  static const String _walletKey = 'wallet';
  static const String _featuresKey = 'features';
  
  /// 保存用户信息到本地
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      // 这里应该使用实际的本地存储服务（如SharedPreferences或Hive）
      developer.log('$_logTag: 保存用户信息到本地 - ${profile.id}');
      
      // 模拟保存操作
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      developer.log('$_logTag: 保存用户信息失败 - $e');
      rethrow;
    }
  }
  
  /// 从本地获取用户信息
  Future<UserProfile?> getUserProfile() async {
    try {
      developer.log('$_logTag: 从本地获取用户信息');
      
      // 这里应该从实际的本地存储读取
      // 目前返回null表示本地无缓存
      return null;
    } catch (e) {
      developer.log('$_logTag: 获取本地用户信息失败 - $e');
      return null;
    }
  }
  
  /// 保存交易统计到本地
  Future<void> saveTransactionStats(TransactionStats stats) async {
    try {
      developer.log('$_logTag: 保存交易统计到本地');
      await Future.delayed(const Duration(milliseconds: 50));
    } catch (e) {
      developer.log('$_logTag: 保存交易统计失败 - $e');
    }
  }
  
  /// 保存钱包信息到本地
  Future<void> saveWallet(Wallet wallet) async {
    try {
      developer.log('$_logTag: 保存钱包信息到本地');
      await Future.delayed(const Duration(milliseconds: 50));
    } catch (e) {
      developer.log('$_logTag: 保存钱包信息失败 - $e');
    }
  }
  
  /// 清除本地缓存
  Future<void> clearCache() async {
    try {
      developer.log('$_logTag: 清除本地缓存');
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      developer.log('$_logTag: 清除缓存失败 - $e');
    }
  }
}

// ============== 4. 统一服务管理器 ==============

/// 🎯 个人信息服务管理器
/// 统一管理API服务和本地存储，提供高级业务逻辑
class ProfileServiceManager {
  static const String _logTag = 'ProfileServiceManager';
  
  final ProfileApiService _apiService;
  final ProfileStorageService _storageService;
  
  ProfileServiceManager({
    ProfileApiService? apiService,
    ProfileStorageService? storageService,
  }) : _apiService = apiService ?? MockProfileApiService(),
        _storageService = storageService ?? ProfileStorageService();
  
  /// 获取用户信息（优先从本地缓存获取）
  Future<UserProfile> getUserProfile(String userId, {bool forceRefresh = false}) async {
    try {
      // 如果不强制刷新，先尝试从本地获取
      if (!forceRefresh) {
        final cachedProfile = await _storageService.getUserProfile();
        if (cachedProfile != null) {
          developer.log('$_logTag: 从本地缓存获取用户信息');
          return cachedProfile;
        }
      }
      
      // 从API获取
      final profile = await _apiService.getUserProfile(userId);
      
      // 保存到本地缓存
      await _storageService.saveUserProfile(profile);
      
      return profile;
    } catch (e) {
      developer.log('$_logTag: 获取用户信息失败 - $e');
      rethrow;
    }
  }
  
  /// 更新用户信息
  Future<UserProfile> updateUserProfile(String userId, ProfileUpdateRequest request) async {
    try {
      // 调用API更新
      final updatedProfile = await _apiService.updateUserProfile(userId, request);
      
      // 更新本地缓存
      await _storageService.saveUserProfile(updatedProfile);
      
      developer.log('$_logTag: 用户信息更新成功');
      return updatedProfile;
    } catch (e) {
      developer.log('$_logTag: 更新用户信息失败 - $e');
      rethrow;
    }
  }
  
  /// 上传头像
  Future<String> uploadAvatar(String userId, File imageFile) async {
    try {
      final avatarUrl = await _apiService.uploadAvatar(userId, imageFile);
      
      // 自动更新用户信息中的头像URL
      await updateUserProfile(userId, ProfileUpdateRequest(avatar: avatarUrl));
      
      developer.log('$_logTag: 头像上传成功 - $avatarUrl');
      return avatarUrl;
    } catch (e) {
      developer.log('$_logTag: 头像上传失败 - $e');
      rethrow;
    }
  }
  
  /// 获取完整用户数据
  Future<Map<String, dynamic>> getCompleteUserData(String userId, {bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        // 强制刷新，从API获取所有数据
        return await _apiService.refreshUserData(userId);
      } else {
        // 并行获取各种数据
        final results = await Future.wait([
          getUserProfile(userId),
          _apiService.getTransactionStats(userId),
          _apiService.getWallet(userId),
          _apiService.getFeatureConfigs(),
        ]);
        
        return {
          'profile': results[0] as UserProfile,
          'stats': results[1] as TransactionStats,
          'wallet': results[2] as Wallet,
          'features': results[3] as List<FeatureConfig>,
        };
      }
    } catch (e) {
      developer.log('$_logTag: 获取完整用户数据失败 - $e');
      rethrow;
    }
  }
  
  /// 清除用户数据缓存
  Future<void> clearUserDataCache() async {
    try {
      await _storageService.clearCache();
      developer.log('$_logTag: 用户数据缓存已清除');
    } catch (e) {
      developer.log('$_logTag: 清除缓存失败 - $e');
    }
  }
}

// ============== 5. 服务实例提供器 ==============

/// 🏭 服务实例工厂
class ProfileServiceFactory {
  static ProfileServiceManager? _instance;
  
  /// 获取服务管理器实例（单例模式）
  static ProfileServiceManager getInstance() {
    return _instance ??= ProfileServiceManager();
  }
  
  /// 重置实例（主要用于测试）
  static void resetInstance() {
    _instance = null;
  }
  
  /// 创建模拟服务实例
  static ProfileServiceManager createMockInstance() {
    return ProfileServiceManager(
      apiService: MockProfileApiService(),
      storageService: ProfileStorageService(),
    );
  }
}
