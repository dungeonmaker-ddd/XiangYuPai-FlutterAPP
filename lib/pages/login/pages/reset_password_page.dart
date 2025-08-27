import 'package:flutter/material.dart';
import '../widgets/password_input_widget.dart';

/// 🔄 重置密码页面
/// 在验证码验证成功后进入此页面设置新密码
class ResetPasswordPage extends StatefulWidget {
  final String phoneNumber; // 传入的手机号
  final String countryCode; // 传入的国家代码
  
  const ResetPasswordPage({
    super.key,
    required this.phoneNumber,
    required this.countryCode,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _showPasswordRequirements = true; // 默认显示密码要求
  
  // 密码验证规则
  bool get _hasMinLength => _newPasswordController.text.length >= 6;
  bool get _hasMaxLength => _newPasswordController.text.length <= 20;
  bool get _passwordsMatch => _newPasswordController.text == _confirmPasswordController.text;
  
  bool get _isPasswordValid => _hasMinLength && _hasMaxLength && !_isAllNumbers;
  bool get _isAllNumbers => RegExp(r'^[0-9]+$').hasMatch(_newPasswordController.text);
  bool get _isFormValid => _isPasswordValid && _passwordsMatch && _newPasswordController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    // 监听密码输入变化
    _newPasswordController.addListener(_updateButtonState);
    _confirmPasswordController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _newPasswordController.removeListener(_updateButtonState);
    _confirmPasswordController.removeListener(_updateButtonState);
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  void _updateButtonState() {
    setState(() {
      // 触发重建以更新按钮状态和验证提示
    });
  }

  Future<void> _resetPassword() async {
    if (!_isFormValid) {
      _showMessage('请检查密码格式', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 模拟重置密码请求
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // 显示成功消息
        _showMessage('密码重置成功！');
        
        // 延迟后跳转到登录页面
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          // 返回到登录页面，清除所有中间页面
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showMessage('重置密码失败，请重试', isError: true);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isError ? '❌ $message' : '✅ $message'),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
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
              
              // 新密码输入
              _buildPasswordForm(),
              
              const SizedBox(height: 30),
              
              // 密码要求提示 - 默认显示
              _buildPasswordRequirements(),
              
              const SizedBox(height: 40),
              
              // 重置密码按钮
              _buildResetButton(),
              
              const Spacer(),
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
          '重置密码',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          '6-20个字符，不可以是纯数字',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 新密码输入
        Focus(
          onFocusChange: (hasFocus) {
            setState(() {
              _showPasswordRequirements = hasFocus || _newPasswordController.text.isNotEmpty;
            });
          },
          child: PasswordInputWidget(
            controller: _newPasswordController,
            hintText: '请输入6-20位密码',
            onChanged: _updateButtonState,
            maxLength: 20, // 设置最大长度为20个字符
          ),
        ),
        
        const SizedBox(height: 24),
        
        // 确认密码输入
        PasswordInputWidget(
          controller: _confirmPasswordController,
          hintText: '请再次输入密码',
          onChanged: _updateButtonState,
          maxLength: 20, // 设置最大长度为20个字符
        ),
        
        // 密码匹配提示
        if (_confirmPasswordController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 0),
            child: Row(
              children: [
                Icon(
                  _passwordsMatch ? Icons.check_circle : Icons.error,
                  size: 16,
                  color: _passwordsMatch ? Colors.green[600] : Colors.red[600],
                ),
                const SizedBox(width: 6),
                Text(
                  _passwordsMatch ? '密码匹配' : '两次输入的密码不一致',
                  style: TextStyle(
                    fontSize: 12,
                    color: _passwordsMatch ? Colors.green[600] : Colors.red[600],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPasswordRequirements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '密码要求：',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        _buildRequirementItem('6-20个字符', _hasMinLength && _hasMaxLength),
        _buildRequirementItem('不能是纯数字', !_isAllNumbers || _newPasswordController.text.isEmpty),
      ],
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        '• $text',
        style: TextStyle(
          fontSize: 12,
          color: isMet ? Colors.green[600] : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    final isEnabled = _isFormValid && !_isLoading;
    
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isEnabled ? _resetPassword : null,
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
              '确认',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
      ),
    );
  }
}
