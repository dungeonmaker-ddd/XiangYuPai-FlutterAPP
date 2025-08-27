/// 🎨 Flutter Widget组件库
/// 
/// 这个文件导出了项目中所有的通用组件，
/// 使用时只需要导入这一个文件即可访问所有组件。
/// 
/// 使用方式：
/// ```dart
/// import '../widgets/index.dart';
/// ```

// 通用组件
export 'common_widgets.dart';

// 表单组件
export 'form_widgets.dart';

// 按钮组件
export 'button_widgets.dart';

// 布局组件
export 'layout_widgets.dart';

/// 📚 组件库说明
/// 
/// ## 🎨 通用组件 (common_widgets.dart)
/// - CustomAppBar: 自定义应用栏
/// - MessageSnackBar: 消息提示
/// - LoadingWidget: 加载指示器
/// - EmptyStateWidget: 空状态页面
/// - CustomCard: 卡片容器
/// 
/// ## 📝 表单组件 (form_widgets.dart)
/// - CustomTextField: 通用输入框
/// - CustomDropdown: 下拉选择器
/// - CustomCheckbox: 复选框
/// - CustomRadioGroup: 单选框组
/// - CustomDatePicker: 日期选择器
/// 
/// ## 🔘 按钮组件 (button_widgets.dart)
/// - PrimaryButton: 主要按钮
/// - SecondaryButton: 次要按钮
/// - CustomTextButton: 文本按钮
/// - CircleIconButton: 圆形图标按钮
/// - TagButton: 标签按钮
/// - CustomFloatingActionButton: 浮动操作按钮
/// - ToggleButton: 切换按钮
/// 
/// ## 📐 布局组件 (layout_widgets.dart)
/// - SafeContainer: 安全区域容器
/// - Gap: 间距组件
/// - CenterLoadingContainer: 中心加载容器
/// - SectionHeader: 标题分割线
/// - ListItemContainer: 列表项容器
/// - CollapsibleContainer: 可折叠容器
/// - AppScaffold: 脚手架容器
/// 
/// ## 🎯 使用示例
/// 
/// ```dart
/// // 导入组件库
/// import '../widgets/index.dart';
/// 
/// class MyPage extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return AppScaffold(
///       title: '示例页面',
///       body: Column(
///         children: [
///           // 使用自定义卡片
///           CustomCard(
///             child: Text('卡片内容'),
///           ),
///           Gap(16), // 间距
///           // 使用主要按钮
///           PrimaryButton(
///             text: '确认',
///             onPressed: () {
///               MessageSnackBar.show(context, '操作成功！');
///             },
///           ),
///         ],
///       ),
///     );
///   }
/// }
/// ```
