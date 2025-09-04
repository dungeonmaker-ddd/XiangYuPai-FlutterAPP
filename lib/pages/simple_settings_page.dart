// 🔧 设置页面 - 单文件架构实践
// 适合简单功能的单文件实现示例

// ============== 1. IMPORTS ==============
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// ============== 2. CONSTANTS ==============
class _SettingsConstants {
  static const double itemHeight = 56.0;
  static const double iconSize = 24.0;
  static const EdgeInsets contentPadding = EdgeInsets.symmetric(horizontal: 16.0);
}

// ============== 3. MODELS ==============
class SettingItem {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Widget? trailing;
  
  const SettingItem({
    required this.title,
    this.subtitle,
    required this.icon,
    this.onTap,
    this.trailing,
  });
}

class SettingsState {
  final bool isDarkMode;
  final bool isPushEnabled;
  final String language;
  
  const SettingsState({
    this.isDarkMode = false,
    this.isPushEnabled = true,
    this.language = '中文',
  });
  
  SettingsState copyWith({
    bool? isDarkMode,
    bool? isPushEnabled,
    String? language,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isPushEnabled: isPushEnabled ?? this.isPushEnabled,
      language: language ?? this.language,
    );
  }
}

// ============== 4. SERVICES ==============
class _SettingsService {
  static Future<void> saveSettings(SettingsState settings) async {
    // 模拟保存到本地存储
    await Future.delayed(const Duration(milliseconds: 500));
    print('Settings saved: ${settings.isDarkMode}, ${settings.isPushEnabled}');
  }
  
  static Future<SettingsState> loadSettings() async {
    // 模拟从本地存储加载
    await Future.delayed(const Duration(milliseconds: 300));
    return const SettingsState();
  }
}

// ============== 5. CONTROLLERS ==============
class _SettingsController extends ValueNotifier<SettingsState> {
  _SettingsController() : super(const SettingsState()) {
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final settings = await _SettingsService.loadSettings();
    value = settings;
  }
  
  Future<void> toggleDarkMode() async {
    value = value.copyWith(isDarkMode: !value.isDarkMode);
    await _SettingsService.saveSettings(value);
  }
  
  Future<void> togglePushNotification() async {
    value = value.copyWith(isPushEnabled: !value.isPushEnabled);
    await _SettingsService.saveSettings(value);
  }
  
  Future<void> changeLanguage(String language) async {
    value = value.copyWith(language: language);
    await _SettingsService.saveSettings(value);
  }
}

// ============== 6. WIDGETS ==============
class _SettingsTile extends StatelessWidget {
  final SettingItem item;
  
  const _SettingsTile({required this.item});
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(item.icon, size: _SettingsConstants.iconSize),
      title: Text(item.title),
      subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
      trailing: item.trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: item.onTap,
      contentPadding: _SettingsConstants.contentPadding,
      minVerticalPadding: 8,
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  
  const _SettingsSection({
    required this.title,
    required this.children,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: children),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ============== 7. PAGES ==============
class SimpleSettingsPage extends StatefulWidget {
  const SimpleSettingsPage({super.key});
  
  @override
  State<SimpleSettingsPage> createState() => _SimpleSettingsPageState();
}

class _SimpleSettingsPageState extends State<SimpleSettingsPage> {
  late final _SettingsController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = _SettingsController();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        elevation: 0,
      ),
      body: ValueListenableBuilder<SettingsState>(
        valueListenable: _controller,
        builder: (context, state, child) {
          return ListView(
            children: [
              _SettingsSection(
                title: '外观设置',
                children: [
                  _SettingsTile(
                    item: SettingItem(
                      title: '深色模式',
                      subtitle: '开启后界面将使用深色主题',
                      icon: Icons.dark_mode,
                      trailing: CupertinoSwitch(
                        value: state.isDarkMode,
                        onChanged: (_) => _controller.toggleDarkMode(),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    item: SettingItem(
                      title: '语言设置',
                      subtitle: '当前: ${state.language}',
                      icon: Icons.language,
                      onTap: () => _showLanguageDialog(context),
                    ),
                  ),
                ],
              ),
              _SettingsSection(
                title: '通知设置',
                children: [
                  _SettingsTile(
                    item: SettingItem(
                      title: '推送通知',
                      subtitle: '接收应用推送消息',
                      icon: Icons.notifications,
                      trailing: CupertinoSwitch(
                        value: state.isPushEnabled,
                        onChanged: (_) => _controller.togglePushNotification(),
                      ),
                    ),
                  ),
                ],
              ),
              _SettingsSection(
                title: '其他设置',
                children: [
                  _SettingsTile(
                    item: SettingItem(
                      title: '关于我们',
                      icon: Icons.info,
                      onTap: () => _showAboutDialog(context),
                    ),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    item: SettingItem(
                      title: '版本信息',
                      subtitle: 'v1.0.0',
                      icon: Icons.info_outline,
                    ),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    item: SettingItem(
                      title: '清除缓存',
                      icon: Icons.cleaning_services,
                      onTap: () => _showClearCacheDialog(context),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
  
  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择语言'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('中文'),
              leading: const Icon(Icons.check),
              onTap: () {
                _controller.changeLanguage('中文');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('English'),
              onTap: () {
                _controller.changeLanguage('English');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Flutter App',
      applicationVersion: '1.0.0',
      children: [
        const Text('这是一个Flutter应用示例'),
      ],
    );
  }
  
  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定要清除应用缓存吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // 清除缓存逻辑
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('缓存已清除')),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

// ============== 8. EXPORTS ==============
export 'simple_settings_page.dart' show SimpleSettingsPage;