// 🔐 增强版统一登录页面
// 使用新的LoginApi，展示如何集成模块化API管理器

// ============== 1. IMPORTS ==============
import 'package:flutter/material.dart';
import 'dart:async';

// 导入登录模块
import 'login_api.dart';
import 'models/country_model.dart';
import 'models/auth_models.dart';
import 'config/auth_config.dart';
import 'widgets/code_input_widget.dart';
import 'widgets/password_input_widget.dart';
import 'widgets/phone_input_widget.dart';

// ============== 2. CONSTANTS ==============
class _EnhancedLoginConstants {
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
/// 增强版登录状态
class EnhancedLoginState {
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
  
  const EnhancedLoginState({
    this.currentMethod = LoginMethod.smsCode, // 默认验证码登录
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
  
  EnhancedLoginState copyWith({
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
    return EnhancedLoginState(
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
        return '密码登录';
      case LoginMethod.smsCode:
        return isCodeSent ? '请输入验证码' : '验证码登录';
      case LoginMethod.forgotPassword:
        return '忘记密码';
      case LoginMethod.resetPassword:
        return '重置密码';
    }
  }
  
  /// 获取当前方法的副标题
  String get methodSubtitle {
    switch (currentMethod) {
      case LoginMethod.password:
        return '使用手机号和密码登录';
      case LoginMethod.smsCode:
        return isCodeSent ? '验证码已发送至您的手机' : '使用手机号验证码登录';
      case LoginMethod.forgotPassword:
        return '请输入您的手机号，我们将发送验证码';
      case LoginMethod.resetPassword:
        return '请设置新密码';
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
    }
  }
}

// ============== 4. SERVICES ==============
class _EnhancedLoginService {
  late final LoginApi _loginApi;
  
  _EnhancedLoginService() {
    // 根据配置决定使用真实API还是Mock API
    _loginApi = LoginApiFactory.getInstance(useMock: AuthConfig.useMockService);
  }
  
  /// 发送验证码
  Future<ApiResponse<SmsCodeResponse>> sendSmsCode({
    required String mobile,
    String? countryCode,
  }) async {
    return await _loginApi.sendSmsCode(
      mobile: mobile,
      countryCode: countryCode,
      clientType: AuthConfig.clientType,
    );
  }
  
  /// 验证码登录
  Future<ApiResponse<LoginResponse>> loginWithSmsCode({
    required String mobile,
    required String code,
  }) async {
    return await _loginApi.verifySmsCode(
      mobile: mobile,
      code: code,
      clientType: AuthConfig.clientType,
    );
  }
  
  /// 密码登录
  Future<ApiResponse<LoginResponse>> loginWithPassword({
    required String mobile,
    required String password,
  }) async {
    return await _loginApi.loginWithPassword(
      mobile: mobile,
      password: password,
      clientType: AuthConfig.clientType,
    );
  }
  
  /// 重置密码
  Future<ApiResponse<Map<String, dynamic>>> resetPassword({
    required String mobile,
    required String newPassword,
    required String verificationCode,
  }) async {
    return await _loginApi.resetPassword(
      mobile: mobile,
      newPassword: newPassword,
      verificationCode: verificationCode,
      clientType: AuthConfig.clientType,
    );
  }
  
  /// 检查登录状态
  Future<bool> isLoggedIn() async {
    return await _loginApi.isLoggedIn();
  }
  
  /// 获取用户信息
  Future<UserInfo?> getUserInfo() async {
    return await _loginApi.getLocalUserInfo();
  }
}

// ============== 5. CONTROLLERS ==============
class _EnhancedLoginController extends ValueNotifier<EnhancedLoginState> {
  // 文本控制器
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  // 服务层
  late final _EnhancedLoginService _service;
  
  // 其他状态
  CountryModel? selectedCountry = CountryData.findByCode('+86');
  Timer? _countdownTimer;
  
  _EnhancedLoginController() : super(const EnhancedLoginState()) {
    _service = _EnhancedLoginService();
    _setupListeners();
    _checkExistingLogin();
  }
  
  /// 检查现有登录状态
  Future<void> _checkExistingLogin() async {
    try {
      final isLoggedIn = await _service.isLoggedIn();
      if (isLoggedIn) {
        final userInfo = await _service.getUserInfo();
        if (userInfo != null) {
          value = value.copyWith(
            userInfo: userInfo,
            successMessage: '欢迎回来，${userInfo.nickname ?? userInfo.mobile}',
          );
        }
      }
    } catch (e) {
      // 静默处理，不影响正常登录流程
    }
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
      isPhoneValid: LoginApi.validateMobile(phone, countryCode: selectedCountry?.code ?? '+86'),
      isPasswordValid: LoginApi.validatePassword(password),
      isCodeValid: LoginApi.validateVerificationCode(code),
    );
  }
  
  /// 切换登录方式
  void switchLoginMethod(LoginMethod method) {
    value = value.copyWith(
      currentMethod: method,
      errorMessage: null,
      successMessage: null,
      isCodeSent: false,
    );
    _clearSensitiveInputs();
    _stopCountdown();
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
  
  /// 发送验证码
  Future<void> sendSmsCode() async {
    if (!value.isPhoneValid) return;
    
    value = value.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final response = await _service.sendSmsCode(
        mobile: phoneController.text.trim(),
        countryCode: selectedCountry?.code,
      );
      
      if (response.isSuccess) {
        value = value.copyWith(
          isLoading: false,
          isCodeSent: true,
          successMessage: response.data?.message ?? '验证码发送成功',
        );
        _startCountdown();
      } else {
        value = value.copyWith(
          isLoading: false,
          errorMessage: response.message,
        );
      }
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
        mobile: phoneController.text.trim(),
        code: codeController.text.trim(),
      );
      
      if (response.isSuccess && response.data != null) {
        value = value.copyWith(
          isLoading: false,
          userInfo: response.data!.userInfo,
          accessToken: response.data!.accessToken,
          successMessage: '登录成功！',
        );
      } else {
        value = value.copyWith(
          isLoading: false,
          errorMessage: response.message,
        );
      }
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
  
  /// 密码登录
  Future<void> loginWithPassword() async {
    if (!value.canSubmit) return;
    
    value = value.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final response = await _service.loginWithPassword(
        mobile: phoneController.text.trim(),
        password: passwordController.text.trim(),
      );
      
      if (response.isSuccess && response.data != null) {
        value = value.copyWith(
          isLoading: false,
          userInfo: response.data!.userInfo,
          accessToken: response.data!.accessToken,
          successMessage: '登录成功！',
        );
      } else {
        value = value.copyWith(
          isLoading: false,
          errorMessage: response.message,
        );
      }
    } on ApiException catch (e) {
      value = value.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
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
    
    if (!LoginApi.validatePassword(newPassword)) {
      value = value.copyWith(errorMessage: '密码格式不正确');
      return;
    }
    
    value = value.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final response = await _service.resetPassword(
        mobile: phoneController.text.trim(),
        newPassword: newPassword,
        verificationCode: codeController.text.trim(),
      );
      
      if (response.isSuccess) {
        value = value.copyWith(
          isLoading: false,
          successMessage: '密码重置成功！',
        );
        
        // 延迟后切换到密码登录
        Timer(const Duration(seconds: 2), () {
          switchLoginMethod(LoginMethod.password);
        });
      } else {
        value = value.copyWith(
          isLoading: false,
          errorMessage: response.message,
        );
      }
    } on ApiException catch (e) {
      value = value.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    }
  }
  
  /// 开始倒计时
  void _startCountdown() {
    value = value.copyWith(
      countdown: _EnhancedLoginConstants.countdownSeconds,
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
  
  /// 停止倒计时
  void _stopCountdown() {
    _countdownTimer?.cancel();
    value = value.copyWith(countdown: 0, canResendCode: true);
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
/// API状态指示器
class _ApiStatusIndicator extends StatelessWidget {
  const _ApiStatusIndicator();
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AuthConfig.useMockService ? Colors.orange.shade100 : Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AuthConfig.useMockService ? Colors.orange.shade300 : Colors.green.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AuthConfig.useMockService ? Icons.science : Icons.cloud,
            size: 16,
            color: AuthConfig.useMockService ? Colors.orange.shade700 : Colors.green.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            AuthConfig.useMockService ? 'Mock API' : 'Live API',
            style: TextStyle(
              fontSize: 12,
              color: AuthConfig.useMockService ? Colors.orange.shade700 : Colors.green.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

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
      height: _EnhancedLoginConstants.buttonHeight,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? _EnhancedLoginConstants.primaryColor : Colors.grey[300],
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
      margin: const EdgeInsets.only(bottom: _EnhancedLoginConstants.spacing),
      decoration: BoxDecoration(
        color: isError
            ? _EnhancedLoginConstants.errorColor.withValues(alpha: 0.1)
            : _EnhancedLoginConstants.successColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isError 
              ? _EnhancedLoginConstants.errorColor 
              : _EnhancedLoginConstants.successColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError 
                ? _EnhancedLoginConstants.errorColor 
                : _EnhancedLoginConstants.successColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message!,
              style: TextStyle(
                color: isError 
                    ? _EnhancedLoginConstants.errorColor 
                    : _EnhancedLoginConstants.successColor,
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
/// 增强版登录页面 - 使用新的LoginApi
class EnhancedLoginPage extends StatefulWidget {
  const EnhancedLoginPage({super.key});
  
  @override
  State<EnhancedLoginPage> createState() => _EnhancedLoginPageState();
}

class _EnhancedLoginPageState extends State<EnhancedLoginPage> {
  late final _EnhancedLoginController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = _EnhancedLoginController();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('欢迎 ${state.userInfo!.nickname ?? state.userInfo!.mobile}！'),
          backgroundColor: _EnhancedLoginConstants.successColor,
        ),
      );
      
      // TODO: 导航到主页
      // Navigator.of(context).pushReplacementNamed('/home');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _EnhancedLoginConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _EnhancedLoginConstants.textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // API状态指示器
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: const _ApiStatusIndicator()),
          ),
        ],
      ),
      body: SafeArea(
        child: ValueListenableBuilder<EnhancedLoginState>(
          valueListenable: _controller,
          builder: (context, state, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(_EnhancedLoginConstants.largeSpacing),
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
  
  Widget _buildHeader(EnhancedLoginState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          state.methodTitle,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: _EnhancedLoginConstants.textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          state.methodSubtitle,
          style: const TextStyle(
            fontSize: 16,
            color: _EnhancedLoginConstants.hintColor,
          ),
        ),
      ],
    );
  }
  
  Widget _buildForm(EnhancedLoginState state) {
    switch (state.currentMethod) {
      case LoginMethod.password:
        return _buildPasswordForm(state);
      case LoginMethod.smsCode:
        return _buildSmsCodeForm(state);
      case LoginMethod.forgotPassword:
        return _buildForgotPasswordForm(state);
      case LoginMethod.resetPassword:
        return _buildResetPasswordForm(state);
    }
  }
  
  Widget _buildPasswordForm(EnhancedLoginState state) {
    return Column(
      children: [
        PhoneInputWidget(
          controller: _controller.phoneController,
          selectedCountry: _controller.selectedCountry,
          onCountryChanged: _controller.updateSelectedCountry,
          onChanged: () => setState(() {}),
          enableValidation: true,
          showValidationHint: false,
        ),
        const SizedBox(height: _EnhancedLoginConstants.spacing),
        PasswordInputWidget(
          controller: _controller.passwordController,
          hintText: '请输入6-20位密码',
          maxLength: _EnhancedLoginConstants.passwordMaxLength,
          onChanged: () => setState(() {}),
        ),
      ],
    );
  }
  
  Widget _buildSmsCodeForm(EnhancedLoginState state) {
    return Column(
      children: [
        if (!state.isCodeSent) ...[
          PhoneInputWidget(
            controller: _controller.phoneController,
            selectedCountry: _controller.selectedCountry,
            onCountryChanged: _controller.updateSelectedCountry,
            onChanged: () => setState(() {}),
            enableValidation: true,
            showValidationHint: false,
          ),
          const SizedBox(height: _EnhancedLoginConstants.spacing),
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
          const SizedBox(height: _EnhancedLoginConstants.spacing),
          _buildResendCodeSection(state),
        ],
      ],
    );
  }
  
  Widget _buildForgotPasswordForm(EnhancedLoginState state) {
    return PhoneInputWidget(
      controller: _controller.phoneController,
      selectedCountry: _controller.selectedCountry,
      onCountryChanged: _controller.updateSelectedCountry,
      onChanged: () => setState(() {}),
      enableValidation: true,
      showValidationHint: false,
    );
  }
  
  Widget _buildResetPasswordForm(EnhancedLoginState state) {
    return Column(
      children: [
        PasswordInputWidget(
          controller: _controller.newPasswordController,
          hintText: '请输入新密码',
          maxLength: _EnhancedLoginConstants.passwordMaxLength,
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: _EnhancedLoginConstants.spacing),
        PasswordInputWidget(
          controller: _controller.confirmPasswordController,
          hintText: '请再次输入新密码',
          maxLength: _EnhancedLoginConstants.passwordMaxLength,
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: _EnhancedLoginConstants.spacing),
        _buildPasswordRequirements(),
      ],
    );
  }
  
  Widget _buildResendCodeSection(EnhancedLoginState state) {
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
                color: state.canResendCode 
                    ? _EnhancedLoginConstants.primaryColor 
                    : Colors.grey,
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
  
  Widget _buildPrimaryButton(EnhancedLoginState state) {
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
        buttonText = '确认重置';
        onPressed = _controller.resetPassword;
        break;
    }
    
    return _PrimaryButton(
      text: buttonText,
      onPressed: onPressed,
      isLoading: state.isLoading,
      isEnabled: state.canSubmit,
    );
  }
  
  Widget _buildSecondaryActions(EnhancedLoginState state) {
    switch (state.currentMethod) {
      case LoginMethod.password:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => _controller.switchLoginMethod(LoginMethod.smsCode),
              child: const Text(
                '验证码登录',
                style: TextStyle(color: _EnhancedLoginConstants.primaryColor, fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () => _controller.switchLoginMethod(LoginMethod.forgotPassword),
              child: const Text(
                '忘记密码?',
                style: TextStyle(color: _EnhancedLoginConstants.primaryColor, fontSize: 16),
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
              style: TextStyle(color: _EnhancedLoginConstants.primaryColor, fontSize: 16),
            ),
          ),
        );
      case LoginMethod.forgotPassword:
      case LoginMethod.resetPassword:
        return Center(
          child: TextButton(
            onPressed: () => _controller.switchLoginMethod(LoginMethod.smsCode),
            child: const Text(
              '返回登录',
              style: TextStyle(color: _EnhancedLoginConstants.primaryColor, fontSize: 16),
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
              style: TextStyle(color: _EnhancedLoginConstants.primaryColor, fontSize: 12),
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
              style: TextStyle(color: _EnhancedLoginConstants.primaryColor, fontSize: 12),
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
}

// ============== 8. EXPORTS ==============
/// 导出增强版登录页面
/// 使用方式：
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (context) => EnhancedLoginPage()),
/// );
/// ```
