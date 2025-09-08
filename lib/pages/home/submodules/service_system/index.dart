// 🛍️ 服务系统模块统一导出
// Service System Module - Unified Exports

// ============== 核心页面导出 ==============
export 'pages/filter/service_filter_page.dart';     // 服务筛选页
export 'pages/detail/service_detail_page.dart';     // 服务详情页
export 'pages/order/order_confirm_page.dart';       // 下单确认页
export 'pages/order/payment_flow_page.dart';        // 支付流程页
export 'pages/review/review_feedback_page.dart';    // 评价反馈页

// ============== 数据模型导出 ==============
export 'models/service_models.dart';                // 所有数据模型和枚举

// ============== 业务服务导出 ==============
export 'services/service_services.dart';            // 业务逻辑服务

// ============== UI组件导出 ==============
export 'widgets/service_widgets.dart';              // 通用UI组件

/// 📋 模块说明
/// 
/// 本模块实现了完整的服务系统功能：
/// - 🔍 服务发现与筛选
/// - 📋 服务提供者详情展示
/// - ✅ 订单确认与管理
/// - 💳 支付流程处理
/// - ⭐ 评价反馈系统
/// 
/// 使用方式：
/// ```dart
/// import 'submodules/service_system/index.dart';
/// 
/// // 直接使用导出的组件
/// ServiceFilterPage(serviceType: ServiceType.game, serviceName: '英雄联盟陪练')
/// ```
