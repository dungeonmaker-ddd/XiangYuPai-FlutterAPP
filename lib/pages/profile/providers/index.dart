// 🧠 个人信息模块状态管理导出文件
// 统一导出所有Provider，便于其他模块引用

// 导出核心Provider
export 'profile_providers.dart';

// 重新导出常用Provider类，方便使用
export 'profile_providers.dart' show
    UserProfileProvider,
    TransactionStatsProvider,
    WalletProvider,
    FeatureConfigProvider,
    ProfileProvider;
