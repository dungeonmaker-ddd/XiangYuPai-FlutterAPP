/// 🔐 登录模块统一导出文件
/// 
/// 现在主要使用 unified_login_page.dart (8段式单文件架构)
/// 保留必要的组件和配置供统一登录页面使用
/// 
/// 使用示例:
/// ```dart
/// import 'package:your_app/pages/login/unified_login_page.dart';
/// 
/// // 使用新的统一登录页面
/// Navigator.push(context, MaterialPageRoute(builder: (context) => UnifiedLoginPage()));
/// ```

// 🆕 新版统一登录页面
export 'unified_login_page.dart';

// 🧩 保留的组件 (供统一登录页面使用)
export 'widgets/country_selector.dart';
export 'widgets/country_bottom_sheet.dart';

// 📊 数据模型 (供统一登录页面使用)
export 'models/country_model.dart';
export 'models/auth_models.dart';

// 🔧 服务层 (供统一登录页面使用)
export 'services/auth_service.dart';

// 🆕 新版API管理器 (推荐使用)
export 'login_api.dart';

// ⚙️ 配置 (供统一登录页面使用)
export 'config/auth_config.dart';

// 🧪 调试工具 (仅在开发环境)
// export 'debug/api_test_page.dart'; // 文件不存在，暂时注释
