// 💬 社交通讯系统统一导出
// 基于Flutter单文件架构的8段式结构设计

// ============== 社交通讯功能 ==============

// 📱 社交页面
export 'pages/chat_page.dart';
export 'pages/contacts_page.dart';
export 'pages/moments_page.dart';
export 'pages/voice_call_page.dart';
export 'pages/video_call_page.dart';

// 📋 数据模型
export 'models/chat_models.dart';
export 'models/contact_models.dart';
export 'models/message_models.dart';

// 🔧 业务服务
export 'services/chat_services.dart';
export 'services/call_services.dart';
export 'services/moments_services.dart';

// 🧩 UI组件
export 'widgets/chat_widgets.dart';
export 'widgets/message_widgets.dart';
export 'widgets/call_widgets.dart';

// ⚙️ 配置文件
export 'config/social_config.dart';

// 🛠️ 工具类
export 'utils/message_utils.dart';
export 'utils/emoji_utils.dart';

// ============== 架构说明 ==============
/// 
/// 社交通讯系统架构特性：
/// 
/// 💬 即时通讯：
/// - 实时消息收发
/// - 表情包支持
/// - 文件传输功能
/// - 语音消息
/// - 图片视频分享
/// 
/// 📞 音视频通话：
/// - 一对一语音通话
/// - 一对一视频通话
/// - 多人语音会议
/// - 屏幕共享功能
/// - 通话录制
/// 
/// 🌟 动态社区：
/// - 个人动态发布
/// - 图文视频内容
/// - 点赞评论互动
/// - 话题标签系统
/// - 隐私权限控制
/// 
/// 👥 好友系统：
/// - 好友添加管理
/// - 分组标签功能
/// - 在线状态显示
/// - 黑名单管理
/// - 推荐好友算法
/// 
/// 🔔 消息推送：
/// - 实时消息提醒
/// - 离线消息同步
/// - 免打扰模式
/// - 消息摘要推送
/// - 自定义提醒设置
///
