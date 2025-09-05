// 🎯 报名支付确认弹窗 - 基于报名流程架构设计的支付确认组件
// 实现发起者确认、支付详情、支付操作的完整支付确认流程

// ============== 1. IMPORTS ==============
// Flutter核心库
import 'package:flutter/material.dart';

// Dart核心库
import 'dart:developer' as developer;

// 项目内部文件
import '../../models/join_models.dart';     // 报名模型
import '../../services/join_services.dart'; // 报名服务

// ============== 2. CONSTANTS ==============
/// 🎨 支付弹窗常量
class _PaymentDialogConstants {
  const _PaymentDialogConstants._();
  
  // 颜色配置
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color backgroundGray = Color(0xFFF5F5F7);
  static const Color cardWhite = Colors.white;
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color borderGray = Color(0xFFE5E7EB);
  static const Color successGreen = Color(0xFF10B981);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color warningOrange = Color(0xFFF59E0B);
  
  // 动画配置
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration quickAnimationDuration = Duration(milliseconds: 150);
  
  // 弹窗配置
  static const double dialogBorderRadius = 20.0;
  static const double dialogPadding = 24.0;
  static const double sectionSpacing = 20.0;
  static const double itemSpacing = 12.0;
}

// ============== 3. WIDGETS ==============
/// 💳 报名支付确认弹窗
class JoinPaymentDialog extends StatefulWidget {
  final PaymentInfo paymentInfo;
  final ValueChanged<PaymentResult> onPaymentResult;

  const JoinPaymentDialog({
    super.key,
    required this.paymentInfo,
    required this.onPaymentResult,
  });

  @override
  State<JoinPaymentDialog> createState() => _JoinPaymentDialogState();

  /// 显示支付确认弹窗
  static Future<PaymentResult?> show(
    BuildContext context,
    PaymentInfo paymentInfo,
  ) async {
    return showDialog<PaymentResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => JoinPaymentDialog(
        paymentInfo: paymentInfo,
        onPaymentResult: (result) => Navigator.pop(context, result),
      ),
    );
  }
}

class _JoinPaymentDialogState extends State<JoinPaymentDialog>
    with TickerProviderStateMixin {
  late final IJoinService _joinService;
  late PaymentMethod _selectedPaymentMethod;
  bool _isProcessing = false;
  String? _errorMessage;
  
  late final AnimationController _slideController;
  late final AnimationController _fadeController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _joinService = JoinServiceFactory.getInstance();
    _selectedPaymentMethod = widget.paymentInfo.paymentMethod;
    
    // 初始化动画
    _slideController = AnimationController(
      duration: _PaymentDialogConstants.animationDuration,
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: _PaymentDialogConstants.animationDuration,
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    // 启动进入动画
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Container(
          color: Colors.black.withOpacity(0.5 * _fadeAnimation.value),
          child: Center(
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                decoration: BoxDecoration(
                  color: _PaymentDialogConstants.cardWhite,
                  borderRadius: BorderRadius.circular(_PaymentDialogConstants.dialogBorderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 头部标题栏
                    _buildHeader(),
                    
                    // 内容区域
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(_PaymentDialogConstants.dialogPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 发起者确认区域
                            _buildHostConfirmationSection(),
                            
                            const SizedBox(height: _PaymentDialogConstants.sectionSpacing),
                            
                            // 支付详情区域
                            _buildPaymentDetailsSection(),
                            
                            const SizedBox(height: _PaymentDialogConstants.sectionSpacing),
                            
                            // 支付方式选择
                            _buildPaymentMethodSection(),
                            
                            const SizedBox(height: _PaymentDialogConstants.sectionSpacing),
                            
                            // 费用明细
                            _buildCostBreakdownSection(),
                            
                            const SizedBox(height: _PaymentDialogConstants.sectionSpacing),
                            
                            // 支付条款
                            _buildTermsSection(),
                            
                            // 错误信息
                            if (_errorMessage != null) ...[
                              const SizedBox(height: _PaymentDialogConstants.itemSpacing),
                              _buildErrorMessage(),
                            ],
                          ],
                        ),
                      ),
                    ),
                    
                    // 底部操作区域
                    _buildBottomActions(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(_PaymentDialogConstants.dialogPadding),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: _PaymentDialogConstants.borderGray,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.payment,
            color: _PaymentDialogConstants.primaryPurple,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '确认支付',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _PaymentDialogConstants.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: _isProcessing ? null : _handleCancel,
            icon: Icon(
              Icons.close,
              color: _PaymentDialogConstants.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHostConfirmationSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _PaymentDialogConstants.backgroundGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // 发起者头像
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _PaymentDialogConstants.primaryPurple,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.network(
                widget.paymentInfo.hostAvatar,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: _PaymentDialogConstants.backgroundGray,
                    child: Icon(
                      Icons.person,
                      color: _PaymentDialogConstants.textSecondary,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // 发起者信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.paymentInfo.hostNickname,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _PaymentDialogConstants.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.paymentInfo.activityTitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: _PaymentDialogConstants.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // 认证标识
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _PaymentDialogConstants.successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified,
                  size: 14,
                  color: _PaymentDialogConstants.successGreen,
                ),
                const SizedBox(width: 4),
                Text(
                  '认证',
                  style: TextStyle(
                    fontSize: 12,
                    color: _PaymentDialogConstants.successGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '支付详情',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _PaymentDialogConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _PaymentDialogConstants.primaryPurple.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _PaymentDialogConstants.primaryPurple.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.monetization_on,
                    color: _PaymentDialogConstants.primaryPurple,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.paymentInfo.totalAmount}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _PaymentDialogConstants.primaryPurple,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '金币',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: _PaymentDialogConstants.primaryPurple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '约等于 ¥${(widget.paymentInfo.totalAmount * 0.1).toStringAsFixed(1)}',
                style: TextStyle(
                  fontSize: 14,
                  color: _PaymentDialogConstants.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '支付方式',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _PaymentDialogConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        
        ...PaymentMethod.values.map((method) {
          final isSelected = _selectedPaymentMethod == method;
          final isEnabled = method == PaymentMethod.coins 
              ? widget.paymentInfo.hasEnoughBalance
              : true;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: isEnabled ? () => _selectPaymentMethod(method) : null,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isEnabled
                      ? (isSelected 
                          ? _PaymentDialogConstants.primaryPurple.withOpacity(0.1)
                          : _PaymentDialogConstants.backgroundGray)
                      : _PaymentDialogConstants.backgroundGray.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected && isEnabled
                        ? _PaymentDialogConstants.primaryPurple
                        : _PaymentDialogConstants.borderGray,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    // 支付方式图标
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        method.icon,
                        size: 20,
                        color: isEnabled
                            ? _PaymentDialogConstants.primaryPurple
                            : _PaymentDialogConstants.textSecondary,
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
                              color: isEnabled
                                  ? _PaymentDialogConstants.textPrimary
                                  : _PaymentDialogConstants.textSecondary,
                            ),
                          ),
                          if (method == PaymentMethod.coins) ...[
                            const SizedBox(height: 4),
                            Text(
                              '余额: ${widget.paymentInfo.userBalance}金币',
                              style: TextStyle(
                                fontSize: 12,
                                color: widget.paymentInfo.hasEnoughBalance
                                    ? _PaymentDialogConstants.successGreen
                                    : _PaymentDialogConstants.errorRed,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // 选中状态指示
                    if (isSelected && isEnabled)
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: _PaymentDialogConstants.primaryPurple,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    
                    // 不可用状态指示
                    if (!isEnabled)
                      Icon(
                        Icons.lock,
                        size: 16,
                        color: _PaymentDialogConstants.textSecondary,
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCostBreakdownSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '费用明细',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _PaymentDialogConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: _PaymentDialogConstants.borderGray),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: widget.paymentInfo.breakdown.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: item.isTotal ? FontWeight.w600 : FontWeight.normal,
                        color: _PaymentDialogConstants.textPrimary,
                      ),
                    ),
                    Text(
                      item.displayAmount,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: item.isTotal ? FontWeight.w600 : FontWeight.normal,
                        color: item.isTotal
                            ? _PaymentDialogConstants.primaryPurple
                            : _PaymentDialogConstants.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '支付条款',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _PaymentDialogConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _PaymentDialogConstants.backgroundGray,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.paymentInfo.termsAndConditions.map((term) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _PaymentDialogConstants.textSecondary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        term,
                        style: TextStyle(
                          fontSize: 12,
                          color: _PaymentDialogConstants.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _PaymentDialogConstants.errorRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _PaymentDialogConstants.errorRed.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 20,
            color: _PaymentDialogConstants.errorRed,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 14,
                color: _PaymentDialogConstants.errorRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    final canPay = _selectedPaymentMethod == PaymentMethod.coins
        ? widget.paymentInfo.hasEnoughBalance
        : true;
    
    return Container(
      padding: const EdgeInsets.all(_PaymentDialogConstants.dialogPadding),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: _PaymentDialogConstants.borderGray,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // 安全提示
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _PaymentDialogConstants.successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.security,
                  size: 16,
                  color: _PaymentDialogConstants.successGreen,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '平台提供支付安全保障，如报名失败将自动退款',
                    style: TextStyle(
                      fontSize: 12,
                      color: _PaymentDialogConstants.successGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // 操作按钮
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isProcessing ? null : _handleCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _PaymentDialogConstants.textSecondary,
                    side: BorderSide(color: _PaymentDialogConstants.borderGray),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('取消支付'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: canPay && !_isProcessing ? _handlePayment : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _PaymentDialogConstants.primaryPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isProcessing
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          canPay ? '立即支付' : '余额不足',
                          style: const TextStyle(
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

  void _selectPaymentMethod(PaymentMethod method) {
    setState(() {
      _selectedPaymentMethod = method;
      _errorMessage = null;
    });
  }

  void _handleCancel() async {
    await _slideController.reverse();
    await _fadeController.reverse();
    
    widget.onPaymentResult(PaymentResult.failure(
      errorMessage: '用户取消支付',
      reason: FailureReason.cancelled,
    ));
  }

  void _handlePayment() async {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // 创建支付信息
      final paymentInfo = PaymentInfo.calculate(
        activityId: widget.paymentInfo.activityId,
        activityTitle: widget.paymentInfo.activityTitle,
        hostNickname: widget.paymentInfo.hostNickname,
        hostAvatar: widget.paymentInfo.hostAvatar,
        baseAmount: widget.paymentInfo.baseAmount,
        paymentMethod: _selectedPaymentMethod,
        userBalance: widget.paymentInfo.userBalance,
        discountAmount: widget.paymentInfo.discountAmount,
      );

      // 处理支付
      final result = await _joinService.processPayment(paymentInfo, 'current_user');
      
      // 添加成功动画
      if (result.success) {
        await _showSuccessAnimation();
      }
      
      widget.onPaymentResult(result);

    } catch (e) {
      setState(() {
        _errorMessage = '支付处理失败: $e';
      });
      developer.log('支付失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _showSuccessAnimation() async {
    // 这里可以添加支付成功的动画效果
    // 比如显示对勾动画、播放成功音效等
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

// ============== 8. EXPORTS ==============
/// 📤 导出定义
/// 
/// 本文件自动导出的公共类：
/// - JoinPaymentDialog: 报名支付确认弹窗（public class）
///
/// 使用方式：
/// ```dart
/// import 'join_payment_dialog.dart';
/// 
/// // 显示支付确认弹窗
/// final result = await JoinPaymentDialog.show(context, paymentInfo);
/// if (result != null && result.success) {
///   // 支付成功处理
/// }
/// ```
