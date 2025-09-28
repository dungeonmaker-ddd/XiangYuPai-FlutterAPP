// 👤 个人信息模块统一导出文件
// 提供完整的Profile模块架构，包括页面、状态管理、服务等

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;

// 导出核心模块
export 'models/index.dart';
export 'services/index.dart';
export 'providers/index.dart';
export 'widgets/index.dart';
export 'pages/profile_main_page.dart';

// 内部导入
import 'models/index.dart';
import 'services/index.dart';
import 'providers/index.dart';
import 'pages/profile_main_page.dart';

// ============== 1. 页面工厂 ==============

/// 🏭 Profile页面工厂
/// 提供Profile模块的页面创建和Provider包装
class ProfilePageFactory {
  static const String _logTag = 'ProfilePageFactory';

  /// 创建带有完整Provider包装的Profile主页面
  static Widget createMainPageWithWrapper() {
    developer.log('$_logTag: 创建Profile主页面');
    
    // 简化Provider设计，避免循环依赖
    return MultiProvider(
      providers: [
        // 服务层Provider
        Provider<ProfileServiceManager>(
          create: (_) => ProfileServiceFactory.getInstance(),
        ),
        
        // 状态管理Provider - 简化为三个核心Provider
        ChangeNotifierProvider<UserProfileProvider>(
          create: (context) => UserProfileProvider(
            serviceManager: context.read<ProfileServiceManager>(),
          ),
        ),
        ChangeNotifierProvider<TransactionStatsProvider>(
          create: (context) => TransactionStatsProvider(
            serviceManager: context.read<ProfileServiceManager>(),
          ),
        ),
        ChangeNotifierProvider<WalletProvider>(
          create: (context) => WalletProvider(
            serviceManager: context.read<ProfileServiceManager>(),
          ),
        ),
      ],
      child: const ProfileMainPage(),
    );
  }

  /// 创建简单的Profile主页面（不带Provider包装）
  static Widget createSimpleMainPage() {
    developer.log('$_logTag: 创建简单Profile主页面');
    return const ProfileMainPage();
  }
}

// ============== 2. 初始化包装器 ==============

/// 🔧 Profile页面初始化包装器
/// 确保Profile模块正确初始化
class ProfilePageWithInitialization extends StatefulWidget {
  final Widget child;

  const ProfilePageWithInitialization({
    super.key,
    required this.child,
  });

  @override
  State<ProfilePageWithInitialization> createState() => _ProfilePageWithInitializationState();
}

class _ProfilePageWithInitializationState extends State<ProfilePageWithInitialization> {
  static const String _logTag = 'ProfilePageWithInitialization';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  void _initializeProfile() {
    developer.log('$_logTag: 初始化Profile模块');
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        // 这里可以添加Profile模块的初始化逻辑
        setState(() {
          _isInitialized = true;
        });
        developer.log('$_logTag: Profile模块初始化完成');
      } catch (e) {
        developer.log('$_logTag: Profile模块初始化失败 - $e');
        setState(() {
          _isInitialized = true; // 即使失败也继续显示页面
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
          ),
        ),
      );
    }

    return widget.child;
  }
}

// ============== 3. 快速访问接口 ==============

/// ⚡ Profile模块快速访问接口
/// 提供全局访问Profile功能的便捷方法
class Profile {
  static const String _logTag = 'Profile';
  static ProfileServiceManager? _serviceManager;

  /// 获取服务管理器实例
  static ProfileServiceManager get serviceManager {
    return _serviceManager ??= ProfileServiceFactory.getInstance();
  }

  /// 初始化Profile模块
  static Future<void> initialize() async {
    try {
      developer.log('$_logTag: 开始初始化Profile模块');
      _serviceManager = ProfileServiceFactory.getInstance();
      developer.log('$_logTag: Profile模块初始化完成');
    } catch (e) {
      developer.log('$_logTag: Profile模块初始化失败 - $e');
      rethrow;
    }
  }

  /// 获取用户信息
  static Future<UserProfile?> getCurrentUser() async {
    try {
      const mockUserId = 'user_123456'; // 模拟用户ID
      return await serviceManager.getUserProfile(mockUserId);
    } catch (e) {
      developer.log('$_logTag: 获取当前用户失败 - $e');
      return null;
    }
  }

  /// 刷新用户数据
  static Future<void> refresh({bool forceRefresh = false}) async {
    try {
      developer.log('$_logTag: 刷新用户数据 - forceRefresh: $forceRefresh');
      const mockUserId = 'user_123456'; // 模拟用户ID
      await serviceManager.getCompleteUserData(mockUserId, forceRefresh: forceRefresh);
      developer.log('$_logTag: 用户数据刷新完成');
    } catch (e) {
      developer.log('$_logTag: 刷新用户数据失败 - $e');
    }
  }

  /// 清除缓存
  static Future<void> clearCache() async {
    try {
      developer.log('$_logTag: 清除Profile缓存');
      await serviceManager.clearUserDataCache();
      developer.log('$_logTag: Profile缓存清除完成');
    } catch (e) {
      developer.log('$_logTag: 清除Profile缓存失败 - $e');
    }
  }

  /// 销毁Profile模块
  static void dispose() {
    try {
      developer.log('$_logTag: 销毁Profile模块');
      _serviceManager = null;
      ProfileServiceFactory.resetInstance();
      developer.log('$_logTag: Profile模块销毁完成');
    } catch (e) {
      developer.log('$_logTag: 销毁Profile模块失败 - $e');
    }
  }
}

// ============== 4. 路由配置 ==============

/// 🛣️ Profile模块路由配置
class ProfileRoutes {
  static const String main = '/profile';
  static const String detail = '/profile/detail';
  static const String edit = '/profile/edit';
  static const String wallet = '/profile/wallet';
  static const String coins = '/profile/coins';
  static const String settings = '/profile/settings';

  /// 获取所有路由
  static Map<String, WidgetBuilder> get routes {
    return {
      main: (context) => ProfilePageFactory.createMainPageWithWrapper(),
      // 其他路由待实现...
    };
  }
}

// ============== 5. 配置类 ==============

/// ⚙️ Profile模块配置
class ProfileConfig {
  /// 是否启用调试模式
  static const bool debugMode = true;
  
  /// 默认头像大小
  static const double defaultAvatarSize = 80.0;
  
  /// 功能卡片大小
  static const double functionCardSize = 64.0;
  
  /// 主题颜色
  static const Color primaryColor = Color(0xFF8B5CF6);
  
  /// 渐变颜色
  static const List<Color> gradientColors = [
    Color(0xFF8A2BE2), // 紫色起点
    Color(0xFFB19CD9), // 浅紫色终点
  ];
  
  /// 功能颜色映射
  static const Map<String, Color> featureColors = {
    'personal_center': Color(0xFFFF9500), // 橙色
    'user_status': Color(0xFFFF3B30),     // 红色
    'wallet': Color(0xFF007AFF),          // 蓝色
    'coins': Color(0xFFFFD700),           // 金色
    'settings': Color(0xFF8A2BE2),        // 紫色
    'customer_service': Color(0xFF34C759), // 绿色
    'expert_verification': Color(0xFFFF69B4), // 粉色
  };
}

// ============== 6. 扩展方法 ==============

/// 🔧 BuildContext扩展方法
extension ProfileContextExtensions on BuildContext {
  /// 获取UserProfileProvider
  UserProfileProvider get userProfileProvider => read<UserProfileProvider>();
  
  /// 监听UserProfileProvider
  UserProfileProvider get userProfileProviderWatch => watch<UserProfileProvider>();
  
  /// 获取TransactionStatsProvider
  TransactionStatsProvider get transactionStatsProvider => read<TransactionStatsProvider>();
  
  /// 监听TransactionStatsProvider
  TransactionStatsProvider get transactionStatsProviderWatch => watch<TransactionStatsProvider>();
  
  /// 获取WalletProvider
  WalletProvider get walletProvider => read<WalletProvider>();
  
  /// 监听WalletProvider
  WalletProvider get walletProviderWatch => watch<WalletProvider>();
}
