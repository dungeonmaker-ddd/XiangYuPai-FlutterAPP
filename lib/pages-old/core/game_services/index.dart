// 🎮 游戏服务模块统一导出
// 基于Flutter单文件架构的8段式结构设计

// ============== 游戏服务功能 ==============

// 📱 服务页面
export 'pages/game_lobby_page.dart';
export 'pages/game_order_page.dart';
export 'pages/game_match_page.dart';
export 'pages/skill_assessment_page.dart';

// 📋 数据模型
export 'models/game_models.dart';
export 'models/order_models.dart';
export 'models/skill_models.dart';

// 🔧 业务服务
export 'services/game_services.dart';
export 'services/match_services.dart';
export 'services/skill_services.dart';

// 🧩 UI组件
export 'widgets/game_widgets.dart';
export 'widgets/order_widgets.dart';
export 'widgets/skill_widgets.dart';

// ⚙️ 配置文件
export 'config/game_config.dart';

// 🛠️ 工具类
export 'utils/game_utils.dart';
export 'utils/rank_utils.dart';

// ============== 架构说明 ==============
/// 
/// 游戏服务模块架构特性：
/// 
/// 🎯 核心游戏：
/// - 王者荣耀陪练服务
/// - 英雄联盟陪练服务
/// - 和平精英陪练服务
/// - 荒野乱斗陪练服务
/// - 其他热门游戏
/// 
/// 🏆 技能系统：
/// - 段位等级认证
/// - 技能专长标签
/// - 游戏成就展示
/// - 胜率统计分析
/// - 历史战绩记录
/// 
/// 💼 服务功能：
/// - 智能匹配系统
/// - 订单管理流程
/// - 服务质量评价
/// - 收益结算系统
/// - 纠纷处理机制
/// 
/// 🤖 智能特性：
/// - 基于技能的匹配
/// - 游戏时间偏好
/// - 用户评价算法
/// - 价格策略优化
/// - 服务质量监控
///
