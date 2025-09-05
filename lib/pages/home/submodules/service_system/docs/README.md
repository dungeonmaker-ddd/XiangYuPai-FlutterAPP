# 🎯 服务系统模块文档

## 📁 文件夹结构

```
service_system/
├── pages/                     # 页面文件夹
│   ├── filter/                # 筛选相关
│   │   └── service_filter_page.dart
│   ├── detail/                # 详情相关
│   │   └── service_detail_page.dart
│   ├── order/                 # 订单相关
│   │   ├── order_confirm_page.dart
│   │   └── payment_flow_page.dart
│   └── review/                # 评价相关
│       └── review_feedback_page.dart
├── models/                    # 数据模型文件夹
│   └── service_models.dart
├── services/                  # 业务服务文件夹
│   └── service_services.dart
├── widgets/                   # 可复用组件
│   └── service_widgets.dart
├── utils/                     # 工具类
│   ├── constants.dart         # 统一常量
│   ├── validators.dart        # 数据验证
│   └── formatters.dart        # 数据格式化
├── docs/                      # 文档
│   ├── README.md              # 模块说明
│   └── SERVICE_SYSTEM_ARCHITECTURE.md  # 架构文档
└── index.dart                 # 统一导出
```

## 📖 功能模块

### 🔍 筛选模块 (pages/filter/)
- `service_filter_page.dart` - 服务筛选页面
- 提供多维度筛选功能：排序、性别、状态、价格范围等

### 📋 详情模块 (pages/detail/)  
- `service_detail_page.dart` - 服务详情页面
- 展示服务完整信息、用户评价、相关推荐等

### 🛒 订单模块 (pages/order/)
- `order_confirm_page.dart` - 订单确认页面
- `payment_flow_page.dart` - 支付流程页面
- 处理下单、支付的完整流程

### 💬 评价模块 (pages/review/)
- `review_feedback_page.dart` - 评价反馈页面
- 用户服务完成后的评价与反馈

## 🛠️ 工具类

### 📊 常量配置 (utils/constants.dart)
- 颜色配置
- 尺寸配置  
- 动画配置
- 业务配置
- 支付方式配置

### 📋 数据验证 (utils/validators.dart)
- 服务信息验证
- 价格数量验证
- 评价内容验证
- 支付密码验证

### 🔧 数据格式化 (utils/formatters.dart)
- 价格格式化
- 时间格式化
- 距离格式化
- 状态格式化
- 输入格式化器

## 🚀 使用方式

### 导入整个模块
```dart
import 'package:your_app/pages/home/submodules/service_system/index.dart';
```

### 按需导入子模块
```dart
// 仅导入页面
import 'package:your_app/pages/home/submodules/service_system/pages/index.dart';

// 仅导入模型
import 'package:your_app/pages/home/submodules/service_system/models/index.dart';

// 仅导入工具类
import 'package:your_app/pages/home/submodules/service_system/utils/index.dart';
```

### 使用示例
```dart
// 使用筛选页面
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ServiceFilterPage(
      initialFilters: filters,
    ),
  ),
);

// 使用格式化工具
final priceText = ServiceSystemFormatters.formatPrice(29.9);
final distanceText = ServiceSystemFormatters.formatDistance(2.5);

// 使用验证工具
final validationResult = ServiceSystemValidators.validatePrice('29.9');
if (!validationResult.isValid) {
  showError(validationResult.errorMessage);
}
```

## 📈 架构特点

### 🎯 清晰的模块分离
- 页面按功能分组到不同文件夹
- 数据模型、服务、组件分离
- 工具类统一管理

### 🔧 高度可复用
- 统一的常量配置
- 标准化的验证和格式化工具
- 可复用的组件设计

### 📱 响应式设计
- 支持多种屏幕尺寸
- 统一的断点配置
- 灵活的布局适配

### 🎨 一致的设计语言
- 统一的颜色和字体配置
- 标准化的动画效果
- 一致的交互体验

## 🔄 状态管理

服务系统模块支持多种状态管理方案：
- Provider (推荐)
- Bloc/Cubit
- Riverpod
- GetX

## 🧪 测试支持

每个模块都可以独立进行单元测试和集成测试：
```dart
// 测试验证工具
test('should validate service price correctly', () {
  final result = ServiceSystemValidators.validatePrice('29.9');
  expect(result, isNull);
});

// 测试格式化工具  
test('should format price correctly', () {
  final formatted = ServiceSystemFormatters.formatPrice(29.9);
  expect(formatted, equals('29.9 金币/次'));
});
```

## 📝 更新日志

### v1.0.0
- 初始化服务系统模块
- 完成文件夹重组
- 添加完整的工具类支持
