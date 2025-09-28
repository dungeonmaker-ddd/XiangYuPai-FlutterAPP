/// 🎯 组局中心模块统一导出文件
/// 
/// 重组后的文件夹结构提供了更清晰的模块组织方式
/// 
/// 文件夹结构：
/// ```
/// team_center/
/// ├── pages/          # 页面文件夹
/// ├── models/         # 数据模型文件夹  
/// ├── services/       # 业务服务文件夹
/// ├── widgets/        # 可复用组件
/// ├── utils/          # 工具类
/// ├── docs/           # 文档
/// └── index.dart      # 统一导出
/// ```
/// 
/// 使用示例:
/// ```dart
/// // 导入整个模块
/// import 'package:your_app/pages/home/submodules/team_center/index.dart';
/// 
/// // 按需导入子模块
/// import 'package:your_app/pages/home/submodules/team_center/pages/index.dart';
/// import 'package:your_app/pages/home/submodules/team_center/models/index.dart';
/// ```

// ========== 核心模块导出 ==========

// 📱 页面模块（按文件夹重新组织）
export 'pages/index.dart';
export 'pages/main/team_center_main_page.dart'; // 组局中心主页面

// 📊 数据模型模块
export 'models/index.dart';

// 🔧 业务服务模块  
export 'services/index.dart';

// 🧩 可复用组件模块
export 'widgets/index.dart';

// 🛠️ 工具类模块
export 'utils/index.dart';

// ========== 兼容性导出（向后兼容） ==========
// 为了保持向后兼容，继续导出原始文件
// 这些导出将在下个版本中移除

// 原始页面文件（向后兼容）
export 'pages/detail/team_detail_page.dart';
export 'pages/create/create_team_page.dart';
export 'pages/create/create_team_page_enhanced.dart';
export 'pages/create/create_team_dialogs.dart';
export 'pages/join/join_confirm_page.dart';
export 'pages/join/join_status_page.dart';
export 'pages/join/join_payment_dialog.dart';
export 'pages/join/join_waiting_page.dart';
export 'pages/join/join_success_page.dart';
export 'pages/join/join_failed_page.dart';

// 原始模型文件（向后兼容）
export 'models/team_models.dart';
export 'models/join_models.dart';

// 原始服务文件（向后兼容）
export 'services/team_services.dart';
export 'services/join_services.dart';
