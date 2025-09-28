// 🧠 个人信息模块状态管理
// 使用Provider模式管理用户数据、交易统计、钱包等状态

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

import '../models/index.dart';
import '../services/index.dart';

// ============== 1. 用户信息状态管理 ==============

/// 👤 用户信息Provider
/// 管理用户个人信息、头像、昵称、简介等数据和状态
class UserProfileProvider extends ChangeNotifier {
  static const String _logTag = 'UserProfileProvider';
  
  final ProfileServiceManager _serviceManager;
  
  // 当前用户ID
  String? _currentUserId;
  
  // 用户信息
  UserProfile? _profile;
  DataLoadState _profileState = DataLoadState.initial;
  String? _profileError;
  
  // 头像上传状态
  bool _isUploadingAvatar = false;
  double _uploadProgress = 0.0;
  
  UserProfileProvider({ProfileServiceManager? serviceManager})
      : _serviceManager = serviceManager ?? ProfileServiceFactory.getInstance();
  
  // ============== Getters ==============
  
  String? get currentUserId => _currentUserId;
  UserProfile? get profile => _profile;
  DataLoadState get profileState => _profileState;
  String? get profileError => _profileError;
  bool get isUploadingAvatar => _isUploadingAvatar;
  double get uploadProgress => _uploadProgress;
  
  bool get hasProfile => _profile != null;
  bool get isLoading => _profileState == DataLoadState.loading;
  bool get hasError => _profileState == DataLoadState.error;
  
  // ============== 用户信息操作 ==============
  
  /// 初始化用户数据
  Future<void> initializeUser(String userId) async {
    if (_currentUserId == userId && hasProfile) {
      developer.log('$_logTag: 用户已初始化，跳过 - $userId');
      return;
    }
    
    _currentUserId = userId;
    await loadUserProfile(forceRefresh: false);
  }
  
  /// 加载用户信息
  Future<void> loadUserProfile({bool forceRefresh = false}) async {
    if (_currentUserId == null) return;
    
    try {
      _setProfileState(DataLoadState.loading);
      developer.log('$_logTag: 开始加载用户信息 - $_currentUserId');
      
      final profile = await _serviceManager.getUserProfile(
        _currentUserId!,
        forceRefresh: forceRefresh,
      );
      
      _profile = profile;
      _setProfileState(DataLoadState.loaded);
      developer.log('$_logTag: 用户信息加载成功 - ${profile.nickname}');
      
    } catch (e) {
      _profileError = e.toString();
      _setProfileState(DataLoadState.error);
      developer.log('$_logTag: 用户信息加载失败 - $e');
    }
  }
  
  /// 更新用户信息
  Future<bool> updateUserProfile(ProfileUpdateRequest request) async {
    if (_currentUserId == null) return false;
    
    try {
      developer.log('$_logTag: 开始更新用户信息 - $request');
      
      final updatedProfile = await _serviceManager.updateUserProfile(_currentUserId!, request);
      
      _profile = updatedProfile;
      notifyListeners();
      
      developer.log('$_logTag: 用户信息更新成功');
      return true;
      
    } catch (e) {
      developer.log('$_logTag: 用户信息更新失败 - $e');
      return false;
    }
  }
  
  /// 更新昵称
  Future<bool> updateNickname(String nickname) async {
    if (nickname.trim().isEmpty) return false;
    
    return await updateUserProfile(ProfileUpdateRequest(nickname: nickname.trim()));
  }
  
  /// 更新简介
  Future<bool> updateBio(String bio) async {
    return await updateUserProfile(ProfileUpdateRequest(bio: bio.trim()));
  }
  
  /// 更新用户状态
  Future<bool> updateUserStatus(UserStatus status) async {
    return await updateUserProfile(ProfileUpdateRequest(status: status));
  }
  
  /// 上传头像
  Future<bool> uploadAvatar(File imageFile) async {
    if (_currentUserId == null) return false;
    
    try {
      _setUploadingAvatar(true);
      developer.log('$_logTag: 开始上传头像 - ${imageFile.path}');
      
      // 模拟上传进度
      _updateUploadProgress(0.1);
      await Future.delayed(const Duration(milliseconds: 200));
      
      _updateUploadProgress(0.5);
      await Future.delayed(const Duration(milliseconds: 500));
      
      final avatarUrl = await _serviceManager.uploadAvatar(_currentUserId!, imageFile);
      
      _updateUploadProgress(1.0);
      await Future.delayed(const Duration(milliseconds: 200));
      
      // 重新加载用户信息以获取最新头像
      await loadUserProfile(forceRefresh: true);
      
      developer.log('$_logTag: 头像上传成功 - $avatarUrl');
      return true;
      
    } catch (e) {
      developer.log('$_logTag: 头像上传失败 - $e');
      return false;
    } finally {
      _setUploadingAvatar(false);
      _updateUploadProgress(0.0);
    }
  }
  
  /// 刷新用户数据
  Future<void> refreshUserData() async {
    await loadUserProfile(forceRefresh: true);
  }
  
  // ============== 私有方法 ==============
  
  void _setProfileState(DataLoadState state) {
    if (_profileState != state) {
      _profileState = state;
      if (state != DataLoadState.error) {
        _profileError = null;
      }
      notifyListeners();
    }
  }
  
  void _setUploadingAvatar(bool uploading) {
    if (_isUploadingAvatar != uploading) {
      _isUploadingAvatar = uploading;
      notifyListeners();
    }
  }
  
  void _updateUploadProgress(double progress) {
    _uploadProgress = progress.clamp(0.0, 1.0);
    notifyListeners();
  }
  
  @override
  void dispose() {
    developer.log('$_logTag: Provider销毁');
    super.dispose();
  }
}

// ============== 2. 交易统计状态管理 ==============

/// 📊 交易统计Provider
/// 管理用户的发布、订单、购买、报名等交易统计数据
class TransactionStatsProvider extends ChangeNotifier {
  static const String _logTag = 'TransactionStatsProvider';
  
  final ProfileServiceManager _serviceManager;
  
  TransactionStats? _stats;
  DataLoadState _statsState = DataLoadState.initial;
  String? _statsError;
  
  TransactionStatsProvider({ProfileServiceManager? serviceManager})
      : _serviceManager = serviceManager ?? ProfileServiceFactory.getInstance();
  
  // ============== Getters ==============
  
  TransactionStats? get stats => _stats;
  DataLoadState get statsState => _statsState;
  String? get statsError => _statsError;
  
  bool get hasStats => _stats != null;
  bool get isLoading => _statsState == DataLoadState.loading;
  bool get hasError => _statsState == DataLoadState.error;
  
  // ============== 统计数据操作 ==============
  
  /// 加载交易统计
  Future<void> loadTransactionStats(String userId) async {
    try {
      _setStatsState(DataLoadState.loading);
      developer.log('$_logTag: 开始加载交易统计 - $userId');
      
      // 直接使用Mock服务获取数据，避免复杂依赖
      final mockService = MockProfileApiService();
      final stats = await mockService.getTransactionStats(userId);
      
      _stats = stats;
      _setStatsState(DataLoadState.loaded);
      developer.log('$_logTag: 交易统计加载成功 - 总交易数: ${stats.totalTransactions}');
      
    } catch (e) {
      _statsError = e.toString();
      _setStatsState(DataLoadState.error);
      developer.log('$_logTag: 交易统计加载失败 - $e');
    }
  }
  
  /// 刷新统计数据
  Future<void> refreshStats(String userId) async {
    await loadTransactionStats(userId);
  }
  
  // ============== 私有方法 ==============
  
  void _setStatsState(DataLoadState state) {
    if (_statsState != state) {
      _statsState = state;
      if (state != DataLoadState.error) {
        _statsError = null;
      }
      notifyListeners();
    }
  }
  
  @override
  void dispose() {
    developer.log('$_logTag: Provider销毁');
    super.dispose();
  }
}

// ============== 3. 钱包状态管理 ==============

/// 💰 钱包Provider
/// 管理用户钱包余额、金币、交易记录等数据
class WalletProvider extends ChangeNotifier {
  static const String _logTag = 'WalletProvider';
  
  final ProfileServiceManager _serviceManager;
  
  Wallet? _wallet;
  DataLoadState _walletState = DataLoadState.initial;
  String? _walletError;
  
  WalletProvider({ProfileServiceManager? serviceManager})
      : _serviceManager = serviceManager ?? ProfileServiceFactory.getInstance();
  
  // ============== Getters ==============
  
  Wallet? get wallet => _wallet;
  DataLoadState get walletState => _walletState;
  String? get walletError => _walletError;
  
  bool get hasWallet => _wallet != null;
  bool get isLoading => _walletState == DataLoadState.loading;
  bool get hasError => _walletState == DataLoadState.error;
  
  // 便捷访问器
  double get balance => _wallet?.balance ?? 0.0;
  double get availableBalance => _wallet?.availableBalance ?? 0.0;
  int get coinBalance => _wallet?.coinBalance ?? 0;
  String get balanceDisplay => _wallet?.balanceDisplay ?? '¥0.00';
  String get coinDisplay => _wallet?.coinDisplay ?? '0';
  
  // ============== 钱包操作 ==============
  
  /// 加载钱包信息
  Future<void> loadWallet(String userId) async {
    try {
      _setWalletState(DataLoadState.loading);
      developer.log('$_logTag: 开始加载钱包信息 - $userId');
      
      // 直接使用Mock服务获取数据，避免复杂依赖
      final mockService = MockProfileApiService();
      final wallet = await mockService.getWallet(userId);
      
      _wallet = wallet;
      _setWalletState(DataLoadState.loaded);
      developer.log('$_logTag: 钱包信息加载成功 - 余额: ${wallet.balanceDisplay}');
      
    } catch (e) {
      _walletError = e.toString();
      _setWalletState(DataLoadState.error);
      developer.log('$_logTag: 钱包信息加载失败 - $e');
    }
  }
  
  /// 检查余额是否足够
  bool hasEnoughBalance(double amount) {
    return _wallet?.hasEnoughBalance(amount) ?? false;
  }
  
  /// 检查金币是否足够
  bool hasEnoughCoins(int amount) {
    return _wallet?.hasEnoughCoins(amount) ?? false;
  }
  
  /// 刷新钱包数据
  Future<void> refreshWallet(String userId) async {
    await loadWallet(userId);
  }
  
  // ============== 私有方法 ==============
  
  void _setWalletState(DataLoadState state) {
    if (_walletState != state) {
      _walletState = state;
      if (state != DataLoadState.error) {
        _walletError = null;
      }
      notifyListeners();
    }
  }
  
  @override
  void dispose() {
    developer.log('$_logTag: Provider销毁');
    super.dispose();
  }
}

// ============== 4. 功能配置状态管理 ==============

/// 🛠️ 功能配置Provider
/// 管理各种功能模块的配置和开关状态
class FeatureConfigProvider extends ChangeNotifier {
  static const String _logTag = 'FeatureConfigProvider';
  
  final ProfileServiceManager _serviceManager;
  
  List<FeatureConfig> _features = [];
  DataLoadState _featuresState = DataLoadState.initial;
  String? _featuresError;
  
  FeatureConfigProvider({ProfileServiceManager? serviceManager})
      : _serviceManager = serviceManager ?? ProfileServiceFactory.getInstance();
  
  // ============== Getters ==============
  
  List<FeatureConfig> get features => List.unmodifiable(_features);
  DataLoadState get featuresState => _featuresState;
  String? get featuresError => _featuresError;
  
  bool get hasFeatures => _features.isNotEmpty;
  bool get isLoading => _featuresState == DataLoadState.loading;
  bool get hasError => _featuresState == DataLoadState.error;
  
  // ============== 功能配置操作 ==============
  
  /// 加载功能配置
  Future<void> loadFeatureConfigs() async {
    try {
      _setFeaturesState(DataLoadState.loading);
      developer.log('$_logTag: 开始加载功能配置');
      
      // 直接使用Mock服务获取数据，避免复杂依赖
      final mockService = MockProfileApiService();
      final features = await mockService.getFeatureConfigs();
      
      _features = features;
      _setFeaturesState(DataLoadState.loaded);
      developer.log('$_logTag: 功能配置加载成功 - ${features.length}个功能');
      
    } catch (e) {
      _featuresError = e.toString();
      _setFeaturesState(DataLoadState.error);
      developer.log('$_logTag: 功能配置加载失败 - $e');
    }
  }
  
  /// 根据key获取功能配置
  FeatureConfig? getFeatureByKey(String key) {
    try {
      return _features.firstWhere((feature) => feature.key == key);
    } catch (e) {
      return null;
    }
  }
  
  /// 检查功能是否启用
  bool isFeatureEnabled(String key) {
    final feature = getFeatureByKey(key);
    return feature?.enabled ?? false;
  }
  
  /// 获取已启用的功能列表
  List<FeatureConfig> get enabledFeatures {
    return _features.where((feature) => feature.enabled).toList();
  }
  
  /// 刷新功能配置
  Future<void> refreshFeatures() async {
    await loadFeatureConfigs();
  }
  
  // ============== 私有方法 ==============
  
  void _setFeaturesState(DataLoadState state) {
    if (_featuresState != state) {
      _featuresState = state;
      if (state != DataLoadState.error) {
        _featuresError = null;
      }
      notifyListeners();
    }
  }
  
  @override
  void dispose() {
    developer.log('$_logTag: Provider销毁');
    super.dispose();
  }
}

// ============== 5. 统一状态管理 ==============

/// 🎯 个人信息统一Provider
/// 聚合管理所有个人信息相关的状态，提供统一的数据访问接口
class ProfileProvider extends ChangeNotifier {
  static const String _logTag = 'ProfileProvider';
  
  final UserProfileProvider _userProvider;
  final TransactionStatsProvider _statsProvider;
  final WalletProvider _walletProvider;
  final FeatureConfigProvider _featureProvider;
  
  bool _isInitialized = false;
  bool _isRefreshing = false;
  
  ProfileProvider({
    UserProfileProvider? userProvider,
    TransactionStatsProvider? statsProvider,
    WalletProvider? walletProvider,
    FeatureConfigProvider? featureProvider,
  }) : _userProvider = userProvider ?? UserProfileProvider(),
       _statsProvider = statsProvider ?? TransactionStatsProvider(),
       _walletProvider = walletProvider ?? WalletProvider(),
       _featureProvider = featureProvider ?? FeatureConfigProvider() {
    
    // 监听子Provider变化
    _userProvider.addListener(_onChildProviderChanged);
    _statsProvider.addListener(_onChildProviderChanged);
    _walletProvider.addListener(_onChildProviderChanged);
    _featureProvider.addListener(_onChildProviderChanged);
  }
  
  // ============== Getters ==============
  
  UserProfileProvider get userProvider => _userProvider;
  TransactionStatsProvider get statsProvider => _statsProvider;
  WalletProvider get walletProvider => _walletProvider;
  FeatureConfigProvider get featureProvider => _featureProvider;
  
  bool get isInitialized => _isInitialized;
  bool get isRefreshing => _isRefreshing;
  
  // 便捷访问器
  UserProfile? get profile => _userProvider.profile;
  TransactionStats? get stats => _statsProvider.stats;
  Wallet? get wallet => _walletProvider.wallet;
  List<FeatureConfig> get features => _featureProvider.features;
  
  bool get hasCompleteData => 
      _userProvider.hasProfile && 
      _statsProvider.hasStats && 
      _walletProvider.hasWallet && 
      _featureProvider.hasFeatures;
  
  bool get isLoading => 
      _userProvider.isLoading || 
      _statsProvider.isLoading || 
      _walletProvider.isLoading || 
      _featureProvider.isLoading;
  
  // ============== 统一操作接口 ==============
  
  /// 初始化用户数据
  Future<void> initializeUser(String userId) async {
    if (_isInitialized && _userProvider.currentUserId == userId) {
      developer.log('$_logTag: 用户数据已初始化，跳过 - $userId');
      return;
    }
    
    try {
      developer.log('$_logTag: 开始初始化用户数据 - $userId');
      
      // 并行加载所有数据
      await Future.wait([
        _userProvider.initializeUser(userId),
        _statsProvider.loadTransactionStats(userId),
        _walletProvider.loadWallet(userId),
        _featureProvider.loadFeatureConfigs(),
      ]);
      
      _isInitialized = true;
      notifyListeners();
      
      developer.log('$_logTag: 用户数据初始化完成');
      
    } catch (e) {
      developer.log('$_logTag: 用户数据初始化失败 - $e');
      rethrow;
    }
  }
  
  /// 刷新所有用户数据
  Future<void> refreshAllData({bool forceRefresh = false}) async {
    if (_userProvider.currentUserId == null) return;
    
    try {
      _setRefreshing(true);
      developer.log('$_logTag: 开始刷新所有用户数据');
      
      final userId = _userProvider.currentUserId!;
      
      // 并行刷新所有数据
      await Future.wait([
        _userProvider.refreshUserData(),
        _statsProvider.refreshStats(userId),
        _walletProvider.refreshWallet(userId),
        _featureProvider.refreshFeatures(),
      ]);
      
      developer.log('$_logTag: 所有用户数据刷新完成');
      
    } catch (e) {
      developer.log('$_logTag: 刷新用户数据失败 - $e');
    } finally {
      _setRefreshing(false);
    }
  }
  
  /// 更新用户信息
  Future<bool> updateUserProfile(ProfileUpdateRequest request) async {
    return await _userProvider.updateUserProfile(request);
  }
  
  /// 上传头像
  Future<bool> uploadAvatar(File imageFile) async {
    return await _userProvider.uploadAvatar(imageFile);
  }
  
  /// 清除所有数据
  void clearAllData() {
    _isInitialized = false;
    notifyListeners();
    developer.log('$_logTag: 所有数据已清除');
  }
  
  // ============== 私有方法 ==============
  
  void _onChildProviderChanged() {
    notifyListeners();
  }
  
  void _setRefreshing(bool refreshing) {
    if (_isRefreshing != refreshing) {
      _isRefreshing = refreshing;
      notifyListeners();
    }
  }
  
  @override
  void dispose() {
    _userProvider.removeListener(_onChildProviderChanged);
    _statsProvider.removeListener(_onChildProviderChanged);
    _walletProvider.removeListener(_onChildProviderChanged);
    _featureProvider.removeListener(_onChildProviderChanged);
    
    _userProvider.dispose();
    _statsProvider.dispose();
    _walletProvider.dispose();
    _featureProvider.dispose();
    
    developer.log('$_logTag: 统一Provider销毁');
    super.dispose();
  }
}
