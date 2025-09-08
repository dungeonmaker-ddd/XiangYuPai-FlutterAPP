// 🔐 统一登录页面 - 单文件架构实现
// 整合密码登录、验证码登录、忘记密码等所有功能

// ============== 1. IMPORTS ==============
import 'package:flutter/material.dart';
import 'dart:async';

// 现有模块导入
import 'models/country_model.dart';
import 'models/auth_models.dart';
import 'services/auth_service.dart';
import 'config/auth_config.dart';
import 'widgets/code_input_widget.dart';
import 'widgets/password_input_widget.dart';
import 'widgets/phone_input_widget.dart';

// ============== 2. CONSTANTS ==============
class _LoginConstants {
  // UI 尺寸配置
  static const double spacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double buttonHeight = 50.0;
  
  // 颜色配置
  static const Color primaryColor = Color(0xFF9C27B0); // 紫色主题
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Colors.black;
  static const Color hintColor = Color(0xFF9E9E9E);
  static const Color errorColor = Color(0xFFE53E3E);
  static const Color successColor = Color(0xFF38A169);
  
  // 业务常量
  static const int passwordMinLength = 6;
  static const int passwordMaxLength = 20;
  static const int countdownSeconds = 60;
}

// ============== 3. MODELS ==============
// LoginMethod 枚举已移动到 models/auth_models.dart 中统一管理

/// 统一登录状态
class UnifiedLoginState {
  final LoginMethod currentMethod;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  
  // 短信验证码相关状态
  final bool isCodeSent;
  final int countdown;
  final bool canResendCode;
  
  // 用户数据
  final UserInfo? userInfo;
  final String? accessToken;
  
  // 表单验证状态
  final bool isPhoneValid;
  final bool isPasswordValid;
  final bool isCodeValid;
  
  const UnifiedLoginState({
    this.currentMethod = LoginMethod.password,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.isCodeSent = false,
    this.countdown = 0,
    this.canResendCode = true,
    this.userInfo,
    this.accessToken,
    this.isPhoneValid = false,
    this.isPasswordValid = false,
    this.isCodeValid = false,
  });
  
  UnifiedLoginState copyWith({
    LoginMethod? currentMethod,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool? isCodeSent,
    int? countdown,
    bool? canResendCode,
    UserInfo? userInfo,
    String? accessToken,
    bool? isPhoneValid,
    bool? isPasswordValid,
    bool? isCodeValid,
  }) {
    return UnifiedLoginState(
      currentMethod: currentMethod ?? this.currentMethod,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isCodeSent: isCodeSent ?? this.isCodeSent,
      countdown: countdown ?? this.countdown,
      canResendCode: canResendCode ?? this.canResendCode,
      userInfo: userInfo ?? this.userInfo,
      accessToken: accessToken ?? this.accessToken,
      isPhoneValid: isPhoneValid ?? this.isPhoneValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      isCodeValid: isCodeValid ?? this.isCodeValid,
    );
  }
  
  /// 获取当前方法的标题
  String get methodTitle {
    switch (currentMethod) {
      case LoginMethod.password:
        return '您好！';
      case LoginMethod.smsCode:
        return isCodeSent ? '请输入验证码' : '您好！';
      case LoginMethod.forgotPassword:
        return '忘记密码';
      case LoginMethod.resetPassword:
        return '重置密码';
      case LoginMethod.phone:
        return '手机号登录';
      case LoginMethod.email:
        return '邮箱登录';
      case LoginMethod.wechat:
        return '微信登录';
      case LoginMethod.qq:
        return 'QQ登录';
    }
  }
  
  /// 获取当前方法的副标题
  String get methodSubtitle {
    switch (currentMethod) {
      case LoginMethod.password:
        return '欢迎使用探店';
      case LoginMethod.smsCode:
        return isCodeSent ? '验证码已发送至您的手机' : '欢迎使用探店';
      case LoginMethod.forgotPassword:
        return '请输入您的手机号，我们将发送验证码';
      case LoginMethod.resetPassword:
        return '6-20个字符，不可以是纯数字';
      case LoginMethod.phone:
        return '请输入您的手机号';
      case LoginMethod.email:
        return '请输入您的邮箱地址';
      case LoginMethod.wechat:
        return '使用微信账号登录';
      case LoginMethod.qq:
        return '使用QQ账号登录';
    }
  }
  
  /// 是否可以提交表单
  bool get canSubmit {
    if (isLoading) return false;

    switch (currentMethod) {
      case LoginMethod.password:
        return isPhoneValid && isPasswordValid;
      case LoginMethod.smsCode:
        return isCodeSent ? isCodeValid : isPhoneValid;
      case LoginMethod.forgotPassword:
        return isPhoneValid;
      case LoginMethod.resetPassword:
        return isPasswordValid;
      case LoginMethod.phone:
        return isPhoneValid;
      case LoginMethod.email:
        return isPhoneValid; // 暂时复用手机验证逻辑
      case LoginMethod.wechat:
        return true; // 第三方登录无需验证
      case LoginMethod.qq:
        return true; // 第三方登录无需验证
    }
  }
}

/// 输入验证工具类
class _ValidationUtils {
  /// 验证手机号
  static bool isPhoneValid(String phone, CountryModel? country) {
    return PhoneInputWidget.isPhoneValid(
      phone: phone,
      selectedCountry: country,
    );
  }
  
  /// 验证密码
  static bool isPasswordValid(String password) {
    if (password.length < _LoginConstants.passwordMinLength) return false;
    if (password.length > _LoginConstants.passwordMaxLength) return false;
    if (RegExp(r'^[0-9]+$').hasMatch(password)) return false; // 不能是纯数字
    return true;
  }
  
  /// 验证验证码
  static bool isCodeValid(String code) {
    return code.length == 6 && RegExp(r'^\d{6}$').hasMatch(code);
  }
}

// ============== 4. SERVICES ==============
class _UnifiedLoginService {
  late final IAuthService _authService;
  
  _UnifiedLoginService() {
    _authService = AuthConfig.useMockService 
        ? MockAuthService() 
        : AuthServiceFactory.getInstance();
  }
  
  /// 密码登录
  Future<ApiResponse<LoginResponse>> loginWithPassword({
    required String phone,
    required String password,
  }) async {
    // 这里应该调用密码登录API，目前模拟实现
    await Future.delayed(const Duration(seconds: 2));
    
    if (password == '123456') {
      return ApiResponse<LoginResponse>(
        code: 200,
        message: '登录成功',
        data: LoginResponse(
          accessToken: 'password_token_${DateTime.now().millisecondsSinceEpoch}',
          refreshToken: 'refresh_token_${DateTime.now().millisecondsSinceEpoch}',
          tokenType: 'Bearer',
          expiresIn: 7200,
          userInfo: UserInfo(
            userId: 'user_$phone',
            mobile: '${phone.substring(0, 3)}****${phone.substring(7)}',
            nickname: '用户${phone.substring(7)}',
            avatarUrl: null,
          ),
        ),
      );
    } else {
      throw const ApiException(code: 400, message: '密码错误');
    }
  }
  
  /// 发送验证码
  Future<ApiResponse<SmsCodeResponse>> sendSmsCode(String phone) async {
    final request = SmsCodeRequest(
      mobile: phone,
      clientType: AuthConfig.clientType,
    );
    return await _authService.sendSmsCode(request);
  }
  
  /// 验证码登录
  Future<ApiResponse<LoginResponse>> loginWithSmsCode({
    required String phone,
    required String code,
  }) async {
    final request = SmsVerifyRequest(
      mobile: phone,
      code: code,
      clientType: AuthConfig.clientType,
    );
    return await _authService.verifySmsCode(request);
  }
  
  /// 重置密码
  Future<bool> resetPassword({
    required String phone,
    required String newPassword,
    required String verificationCode,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    // 模拟重置成功
    return true;
  }
}

// ============== 5. CONTROLLERS ==============
class _UnifiedLoginController extends ValueNotifier<UnifiedLoginState> {
  // 文本控制器
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  // 服务层
  late final _UnifiedLoginService _service;
  
  // 其他状态
  CountryModel? selectedCountry = CountryData.findByCode('+86');
  Timer? _countdownTimer;
  
  _UnifiedLoginController() : super(const UnifiedLoginState()) {
    _service = _UnifiedLoginService();
    _setupListeners();
  }
  
  /// 设置监听器
  void _setupListeners() {
    phoneController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
    codeController.addListener(_validateForm);
    newPasswordController.addListener(_validateForm);
    confirmPasswordController.addListener(_validateForm);
  }
  
  /// 验证表单
  void _validateForm() {
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();
    final code = codeController.text.trim();
    
    value = value.copyWith(
      isPhoneValid: _ValidationUtils.isPhoneValid(phone, selectedCountry),
      isPasswordValid: _ValidationUtils.isPasswordValid(password),
      isCodeValid: _ValidationUtils.isCodeValid(code),
    );
  }
  
  /// 切换登录方式
  void switchLoginMethod(LoginMethod method) {
    value = value.copyWith(
      currentMethod: method,
      errorMessage: null,
      successMessage: null,
    );
    _clearSensitiveInputs();
  }
  
  /// 清除敏感输入
  void _clearSensitiveInputs() {
    if (value.currentMethod != LoginMethod.password) {
      passwordController.clear();
    }
    if (value.currentMethod != LoginMethod.smsCode && 
        value.currentMethod != LoginMethod.forgotPassword) {
      codeController.clear();
    }
    if (value.currentMethod != LoginMethod.resetPassword) {
      newPasswordController.clear();
      confirmPasswordController.clear();
    }
  }
  
  /// 更新选中的国家
  void updateSelectedCountry(CountryModel country) {
    selectedCountry = country;
    phoneController.clear(); // 清空手机号重新输入
    _validateForm();
  }
  
  /// 密码登录
  Future<void> loginWithPassword() async {
    if (!value.canSubmit) return;
    
    value = value.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final response = await _service.loginWithPassword(
        phone: phoneController.text.trim(),
        password: passwordController.text.trim(),
      );
      
      value = value.copyWith(
        isLoading: false,
        userInfo: response.data?.userInfo,
        accessToken: response.data?.accessToken,
        successMessage: '登录成功！',
      );
    } on ApiException catch (e) {
      value = value.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    }
  }
  
  /// 发送验证码
  Future<void> sendSmsCode() async {
    if (!value.isPhoneValid) return;
    
    value = value.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final response = await _service.sendSmsCode(phoneController.text.trim());
      
      value = value.copyWith(
        isLoading: false,
        isCodeSent: true,
        successMessage: response.message,
      );
      
      _startCountdown();
    } on ApiException catch (e) {
      value = value.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    }
  }
  
  /// 验证码登录
  Future<void> loginWithSmsCode() async {
    if (!value.canSubmit) return;
    
    value = value.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final response = await _service.loginWithSmsCode(
        phone: phoneController.text.trim(),
        code: codeController.text.trim(),
      );
      
      value = value.copyWith(
        isLoading: false,
        userInfo: response.data?.userInfo,
        accessToken: response.data?.accessToken,
        successMessage: '登录成功！',
      );
    } on ApiException catch (e) {
      value = value.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      
      // 验证码错误时清空输入
      if (e.code == 400) {
        codeController.clear();
      }
    }
  }
  
  /// 忘记密码 - 发送验证码
  Future<void> forgotPasswordSendCode() async {
    await sendSmsCode(); // 复用发送验证码逻辑
    
    if (value.isCodeSent) {
      // 切换到重置密码模式
      switchLoginMethod(LoginMethod.resetPassword);
    }
  }
  
  /// 重置密码
  Future<void> resetPassword() async {
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    
    if (newPassword != confirmPassword) {
      value = value.copyWith(errorMessage: '两次输入的密码不一致');
      return;
    }
    
    if (!_ValidationUtils.isPasswordValid(newPassword)) {
      value = value.copyWith(errorMessage: '密码格式不正确');
      return;
    }
    
    value = value.copyWith(isLoading: true, errorMessage: null);
    
    try {
      await _service.resetPassword(
        phone: phoneController.text.trim(),
        newPassword: newPassword,
        verificationCode: codeController.text.trim(),
      );
      
      value = value.copyWith(
        isLoading: false,
        successMessage: '密码重置成功！',
      );
      
      // 延迟后切换到密码登录
      Timer(const Duration(seconds: 2), () {
        switchLoginMethod(LoginMethod.password);
      });
    } catch (e) {
      value = value.copyWith(
        isLoading: false,
        errorMessage: '重置密码失败，请重试',
      );
    }
  }
  
  /// 开始倒计时
  void _startCountdown() {
    value = value.copyWith(
      countdown: _LoginConstants.countdownSeconds,
      canResendCode: false,
    );
    
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (value.countdown <= 1) {
        timer.cancel();
        value = value.copyWith(countdown: 0, canResendCode: true);
      } else {
        value = value.copyWith(countdown: value.countdown - 1);
      }
    });
  }
  
  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    codeController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }
}

// ============== 6. WIDGETS ==============
/// 主要操作按钮
class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  
  const _PrimaryButton({
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
  });
  
  @override
  Widget build(BuildContext context) {
    final enabled = isEnabled && !isLoading && onPressed != null;
    
    return SizedBox(
      width: double.infinity,
      height: _LoginConstants.buttonHeight,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? _LoginConstants.primaryColor : Colors.grey[300],
          foregroundColor: enabled ? Colors.white : Colors.grey[600],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
}

/// 消息显示组件
class _MessageDisplay extends StatelessWidget {
  final String? message;
  final bool isError;
  
  const _MessageDisplay({
    this.message,
    this.isError = false,
  });
  
  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: _LoginConstants.spacing),
      decoration: BoxDecoration(
        color: isError ? _LoginConstants.errorColor.withValues(alpha: 0.1) : _LoginConstants.successColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isError ? _LoginConstants.errorColor : _LoginConstants.successColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? _LoginConstants.errorColor : _LoginConstants.successColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message!,
              style: TextStyle(
                color: isError ? _LoginConstants.errorColor : _LoginConstants.successColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============== 7. PAGES ==============
/// 统一登录页面 - 主页面入口
class UnifiedLoginPage extends StatefulWidget {
  const UnifiedLoginPage({super.key});
  
  @override
  State<UnifiedLoginPage> createState() => _UnifiedLoginPageState();
}

class _UnifiedLoginPageState extends State<UnifiedLoginPage> {
  late final _UnifiedLoginController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = _UnifiedLoginController();
    _controller.addListener(_onStateChanged);
  }
  
  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    _controller.dispose();
    super.dispose();
  }
  
  void _onStateChanged() {
    final state = _controller.value;
    
    // 登录成功处理
    if (state.userInfo != null && state.accessToken != null) {
      // TODO: 保存登录状态到本地存储
      // TODO: 导航到主页
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('欢迎 ${state.userInfo!.nickname ?? ''}！'),
          backgroundColor: _LoginConstants.successColor,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _LoginConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _LoginConstants.textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ValueListenableBuilder<UnifiedLoginState>(
          valueListenable: _controller,
          builder: (context, state, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(_LoginConstants.largeSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  // 标题区域
                  _buildHeader(state),
                  
                  const SizedBox(height: 40),
                  
                  // 消息显示
                  _MessageDisplay(
                    message: state.errorMessage,
                    isError: true,
                  ),
                  _MessageDisplay(
                    message: state.successMessage,
                    isError: false,
                  ),
                  
                  // 表单区域
                  _buildForm(state),
                  
                  const SizedBox(height: 40),
                  
                  // 主要操作按钮
                  _buildPrimaryButton(state),
                  
                  const SizedBox(height: 20),
                  
                  // 辅助操作区域
                  _buildSecondaryActions(state),
                  
                  const SizedBox(height: 40),
                  
                  // 底部协议
                  _buildUserAgreement(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildHeader(UnifiedLoginState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          state.methodTitle,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: _LoginConstants.textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          state.methodSubtitle,
          style: const TextStyle(
            fontSize: 18,
            color: _LoginConstants.hintColor,
          ),
        ),
      ],
    );
  }
  
  Widget _buildForm(UnifiedLoginState state) {
    switch (state.currentMethod) {
      case LoginMethod.password:
        return _buildPasswordForm(state);
      case LoginMethod.smsCode:
        return _buildSmsCodeForm(state);
      case LoginMethod.forgotPassword:
        return _buildForgotPasswordForm(state);
      case LoginMethod.resetPassword:
        return _buildResetPasswordForm(state);
      case LoginMethod.phone:
        return _buildPasswordForm(state); // 复用密码表单
      case LoginMethod.email:
        return _buildPasswordForm(state); // 复用密码表单
      case LoginMethod.wechat:
        return _buildThirdPartyForm('微信登录');
      case LoginMethod.qq:
        return _buildThirdPartyForm('QQ登录');
    }
  }
  
  Widget _buildPasswordForm(UnifiedLoginState state) {
    return Column(
      children: [
        PhoneInputWidget(
          controller: _controller.phoneController,
          selectedCountry: _controller.selectedCountry,
          onCountryChanged: _controller.updateSelectedCountry,
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: _LoginConstants.spacing),
        PasswordInputWidget(
          controller: _controller.passwordController,
          hintText: '请输入6-20位密码',
          maxLength: _LoginConstants.passwordMaxLength,
          onChanged: () => setState(() {}),
        ),
      ],
    );
  }
  
  Widget _buildSmsCodeForm(UnifiedLoginState state) {
    return Column(
      children: [
        if (!state.isCodeSent) ...[
          PhoneInputWidget(
            controller: _controller.phoneController,
            selectedCountry: _controller.selectedCountry,
            onCountryChanged: _controller.updateSelectedCountry,
            onChanged: () => setState(() {}),
          ),
          const SizedBox(height: _LoginConstants.spacing),
          Text(
            '未注册手机号验证后自动创建账号',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ] else ...[
          CodeInputWidget(
            controller: _controller.codeController,
            onCompleted: _controller.loginWithSmsCode,
            onChanged: () => setState(() {}),
          ),
          const SizedBox(height: _LoginConstants.spacing),
          _buildResendCodeSection(state),
        ],
      ],
    );
  }
  
  Widget _buildForgotPasswordForm(UnifiedLoginState state) {
    return PhoneInputWidget(
      controller: _controller.phoneController,
      selectedCountry: _controller.selectedCountry,
      onCountryChanged: _controller.updateSelectedCountry,
      onChanged: () => setState(() {}),
    );
  }
  
  Widget _buildResetPasswordForm(UnifiedLoginState state) {
    return Column(
      children: [
        PasswordInputWidget(
          controller: _controller.newPasswordController,
          hintText: '请输入新密码',
          maxLength: _LoginConstants.passwordMaxLength,
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: _LoginConstants.spacing),
        PasswordInputWidget(
          controller: _controller.confirmPasswordController,
          hintText: '请再次输入新密码',
          maxLength: _LoginConstants.passwordMaxLength,
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: _LoginConstants.spacing),
        _buildPasswordRequirements(),
      ],
    );
  }
  
  Widget _buildResendCodeSection(UnifiedLoginState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (state.countdown > 0) ...[
          Text(
            '${state.countdown}秒后重新获取验证码',
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
            onTap: state.canResendCode ? _controller.sendSmsCode : null,
            child: Text(
              '重新发送',
              style: TextStyle(
                color: state.canResendCode ? _LoginConstants.primaryColor : Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ]
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
        Text('• 6-20个字符', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        Text('• 不能是纯数字', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
  
  Widget _buildPrimaryButton(UnifiedLoginState state) {
    String buttonText;
    VoidCallback? onPressed;
    
    switch (state.currentMethod) {
      case LoginMethod.password:
        buttonText = '登录';
        onPressed = _controller.loginWithPassword;
        break;
      case LoginMethod.smsCode:
        if (state.isCodeSent) {
          buttonText = '立即登录';
          onPressed = _controller.loginWithSmsCode;
        } else {
          buttonText = '获取验证码';
          onPressed = _controller.sendSmsCode;
        }
        break;
      case LoginMethod.forgotPassword:
        buttonText = '获取短信验证码';
        onPressed = _controller.forgotPasswordSendCode;
        break;
      case LoginMethod.resetPassword:
        buttonText = '确认';
        onPressed = _controller.resetPassword;
        break;
      case LoginMethod.phone:
        buttonText = '登录';
        onPressed = _controller.loginWithPassword;
        break;
      case LoginMethod.email:
        buttonText = '登录';
        onPressed = _controller.loginWithPassword;
        break;
      case LoginMethod.wechat:
        buttonText = '微信登录';
        onPressed = () => _controller.loginWithThirdParty('wechat');
        break;
      case LoginMethod.qq:
        buttonText = 'QQ登录';
        onPressed = () => _controller.loginWithThirdParty('qq');
        break;
    }
    
    return _PrimaryButton(
      text: buttonText,
      onPressed: onPressed,
      isLoading: state.isLoading,
      isEnabled: state.canSubmit,
    );
  }
  
  Widget _buildSecondaryActions(UnifiedLoginState state) {
    switch (state.currentMethod) {
      case LoginMethod.password:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => _controller.switchLoginMethod(LoginMethod.smsCode),
              child: const Text(
                '验证码登录',
                style: TextStyle(color: _LoginConstants.primaryColor, fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () => _controller.switchLoginMethod(LoginMethod.forgotPassword),
              child: const Text(
                '忘记密码?',
                style: TextStyle(color: _LoginConstants.primaryColor, fontSize: 16),
              ),
            ),
          ],
        );
      case LoginMethod.smsCode:
        return Center(
          child: TextButton(
            onPressed: () => _controller.switchLoginMethod(LoginMethod.password),
            child: const Text(
              '密码登录',
              style: TextStyle(color: _LoginConstants.primaryColor, fontSize: 16),
            ),
          ),
        );
      case LoginMethod.forgotPassword:
      case LoginMethod.resetPassword:
        return Center(
          child: TextButton(
            onPressed: () => _controller.switchLoginMethod(LoginMethod.password),
            child: const Text(
              '返回登录',
              style: TextStyle(color: _LoginConstants.primaryColor, fontSize: 16),
            ),
          ),
        );
      case LoginMethod.phone:
      case LoginMethod.email:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => _controller.switchLoginMethod(LoginMethod.smsCode),
              child: const Text(
                '验证码登录',
                style: TextStyle(color: _LoginConstants.primaryColor, fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () => _controller.switchLoginMethod(LoginMethod.forgotPassword),
              child: const Text(
                '忘记密码?',
                style: TextStyle(color: _LoginConstants.primaryColor, fontSize: 16),
              ),
            ),
          ],
        );
      case LoginMethod.wechat:
      case LoginMethod.qq:
        return Center(
          child: TextButton(
            onPressed: () => _controller.switchLoginMethod(LoginMethod.password),
            child: const Text(
              '其他登录方式',
              style: TextStyle(color: _LoginConstants.primaryColor, fontSize: 16),
            ),
          ),
        );
    }
  }
  
  Widget _buildUserAgreement() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '登陆即表示同意 ',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          GestureDetector(
            onTap: () => _showUserAgreement(),
            child: const Text(
              '《探店用户协议》',
              style: TextStyle(color: _LoginConstants.primaryColor, fontSize: 12),
            ),
          ),
          Text(
            ' 和 ',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          GestureDetector(
            onTap: () => _showPrivacyPolicy(),
            child: const Text(
              '《隐私政策》',
              style: TextStyle(color: _LoginConstants.primaryColor, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showUserAgreement() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('探店用户协议'),
        content: const SingleChildScrollView(
          child: Text('这里是用户协议的内容...\n\n1. 用户权利与义务\n2. 服务条款\n3. 隐私保护\n4. 免责声明'),
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
  
  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('隐私政策'),
        content: const SingleChildScrollView(
          child: Text('这里是隐私政策的内容...\n\n1. 信息收集\n2. 信息使用\n3. 信息安全\n4. 用户控制'),
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

  /// 构建第三方登录表单
  Widget _buildThirdPartyForm(String loginType) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(
            loginType.contains('微信') ? Icons.chat : Icons.account_circle,
            size: 80,
            color: _LoginConstants.primaryColor,
          ),
          const SizedBox(height: 20),
          Text(
            '点击下方按钮使用$loginType',
            style: const TextStyle(
              fontSize: 16,
              color: _LoginConstants.hintColor,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// 在 _UnifiedLoginController 中添加第三方登录方法的扩展
extension _UnifiedLoginControllerExtension on _UnifiedLoginController {
  /// 第三方登录
  Future<void> loginWithThirdParty(String platform) async {
    value = value.copyWith(isLoading: true, errorMessage: null);

    try {
      // 模拟第三方登录
      await Future.delayed(const Duration(seconds: 2));

      // 模拟登录成功
      value = value.copyWith(
        isLoading: false,
        userInfo: UserInfo(
          userId: '${platform}_user_123',
          mobile: '138****8888',
          nickname: '$platform用户',
          avatarUrl: '',
        ),
        successMessage: '$platform登录成功',
      );
    } catch (e) {
      value = value.copyWith(
        isLoading: false,
        errorMessage: '$platform登录失败，请重试',
      );
    }
  }
}

// ============== 8. EXPORTS ==============
/// 只导出主页面，保持接口简洁
/// 注意：export语句应该放在文件顶部，这里仅作为注释说明
/// 实际使用时，在其他文件中通过 import 'unified_login_page.dart' 导入
