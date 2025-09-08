# 📦 组局中心模块迁移指南

## 🎯 重组目标

为了更好地组织和维护组局中心模块的代码，我们对文件结构进行了重组，按功能模块分离到不同的文件夹中。

## 📁 新的文件夹结构

### 重组前
```
team_center/
├── team_center_main_page.dart
├── create_team_page.dart
├── create_team_page_enhanced.dart
├── create_team_dialogs.dart
├── join_confirm_page.dart
├── join_status_page.dart
├── join_waiting_page.dart
├── join_success_page.dart
├── join_failed_page.dart
├── join_payment_dialog.dart
├── team_detail_page.dart
├── team_models.dart
├── join_models.dart
├── team_services.dart
├── join_services.dart
└── index.dart
```

### 重组后
```
team_center/
├── pages/                     # 页面文件夹
│   ├── main/                  # 主页相关
│   │   └── team_center_main_page.dart
│   ├── create/                # 创建组局相关
│   │   ├── create_team_page.dart
│   │   ├── create_team_page_enhanced.dart
│   │   └── create_team_dialogs.dart
│   ├── join/                  # 报名相关
│   │   ├── join_confirm_page.dart
│   │   ├── join_status_page.dart
│   │   ├── join_waiting_page.dart
│   │   ├── join_success_page.dart
│   │   ├── join_failed_page.dart
│   │   └── join_payment_dialog.dart
│   ├── detail/                # 详情相关
│   │   └── team_detail_page.dart
│   └── index.dart             # 页面统一导出
├── models/                    # 数据模型文件夹
│   ├── team_models.dart
│   ├── join_models.dart
│   └── index.dart
├── services/                  # 业务服务文件夹
│   ├── team_services.dart
│   ├── join_services.dart
│   └── index.dart
├── widgets/                   # 可复用组件
│   └── index.dart
├── utils/                     # 工具类
│   ├── constants.dart
│   ├── validators.dart
│   ├── formatters.dart
│   ├── date_utils.dart
│   └── index.dart
├── docs/                      # 文档
│   ├── README.md
│   ├── MIGRATION_GUIDE.md
│   ├── 组局发布支付功能架构设计.md
│   └── 组局报名流程架构设计.md
└── index.dart                 # 统一导出
```

## 🔄 迁移步骤

### 1. 更新导入路径

#### 旧的导入方式
```dart
import 'package:your_app/pages/home/submodules/team_center/create_team_page.dart';
import 'package:your_app/pages/home/submodules/team_center/team_models.dart';
import 'package:your_app/pages/home/submodules/team_center/team_services.dart';
```

#### 新的导入方式（推荐）
```dart
// 导入整个模块
import 'package:your_app/pages/home/submodules/team_center/index.dart';

// 或者按需导入子模块
import 'package:your_app/pages/home/submodules/team_center/pages/index.dart';
import 'package:your_app/pages/home/submodules/team_center/models/index.dart';
import 'package:your_app/pages/home/submodules/team_center/services/index.dart';

// 或者导入具体文件
import 'package:your_app/pages/home/submodules/team_center/pages/create/create_team_page.dart';
```

### 2. 使用新的工具类

#### 使用统一的常量
```dart
// 旧方式：每个文件定义自己的常量
class _CreateTeamPageConstants {
  static const Color primaryPurple = Color(0xFF8B5CF6);
}

// 新方式：使用统一的常量
import 'package:your_app/pages/home/submodules/team_center/utils/index.dart';

// 使用 TeamCenterConstants.primaryPurple
```

#### 使用统一的验证器
```dart
// 新方式：使用统一的验证器
import 'package:your_app/pages/home/submodules/team_center/utils/index.dart';

String? error = TeamCenterValidators.validateTitle(titleValue);
```

#### 使用统一的格式化器
```dart
// 新方式：使用统一的格式化器
import 'package:your_app/pages/home/submodules/team_center/utils/index.dart';

String priceText = TeamCenterFormatters.formatPrice(price);
String timeText = TeamCenterFormatters.formatDateTime(dateTime);
```

## ⚠️ 向后兼容性

为了保证平滑迁移，我们在主`index.dart`文件中保留了对原始文件的导出，这意味着：

1. **现有代码无需立即修改** - 原有的导入路径仍然有效
2. **建议逐步迁移** - 可以在新功能中使用新的结构
3. **计划移除时间** - 兼容性导出将在下个主要版本中移除

## 📚 最佳实践

### 1. 新项目建议
- 直接使用新的文件夹结构
- 按模块导入所需的功能
- 使用统一的工具类和常量

### 2. 现有项目迁移
- 逐步将导入路径更新为新结构
- 将散落的常量和工具方法迁移到utils模块
- 提取可复用的组件到widgets模块

### 3. 组件开发
- 新组件放在对应的子文件夹中
- 遵循命名规范：`xxx_page.dart`, `xxx_models.dart`等
- 每个子模块都要有`index.dart`统一导出

## 🚀 示例代码

### 创建新页面
```dart
// 文件位置: pages/create/my_new_create_page.dart
import 'package:flutter/material.dart';
import '../../utils/index.dart';  // 使用相对路径导入工具类
import '../../models/index.dart'; // 使用相对路径导入模型

class MyNewCreatePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TeamCenterConstants.backgroundGray,
      // ... 其他实现
    );
  }
}

// 在pages/create/index.dart中添加导出
export 'my_new_create_page.dart';
```

### 创建新组件
```dart
// 文件位置: widgets/team_status_badge.dart
import 'package:flutter/material.dart';
import '../utils/index.dart';
import '../models/index.dart';

class TeamStatusBadge extends StatelessWidget {
  final TeamStatus status;
  
  const TeamStatusBadge({super.key, required this.status});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(),
        borderRadius: BorderRadius.circular(TeamCenterConstants.cardBorderRadius / 2),
      ),
      child: Text(
        status.displayName,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
    );
  }
  
  Color _getStatusColor() {
    switch (status) {
      case TeamStatus.recruiting:
        return TeamCenterConstants.successGreen;
      case TeamStatus.confirmed:
        return TeamCenterConstants.primaryPurple;
      // ... 其他状态
      default:
        return TeamCenterConstants.textSecondary;
    }
  }
}

// 在widgets/index.dart中添加导出
export 'team_status_badge.dart';
```

## 🔍 迁移检查清单

- [ ] 更新导入路径为新的模块结构
- [ ] 将散落的常量迁移到`utils/constants.dart`
- [ ] 将验证逻辑迁移到`utils/validators.dart`
- [ ] 将格式化逻辑迁移到`utils/formatters.dart`
- [ ] 提取可复用组件到`widgets/`文件夹
- [ ] 更新文档和注释
- [ ] 测试所有功能正常工作
- [ ] 移除旧的兼容性导出（在下个版本）
