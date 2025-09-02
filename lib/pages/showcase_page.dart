import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login/index.dart'; // 使用统一导出
import 'home/index.dart'; // 导入首页模块

/// Debug: 调试选项页面
class ShowcasePage extends StatefulWidget {
  const ShowcasePage({super.key});

  @override
  State<ShowcasePage> createState() => _ShowcasePageState();
}

class _ShowcasePageState extends State<ShowcasePage> {
  bool _showLoginOptions = false;
  bool _showHomeOptions = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'DEBUG MODE',
          style: TextStyle(
            color: Colors.green,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 系统信息
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                border: Border.all(color: Colors.green, width: 1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'SYSTEM INFO:\nFlutter Debug Build\nDevelopment Mode: ON\nHot Reload: ENABLED',
                style: TextStyle(
                  color: Colors.green,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              'DEBUG OPTIONS:',
              style: TextStyle(
                color: Colors.green,
                fontFamily: 'monospace',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 调试选项列表
            Expanded(
              child: ListView(
                children: [
                  // 登录模块开关
                  _buildToggleOption(
                    context,
                    '[1] LOGIN MODULE',
                    'Authentication & User Management',
                    Icons.account_circle,
                    _showLoginOptions,
                    (value) {
                      setState(() {
                        _showLoginOptions = value;
                      });
                    },
                  ),
                  
                  // 登录模块子选项
                  if (_showLoginOptions) ...[
                    _buildSubOption(
                      context,
                      '[1.1] PASSWORD LOGIN',
                      'Mobile phone + password login',
                      Icons.login,
                      () => _navigateToLogin(context),
                    ),
                    _buildSubOption(
                      context,
                      '[1.2] SMS LOGIN',
                      'Mobile phone SMS verification',
                      Icons.phone_android,
                      () => _navigateToMobileLogin(context),
                    ),
                    _buildSubOption(
                      context,
                      '[1.3] FORGOT PASSWORD',
                      'Password recovery flow',
                      Icons.lock_reset,
                      () => _navigateToForgotPassword(context),
                    ),
                    _buildSubOption(
                      context,
                      '[1.4] VERIFY CODE',
                      'SMS verification code page',
                      Icons.security,
                      () => _navigateToVerifyCode(context),
                    ),
                    _buildSubOption(
                      context,
                      '[1.5] RESET PASSWORD',
                      'Password reset page',
                      Icons.key,
                      () => _navigateToResetPassword(context),
                    ),
                  ],
                  
                  // 首页模块开关
                  _buildToggleOption(
                    context,
                    '[2] HOME MODULE',
                    'Homepage & User Discovery',
                    Icons.home,
                    _showHomeOptions,
                    (value) {
                      setState(() {
                        _showHomeOptions = value;
                      });
                    },
                  ),
                  
                  // 首页模块子选项
                  if (_showHomeOptions) ...[
                    _buildSubOption(
                      context,
                      '[2.1] HOME PAGE',
                      'Main homepage with recommendations',
                      Icons.dashboard,
                      () => _navigateToHomePage(context),
                    ),
                    _buildSubOption(
                      context,
                      '[2.2] SEARCH BAR',
                      'Search functionality test',
                      Icons.search,
                      () => _showMessage(context, 'Search Bar test - Available in HomePage'),
                    ),
                    _buildSubOption(
                      context,
                      '[2.3] CATEGORY GRID',
                      'Category selection grid',
                      Icons.grid_view,
                      () => _showMessage(context, 'Category Grid test - Available in HomePage'),
                    ),
                    _buildSubOption(
                      context,
                      '[2.4] USER CARDS',
                      'User recommendation cards',
                      Icons.people,
                      () => _showMessage(context, 'User Cards test - Available in HomePage'),
                    ),
                    _buildSubOption(
                      context,
                      '[2.5] LOCATION PICKER',
                      'City location selection page',
                      Icons.location_on,
                      () => _navigateToLocationPicker(context),
                    ),
                  ],
                  
                  _buildDebugOption(
                    context,
                    '[3] UI COMPONENTS TEST',
                    'Test various UI components',
                    Icons.widgets,
                    () => _showMessage(context, 'UI Components test - Not implemented'),
                  ),
                  _buildDebugOption(
                    context,
                    '[4] NETWORK DEBUG',
                    'Test network requests and responses',
                    Icons.network_check,
                    () => _showMessage(context, 'Network debug - Not implemented'),
                  ),
                  _buildDebugOption(
                    context,
                    '[5] DATABASE TEST',
                    'Test local database operations',
                    Icons.storage,
                    () => _showMessage(context, 'Database test - Not implemented'),
                  ),
                  _buildDebugOption(
                    context,
                    '[6] PERFORMANCE MONITOR',
                    'Monitor app performance metrics',
                    Icons.speed,
                    () => _showMessage(context, 'Performance monitor - Not implemented'),
                  ),
                  _buildDebugOption(
                    context,
                    '[7] CACHE MANAGER',
                    'Manage application cache',
                    Icons.cached,
                    () => _showMessage(context, 'Cache manager - Not implemented'),
                  ),
                  _buildDebugOption(
                    context,
                    '[8] LOG VIEWER',
                    'View application logs',
                    Icons.description,
                    () => _showMessage(context, 'Log viewer - Not implemented'),
                  ),
                  _buildDebugOption(
                    context,
                    '[9] DEVICE INFO',
                    'Display device information',
                    Icons.phone_android,
                    () => _showDeviceInfo(context),
                  ),
                  _buildDebugOption(
                    context,
                    '[10] THEME SWITCHER',
                    'Switch between themes',
                    Icons.palette,
                    () => _showMessage(context, 'Theme switcher - Not implemented'),
                  ),
                  _buildDebugOption(
                    context,
                    '[0] EXIT DEBUG MODE',
                    'Return to normal mode',
                    Icons.exit_to_app,
                    () => _exitDebug(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleOption(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    bool isExpanded,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.green,
          size: 20,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.green,
            fontFamily: 'monospace',
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: Colors.grey[400],
            fontFamily: 'monospace',
            fontSize: 11,
          ),
        ),
        trailing: Icon(
          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          color: Colors.green,
          size: 20,
        ),
        onTap: () => onChanged(!isExpanded), // 点击整个ListTile触发开关
        tileColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: Colors.green.withOpacity(0.3)),
        ),
      ),
    );
  }

  Widget _buildSubOption(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4, left: 16),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.green.withOpacity(0.8),
          size: 18,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.green.withOpacity(0.8),
            fontFamily: 'monospace',
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: Colors.grey[500],
            fontFamily: 'monospace',
            fontSize: 10,
          ),
        ),
        onTap: onTap,
        tileColor: Colors.grey[850],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: Colors.green.withOpacity(0.2)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        minLeadingWidth: 20,
      ),
    );
  }

  Widget _buildDebugOption(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.green,
          size: 20,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.green,
            fontFamily: 'monospace',
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: Colors.grey[400],
            fontFamily: 'monospace',
            fontSize: 11,
          ),
        ),
        onTap: onTap,
        tileColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: Colors.green.withOpacity(0.3)),
        ),
      ),
    );
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _navigateToMobileLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MobileLoginPage()),
    );
  }

  void _navigateToForgotPassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
    );
  }

  void _navigateToVerifyCode(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VerifyCodePage(
          phoneNumber: '13800138000',
          countryCode: '+86',
          purpose: 'reset_password',
        ),
      ),
    );
  }

  void _navigateToResetPassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ResetPasswordPage(
          phoneNumber: '13800138000',
          countryCode: '+86',
        ),
      ),
    );
  }

  void _navigateToHomePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  void _navigateToLocationPicker(BuildContext context) async {
    final result = await HomeRoutes.toLocationPickerPage(context);
    if (result != null && mounted) {
      _showMessage(context, '选择了城市: ${result.name}');
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'monospace',
            color: Colors.green,
          ),
        ),
        backgroundColor: Colors.grey[900],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDeviceInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'DEVICE INFO',
          style: TextStyle(
            color: Colors.green,
            fontFamily: 'monospace',
          ),
        ),
        content: const Text(
          'Platform: Flutter\nOS: Unknown\nScreen: Dynamic\nMemory: Available\nStorage: Available',
          style: TextStyle(
            color: Colors.green,
            fontFamily: 'monospace',
            fontSize: 12,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'CLOSE',
              style: TextStyle(
                color: Colors.green,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _exitDebug(BuildContext context) {
    SystemNavigator.pop();
  }
}
