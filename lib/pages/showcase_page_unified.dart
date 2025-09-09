// 🔧 调试展示页面 - 8段式单文件架构实现
// 展示如何将复杂调试页面也按照单文件架构组织

// ============== 1. IMPORTS ==============
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

// 现有模块导入
import 'login/unified_login_page.dart';
import 'login_demo_page.dart';
import 'home/index.dart';
import 'discovery/index.dart';
import 'main_tab_page.dart';

// ============== 2. CONSTANTS ==============
class _ShowcaseConstants {
  // 颜色配置
  static const Color primaryColor = Colors.green;
  static const Color backgroundColor = Color(0xFF212121); // Colors.black87
  static const Color surfaceColor = Color(0xFF303030); // Colors.grey[900]
  static const Color surfaceLightColor = Color(0xFF424242); // Colors.grey[850]
  static const Color textPrimaryColor = Colors.green;
  static const Color textSecondaryColor = Color(0xFF9E9E9E); // Colors.grey[400]
  static const Color textTertiaryColor = Color(0xFF757575); // Colors.grey[500]
  static const Color accentColor = Colors.cyan;
  static const Color warningColor = Colors.yellow;
  
  // 尺寸配置
  static const double spacing = 16.0;
  static const double smallSpacing = 8.0;
  static const double largeSpacing = 20.0;
  static const double borderRadius = 4.0;
  static const double iconSize = 20.0;
  static const double smallIconSize = 18.0;
  
  // 文本样式配置
  static const String fontFamily = 'monospace';
  static const double titleFontSize = 16.0;
  static const double subtitleFontSize = 14.0;
  static const double bodyFontSize = 12.0;
  static const double captionFontSize = 11.0;
  static const double smallFontSize = 10.0;
  
  // 系统信息
  static const String systemInfo = 
    'SYSTEM INFO:\n'
    'Flutter Debug Build\n'
    'Development Mode: ON\n'
    'Hot Reload: ENABLED\n'
    'Architecture: Single-File + Multi-Module\n'
    'State Management: ValueNotifier + Provider';
  
  // 设备信息
  static const String deviceInfo = 
    'Platform: Flutter\n'
    'OS: Unknown\n'
    'Screen: Dynamic\n'
    'Memory: Available\n'
    'Storage: Available';
}

// ============== 3. MODELS ==============
/// 调试选项类型枚举
enum DebugOptionType {
  toggle,    // 可展开/收缩的选项
  action,    // 直接执行的操作
  navigation, // 导航到其他页面
}

/// 调试选项数据模型
class DebugOption {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final DebugOptionType type;
  final VoidCallback? onTap;
  final List<DebugOption>? children;
  final bool isNew;
  final bool isLegacy;
  
  const DebugOption({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    this.onTap,
    this.children,
    this.isNew = false,
    this.isLegacy = false,
  });
}

/// 展示页面状态模型
class ShowcaseState {
  final Map<String, bool> expandedOptions;
  final bool isLoading;
  final String? message;
  
  const ShowcaseState({
    this.expandedOptions = const {},
    this.isLoading = false,
    this.message,
  });
  
  ShowcaseState copyWith({
    Map<String, bool>? expandedOptions,
    bool? isLoading,
    String? message,
  }) {
    return ShowcaseState(
      expandedOptions: expandedOptions ?? this.expandedOptions,
      isLoading: isLoading ?? this.isLoading,
      message: message,
    );
  }
  
  bool isExpanded(String optionId) {
    return expandedOptions[optionId] ?? false;
  }
}

// ============== 4. SERVICES ==============
class _ShowcaseService {
  /// 模拟系统信息获取
  static Future<Map<String, String>> getSystemInfo() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'platform': 'Flutter',
      'mode': 'Debug',
      'hotReload': 'Enabled',
      'architecture': 'Single-File + Multi-Module',
      'stateManagement': 'ValueNotifier + Provider',
    };
  }
  
  /// 模拟设备信息获取
  static Future<Map<String, String>> getDeviceInfo() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'platform': 'Flutter',
      'os': 'Unknown',
      'screen': 'Dynamic',
      'memory': 'Available',
      'storage': 'Available',
    };
  }
  
  /// 模拟网络测试
  static Future<bool> testNetwork() async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }
  
  /// 模拟缓存清理
  static Future<void> clearCache() async {
    await Future.delayed(const Duration(seconds: 1));
  }
}

// ============== 5. CONTROLLERS ==============
class _ShowcaseController extends ValueNotifier<ShowcaseState> {
  _ShowcaseController() : super(const ShowcaseState());
  
  /// 切换选项展开状态
  void toggleOption(String optionId) {
    final newExpanded = Map<String, bool>.from(value.expandedOptions);
    newExpanded[optionId] = !value.isExpanded(optionId);
    
    value = value.copyWith(expandedOptions: newExpanded);
  }
  
  /// 显示消息
  void showMessage(String message) {
    value = value.copyWith(message: message);
    
    // 3秒后清除消息
    Timer(const Duration(seconds: 3), () {
      if (value.message == message) {
        value = value.copyWith(message: null);
      }
    });
  }
  
  /// 设置加载状态
  void setLoading(bool loading) {
    value = value.copyWith(isLoading: loading);
  }
  
  /// 执行网络测试
  Future<void> testNetwork() async {
    setLoading(true);
    try {
      final success = await _ShowcaseService.testNetwork();
      showMessage(success ? 'Network test successful' : 'Network test failed');
    } catch (e) {
      showMessage('Network test error: $e');
    } finally {
      setLoading(false);
    }
  }
  
  /// 清理缓存
  Future<void> clearCache() async {
    setLoading(true);
    try {
      await _ShowcaseService.clearCache();
      showMessage('Cache cleared successfully');
    } catch (e) {
      showMessage('Cache clear error: $e');
    } finally {
      setLoading(false);
    }
  }
}

// ============== 6. WIDGETS ==============
/// 系统信息卡片组件
class _SystemInfoCard extends StatelessWidget {
  const _SystemInfoCard();
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _ShowcaseConstants.surfaceColor,
        border: Border.all(color: _ShowcaseConstants.primaryColor, width: 1),
        borderRadius: BorderRadius.circular(_ShowcaseConstants.borderRadius),
      ),
      child: const Text(
        _ShowcaseConstants.systemInfo,
        style: TextStyle(
          color: _ShowcaseConstants.textPrimaryColor,
          fontFamily: _ShowcaseConstants.fontFamily,
          fontSize: _ShowcaseConstants.bodyFontSize,
        ),
      ),
    );
  }
}

/// 调试选项切换组件
class _ToggleOption extends StatelessWidget {
  final DebugOption option;
  final bool isExpanded;
  final VoidCallback onToggle;
  
  const _ToggleOption({
    required this.option,
    required this.isExpanded,
    required this.onToggle,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: _ShowcaseConstants.smallSpacing),
      child: ListTile(
        leading: Icon(
          option.icon,
          color: _ShowcaseConstants.textPrimaryColor,
          size: _ShowcaseConstants.iconSize,
        ),
        title: Text(
          option.title,
          style: const TextStyle(
            color: _ShowcaseConstants.textPrimaryColor,
            fontFamily: _ShowcaseConstants.fontFamily,
            fontSize: _ShowcaseConstants.subtitleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          option.description,
          style: const TextStyle(
            color: _ShowcaseConstants.textSecondaryColor,
            fontFamily: _ShowcaseConstants.fontFamily,
            fontSize: _ShowcaseConstants.captionFontSize,
          ),
        ),
        trailing: Icon(
          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          color: _ShowcaseConstants.textPrimaryColor,
          size: _ShowcaseConstants.iconSize,
        ),
        onTap: onToggle,
        tileColor: _ShowcaseConstants.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_ShowcaseConstants.borderRadius),
          side: BorderSide(color: _ShowcaseConstants.textPrimaryColor.withOpacity(0.3)),
        ),
      ),
    );
  }
}

/// 子选项组件
class _SubOption extends StatelessWidget {
  final DebugOption option;
  
  const _SubOption({required this.option});
  
  @override
  Widget build(BuildContext context) {
    Color textColor = _ShowcaseConstants.textPrimaryColor.withOpacity(0.8);
    String title = option.title;
    
    // 特殊样式处理
    if (option.isNew) {
      textColor = _ShowcaseConstants.textPrimaryColor;
      title = option.title; // 保持原有的emoji
    } else if (option.isLegacy) {
      textColor = _ShowcaseConstants.textSecondaryColor;
    }
    
    return Container(
      margin: const EdgeInsets.only(
        bottom: 4, 
        left: _ShowcaseConstants.spacing,
      ),
      child: ListTile(
        leading: Icon(
          option.icon,
          color: textColor,
          size: _ShowcaseConstants.smallIconSize,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontFamily: _ShowcaseConstants.fontFamily,
            fontSize: 13,
            fontWeight: option.isNew ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        subtitle: Text(
          option.description,
          style: TextStyle(
            color: option.isLegacy 
                ? _ShowcaseConstants.textTertiaryColor 
                : _ShowcaseConstants.textSecondaryColor,
            fontFamily: _ShowcaseConstants.fontFamily,
            fontSize: _ShowcaseConstants.smallFontSize,
          ),
        ),
        onTap: option.onTap,
        tileColor: _ShowcaseConstants.surfaceLightColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_ShowcaseConstants.borderRadius),
          side: BorderSide(color: textColor.withOpacity(0.2)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        minLeadingWidth: 20,
      ),
    );
  }
}

/// 普通调试选项组件
class _DebugOption extends StatelessWidget {
  final DebugOption option;
  
  const _DebugOption({required this.option});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: _ShowcaseConstants.smallSpacing),
      child: ListTile(
        leading: Icon(
          option.icon,
          color: _ShowcaseConstants.textPrimaryColor,
          size: _ShowcaseConstants.iconSize,
        ),
        title: Text(
          option.title,
          style: const TextStyle(
            color: _ShowcaseConstants.textPrimaryColor,
            fontFamily: _ShowcaseConstants.fontFamily,
            fontSize: _ShowcaseConstants.subtitleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          option.description,
          style: const TextStyle(
            color: _ShowcaseConstants.textSecondaryColor,
            fontFamily: _ShowcaseConstants.fontFamily,
            fontSize: _ShowcaseConstants.captionFontSize,
          ),
        ),
        onTap: option.onTap,
        tileColor: _ShowcaseConstants.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_ShowcaseConstants.borderRadius),
          side: BorderSide(color: _ShowcaseConstants.textPrimaryColor.withOpacity(0.3)),
        ),
      ),
    );
  }
}

/// 消息提示组件
class _MessageDisplay extends StatelessWidget {
  final String? message;
  
  const _MessageDisplay({this.message});
  
  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.only(bottom: _ShowcaseConstants.spacing),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _ShowcaseConstants.surfaceColor,
        borderRadius: BorderRadius.circular(_ShowcaseConstants.borderRadius),
        border: Border.all(color: _ShowcaseConstants.primaryColor),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: _ShowcaseConstants.primaryColor,
            size: _ShowcaseConstants.iconSize,
          ),
          const SizedBox(width: _ShowcaseConstants.smallSpacing),
          Expanded(
            child: Text(
              message!,
              style: const TextStyle(
                color: _ShowcaseConstants.textPrimaryColor,
                fontFamily: _ShowcaseConstants.fontFamily,
                fontSize: _ShowcaseConstants.bodyFontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============== 7. PAGES ==============
/// 统一展示页面 - 主页面入口
class ShowcasePageUnified extends StatefulWidget {
  const ShowcasePageUnified({super.key});
  
  @override
  State<ShowcasePageUnified> createState() => _ShowcasePageUnifiedState();
}

class _ShowcasePageUnifiedState extends State<ShowcasePageUnified> {
  late final _ShowcaseController _controller;
  late final List<DebugOption> _debugOptions;
  
  @override
  void initState() {
    super.initState();
    _controller = _ShowcaseController();
    _debugOptions = _buildDebugOptions();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  /// 构建调试选项列表
  List<DebugOption> _buildDebugOptions() {
    return [
      // 登录模块
      DebugOption(
        id: 'login',
        title: '[1] LOGIN MODULE',
        description: 'Authentication & User Management',
        icon: Icons.account_circle,
        type: DebugOptionType.toggle,
        children: [
          DebugOption(
            id: 'unified_login',
            title: '[1.0] 🆕 UNIFIED LOGIN',
            description: '⭐ New single-file architecture login',
            icon: Icons.stars,
            type: DebugOptionType.navigation,
            isNew: true,
            onTap: () => _navigateToUnifiedLogin(),
          ),
          DebugOption(
            id: 'login_demo',
            title: '[1.0] 🎯 LOGIN DEMO',
            description: '⭐ Complete login demo page',
            icon: Icons.play_circle_filled,
            type: DebugOptionType.navigation,
            isNew: true,
            onTap: () => _navigateToLoginDemo(),
          ),
          DebugOption(
            id: 'password_login',
            title: '[1.1] PASSWORD LOGIN',
            description: 'Mobile phone + password login (Legacy)',
            icon: Icons.login,
            type: DebugOptionType.navigation,
            isLegacy: true,
            onTap: () => _navigateToLogin(),
          ),
          DebugOption(
            id: 'sms_login',
            title: '[1.2] SMS LOGIN',
            description: 'Mobile phone SMS verification (Legacy)',
            icon: Icons.phone_android,
            type: DebugOptionType.navigation,
            isLegacy: true,
            onTap: () => _navigateToMobileLogin(),
          ),
          DebugOption(
            id: 'forgot_password',
            title: '[1.3] FORGOT PASSWORD',
            description: 'Password recovery flow (Legacy)',
            icon: Icons.lock_reset,
            type: DebugOptionType.navigation,
            isLegacy: true,
            onTap: () => _navigateToForgotPassword(),
          ),
          DebugOption(
            id: 'verify_code',
            title: '[1.4] VERIFY CODE',
            description: 'SMS verification code page (Legacy)',
            icon: Icons.security,
            type: DebugOptionType.navigation,
            isLegacy: true,
            onTap: () => _navigateToVerifyCode(),
          ),
          DebugOption(
            id: 'reset_password',
            title: '[1.5] RESET PASSWORD',
            description: 'Password reset page (Legacy)',
            icon: Icons.key,
            type: DebugOptionType.navigation,
            isLegacy: true,
            onTap: () => _navigateToResetPassword(),
          ),
        ],
      ),
      
      // 首页模块
      DebugOption(
        id: 'home',
        title: '[2] HOME MODULE',
        description: 'Homepage & User Discovery',
        icon: Icons.home,
        type: DebugOptionType.toggle,
        children: [
          DebugOption(
            id: 'main_tab_page',
            title: '[2.1] 🆕 MAIN TAB PAGE',
            description: '⭐ Unified tab navigation with refactored home',
            icon: Icons.dashboard,
            type: DebugOptionType.navigation,
            isNew: true,
            onTap: () => _navigateToMainTabPage(),
          ),
          DebugOption(
            id: 'home_page_standalone',
            title: '[2.2] STANDALONE HOME',
            description: 'Direct home page (with own bottom nav)',
            icon: Icons.home_outlined,
            type: DebugOptionType.navigation,
            onTap: () => _navigateToHomePage(),
          ),
          DebugOption(
            id: 'search_bar',
            title: '[2.3] SEARCH BAR',
            description: 'Search functionality test',
            icon: Icons.search,
            type: DebugOptionType.action,
            onTap: () => _controller.showMessage('Search Bar test - Available in MainTabPage'),
          ),
          DebugOption(
            id: 'category_grid',
            title: '[2.4] CATEGORY GRID',
            description: 'Category selection grid',
            icon: Icons.grid_view,
            type: DebugOptionType.action,
            onTap: () => _controller.showMessage('Category Grid test - Available in MainTabPage'),
          ),
          DebugOption(
            id: 'user_cards',
            title: '[2.5] USER CARDS',
            description: 'User recommendation cards',
            icon: Icons.people,
            type: DebugOptionType.action,
            onTap: () => _controller.showMessage('User Cards test - Available in MainTabPage'),
          ),
          DebugOption(
            id: 'location_picker',
            title: '[2.6] LOCATION PICKER',
            description: 'City location selection page',
            icon: Icons.location_on,
            type: DebugOptionType.navigation,
            onTap: () => _navigateToLocationPicker(),
          ),
        ],
      ),
      
      // 发现模块
      DebugOption(
        id: 'discovery',
        title: '[3] 🔍 DISCOVERY MODULE',
        description: 'Content discovery & publishing system',
        icon: Icons.explore,
        type: DebugOptionType.toggle,
        children: [
          DebugOption(
            id: 'discovery_main',
            title: '[3.1] DISCOVERY PAGE',
            description: 'Main discovery page with Follow/Hot/City tabs',
            icon: Icons.explore,
            type: DebugOptionType.navigation,
            onTap: () => _navigateToDiscoveryMain(),
          ),
          DebugOption(
            id: 'publish_content',
            title: '[3.2] PUBLISH CONTENT',
            description: 'Content creation with media, topics & location',
            icon: Icons.add_circle,
            type: DebugOptionType.navigation,
            onTap: () => _navigateToPublishContent(),
          ),
        ],
      ),
      
      // 其他功能选项
      DebugOption(
        id: 'architecture_comparison',
        title: '[4] 📊 ARCHITECTURE COMPARISON',
        description: 'Compare Single-File vs Multi-Module architectures',
        icon: Icons.architecture,
        type: DebugOptionType.action,
        onTap: () => _showArchitectureComparison(),
      ),
      DebugOption(
        id: 'ui_components',
        title: '[5] UI COMPONENTS TEST',
        description: 'Test various UI components',
        icon: Icons.widgets,
        type: DebugOptionType.action,
        onTap: () => _controller.showMessage('UI Components test - Not implemented'),
      ),
      DebugOption(
        id: 'network_debug',
        title: '[5] NETWORK DEBUG',
        description: 'Test network requests and responses',
        icon: Icons.network_check,
        type: DebugOptionType.action,
        onTap: () => _controller.testNetwork(),
      ),
      DebugOption(
        id: 'database_test',
        title: '[6] DATABASE TEST',
        description: 'Test local database operations',
        icon: Icons.storage,
        type: DebugOptionType.action,
        onTap: () => _controller.showMessage('Database test - Not implemented'),
      ),
      DebugOption(
        id: 'performance_monitor',
        title: '[7] PERFORMANCE MONITOR',
        description: 'Monitor app performance metrics',
        icon: Icons.speed,
        type: DebugOptionType.action,
        onTap: () => _controller.showMessage('Performance monitor - Not implemented'),
      ),
      DebugOption(
        id: 'cache_manager',
        title: '[8] CACHE MANAGER',
        description: 'Manage application cache',
        icon: Icons.cached,
        type: DebugOptionType.action,
        onTap: () => _controller.clearCache(),
      ),
      DebugOption(
        id: 'log_viewer',
        title: '[9] LOG VIEWER',
        description: 'View application logs',
        icon: Icons.description,
        type: DebugOptionType.action,
        onTap: () => _controller.showMessage('Log viewer - Not implemented'),
      ),
      DebugOption(
        id: 'device_info',
        title: '[10] DEVICE INFO',
        description: 'Display device information',
        icon: Icons.phone_android,
        type: DebugOptionType.action,
        onTap: () => _showDeviceInfo(),
      ),
      DebugOption(
        id: 'theme_switcher',
        title: '[11] THEME SWITCHER',
        description: 'Switch between themes',
        icon: Icons.palette,
        type: DebugOptionType.action,
        onTap: () => _controller.showMessage('Theme switcher - Not implemented'),
      ),
      DebugOption(
        id: 'exit_debug',
        title: '[0] EXIT DEBUG MODE',
        description: 'Return to normal mode',
        icon: Icons.exit_to_app,
        type: DebugOptionType.action,
        onTap: () => _exitDebug(),
      ),
    ];
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ShowcaseConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: _ShowcaseConstants.surfaceColor,
        title: const Text(
          'DEBUG MODE',
          style: TextStyle(
            color: _ShowcaseConstants.textPrimaryColor,
            fontFamily: _ShowcaseConstants.fontFamily,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<ShowcaseState>(
        valueListenable: _controller,
        builder: (context, state, child) {
          return Padding(
            padding: const EdgeInsets.all(_ShowcaseConstants.spacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 系统信息
                const _SystemInfoCard(),
                
                const SizedBox(height: _ShowcaseConstants.largeSpacing),
                
                // 标题
                const Text(
                  'DEBUG OPTIONS:',
                  style: TextStyle(
                    color: _ShowcaseConstants.textPrimaryColor,
                    fontFamily: _ShowcaseConstants.fontFamily,
                    fontSize: _ShowcaseConstants.titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: _ShowcaseConstants.spacing),
                
                // 消息显示
                _MessageDisplay(message: state.message),
                
                // 调试选项列表
                Expanded(
                  child: ListView.builder(
                    itemCount: _debugOptions.length,
                    itemBuilder: (context, index) {
                      final option = _debugOptions[index];
                      return _buildOptionWidget(option, state);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildOptionWidget(DebugOption option, ShowcaseState state) {
    switch (option.type) {
      case DebugOptionType.toggle:
        final isExpanded = state.isExpanded(option.id);
        return Column(
          children: [
            _ToggleOption(
              option: option,
              isExpanded: isExpanded,
              onToggle: () => _controller.toggleOption(option.id),
            ),
            if (isExpanded && option.children != null) ...[
              ...option.children!.map((child) => _SubOption(option: child)),
              if (option.id == 'login') // 在登录模块后添加分割线
                const Divider(color: _ShowcaseConstants.primaryColor, thickness: 0.5),
            ],
          ],
        );
      case DebugOptionType.action:
      case DebugOptionType.navigation:
        return _DebugOption(option: option);
    }
  }
  
  // 导航方法
  void _navigateToUnifiedLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UnifiedLoginPage()),
    );
  }
  
  void _navigateToLoginDemo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginDemoPage()),
    );
  }
  
  void _navigateToLogin() {
    _controller.showMessage('Legacy LoginPage - Use Unified Login instead');
  }
  
  void _navigateToMobileLogin() {
    _controller.showMessage('Legacy MobileLoginPage - Use Unified Login instead');
  }
  
  void _navigateToForgotPassword() {
    _controller.showMessage('Legacy ForgotPasswordPage - Use Unified Login instead');
  }
  
  void _navigateToVerifyCode() {
    _controller.showMessage('Legacy VerifyCodePage - Use Unified Login instead');
  }
  
  void _navigateToResetPassword() {
    _controller.showMessage('Legacy ResetPasswordPage - Use Unified Login instead');
  }
  
  void _navigateToMainTabPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MainTabPage()),
    );
  }
  
  void _navigateToHomePage() {
    // 推荐使用MainTabPage，保留此方法以防有其他用途
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UnifiedHomePage()),
    );
  }
  
  void _navigateToLocationPicker() async {
    // 位置选择功能已整合到MainTabPage中的首页
    _controller.showMessage('位置选择功能已整合到MainTabPage首页中，请使用MainTabPage访问');
  }
  
  void _navigateToDiscoveryMain() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DiscoveryMainPage()),
    );
  }
  
  void _navigateToPublishContent() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PublishContentPage(),
        fullscreenDialog: true, // 全屏模态展示
      ),
    );
  }
  
  // 对话框方法
  void _showArchitectureComparison() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _ShowcaseConstants.surfaceColor,
        title: const Text(
          '📊 ARCHITECTURE COMPARISON',
          style: TextStyle(
            color: _ShowcaseConstants.textPrimaryColor,
            fontFamily: _ShowcaseConstants.fontFamily,
            fontSize: _ShowcaseConstants.titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🆕 SINGLE-FILE ARCHITECTURE:',
                style: TextStyle(
                  color: _ShowcaseConstants.textPrimaryColor,
                  fontFamily: _ShowcaseConstants.fontFamily,
                  fontSize: _ShowcaseConstants.subtitleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '✅ unified_login_page.dart (1338 lines)\n'
                '• 8-segment structure\n'
                '• All-in-one implementation\n'
                '• Fast prototyping\n'
                '• Easy to understand\n'
                '• Perfect for simple features',
                style: TextStyle(
                  color: _ShowcaseConstants.textPrimaryColor,
                  fontFamily: _ShowcaseConstants.fontFamily,
                  fontSize: _ShowcaseConstants.bodyFontSize,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '🏢 MULTI-MODULE ARCHITECTURE:',
                style: TextStyle(
                  color: _ShowcaseConstants.accentColor,
                  fontFamily: _ShowcaseConstants.fontFamily,
                  fontSize: _ShowcaseConstants.subtitleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '✅ 5 separate pages + components\n'
                '• High modularity\n'
                '• Team collaboration friendly\n'
                '• Reusable components\n'
                '• Scalable architecture\n'
                '• Production-ready',
                style: TextStyle(
                  color: _ShowcaseConstants.accentColor,
                  fontFamily: _ShowcaseConstants.fontFamily,
                  fontSize: _ShowcaseConstants.bodyFontSize,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '🎯 RECOMMENDATION:',
                style: TextStyle(
                  color: _ShowcaseConstants.warningColor,
                  fontFamily: _ShowcaseConstants.fontFamily,
                  fontSize: _ShowcaseConstants.subtitleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Single-file: Prototypes, demos\n'
                '• Multi-module: Production apps\n'
                '• Both approaches are valid\n'
                '• Choose based on project needs',
                style: TextStyle(
                  color: _ShowcaseConstants.warningColor,
                  fontFamily: _ShowcaseConstants.fontFamily,
                  fontSize: _ShowcaseConstants.bodyFontSize,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'UNDERSTOOD',
              style: TextStyle(
                color: _ShowcaseConstants.textPrimaryColor,
                fontFamily: _ShowcaseConstants.fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showDeviceInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _ShowcaseConstants.surfaceColor,
        title: const Text(
          'DEVICE INFO',
          style: TextStyle(
            color: _ShowcaseConstants.textPrimaryColor,
            fontFamily: _ShowcaseConstants.fontFamily,
          ),
        ),
        content: const Text(
          _ShowcaseConstants.deviceInfo,
          style: TextStyle(
            color: _ShowcaseConstants.textPrimaryColor,
            fontFamily: _ShowcaseConstants.fontFamily,
            fontSize: _ShowcaseConstants.bodyFontSize,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'CLOSE',
              style: TextStyle(
                color: _ShowcaseConstants.textPrimaryColor,
                fontFamily: _ShowcaseConstants.fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _exitDebug() {
    SystemNavigator.pop();
  }
}

// ============== 8. EXPORTS ==============
/// 只导出主页面，保持接口简洁
/// 注意：export语句应该放在文件顶部，这里仅作为注释说明
/// 实际使用时，在其他文件中通过 import 'showcase_page_unified.dart' 导入
