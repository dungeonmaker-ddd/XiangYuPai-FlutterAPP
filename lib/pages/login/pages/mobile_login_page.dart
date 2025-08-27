import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../widgets/phone_input_widget.dart';
import '../widgets/code_input_widget.dart';
import '../utils/login_routes.dart';
import '../models/country_model.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';
import '../config/auth_config.dart';

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
  
  // 服务层实例
  late final IAuthService _authService;
  
  // 状态管理
  SmsCodeState _smsState = const SmsCodeState();
  bool _isVerifying = false;
  Timer? _timer;
  
  CountryModel? _selectedCountry = CountryData.findByCode('+86'); // 默认中国大陆
  
  // 获取当前选中的国家，默认为中国大陆
  CountryModel get _currentCountry {
    return _selectedCountry ?? CountryData.findByCode('+86')!;
  }

  // 使用升级后的PhoneInputWidget验证逻辑
  bool get _isPhoneValid {
    return PhoneInputWidget.isPhoneValid(
      phone: _phoneController.text,
      selectedCountry: _selectedCountry,
    );
  }

  @override
  void initState() {
    super.initState();
    // 初始化服务层
    _authService = AuthConfig.useMockService 
        ? MockAuthService() 
        : AuthServiceFactory.getInstance();
    
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

  void _startCountdown(int initialCountdown) {
    setState(() {
      _smsState = _smsState.copyWith(
        countdown: initialCountdown,
        canResend: false,
      );
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _smsState = _smsState.copyWith(countdown: _smsState.countdown - 1);
      });
      
      if (_smsState.countdown <= 0) {
        timer.cancel();
        setState(() {
          _smsState = _smsState.copyWith(canResend: true);
        });
      }
    });
  }

  Future<void> _sendCode() async {
    if (!_isPhoneValid) {
      _showError('请输入正确的手机号');
      return;
    }

    setState(() {
      _smsState = _smsState.copyWith(status: AuthStatus.loading);
    });

    try {
      final request = SmsCodeRequest(
        mobile: _phoneController.text.trim(),
        clientType: 'app',
      );

      final response = await _authService.sendSmsCode(request);
      
      if (mounted) {
        setState(() {
          _smsState = _smsState.copyWith(
            status: AuthStatus.codeSent,
            data: response.data,
            message: response.message,
          );
        });
        
        // 启动倒计时
        final nextSendIn = response.data?.nextSendIn ?? 60;
        _startCountdown(nextSendIn);
        
        _showSuccess('验证码已发送至 ${response.data?.mobile ?? _phoneController.text}');
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _smsState = _smsState.copyWith(
            status: AuthStatus.error,
            error: e,
          );
        });
        _showError(e.message);
      }
    }
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.isEmpty) {
      _showError('请输入验证码');
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      final request = SmsVerifyRequest(
        mobile: _phoneController.text.trim(),
        code: _codeController.text.trim(),
        clientType: 'app',
      );

      final response = await _authService.verifySmsCode(request);
      
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });

        // 保存登录令牌（这里应该保存到安全存储中）
        // await SecureStorage.saveTokens(response.data);
        
        _showSuccess('登录成功！欢迎 ${response.data?.userInfo.nickname ?? ''}');
        
        // 延迟导航以显示成功消息
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          // 这里应该导航到主页面
          LoginRoutes.toHomePage(context);
        }
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
        _showError(e.message);
        
        // 如果验证码错误，清空输入框
        if (e.code == 400) {
          _codeController.clear();
        }
      }
    }
  }

  void _showMessage(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: backgroundColor,
      ),
    );
  }

  void _showError(String message) {
    _showMessage(message, backgroundColor: Colors.red);
  }

  void _showSuccess(String message) {
    _showMessage(message, backgroundColor: Colors.green);
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
                _smsState.status == AuthStatus.codeSent ? '请输入验证码' : '您好！',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              
              const SizedBox(height: 8),
              
              if (_smsState.status == AuthStatus.codeSent)
                Text(
                  '验证码已发送至 ${_smsState.data?.mobile ?? '${_currentCountry.code} ${_phoneController.text}'}',
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
              
              if (_smsState.status != AuthStatus.codeSent) ...[
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
                  showValidationHint: true, // 显示验证提示
                  hintText: '请输入手机号获取验证码',
                ),
              ] else ...[
                // 使用统一的验证码输入组件
                CodeInputWidget(
                  controller: _codeController,
                  onCompleted: _verifyCode,
                  onChanged: () {
                    setState(() {}); // 刷新UI状态
                  },
                ),
              ],
              
              const SizedBox(height: 20),
              
              // 重新发送验证码区域  
              if (_smsState.status == AuthStatus.codeSent)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_smsState.countdown > 0) ...[
                      Text(
                        '${_smsState.countdown}秒后重新获取验证码',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                      ),
                    ] else ...[
                      Text(
                        '没有收到验证码？',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _smsState.canResend ? _sendCode : null,
                        child: Text(
                          '重新发送',
                          style: TextStyle(
                            color: _smsState.canResend ? Colors.purple : Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ]
                  ],
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
              if (_smsState.status != AuthStatus.codeSent)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (_smsState.status == AuthStatus.loading || !_isPhoneValid) ? null : _sendCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isPhoneValid ? Colors.purple : Colors.grey[400],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: _smsState.status == AuthStatus.loading
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
              
              // 验证码登录按钮（只在验证码发送后显示）
              if (_smsState.status == AuthStatus.codeSent)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isVerifying || _codeController.text.isEmpty ? null : _verifyCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _codeController.text.isNotEmpty ? Colors.purple : Colors.grey[400],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: _isVerifying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          '立即登录',
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
                  onPressed: () {
                    Navigator.of(context).pop(); // 返回到登录选择页面
                  },
                  child: const Text(
                    '密码登录',
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
              ),
            ],
          ),
        ),
      ),
    );
  }


}
