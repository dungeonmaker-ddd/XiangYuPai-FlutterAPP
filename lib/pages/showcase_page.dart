import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login/login_page.dart';
import 'login/mobile_login_page.dart';
import 'login/forgot_password_page.dart';

/// Debug: 调试选项页面
class ShowcasePage extends StatelessWidget {
  const ShowcasePage({super.key});

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
                  _buildDebugOption(
                    context,
                    '[1] MOBILE PASSWORD LOGIN',
                    'Test mobile phone + password login',
                    Icons.login,
                    () => _navigateToLogin(context),
                  ),
                  _buildDebugOption(
                    context,
                    '[1.1] MOBILE SMS LOGIN',
                    'Test mobile phone SMS verification',
                    Icons.phone_android,
                    () => _navigateToMobileLogin(context),
                  ),
                  _buildDebugOption(
                    context,
                    '[1.2] FORGOT PASSWORD',
                    'Test forgot password flow',
                    Icons.lock_reset,
                    () => _navigateToForgotPassword(context),
                  ),
                  _buildDebugOption(
                    context,
                    '[2] UI COMPONENTS TEST',
                    'Test various UI components',
                    Icons.widgets,
                    () => _showMessage(context, 'UI Components test - Not implemented'),
                  ),
                  _buildDebugOption(
                    context,
                    '[3] NETWORK DEBUG',
                    'Test network requests and responses',
                    Icons.network_check,
                    () => _showMessage(context, 'Network debug - Not implemented'),
                  ),
                  _buildDebugOption(
                    context,
                    '[4] DATABASE TEST',
                    'Test local database operations',
                    Icons.storage,
                    () => _showMessage(context, 'Database test - Not implemented'),
                  ),
                  _buildDebugOption(
                    context,
                    '[5] PERFORMANCE MONITOR',
                    'Monitor app performance metrics',
                    Icons.speed,
                    () => _showMessage(context, 'Performance monitor - Not implemented'),
                  ),
                  _buildDebugOption(
                    context,
                    '[6] CACHE MANAGER',
                    'Manage application cache',
                    Icons.cached,
                    () => _showMessage(context, 'Cache manager - Not implemented'),
                  ),
                  _buildDebugOption(
                    context,
                    '[7] LOG VIEWER',
                    'View application logs',
                    Icons.description,
                    () => _showMessage(context, 'Log viewer - Not implemented'),
                  ),
                  _buildDebugOption(
                    context,
                    '[8] DEVICE INFO',
                    'Display device information',
                    Icons.phone_android,
                    () => _showDeviceInfo(context),
                  ),
                  _buildDebugOption(
                    context,
                    '[9] THEME SWITCHER',
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
