// 💳 支付流程页面 - 单文件架构完整实现
// 基于Flutter单文件架构规范的8段式结构设计
// 完整的支付流程：选择支付方式 -> 输入密码 -> 处理支付 -> 支付结果

// ============== 1. IMPORTS ==============
// Flutter核心库
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Dart核心库
import 'dart:async';
import 'dart:developer' as developer;

// 项目内部文件
import '../../models/service_models.dart';        // 服务系统数据模型

// ============== 2. CONSTANTS ==============
/// 🎨 支付流程页私有常量
class _PaymentFlowConstants {
  const _PaymentFlowConstants._();
  
  // 页面标识
  static const String pageTitle = '支付';
  static const String routeName = '/payment-flow';
  
  // UI配置
  static const double cardBorderRadius = 12.0;
  static const double sectionSpacing = 16.0;
  static const double bottomBarHeight = 80.0;
  static const double passwordDotSize = 16.0;
  static const int passwordLength = 6;
  
  // 颜色配置
  static const int primaryPurple = 0xFF8B5CF6;
  static const int backgroundGray = 0xFFF9FAFB;
  static const int cardWhite = 0xFFFFFFFF;
  static const int textPrimary = 0xFF1F2937;
  static const int textSecondary = 0xFF6B7280;
  static const int successGreen = 0xFF10B981;
  static const int errorRed = 0xFFEF4444;
  static const int borderGray = 0xFFE5E7EB;
  static const int warningOrange = 0xFFF59E0B;
  
  // 支付方式配置
  static const List<Map<String, dynamic>> paymentMethods = [
    {
      'method': PaymentMethod.coin,
      'icon': Icons.monetization_on,
      'color': 0xFFFFD700,
      'description': '使用金币余额支付',
      'isDefault': true,
    },
    {
      'method': PaymentMethod.wechat,
      'icon': Icons.chat,
      'color': 0xFF07C160,
      'description': '微信支付',
      'isDefault': false,
    },
    {
      'method': PaymentMethod.alipay,
      'icon': Icons.account_balance_wallet,
      'color': 0xFF1677FF,
      'description': '支付宝',
      'isDefault': false,
    },
    {
      'method': PaymentMethod.apple,
      'icon': Icons.apple,
      'color': 0xFF000000,
      'description': 'Apple Pay',
      'isDefault': false,
    },
  ];
}

// ============== 3. MODELS ==============
// 使用 service_models.dart 中定义的通用模型

// ============== 4. SERVICES ==============
/// 🔧 支付流程服务
class _PaymentFlowService {
  /// 获取用户金币余额
  static Future<double> getUserBalance() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 888.88; // 模拟用户余额
  }
  
  /// 验证支付密码
  static Future<bool> verifyPaymentPassword(String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    // 模拟密码验证（实际应该调用后端API）
    if (password.length != _PaymentFlowConstants.passwordLength) {
      throw '支付密码必须是6位数字';
    }
    
    // 模拟验证失败的情况
    if (password == '000000') {
      throw '支付密码错误，请重新输入';
    }
    
    return true;
  }
  
  /// 处理支付
  static Future<PaymentInfoModel> processPayment({
    required ServiceOrderModel order,
    required PaymentMethod paymentMethod,
    required String paymentPassword,
  }) async {
    // 模拟支付处理时间
    await Future.delayed(const Duration(milliseconds: 2000));
    
    // 生成交易ID
    final transactionId = 'txn_${DateTime.now().millisecondsSinceEpoch}';
    
    // 模拟支付成功/失败
    final isSuccess = DateTime.now().millisecond % 10 != 0; // 90%成功率
    
    final paymentInfo = PaymentInfoModel(
      orderId: order.id,
      paymentMethod: paymentMethod,
      amount: order.totalPrice,
      currency: order.currency,
      status: isSuccess ? PaymentStatus.success : PaymentStatus.failed,
      transactionId: isSuccess ? transactionId : null,
      createdAt: DateTime.now(),
      completedAt: isSuccess ? DateTime.now() : null,
      errorMessage: isSuccess ? null : '支付处理失败，请重试',
    );
    
    if (!isSuccess) {
      throw paymentInfo.errorMessage!;
    }
    
    return paymentInfo;
  }
  
  /// 获取支付方式可用状态
  static Future<Map<PaymentMethod, bool>> getPaymentMethodAvailability() async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    return {
      PaymentMethod.coin: true,
      PaymentMethod.wechat: true,
      PaymentMethod.alipay: true,
      PaymentMethod.apple: false, // 模拟Apple Pay不可用
    };
  }
}

// ============== 5. CONTROLLERS ==============
/// 🧠 支付流程页面控制器
class _PaymentFlowController extends ValueNotifier<PaymentFlowPageState> {
  _PaymentFlowController(this.order) 
      : super(PaymentFlowPageState(order: order)) {
    _initialize();
  }

  final ServiceOrderModel order;
  String _paymentPassword = '';

  /// 初始化数据
  Future<void> _initialize() async {
    try {
      value = value.copyWith(isLoading: true, errorMessage: null);
      
      // 并发获取用户余额和支付方式可用性
      final results = await Future.wait([
        _PaymentFlowService.getUserBalance(),
        _PaymentFlowService.getPaymentMethodAvailability(),
      ]);
      
      final userBalance = results[0] as double;
      final availability = results[1] as Map<PaymentMethod, bool>;
      
      // 检查金币余额是否充足
      PaymentMethod? defaultMethod;
      if (userBalance >= order.totalPrice && availability[PaymentMethod.coin] == true) {
        defaultMethod = PaymentMethod.coin;
      } else {
        // 选择第一个可用的支付方式
        for (final method in PaymentMethod.values) {
          if (availability[method] == true && method != PaymentMethod.coin) {
            defaultMethod = method;
            break;
          }
        }
      }
      
      value = value.copyWith(
        isLoading: false,
        selectedPaymentMethod: defaultMethod,
        currentStep: PaymentStep.selectMethod,
      );
    } catch (e) {
      value = value.copyWith(
        isLoading: false,
        errorMessage: '初始化失败: $e',
      );
      developer.log('支付流程初始化失败: $e');
    }
  }

  /// 选择支付方式
  void selectPaymentMethod(PaymentMethod method) {
    value = value.copyWith(
      selectedPaymentMethod: method,
      errorMessage: null,
    );
  }

  /// 确认支付方式，进入密码输入步骤
  void confirmPaymentMethod() {
    if (value.selectedPaymentMethod == null) {
      value = value.copyWith(errorMessage: '请选择支付方式');
      return;
    }
    
    value = value.copyWith(
      currentStep: PaymentStep.inputPassword,
      errorMessage: null,
    );
    _paymentPassword = '';
  }

  /// 输入支付密码
  void inputPasswordDigit(String digit) {
    if (_paymentPassword.length < _PaymentFlowConstants.passwordLength) {
      _paymentPassword += digit;
      
      // 触发UI更新
      value = value.copyWith(
        paymentPassword: _paymentPassword,
        errorMessage: null,
      );
      
      // 如果密码输入完整，自动开始支付
      if (_paymentPassword.length == _PaymentFlowConstants.passwordLength) {
        _processPayment();
      }
    }
  }

  /// 删除密码数字
  void deletePasswordDigit() {
    if (_paymentPassword.isNotEmpty) {
      _paymentPassword = _paymentPassword.substring(0, _paymentPassword.length - 1);
      value = value.copyWith(
        paymentPassword: _paymentPassword,
        errorMessage: null,
      );
    }
  }

  /// 清除密码
  void clearPassword() {
    _paymentPassword = '';
    value = value.copyWith(
      paymentPassword: '',
      errorMessage: null,
    );
  }

  /// 处理支付
  Future<void> _processPayment() async {
    if (value.selectedPaymentMethod == null || _paymentPassword.isEmpty) return;
    
    try {
      value = value.copyWith(
        currentStep: PaymentStep.processing,
        isLoading: true,
        errorMessage: null,
      );
      
      // 验证支付密码
      await _PaymentFlowService.verifyPaymentPassword(_paymentPassword);
      
      // 处理支付
      final paymentInfo = await _PaymentFlowService.processPayment(
        order: order,
        paymentMethod: value.selectedPaymentMethod!,
        paymentPassword: _paymentPassword,
      );
      
      value = value.copyWith(
        isLoading: false,
        paymentInfo: paymentInfo,
        currentStep: PaymentStep.success,
      );
    } catch (e) {
      value = value.copyWith(
        isLoading: false,
        currentStep: PaymentStep.failed,
        errorMessage: e.toString(),
      );
      developer.log('支付处理失败: $e');
    }
  }

  /// 重试支付
  void retryPayment() {
    _paymentPassword = '';
    value = value.copyWith(
      currentStep: PaymentStep.inputPassword,
      paymentPassword: '',
      errorMessage: null,
    );
  }

  /// 返回上一步
  void goBack() {
    switch (value.currentStep) {
      case PaymentStep.inputPassword:
        value = value.copyWith(
          currentStep: PaymentStep.selectMethod,
          paymentPassword: '',
          errorMessage: null,
        );
        _paymentPassword = '';
        break;
      case PaymentStep.failed:
        value = value.copyWith(
          currentStep: PaymentStep.inputPassword,
          paymentPassword: '',
          errorMessage: null,
        );
        _paymentPassword = '';
        break;
      default:
        break;
    }
  }

  /// 完成支付流程
  void completePayment(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('支付成功！订单已确认'),
        backgroundColor: Color(_PaymentFlowConstants.successGreen),
      ),
    );
  }
}

// ============== 6. WIDGETS ==============
/// 📋 订单信息摘要卡片
class _OrderSummaryCard extends StatelessWidget {
  final ServiceOrderModel order;

  const _OrderSummaryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(_PaymentFlowConstants.cardWhite),
        borderRadius: BorderRadius.circular(_PaymentFlowConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 服务者信息
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.serviceProvider.nickname,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(_PaymentFlowConstants.textPrimary),
                      ),
                    ),
                    Text(
                      order.serviceType.displayName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(_PaymentFlowConstants.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          const Divider(color: Color(_PaymentFlowConstants.borderGray)),
          const SizedBox(height: 12),
          
          // 订单详情
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '订单金额',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(_PaymentFlowConstants.textPrimary),
                ),
              ),
              Text(
                '${order.totalPrice} ${order.currency}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(_PaymentFlowConstants.errorRed),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '${order.quantity} ${order.serviceUnit} × ${order.unitPrice} ${order.currency}/${order.serviceUnit}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(_PaymentFlowConstants.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

/// 💳 支付方式选择组件
class _PaymentMethodSelector extends StatelessWidget {
  final PaymentMethod? selectedMethod;
  final ValueChanged<PaymentMethod>? onMethodSelected;

  const _PaymentMethodSelector({
    this.selectedMethod,
    this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(_PaymentFlowConstants.cardWhite),
        borderRadius: BorderRadius.circular(_PaymentFlowConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '选择支付方式',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(_PaymentFlowConstants.textPrimary),
              ),
            ),
          ),
          
          // 支付方式列表
          ..._PaymentFlowConstants.paymentMethods.map((methodConfig) {
            final method = methodConfig['method'] as PaymentMethod;
            final isSelected = selectedMethod == method;
            
            return _PaymentMethodItem(
              method: method,
              icon: methodConfig['icon'] as IconData,
              color: Color(methodConfig['color'] as int),
              description: methodConfig['description'] as String,
              isSelected: isSelected,
              isAvailable: method != PaymentMethod.apple, // 模拟Apple Pay不可用
              onTap: () => onMethodSelected?.call(method),
            );
          }).toList(),
        ],
      ),
    );
  }
}

/// 💳 支付方式项组件
class _PaymentMethodItem extends StatelessWidget {
  final PaymentMethod method;
  final IconData icon;
  final Color color;
  final String description;
  final bool isSelected;
  final bool isAvailable;
  final VoidCallback? onTap;

  const _PaymentMethodItem({
    required this.method,
    required this.icon,
    required this.color,
    required this.description,
    this.isSelected = false,
    this.isAvailable = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: const Color(_PaymentFlowConstants.borderGray),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // 支付方式图标
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isAvailable ? color.withOpacity(0.1) : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isAvailable ? color : Colors.grey,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // 支付方式信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.displayName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isAvailable 
                          ? const Color(_PaymentFlowConstants.textPrimary)
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isAvailable ? description : '暂不可用',
                    style: TextStyle(
                      fontSize: 12,
                      color: isAvailable 
                          ? const Color(_PaymentFlowConstants.textSecondary)
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            
            // 选择状态
            if (isAvailable)
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: isSelected 
                    ? const Color(_PaymentFlowConstants.primaryPurple)
                    : const Color(_PaymentFlowConstants.textSecondary),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

/// 🔐 密码输入组件
class _PasswordInputWidget extends StatelessWidget {
  final String password;
  final String? errorMessage;
  final ValueChanged<String>? onDigitInput;
  final VoidCallback? onDelete;
  final VoidCallback? onClear;

  const _PasswordInputWidget({
    required this.password,
    this.errorMessage,
    this.onDigitInput,
    this.onDelete,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(_PaymentFlowConstants.cardWhite),
        borderRadius: BorderRadius.circular(_PaymentFlowConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 标题
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Text(
              '请输入支付密码',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(_PaymentFlowConstants.textPrimary),
              ),
            ),
          ),
          
          // 密码点显示
          _buildPasswordDots(),
          
          // 错误提示
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                errorMessage!,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(_PaymentFlowConstants.errorRed),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          
          const SizedBox(height: 16),
          
          // 数字键盘
          _buildNumberKeyboard(),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// 构建密码点显示
  Widget _buildPasswordDots() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_PaymentFlowConstants.passwordLength, (index) {
          final isFilled = index < password.length;
          return Container(
            width: _PaymentFlowConstants.passwordDotSize,
            height: _PaymentFlowConstants.passwordDotSize,
            decoration: BoxDecoration(
              color: isFilled 
                  ? const Color(_PaymentFlowConstants.primaryPurple)
                  : const Color(_PaymentFlowConstants.borderGray),
              borderRadius: BorderRadius.circular(_PaymentFlowConstants.passwordDotSize / 2),
            ),
          );
        }),
      ),
    );
  }

  /// 构建数字键盘
  Widget _buildNumberKeyboard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 第一行: 1, 2, 3
          Row(
            children: [
              _buildKeyboardButton('1'),
              _buildKeyboardButton('2'),
              _buildKeyboardButton('3'),
            ],
          ),
          const SizedBox(height: 12),
          
          // 第二行: 4, 5, 6
          Row(
            children: [
              _buildKeyboardButton('4'),
              _buildKeyboardButton('5'),
              _buildKeyboardButton('6'),
            ],
          ),
          const SizedBox(height: 12),
          
          // 第三行: 7, 8, 9
          Row(
            children: [
              _buildKeyboardButton('7'),
              _buildKeyboardButton('8'),
              _buildKeyboardButton('9'),
            ],
          ),
          const SizedBox(height: 12),
          
          // 第四行: 清除, 0, 删除
          Row(
            children: [
              _buildKeyboardButton('清除', isSpecial: true, onTap: onClear),
              _buildKeyboardButton('0'),
              _buildKeyboardButton('删除', isSpecial: true, icon: Icons.backspace, onTap: onDelete),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建键盘按钮
  Widget _buildKeyboardButton(
    String text, {
    bool isSpecial = false,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap ?? (isSpecial ? null : () => onDigitInput?.call(text)),
        child: Container(
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isSpecial 
                ? const Color(_PaymentFlowConstants.backgroundGray)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: icon != null
                ? Icon(
                    icon,
                    color: const Color(_PaymentFlowConstants.textSecondary),
                    size: 20,
                  )
                : Text(
                    text,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isSpecial 
                          ? const Color(_PaymentFlowConstants.textSecondary)
                          : const Color(_PaymentFlowConstants.textPrimary),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// ⏳ 支付处理中组件
class _PaymentProcessingWidget extends StatelessWidget {
  const _PaymentProcessingWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(_PaymentFlowConstants.cardWhite),
        borderRadius: BorderRadius.circular(_PaymentFlowConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(_PaymentFlowConstants.primaryPurple)),
            strokeWidth: 3,
          ),
          SizedBox(height: 24),
          Text(
            '支付处理中...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(_PaymentFlowConstants.textPrimary),
            ),
          ),
          SizedBox(height: 8),
          Text(
            '请稍候，正在为您处理支付',
            style: TextStyle(
              fontSize: 14,
              color: Color(_PaymentFlowConstants.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

/// ✅ 支付成功组件
class _PaymentSuccessWidget extends StatelessWidget {
  final PaymentInfoModel paymentInfo;
  final VoidCallback? onComplete;

  const _PaymentSuccessWidget({
    required this.paymentInfo,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(_PaymentFlowConstants.cardWhite),
        borderRadius: BorderRadius.circular(_PaymentFlowConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 成功图标
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(_PaymentFlowConstants.successGreen).withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Color(_PaymentFlowConstants.successGreen),
              size: 48,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 成功标题
          const Text(
            '支付成功',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(_PaymentFlowConstants.textPrimary),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 支付金额
          Text(
            '${paymentInfo.amount} ${paymentInfo.currency}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(_PaymentFlowConstants.errorRed),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 支付信息
          _buildPaymentInfo(),
          
          const SizedBox(height: 32),
          
          // 完成按钮
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(_PaymentFlowConstants.primaryPurple),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                '完成',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建支付信息
  Widget _buildPaymentInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(_PaymentFlowConstants.backgroundGray),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildInfoRow('支付方式', paymentInfo.paymentMethod.displayName),
          const SizedBox(height: 8),
          _buildInfoRow('交易单号', paymentInfo.transactionId ?? ''),
          const SizedBox(height: 8),
          _buildInfoRow('支付时间', _formatDateTime(paymentInfo.completedAt)),
        ],
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(_PaymentFlowConstants.textSecondary),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(_PaymentFlowConstants.textPrimary),
          ),
        ),
      ],
    );
  }

  /// 格式化日期时间
  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// ❌ 支付失败组件
class _PaymentFailedWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onCancel;

  const _PaymentFailedWidget({
    required this.errorMessage,
    this.onRetry,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(_PaymentFlowConstants.cardWhite),
        borderRadius: BorderRadius.circular(_PaymentFlowConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 失败图标
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(_PaymentFlowConstants.errorRed).withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.error_outline,
              color: Color(_PaymentFlowConstants.errorRed),
              size: 48,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 失败标题
          const Text(
            '支付失败',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(_PaymentFlowConstants.textPrimary),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 错误信息
          Text(
            errorMessage,
            style: const TextStyle(
              fontSize: 14,
              color: Color(_PaymentFlowConstants.textSecondary),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // 操作按钮
          Row(
            children: [
              // 取消按钮
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(_PaymentFlowConstants.textSecondary),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '取消',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(_PaymentFlowConstants.textSecondary),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // 重试按钮
              Expanded(
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(_PaymentFlowConstants.primaryPurple),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '重试',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 🔻 底部操作栏
class _BottomActionBar extends StatelessWidget {
  final PaymentStep currentStep;
  final bool isLoading;
  final VoidCallback? onConfirm;
  final VoidCallback? onBack;

  const _BottomActionBar({
    required this.currentStep,
    this.isLoading = false,
    this.onConfirm,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    // 只在选择支付方式步骤显示底部操作栏
    if (currentStep != PaymentStep.selectMethod) {
      return const SizedBox.shrink();
    }
    
    return Container(
      height: _PaymentFlowConstants.bottomBarHeight,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: const Color(_PaymentFlowConstants.cardWhite),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 返回按钮
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: Color(_PaymentFlowConstants.textSecondary),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '返回',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(_PaymentFlowConstants.textSecondary),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // 确认支付按钮
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: isLoading ? null : onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(_PaymentFlowConstants.primaryPurple),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
                    : const Text(
                        '确认支付',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============== 7. PAGES ==============
/// 💳 支付流程页面
class PaymentFlowPage extends StatefulWidget {
  final ServiceOrderModel order;

  const PaymentFlowPage({
    super.key,
    required this.order,
  });

  @override
  State<PaymentFlowPage> createState() => _PaymentFlowPageState();
}

class _PaymentFlowPageState extends State<PaymentFlowPage> {
  late final _PaymentFlowController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _PaymentFlowController(widget.order);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(_PaymentFlowConstants.backgroundGray),
      appBar: AppBar(
        title: const Text(_PaymentFlowConstants.pageTitle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: ValueListenableBuilder<PaymentFlowPageState>(
          valueListenable: _controller,
          builder: (context, state, child) {
            if (state.currentStep == PaymentStep.success) {
              return const SizedBox.shrink();
            }
            return IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (state.currentStep == PaymentStep.selectMethod) {
                  Navigator.pop(context);
                } else {
                  _controller.goBack();
                }
              },
            );
          },
        ),
      ),
      body: ValueListenableBuilder<PaymentFlowPageState>(
        valueListenable: _controller,
        builder: (context, state, child) {
          if (state.isLoading && state.order == null) {
            return _buildLoadingView();
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // 订单信息摘要
                _OrderSummaryCard(order: widget.order),
                
                // 根据当前步骤显示不同内容
                _buildStepContent(state),
                
                // 底部占位
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: ValueListenableBuilder<PaymentFlowPageState>(
        valueListenable: _controller,
        builder: (context, state, child) {
          return _BottomActionBar(
            currentStep: state.currentStep,
            isLoading: state.isLoading,
            onConfirm: _controller.confirmPaymentMethod,
            onBack: () => Navigator.pop(context),
          );
        },
      ),
    );
  }

  /// 根据步骤构建内容
  Widget _buildStepContent(PaymentFlowPageState state) {
    switch (state.currentStep) {
      case PaymentStep.selectMethod:
        return _PaymentMethodSelector(
          selectedMethod: state.selectedPaymentMethod,
          onMethodSelected: _controller.selectPaymentMethod,
        );
        
      case PaymentStep.inputPassword:
        return _PasswordInputWidget(
          password: state.paymentPassword ?? '',
          errorMessage: state.errorMessage,
          onDigitInput: _controller.inputPasswordDigit,
          onDelete: _controller.deletePasswordDigit,
          onClear: _controller.clearPassword,
        );
        
      case PaymentStep.processing:
        return const _PaymentProcessingWidget();
        
      case PaymentStep.success:
        return _PaymentSuccessWidget(
          paymentInfo: state.paymentInfo!,
          onComplete: () => _controller.completePayment(context),
        );
        
      case PaymentStep.failed:
        return _PaymentFailedWidget(
          errorMessage: state.errorMessage ?? '支付失败',
          onRetry: _controller.retryPayment,
          onCancel: () => Navigator.pop(context),
        );
    }
  }

  /// 构建加载视图
  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(_PaymentFlowConstants.primaryPurple)),
      ),
    );
  }
}

// ============== 8. EXPORTS ==============
/// 📤 导出定义
