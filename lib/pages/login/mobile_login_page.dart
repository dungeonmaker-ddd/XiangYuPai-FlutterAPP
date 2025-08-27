import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'login_widgets.dart';
import '../../models/country_model.dart';

/// 📱 手机号登录页面
/// 提供手机号验证码登录功能
class MobileLoginPage extends StatefulWidget {
  const MobileLoginPage({super.key});

  @override
  State<MobileLoginPage> createState() => _MobileLoginPageState();
}

class _MobileLoginPageState extends State<MobileLoginPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  
  bool _isCodeSent = false;
  bool _isLoading = false;
  int _countdown = 0;
  Timer? _timer;
  
  CountryModel? _selectedCountry;
  
  // 获取当前区号对应的手机号长度
  int get _requiredPhoneLength {
    if (_selectedCountry == null) return 11;
    return CountryData.getPhoneLengthByCode(_selectedCountry!.code);
  }

  // 获取当前选中的国家，默认为中国大陆
  CountryModel get _currentCountry {
    return _selectedCountry ?? CountryData.findByCode('+86')!;
  }

  // 手机号验证
  bool get _isPhoneValid {
    final phone = _phoneController.text.trim();
    return phone.length == _requiredPhoneLength && 
           phone.isNotEmpty && 
           RegExp(r'^[0-9]+$').hasMatch(phone);
  }

  @override
  void initState() {
    super.initState();
    // 监听手机号输入变化以更新按钮状态
    _phoneController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _countdown = 60;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
      });
      
      if (_countdown == 0) {
        timer.cancel();
      }
    });
  }

  Future<void> _sendCode() async {
    if (!_isPhoneValid) {
      _showMessage('请输入正确的手机号');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // 模拟发送验证码
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isCodeSent = true;
      });
      
      _startCountdown();
      _showMessage('验证码已发送至 ${_currentCountry.code} ${_phoneController.text}');
    }
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.isEmpty) {
      _showMessage('请输入验证码');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // 模拟验证码验证
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // 验证成功，显示消息并返回
      _showMessage('登录成功！');
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.of(context).pop();
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
              
              // 标题
              Text(
                _isCodeSent ? '请输入验证码' : '您好！',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              
              const SizedBox(height: 8),
              
              if (_isCodeSent)
                Text(
                  '验证码已发送至 ${_currentCountry.code} ${_phoneController.text}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                )
              else
                const Text(
                  '欢迎使用探店',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              
              const SizedBox(height: 40),
              
              if (!_isCodeSent) ...[
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
                ),
              ] else ...[
                // 验证码输入框（6位数字分开显示）
                Column(
                  children: [
                    _buildCodeInputBoxes(),
                    // 隐藏的输入框用于输入验证码
                    Opacity(
                      opacity: 0,
                      child: TextField(
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        onChanged: (value) {
                          setState(() {});
                          if (value.length == 6) {
                            _verifyCode();
                          }
                        },
                        autofocus: true,
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 20),
              
              // 提示文字
              if (_isCodeSent)
                Text(
                  '${_countdown > 0 ? '$_countdown秒后重新获取验证码' : ''}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                )
              else
                Text(
                  '未注册手机号验证后自动创建账号',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              
              const SizedBox(height: 40),
              
              // 获取验证码按钮（只在未发送状态显示）
              if (!_isCodeSent)
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
                          '获取验证码',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                  ),
                ),
              
              const SizedBox(height: 20),
              
              // 密码登录链接
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    '密码登陆',
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              
              const Spacer(),
              
              // 底部协议
              Padding(
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
                      onTap: () {
                        _showMessage('用户协议');
                      },
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
                      onTap: () {
                        _showMessage('隐私政策');
                      },
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodeInputBoxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return Container(
          width: 45,
          height: 50,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: _codeController.text.length > index 
                  ? Colors.purple 
                  : Colors.grey[300]!,
                width: 2,
              ),
            ),
          ),
          child: Center(
            child: Text(
              _codeController.text.length > index 
                ? _codeController.text[index] 
                : '',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        );
      }),
    );
  }
}
