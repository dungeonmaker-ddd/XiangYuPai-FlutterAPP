import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../models/country_model.dart';
import 'login_widgets.dart';

/// 🔄 忘记密码页面
/// 提供密码重置功能
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  
  bool _isCodeSent = false;
  bool _isLoading = false;
  int _countdown = 0;
  Timer? _timer;
  
  // 使用CountryModel替代简单的字符串列表
  CountryModel? _selectedCountry = CountryData.findByCode('+86');
  
  // 手机号验证 - 根据选择的国家动态验证
  bool get _isPhoneValid {
    final phone = _phoneController.text.trim();
    if (_selectedCountry == null || phone.isEmpty) return false;
    
    final requiredLength = CountryData.getPhoneLengthByCode(_selectedCountry!.code);
    
    // 针对中国大陆的特殊验证规则
    if (_selectedCountry!.code == '+86') {
      return phone.length == requiredLength && RegExp(r'^1[3-9]\d{9}$').hasMatch(phone);
    }
    
    // 其他国家只验证长度和数字
    return phone.length == requiredLength && RegExp(r'^\d+$').hasMatch(phone);
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
      _showMessage('验证码已发送至 ${_selectedCountry?.code} ${_phoneController.text}');
    }
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.length != 6) {
      _showMessage('请输入完整的验证码');
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
      _showMessage('验证成功！');
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
                    _isCodeSent 
                      ? '请输入收到的6位验证码' 
                      : '请输入您的手机号，我们将发送验证码',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              if (!_isCodeSent) ...[
                // 使用统一的手机号输入组件
                _PhoneInputSection(
                  controller: _phoneController,
                  selectedCountry: _selectedCountry,
                  onCountryChanged: (country) {
                    setState(() {
                      _selectedCountry = country;
                      // 清空手机号以重新输入
                      _phoneController.clear();
                    });
                  },
                  onChanged: () {
                    setState(() {}); // 刷新按钮状态
                  },
                ),
              ] else ...[
                // 验证码输入区域
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '验证码已发送至 ${_selectedCountry?.code} ${_phoneController.text}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _CodeInputWidget(
                      controller: _codeController,
                      onCompleted: _verifyCode,
                      onChanged: () {
                        setState(() {}); // 刷新UI状态
                      },
                    ),
                    const SizedBox(height: 30),
                    // 返回重新输入手机号
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isCodeSent = false;
                            _codeController.clear();
                            _countdown = 0;
                            _timer?.cancel();
                          });
                        },
                        child: Text(
                          '重新输入手机号',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              
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
                          '获取短信验证码',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                  ),
                ),
              
              // 重新发送验证码区域
              if (_isCodeSent)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_countdown > 0) ...[
                        Text(
                          '${_countdown}秒后重新获取验证码',
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
                          onTap: _sendCode,
                          child: const Text(
                            '重新发送',
                            style: TextStyle(
                              color: Colors.purple,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ]
                    ],
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

/// 🔢 验证码输入组件
/// 提供6位数字验证码输入功能，支持自动完成
class _CodeInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onCompleted;
  final VoidCallback? onChanged;
  
  const _CodeInputWidget({
    required this.controller,
    this.onCompleted,
    this.onChanged,
  });

  @override
  State<_CodeInputWidget> createState() => _CodeInputWidgetState();
}

class _CodeInputWidgetState extends State<_CodeInputWidget> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;
  
  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(6, (index) => FocusNode());
    _controllers = List.generate(6, (index) => TextEditingController());
    
    // 监听主控制器变化
    widget.controller.addListener(_updateFromMainController);
  }
  
  @override
  void dispose() {
    widget.controller.removeListener(_updateFromMainController);
    for (final node in _focusNodes) {
      node.dispose();
    }
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
  
  void _updateFromMainController() {
    final text = widget.controller.text;
    for (int i = 0; i < 6; i++) {
      _controllers[i].text = i < text.length ? text[i] : '';
    }
    widget.onChanged?.call();
  }
  
  void _updateMainController() {
    final text = _controllers.map((c) => c.text).join();
    widget.controller.text = text;
    
    if (text.length == 6) {
      widget.onCompleted?.call();
    }
    widget.onChanged?.call();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 6位验证码输入框
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 45,
              height: 55,
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(1),
                ],
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: _controllers[index].text.isNotEmpty
                          ? Colors.purple
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple, width: 2),
                  ),
                ),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                onChanged: (value) {
                  if (value.isNotEmpty && index < 5) {
                    // 自动跳转到下一个输入框
                    _focusNodes[index + 1].requestFocus();
                  } else if (value.isEmpty && index > 0) {
                    // 删除时跳转到上一个输入框
                    _focusNodes[index - 1].requestFocus();
                  }
                  _updateMainController();
                },
                onTap: () {
                  // 点击时选中内容
                  _controllers[index].selection = TextSelection.fromPosition(
                    TextPosition(offset: _controllers[index].text.length),
                  );
                },
              ),
            );
          }),
        ),
        
        // 隐藏的完整输入框，用于粘贴功能
        Opacity(
          opacity: 0,
          child: TextField(
            controller: widget.controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            autofocus: true,
          ),
        ),
      ],
    );
  }
}

/// 📱 手机号输入区域组件
/// 基于PhoneInputWidget的包装器，添加了状态变化回调
class _PhoneInputSection extends StatefulWidget {
  final TextEditingController controller;
  final CountryModel? selectedCountry;
  final ValueChanged<CountryModel> onCountryChanged;
  final VoidCallback? onChanged;
  
  const _PhoneInputSection({
    required this.controller,
    this.selectedCountry,
    required this.onCountryChanged,
    this.onChanged,
  });

  @override
  State<_PhoneInputSection> createState() => _PhoneInputSectionState();
}

class _PhoneInputSectionState extends State<_PhoneInputSection> {
  @override
  void initState() {
    super.initState();
    if (widget.onChanged != null) {
      widget.controller.addListener(widget.onChanged!);
    }
  }

  @override
  void dispose() {
    if (widget.onChanged != null) {
      widget.controller.removeListener(widget.onChanged!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PhoneInputWidget(
      controller: widget.controller,
      selectedCountry: widget.selectedCountry,
      onCountryChanged: widget.onCountryChanged,
      hintText: '请输入手机号',
    );
  }
}
