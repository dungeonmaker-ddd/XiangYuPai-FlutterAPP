// 🎨 个人信息模块UI组件导出文件
// 统一导出所有UI组件，便于其他模块引用

// 导出核心组件
export 'profile_widgets.dart';

// 重新导出常用组件类，方便使用
export 'profile_widgets.dart' show
    UserAvatarWidget,
    UserStatusIndicator,
    FunctionCard,
    TransactionStatsCard,
    WalletInfoCard,
    ProfileLoadingWidget,
    ProfileErrorWidget;
