/// 🏠 首页模块统一导出文件
/// 
/// 这个文件提供了首页模块所有组件的统一入口，方便外部模块引用
/// 
/// 使用示例:
/// ```dart
/// import 'package:your_app/pages/home/index.dart';
/// 
/// // 直接使用首页
/// Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
/// 
/// // 或使用路由管理
/// HomeRoutes.toHomePage(context);
/// ```

// 📱 页面导出
export 'pages/home_page.dart';
export 'pages/location_picker_page.dart';

// 🧩 组件导出
export 'widgets/search_bar_widget.dart';
export 'widgets/category_grid_widget.dart';
export 'widgets/recommendation_card_widget.dart';
export 'widgets/user_profile_card.dart';
export 'widgets/svg_icon_widget.dart';

// 🧭 工具导出
export 'utils/home_routes.dart';

// 📊 模型导出
export 'models/user_model.dart';
export 'models/store_model.dart';
export 'models/category_model.dart';
export 'models/location_model.dart';

// 🔧 服务导出
export 'services/home_service.dart';

// ⚙️ 配置导出
export 'config/home_config.dart';
