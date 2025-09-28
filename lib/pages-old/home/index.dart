/// 🏠 首页模块统一导出文件
/// 
/// 基于Flutter单文件架构规范，只导出统一的首页组件
/// 
/// 使用示例:
/// ```dart
/// import 'package:your_app/pages/home/index.dart';
/// 
/// // 使用统一首页
/// Navigator.push(
///   context, 
///   MaterialPageRoute(builder: (context) => UnifiedHomePage())
/// );
/// ```

// 📱 统一首页导出
export 'unified_home_page.dart';
export 'location_picker_page.dart';
export 'home_models.dart';
export 'home_services.dart';

// 🔍 搜索子模块导出
export 'search/index.dart';
