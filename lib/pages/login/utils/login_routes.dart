import 'package:flutter/material.dart';
import '../pages/login_page.dart';
import '../pages/mobile_login_page.dart';
import '../pages/forgot_password_page.dart';
import '../pages/verify_code_page.dart';
import '../pages/reset_password_page.dart';

/// 🧭 登录模块路由管理
/// 统一管理所有登录相关页面的路由跳转
class LoginRoutes {
  
  /// 🔐 跳转到密码登录页面
  static void toPasswordLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }
  
  /// 📱 跳转到验证码登录页面
  static void toMobileLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MobileLoginPage()),
    );
  }
  
  /// 🔄 跳转到忘记密码页面
  static void toForgotPassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
    );
  }
  
  /// 📱 跳转到验证码验证页面
  static void toVerifyCode(BuildContext context, {
    required String phoneNumber,
    required String countryCode,
    String purpose = 'reset_password',
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerifyCodePage(
          phoneNumber: phoneNumber,
          countryCode: countryCode,
          purpose: purpose,
        ),
      ),
    );
  }
  
  /// 🔑 跳转到重置密码页面
  static void toResetPassword(BuildContext context, {
    required String phoneNumber,
    required String countryCode,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResetPasswordPage(
          phoneNumber: phoneNumber,
          countryCode: countryCode,
        ),
      ),
    );
  }
  
  /// 🏠 登录成功后跳转到主页
  /// TODO: 替换为实际的主页Widget
  static void toHomePage(BuildContext context) {
    // 清除所有登录相关页面，跳转到主页
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home', // TODO: 定义主页路由
      (route) => false,
    );
  }
  
  /// 📄 跳转到用户协议页面
  static void toUserAgreement(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('探店用户协议'),
        content: const SingleChildScrollView(
          child: Text(
            '这里是用户协议的内容...\n\n'
            '1. 用户权利与义务\n'
            '2. 服务条款\n'
            '3. 隐私保护\n'
            '4. 免责声明\n\n'
            '更多详细内容请访问官网...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('我已阅读'),
          ),
        ],
      ),
    );
  }
  
  /// 🔒 跳转到隐私政策页面
  static void toPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('隐私政策'),
        content: const SingleChildScrollView(
          child: Text(
            '这里是隐私政策的内容...\n\n'
            '1. 信息收集\n'
            '2. 信息使用\n'
            '3. 信息安全\n'
            '4. 用户控制\n\n'
            '我们承诺保护您的隐私...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('我已阅读'),
          ),
        ],
      ),
    );
  }
}
