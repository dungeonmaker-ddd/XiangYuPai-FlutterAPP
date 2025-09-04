# Flutter 架构规范 - AI驱动开发

## 📜 Flutter之禅 - 编程原则

- **简洁胜于复杂** - 优先使用StatelessWidget，状态管理选择适合的而非最强大的
- **组合优于继承** - 通过Widget组合构建UI，避免深层继承链
- **声明式优于命令式** - UI即函数f(state)，通过状态驱动界面更新
- **不可变优于可变** - 使用final/const，创建新对象而非修改现有对象
- **异步思维原生化** - 拥抱Future/Stream，async/await是一等公民
- **响应式而非被动式** - 监听数据流变化，而非主动轮询状态
- **分离关注点** - UI、业务逻辑、数据层职责明确，单向数据流
- **约定优于配置** - 遵循Flutter惯例，减少个性化配置
- **测试驱动信心** - Widget测试保证UI，单元测试保证逻辑
- **性能意识常在** - 避免不必要的rebuild，使用const构造函数

## 🏗️ 项目架构 - 标准多模块结构

```
lib/
├── main.dart                    # 应用入口: runApp() + 依赖注入
├── app.dart                     # App壳: MaterialApp路由、主题、国际化配置
│
├── modules/                     # 业务模块 - 按功能垂直切分
│   └── {feature}/              # 特性名称，如: auth, home, profile
│       ├── presentation/        # 展示层 (对标BLoC架构)
│       │   ├── pages/          # 页面：路由级别的Widget
│       │   ├── widgets/        # 组件：模块私有的UI片段
│       │   └── controllers/    # 状态管理：BLoC/Cubit/GetX/Riverpod
│       │
│       ├── domain/             # 领域层 (Clean Architecture)
│       │   ├── entities/       # 实体：核心业务对象
│       │   ├── repositories/   # 仓库接口：数据源抽象
│       │   └── usecases/       # 用例：业务规则实现
│       │
│       ├── data/               # 数据层 (Repository Pattern)
│       │   ├── models/         # 模型：JSON序列化，继承自Entity
│       │   ├── repositories/   # 仓库实现：整合多数据源
│       │   └── datasources/    # 数据源：API/Local/Cache
│       │
│       └── index.dart          # 模块导出：只暴露pages和必要的public API
│
├── core/                       # 核心层 - 基础设施（不含业务逻辑）
│   ├── network/                # 网络：Dio配置、拦截器、错误处理
│   ├── theme/                  # 主题：Material3设计系统
│   ├── router/                 # 路由：GoRouter/AutoRoute配置
│   └── di/                     # 依赖注入：GetIt/Injectable配置
│
└── shared/                     # 共享层 - 跨模块复用
    ├── widgets/                # 通用组件：设计系统实现
    ├── utils/                  # 工具类：扩展、辅助函数
    └── validators/             # 验证器：表单、业务规则验证
```

### 🎯 分层架构映射
- **Presentation** → View/ViewModel (MVVM) | Widget/Bloc (BLoC) | Page/Controller (MVC)
- **Domain** → 纯Dart代码，无Flutter依赖，包含业务规则
- **Data** → 数据获取和转换，Model知道如何序列化自己
- **Core** → 横切关注点，所有模块都需要但不含业务逻辑
- **Shared** → 可选的共享资源，避免重复代码

## 📄 单文件架构 - 快速原型实现

### 8段式结构定义

```dart
// {feature}_page.dart - 单文件完整实现 (~300-500行)

/*
1. IMPORTS      - 依赖导入 (10-15行)
2. CONSTANTS    - 常量配置 (15-25行)  
3. MODELS       - 数据模型 (30-50行)
4. SERVICES     - 业务逻辑 (40-80行)
5. CONTROLLERS  - 状态管理 (50-100行)
6. WIDGETS      - UI组件 (80-150行)
7. PAGES        - 页面视图 (60-100行)
8. EXPORTS      - 接口导出 (5-10行)
*/

// ============== 1. IMPORTS ==============
// Flutter官方 → 第三方 → 项目内

// ============== 2. CONSTANTS ==============
class _{Feature}Constants {
  // UI配置、颜色主题、业务常量
}

// ============== 3. MODELS ==============
// 实体模型(fromJson/toJson) + 状态模型(copyWith)

// ============== 4. SERVICES ==============  
// API调用、数据处理、错误处理

// ============== 5. CONTROLLERS ==============
// 状态管理：ValueNotifier/Provider/BLoC

// ============== 6. WIDGETS ==============
// 私有组件：_{Feature}{Component}命名

// ============== 7. PAGES ==============
// 页面入口：{Feature}Page类

// ============== 8. EXPORTS ==============
// 仅导出页面和必要公共接口
// 注意：实际的export语句应该放在文件顶部，这里仅作为注释说明
```

### 命名规范
- **文件名**: `{feature}_page.dart`
- **页面类**: `{Feature}Page`  
- **状态类**: `{Feature}Controller`
- **私有组件**: `_{Feature}{Component}`

## ✅ 最佳实践 - 2025现代移动端开发

### 状态管理策略
- **响应式优先**: 根据项目复杂度选择合适方案
- **渐进式升级**: 从简单到复杂，按需引入
- **团队一致性**: 项目内保持统一的状态管理模式

### 技术选型原则
- **成熟稳定**: 优先选择社区活跃、长期维护的方案
- **学习成本**: 平衡功能强大与团队掌握难度
- **项目适配**: 基于业务复杂度和团队规模选择

### 后端集成规范
- **RESTful API**: 与SpringBoot标准接口对接
- **统一响应格式**: 标准化数据传输协议
- **错误处理**: 客户端与服务端错误码统一
- **认证授权**: Token-based认证，支持刷新机制

## ⚠️ AI开发注意事项

- **智能推断**: 常量、配置等AI可推断的内容无需过度封装
- **关注核心**: 专注业务逻辑和架构设计，工具类按需创建
- **模式识别**: 遵循Flutter惯例，AI能识别并复用模式
- **增量开发**: 从核心功能开始，逐步完善周边设施

## 📐 架构决策记录 (ADR)

**Q: 为什么Feature-First而非Layer-First？**  
A: 提高内聚性，便于团队并行开发，模块可独立交付

**Q: 为什么分离Domain层？**  
A: 业务逻辑与Flutter解耦，可单独测试，便于迁移

**Q: 为什么Core不包含业务代码？**  
A: 保持稳定性，减少变更影响范围

**Q: 单文件 vs 多模块如何选择？**  
A: 单文件适用POC/原型，多模块适用生产项目

**Q: 如何与SpringBoot后端协作？**  
A: 遵循RESTful规范，统一数据格式，分离前后端关注点

## 🌐 移动端现代化开发要点

### 跨平台一致性
- **UI适配**: 遵循Material Design 3.0设计规范
- **性能优化**: 60fps流畅体验，合理的内存使用
- **用户体验**: 响应式布局，适配不同屏幕尺寸

### 与后端协作
- **API设计**: RESTful风格，语义化URL
- **数据格式**: JSON标准，字段命名一致性
- **版本管理**: API版本控制，向后兼容
- **错误处理**: HTTP状态码 + 业务错误码双重机制

### 现代开发工具链
- **代码生成**: 减少样板代码，提高开发效率
- **静态分析**: 代码质量保障，最佳实践检查
- **自动化测试**: 单元测试、Widget测试、集成测试
- **CI/CD流水线**: 自动构建、测试、部署

## 🚀 AI开发指令模板

```
任务：现代Flutter移动应用 - {功能}模块

目标平台：Android + iOS (2025现代标准)
后端技术：Java SpringBoot RESTful API

架构选择：
【单文件】快速原型/简单功能 (<500行)
【多模块】生产级应用 (Clean Architecture)

核心要求：
- 遵循Flutter之禅设计原则
- 适配Android/iOS平台差异
- 与SpringBoot后端标准化集成
- 支持响应式UI和数据流

开发约束：
- 类型安全：利用Dart空安全特性
- 性能导向：避免不必要的rebuild和内存泄漏
- 测试友好：业务逻辑与UI层分离
- 维护性：清晰的代码组织和文档

输出标准：
- 生产就绪的代码质量
- 标准化的错误处理
- 完整的数据流管理
- 现代化的UI/UX设计
```
