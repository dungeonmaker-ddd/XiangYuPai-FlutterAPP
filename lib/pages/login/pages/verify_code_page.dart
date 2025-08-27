import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../widgets/code_input_widget.dart';
import '../utils/login_routes.dart';
import 'reset_password_page.dart';

/// 📱 验证码验证页面
/// 用于验证手机验证码，验证成功后跳转到重置密码页面
class VerifyCodePage extends StatefulWidget {
  final String phoneNumber; // 手机号
  final String countryCode; // 国家代码
  final String purpose; // 验证目的：'reset_password' 或 'login' 等
  
  const VerifyCodePage({
    super.key,
    required this.phoneNumber,
    required this.countryCode,
    this.purpose = 'reset_password',
  });

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  final _codeController = TextEditingController();
  
  bool _isLoading = false;
  int _countdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    // 验证码页面初始化完成
  }

  @override
  void dispose() {
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

  Future<void> _resendCode() async {
    setState(() {
      _isLoading = true;
    });

    // 模拟重新发送验证码
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      
      _startCountdown();
      _showMessage('验证码已重新发送至 ${widget.countryCode} ${widget.phoneNumber}');
    }
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.length != 6) {
      _showMessage('请输入完整的6位验证码', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 模拟验证码验证
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // 根据验证目的跳转到不同页面
        if (widget.purpose == 'reset_password') {
          _showMessage('验证成功！正在跳转到重置密码页面...');
          await Future.delayed(const Duration(milliseconds: 800));
          
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => ResetPasswordPage(
                  phoneNumber: widget.phoneNumber,
                  countryCode: widget.countryCode,
                ),
              ),
            );
          }
        } else {
          // 其他验证目的的处理
          _showMessage('验证成功！');
          Navigator.of(context).pop(true); // 返回成功结果
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showMessage('验证失败，请重试', isError: true);
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
              
              // 验证码输入
              _buildCodeInput(),
              
              const SizedBox(height: 30),
              
              // 重新发送验证码
              _buildResendSection(),
              
              const SizedBox(height: 20),
              
              // 返回重新输入手机号
              _buildBackToPhoneInput(),
              
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
        Text(
          widget.purpose == 'reset_password' ? '输入验证码' : '验证手机号',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          '验证码已发送至 ${widget.countryCode} ${widget.phoneNumber}',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Text(
          '请输入收到的6位验证码',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildCodeInput() {
    return Column(
      children: [
        CodeInputWidget(
          controller: _codeController,
          onCompleted: _verifyCode,
          onChanged: () {
            setState(() {}); // 刷新UI状态
          },
        ),
        
        // 验证按钮 (可选，因为输入完成会自动验证)
        if (_codeController.text.length == 6)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
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
                      '验证',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildResendSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_countdown > 0) ...[
          Text(
            '${_countdown}秒后可重新获取验证码',
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
            onTap: _isLoading ? null : _resendCode,
            child: Text(
              '重新发送',
              style: TextStyle(
                color: _isLoading ? Colors.grey[400] : Colors.purple,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildBackToPhoneInput() {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Text(
          '重新输入手机号',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
