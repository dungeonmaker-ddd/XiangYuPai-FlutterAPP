/// 🔐 登录模块统一导出文件
/// 
/// 这个文件提供了登录模块所有组件的统一入口，方便外部模块引用
/// 
/// 使用示例:
/// ```dart
/// import 'package:your_app/pages/login/index.dart';
/// 
/// // 直接使用登录页面
/// Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
/// 
/// // 或使用路由管理
/// LoginRoutes.toPasswordLogin(context);
/// ```

// 📱 页面导出
export 'pages/login_page.dart';
export 'pages/mobile_login_page.dart';
export 'pages/forgot_password_page.dart';
export 'pages/verify_code_page.dart';
export 'pages/reset_password_page.dart';

// 🧩 组件导出
export 'widgets/phone_input_widget.dart';
export 'widgets/password_input_widget.dart';
export 'widgets/code_input_widget.dart';
export 'widgets/country_selector.dart';
export 'widgets/country_bottom_sheet.dart';

// 🧭 工具导出
export 'utils/login_routes.dart';

// 📊 模型导出
export 'models/country_model.dart';
export 'models/auth_models.dart';

// 🔧 服务导出
export 'services/auth_service.dart';

// ⚙️ 配置导出
export 'config/auth_config.dart';

// 🧪 调试工具导出 (仅在开发环境)
export 'debug/api_test_page.dart';
