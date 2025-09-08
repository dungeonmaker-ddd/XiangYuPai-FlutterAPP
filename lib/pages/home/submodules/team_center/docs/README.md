# 🎯 组局中心模块文档

## 📁 文件夹结构

```
team_center/
├── pages/                     # 页面文件夹
│   ├── main/                  # 主页相关
│   ├── create/                # 创建组局相关
│   ├── join/                  # 报名相关
│   └── detail/                # 详情相关
├── models/                    # 数据模型文件夹
├── services/                  # 业务服务文件夹
├── widgets/                   # 可复用组件
├── utils/                     # 工具类
├── docs/                      # 文档
└── index.dart                 # 统一导出
```

## 📖 文档列表

- [组局发布支付功能架构设计.md](./组局发布支付功能架构设计.md) - 发布组局的支付流程设计
- [组局报名流程架构设计.md](./组局报名流程架构设计.md) - 报名流程的完整架构设计

## 🚀 使用方式

### 导入整个模块
```dart
import 'package:your_app/pages/home/submodules/team_center/index.dart';
```

### 按需导入子模块
```dart
// 仅导入页面
import 'package:your_app/pages/home/submodules/team_center/pages/index.dart';

// 仅导入模型
import 'package:your_app/pages/home/submodules/team_center/models/index.dart';

// 仅导入服务
import 'package:your_app/pages/home/submodules/team_center/services/index.dart';
```

## 🎨 设计原则

1. **文件夹分离**: 按功能模块分离文件夹，便于维护
2. **统一导出**: 每个文件夹都有index.dart统一导出
3. **清晰命名**: 文件和类名清晰表达其功能
4. **文档完整**: 重要功能都有对应的架构设计文档

## 🔧 开发规范

### 文件命名
- 页面文件：`xxx_page.dart`
- 模型文件：`xxx_models.dart`
- 服务文件：`xxx_services.dart`
- 组件文件：`xxx_widgets.dart`
- 工具文件：`xxx_utils.dart`

### 导出规范
- 每个文件夹必须有`index.dart`统一导出
- 公共类使用export导出，私有类不导出
- 按模块分组导出，添加清晰的注释
