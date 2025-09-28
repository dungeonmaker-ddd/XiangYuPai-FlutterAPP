// 💰 交易支付模块统一导出
// 基于Flutter单文件架构的8段式结构设计

// ============== 交易支付功能 ==============

// 📱 支付页面
export 'pages/payment_page.dart';
export 'pages/wallet_page.dart';
export 'pages/order_page.dart';
export 'pages/recharge_page.dart';
export 'pages/withdraw_page.dart';

// 📋 数据模型
export 'models/payment_models.dart';
export 'models/wallet_models.dart';
export 'models/transaction_models.dart';

// 🔧 业务服务
export 'services/payment_services.dart';
export 'services/wallet_services.dart';
export 'services/order_services.dart';

// 🧩 UI组件
export 'widgets/payment_widgets.dart';
export 'widgets/wallet_widgets.dart';
export 'widgets/order_widgets.dart';

// ⚙️ 配置文件
export 'config/payment_config.dart';

// 🛠️ 工具类
export 'utils/payment_utils.dart';
export 'utils/currency_utils.dart';

// ============== 架构说明 ==============
/// 
/// 交易支付模块架构特性：
/// 
/// 💳 支付方式：
/// - 微信支付
/// - 支付宝支付
/// - 银行卡支付
/// - 余额支付
/// - 花呗分期
/// 
/// 👛 钱包系统：
/// - 余额管理
/// - 收益统计
/// - 交易记录
/// - 提现功能
/// - 冻结资金管理
/// 
/// 📋 订单管理：
/// - 订单创建流程
/// - 支付状态跟踪
/// - 退款处理
/// - 纠纷仲裁
/// - 发票开具
/// 
/// 🔄 资金流转：
/// - 实时到账
/// - T+1结算
/// - 手续费计算
/// - 风险控制
/// - 合规审核
/// 
/// 📊 财务报表：
/// - 收支明细
/// - 月度账单
/// - 年度报告
/// - 税务凭证
/// - 数据导出
/// 
/// 🛡️ 安全保障：
/// - 支付密码
/// - 指纹/面容支付
/// - 风险识别
/// - 异常监控
/// - 资金保护
///
