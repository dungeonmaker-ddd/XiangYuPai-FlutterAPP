import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/phone_input_widget.dart';
import '../models/country_model.dart';
import 'verify_code_page.dart';

/// 🔄 忘记密码页面
/// 提供密码重置功能
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _phoneController = TextEditingController();
  
  bool _isLoading = false;
  
  // 使用CountryModel替代简单的字符串列表
  CountryModel? _selectedCountry = CountryData.findByCode('+86');
  
  // 使用升级后的PhoneInputWidget验证逻辑
  bool get _isPhoneValid {
    return PhoneInputWidget.isPhoneValid(
      phone: _phoneController.text,
      selectedCountry: _selectedCountry,
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }



  Future<void> _sendCode() async {
    if (!_isPhoneValid) {
      _showMessage('请输入正确的手机号');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 模拟发送验证码
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        _showMessage('验证码已发送至 ${_selectedCountry?.code} ${_phoneController.text}');
        
        // 跳转到验证码验证页面
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => VerifyCodePage(
                phoneNumber: _phoneController.text,
                countryCode: _selectedCountry?.code ?? '+86',
                purpose: 'reset_password',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showMessage('发送失败，请重试');
      }
    }
  }



  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
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
              
              // 标题和描述
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '忘记密码',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '请输入您的手机号，我们将发送验证码',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // 手机号输入组件
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
                showValidationHint: true, // 显示验证提示
                hintText: '请输入手机号',
              ),
              
              const SizedBox(height: 40),
              
              // 获取验证码按钮
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: (_isLoading || !_isPhoneValid) ? null : _sendCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isPhoneValid ? Colors.purple : Colors.grey[400],
                    foregroundColor: Colors.white,
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
                        '获取短信验证码',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                ),
              ),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }


}





