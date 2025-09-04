// 🔐 用户认证系统统一导出
// 基于Flutter单文件架构的8段式结构设计

// ============== 核心认证功能 ==============

// 📱 认证页面
export 'pages/auth_page.dart';
export 'pages/register_page.dart';
export 'pages/profile_page.dart';
export 'pages/verification_page.dart';

// 📋 数据模型
export 'models/auth_models.dart';
export 'models/user_models.dart';
export 'models/profile_models.dart';

// 🔧 业务服务
export 'services/auth_services.dart';
export 'services/user_services.dart';
export 'services/verification_services.dart';

// 🧩 UI组件
export 'widgets/auth_widgets.dart';
export 'widgets/profile_widgets.dart';
export 'widgets/verification_widgets.dart';

// ⚙️ 配置文件
export 'config/auth_config.dart';

// 🛠️ 工具类
export 'utils/auth_utils.dart';
export 'utils/encryption_utils.dart';

// ============== 架构说明 ==============
/// 
/// 用户认证系统架构特性：
/// 
/// 🎯 核心功能：
/// - 手机号/邮箱注册登录
/// - 第三方登录（微信、QQ、支付宝）
/// - 实名认证体系
/// - 会员等级系统
/// - 安全设置管理
/// 
/// 🔒 安全特性：
/// - JWT Token 认证
/// - 密码加密存储
/// - 设备指纹识别
/// - 异常登录检测
/// - 隐私权限管理
/// 
/// 📱 用户体验：
/// - 快速登录流程
/// - 免密登录
/// - 记住登录状态
/// - 优雅的错误提示
/// - 无障碍支持
///
