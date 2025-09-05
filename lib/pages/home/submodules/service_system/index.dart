/// 🎯 服务系统模块统一导出文件
/// 
/// 重组后的文件夹结构提供了更清晰的模块组织方式
/// 
/// 文件夹结构：
/// - pages/: 页面文件夹（按功能分组）
/// - models/: 数据模型文件夹
/// - services/: 业务服务文件夹  
/// - widgets/: 可复用组件文件夹
/// - utils/: 工具类文件夹
/// - docs/: 文档文件夹

// 📱 页面模块导出
export 'pages/index.dart';

// 📊 数据模型导出
export 'models/index.dart';

// 🔧 业务服务导出
export 'services/index.dart';

// 🧩 可复用组件导出
export 'widgets/index.dart';

// 🛠️ 工具类导出
export 'utils/index.dart';

/// 📋 模块说明
/// 
/// 本模块实现了完整的服务系统功能：
/// - 🔍 服务发现与筛选 (pages/filter/)
/// - 📋 服务提供者详情展示 (pages/detail/)
/// - 🛒 订单确认与管理 (pages/order/)
/// - 💳 支付流程处理 (pages/order/)
/// - ⭐ 评价反馈系统 (pages/review/)
/// 
/// 使用方式：
/// ```dart
/// import 'package:your_app/pages/home/submodules/service_system/index.dart';
/// 
/// // 使用筛选页面
/// Navigator.push(context, MaterialPageRoute(builder: (context) => ServiceFilterPage()));
/// 
/// // 使用格式化工具
/// final priceText = ServiceSystemFormatters.formatPrice(29.9);
/// ```
