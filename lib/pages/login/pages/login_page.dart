import 'package:flutter/material.dart';
import '../widgets/phone_input_widget.dart';
import '../widgets/password_input_widget.dart';
import '../utils/login_routes.dart';
import '../models/country_model.dart';

/// 🔐 密码登录页面
/// 提供手机号+密码登录功能
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  CountryModel? _selectedCountry = CountryData.findByCode('+86'); // 默认中国大陆
  
  // 验证逻辑已移到PhoneInputWidget中，这些辅助方法可以移除

  bool get _isFormValid {
    return PhoneInputWidget.isPhoneValid(
      phone: _phoneController.text,
      selectedCountry: _selectedCountry,
    ) && _passwordController.text.length >= 6;
  }

  @override
  void initState() {
    super.initState();
    // 监听输入变化以更新按钮状态
    _phoneController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_updateButtonState);
    _passwordController.removeListener(_updateButtonState);
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  void _updateButtonState() {
    setState(() {
      // 触发重建以更新按钮状态
    });
  }

  Future<void> _handleLogin() async {
    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ 请检查手机号和密码'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // 模拟登录请求
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // 显示登录成功消息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ 登录成功！欢迎 ${_phoneController.text}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // 这里可以导航到主页面
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // 标题区域
              _buildHeader(),
              
              const SizedBox(height: 40),
              
              // 登录表单
              _buildLoginForm(),
              
              const SizedBox(height: 40),
              
              // 登录按钮
              _buildLoginButton(),
              
              const SizedBox(height: 20),
              
              // 底部选项
              _buildFooterOptions(),
              
              const Spacer(),
              
              // 用户协议
              _buildUserAgreement(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '您好！',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        
        const SizedBox(height: 8),
        
        const Text(
          '欢迎使用探店',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        // 手机号输入组件 - 使用升级版本
        PhoneInputWidget(
          controller: _phoneController,
          selectedCountry: _selectedCountry,
          onCountryChanged: (country) {
            setState(() {
              _selectedCountry = country;
              // 清空手机号以重新输入
              _phoneController.clear();
            });
          },
          onChanged: () => setState(() {}), // 内置状态监听
          enableValidation: true,
          showValidationHint: false, // 登录页面不显示验证提示
        ),
        
        const SizedBox(height: 20),
        
        // 密码输入组件
        PasswordInputWidget(
          controller: _passwordController,
          onChanged: _updateButtonState,
        ),
      ],
    );
  }


  Widget _buildLoginButton() {
    final isEnabled = _isFormValid && !_isLoading;
    
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isEnabled ? _handleLogin : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? Colors.purple : Colors.grey[300],
          foregroundColor: isEnabled ? Colors.white : Colors.grey[600],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
        child: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              '登录',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
      ),
    );
  }

  Widget _buildFooterOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => LoginRoutes.toMobileLogin(context),
          child: const Text(
            '验证码登录',
            style: TextStyle(
              color: Colors.purple,
              fontSize: 16,
            ),
          ),
        ),
        TextButton(
          onPressed: () => LoginRoutes.toForgotPassword(context),
          child: const Text(
            '忘记密码?',
            style: TextStyle(
              color: Colors.purple,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserAgreement() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '登陆即表示同意 ',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
          GestureDetector(
            onTap: () => LoginRoutes.toUserAgreement(context),
            child: const Text(
              '《探店用户协议》',
              style: TextStyle(
                color: Colors.purple,
                fontSize: 12,
              ),
            ),
          ),
          Text(
            ' 和 ',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
          GestureDetector(
            onTap: () => LoginRoutes.toPrivacyPolicy(context),
            child: const Text(
              '《隐私政策》',
              style: TextStyle(
                color: Colors.purple,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
