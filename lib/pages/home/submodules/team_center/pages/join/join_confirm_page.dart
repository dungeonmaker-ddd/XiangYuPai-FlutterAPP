// 🎯 报名确认页面 - 单文件架构完整实现
// 基于Flutter单文件架构规范的8段式结构设计

// ============== 1. IMPORTS ==============
// Flutter核心库
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Dart核心库
import 'dart:async';
import 'dart:developer' as developer;

// 项目内部文件 - 按依赖关系排序
import '../../models/team_models.dart';      // 数据模型
import '../../services/team_services.dart';  // 业务服务
import '../../utils/constants.dart';         // 常量定义
import 'join_status_page.dart';              // 报名状态页面

// ============== 2. CONSTANTS ==============
/// 🎨 报名确认页面私有常量
class _JoinConfirmPageConstants {
  // 私有构造函数，防止实例化
  const _JoinConfirmPageConstants._();
  
  // 页面标识
  static const String pageTitle = '确认支付';
  static const String routeName = '/join_confirm';
  
  // 金币相关
  static const String coinSymbol = '金币';
  static const double serviceFeeRate = 0.05; // 5%服务费
  
  // UI配置
  static const double avatarSize = 60.0;
  static const double cardMargin = 16.0;
  static const double sectionSpacing = 24.0;
}

// ============== 3. MODELS ==============
/// 📋 数据模型引用
/// 主要模型定义在 team_models.dart 中：
/// - TeamActivity: 组局活动模型
/// - TeamHost: 发起者模型

/// 用户金币余额模型
class UserBalance {
  final int totalCoins;
  final int availableCoins;
  final int frozenCoins;

  const UserBalance({
    required this.totalCoins,
    required this.availableCoins,
    required this.frozenCoins,
  });

  bool canPay(int amount) => availableCoins >= amount;
}

/// 支付详情模型
class PaymentDetails {
  final int baseAmount;
  final int serviceFee;
  final int totalAmount;
  final String paymentMethod;

  const PaymentDetails({
    required this.baseAmount,
    required this.serviceFee,
    required this.totalAmount,
    this.paymentMethod = '金币支付',
  });

  factory PaymentDetails.fromBaseAmount(int baseAmount) {
    final serviceFee = (baseAmount * _JoinConfirmPageConstants.serviceFeeRate).round();
    final totalAmount = baseAmount + serviceFee;
    
    return PaymentDetails(
      baseAmount: baseAmount,
      serviceFee: serviceFee,
      totalAmount: totalAmount,
    );
  }
}

/// 报名确认页面状态模型
class JoinConfirmState {
  final bool isLoading;
  final String? errorMessage;
  final TeamActivity? activity;
  final UserBalance? userBalance;
  final PaymentDetails? paymentDetails;
  final bool isPaymentProcessing;
  final String? paymentErrorMessage;

  const JoinConfirmState({
    this.isLoading = false,
    this.errorMessage,
    this.activity,
    this.userBalance,
    this.paymentDetails,
    this.isPaymentProcessing = false,
    this.paymentErrorMessage,
  });

  JoinConfirmState copyWith({
    bool? isLoading,
    String? errorMessage,
    TeamActivity? activity,
    UserBalance? userBalance,
    PaymentDetails? paymentDetails,
    bool? isPaymentProcessing,
    String? paymentErrorMessage,
  }) {
    return JoinConfirmState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      activity: activity ?? this.activity,
      userBalance: userBalance ?? this.userBalance,
      paymentDetails: paymentDetails ?? this.paymentDetails,
      isPaymentProcessing: isPaymentProcessing ?? this.isPaymentProcessing,
      paymentErrorMessage: paymentErrorMessage,
    );
  }

  bool get canPay {
    return activity != null &&
           userBalance != null &&
           paymentDetails != null &&
           userBalance!.canPay(paymentDetails!.totalAmount) &&
           !isPaymentProcessing;
  }
}

// ============== 4. SERVICES ==============
/// 🔧 业务服务引用
/// 主要服务定义在 team_services.dart 中：
/// - TeamService: 组局数据服务
/// - TeamServiceFactory: 服务工厂

/// 支付服务接口
abstract class IPaymentService {
  Future<UserBalance> getUserBalance();
  Future<void> processPayment(String activityId, int amount);
}

/// 支付服务实现（模拟）
class PaymentService implements IPaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  @override
  Future<UserBalance> getUserBalance() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 300));
    
    // 模拟用户余额
    return const UserBalance(
      totalCoins: 500,
      availableCoins: 300,
      frozenCoins: 200,
    );
  }

  @override
  Future<void> processPayment(String activityId, int amount) async {
    // 模拟支付处理延迟
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // 模拟支付成功
    developer.log('支付成功：活动ID $activityId，金额 $amount 金币');
  }
}

// ============== 5. CONTROLLERS ==============
/// 🧠 报名确认控制器
class _JoinConfirmController extends ValueNotifier<JoinConfirmState> {
  _JoinConfirmController(this.activityId) : super(const JoinConfirmState()) {
    _initialize();
  }

  final String activityId;
  late ITeamService _teamService;
  late IPaymentService _paymentService;

  /// 初始化数据
  Future<void> _initialize() async {
    try {
      _teamService = TeamServiceFactory.getInstance();
      _paymentService = PaymentService();
      
      value = value.copyWith(isLoading: true, errorMessage: null);

      // 并行加载活动信息和用户余额
      final results = await Future.wait([
        _teamService.getTeamActivity(activityId),
        _paymentService.getUserBalance(),
      ]);

      final activity = results[0] as TeamActivity;
      final userBalance = results[1] as UserBalance;
      final paymentDetails = PaymentDetails.fromBaseAmount(activity.pricePerHour);

      value = value.copyWith(
        isLoading: false,
        activity: activity,
        userBalance: userBalance,
        paymentDetails: paymentDetails,
      );
    } catch (e) {
      value = value.copyWith(
        isLoading: false,
        errorMessage: '加载失败，请重试',
      );
      developer.log('报名确认初始化失败: $e');
    }
  }

  /// 刷新数据
  Future<void> refresh() async {
    await _initialize();
  }

  /// 处理支付
  Future<bool> processPayment() async {
    if (!value.canPay || value.isPaymentProcessing) return false;

    try {
      value = value.copyWith(isPaymentProcessing: true, paymentErrorMessage: null);

      await _paymentService.processPayment(
        activityId,
        value.paymentDetails!.totalAmount,
      );

      // 报名参与活动
      await _teamService.joinTeamActivity(activityId, 'current_user_123');

      value = value.copyWith(isPaymentProcessing: false);
      
      developer.log('支付并报名成功');
      return true;
    } catch (e) {
      value = value.copyWith(
        isPaymentProcessing: false,
        paymentErrorMessage: '支付失败：$e',
      );
      developer.log('支付失败: $e');
      return false;
    }
  }
}

// ============== 6. WIDGETS ==============
/// 🧩 UI组件定义

/// 🔝 报名确认导航栏
class _JoinConfirmAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _JoinConfirmAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        _JoinConfirmPageConstants.pageTitle,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline, color: Colors.black54),
          onPressed: () {
            // TODO: 显示帮助信息
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// 👤 发起者确认卡片
class _HostConfirmCard extends StatelessWidget {
  final TeamHost host;
  final String activityTitle;

  const _HostConfirmCard({
    required this.host,
    required this.activityTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(_JoinConfirmPageConstants.cardMargin),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(TeamCenterConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 发起者头像
          Stack(
            children: [
              Container(
                width: _JoinConfirmPageConstants.avatarSize,
                height: _JoinConfirmPageConstants.avatarSize,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(_JoinConfirmPageConstants.avatarSize / 2),
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: host.avatar != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(_JoinConfirmPageConstants.avatarSize / 2 - 3),
                        child: Image.network(
                          host.avatar!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                              const Icon(Icons.person, color: Colors.white, size: 30),
                        ),
                      )
                    : const Icon(Icons.person, color: Colors.white, size: 30),
              ),
              
              // 认证标识
              if (host.isVerified)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          
          // 发起者信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  host.nickname,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                
                // 活动标签
                if (host.tags.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    children: host.tags.take(2).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: TeamCenterConstants.primaryPurple,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                
                const SizedBox(height: 8),
                
                // 活动标题
                Text(
                  activityTitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 💳 支付详情卡片
class _PaymentDetailsCard extends StatelessWidget {
  final PaymentDetails paymentDetails;
  final UserBalance userBalance;

  const _PaymentDetailsCard({
    required this.paymentDetails,
    required this.userBalance,
  });

  @override
  Widget build(BuildContext context) {
    final canPay = userBalance.canPay(paymentDetails.totalAmount);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: _JoinConfirmPageConstants.cardMargin),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(TeamCenterConstants.cardBorderRadius),
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
          // 标题
          const Text(
            '确认支付',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          // 支付金额
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '支付金额',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${paymentDetails.totalAmount}${_JoinConfirmPageConstants.coinSymbol}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: TeamCenterConstants.primaryPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 费用明细
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildDetailRow('基础费用', '${paymentDetails.baseAmount}${_JoinConfirmPageConstants.coinSymbol}'),
                if (paymentDetails.serviceFee > 0) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow('服务费', '${paymentDetails.serviceFee}${_JoinConfirmPageConstants.coinSymbol}'),
                ],
                const Divider(height: 16),
                _buildDetailRow(
                  '总计',
                  '${paymentDetails.totalAmount}${_JoinConfirmPageConstants.coinSymbol}',
                  isTotal: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // 支付方式
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: TeamCenterConstants.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.monetization_on,
                  color: TeamCenterConstants.primaryPurple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_JoinConfirmPageConstants.coinSymbol} 余额: ${userBalance.availableCoins}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      paymentDetails.paymentMethod,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.check_circle,
                color: canPay ? TeamCenterConstants.primaryPurple : Colors.grey[400],
                size: 20,
              ),
            ],
          ),
          
          // 余额不足提示
          if (!canPay) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.red[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '余额不足，需要充值 ${paymentDetails.totalAmount - userBalance.availableCoins} ${_JoinConfirmPageConstants.coinSymbol}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red[700],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: 跳转到充值页面
                    },
                    child: const Text(
                      '去充值',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          
          // 支付条款
          Text(
            '我同意支付以下费用，该金额(含服务费)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 14 : 12,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            color: isTotal ? Colors.black87 : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 14 : 12,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            color: isTotal ? TeamCenterConstants.primaryPurple : Colors.black87,
          ),
        ),
      ],
    );
  }
}

/// 🔻 支付按钮
class _PaymentButton extends StatelessWidget {
  final bool canPay;
  final bool isProcessing;
  final int amount;
  final VoidCallback? onPressed;

  const _PaymentButton({
    this.canPay = false,
    this.isProcessing = false,
    required this.amount,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: canPay && !isProcessing ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canPay ? TeamCenterConstants.primaryPurple : Colors.grey[400],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
            child: isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    canPay 
                        ? '立即支付 $amount${_JoinConfirmPageConstants.coinSymbol}'
                        : '余额不足',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ============== 7. PAGES ==============
/// 📱 报名确认页面
class JoinConfirmPage extends StatefulWidget {
  final String activityId;

  const JoinConfirmPage({
    super.key,
    required this.activityId,
  });

  @override
  State<JoinConfirmPage> createState() => _JoinConfirmPageState();
}

class _JoinConfirmPageState extends State<JoinConfirmPage> {
  late final _JoinConfirmController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _JoinConfirmController(widget.activityId);
    
    // 监听状态变化
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
    
    // 处理支付错误
    if (state.paymentErrorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.paymentErrorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 设置状态栏样式
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));
    
    return Scaffold(
      backgroundColor: TeamCenterConstants.backgroundGray,
      appBar: const _JoinConfirmAppBar(),
      body: ValueListenableBuilder<JoinConfirmState>(
        valueListenable: _controller,
        builder: (context, state, child) {
          if (state.isLoading) {
            return _buildLoadingView();
          }

          if (state.errorMessage != null) {
            return _buildErrorView(state.errorMessage!);
          }

          if (state.activity == null || state.userBalance == null || state.paymentDetails == null) {
            return _buildNotFoundView();
          }

          return _buildMainContent(state);
        },
      ),
      bottomNavigationBar: ValueListenableBuilder<JoinConfirmState>(
        valueListenable: _controller,
        builder: (context, state, child) {
          if (state.paymentDetails == null) return const SizedBox.shrink();
          
          return _PaymentButton(
            canPay: state.canPay,
            isProcessing: state.isPaymentProcessing,
            amount: state.paymentDetails!.totalAmount,
            onPressed: _handlePayment,
          );
        },
      ),
    );
  }

  /// 构建加载视图
  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(TeamCenterConstants.primaryPurple),
      ),
    );
  }

  /// 构建错误视图
  Widget _buildErrorView(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(errorMessage, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _controller.refresh(),
            style: ElevatedButton.styleFrom(
              backgroundColor: TeamCenterConstants.primaryPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  /// 构建未找到视图
  Widget _buildNotFoundView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('活动不存在', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: TeamCenterConstants.primaryPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('返回'),
          ),
        ],
      ),
    );
  }

  /// 构建主要内容
  Widget _buildMainContent(JoinConfirmState state) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 8),
          
          // 发起者确认卡片
          _HostConfirmCard(
            host: state.activity!.host,
            activityTitle: state.activity!.title,
          ),
          
          const SizedBox(height: _JoinConfirmPageConstants.sectionSpacing),
          
          // 支付详情卡片
          _PaymentDetailsCard(
            paymentDetails: state.paymentDetails!,
            userBalance: state.userBalance!,
          ),
          
          const SizedBox(height: 100), // 底部占位
        ],
      ),
    );
  }

  /// 处理支付
  void _handlePayment() async {
    // 显示确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认支付'),
        content: Text(
          '确定要支付 ${_controller.value.paymentDetails!.totalAmount} ${_JoinConfirmPageConstants.coinSymbol} 报名参加此活动吗？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: TeamCenterConstants.primaryPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('确认支付'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final success = await _controller.processPayment();
      
      if (success && mounted) {
        // 支付成功，跳转到报名状态页面
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => JoinStatusPage(
              activityId: widget.activityId,
              initialStatus: JoinStatus.waiting,
            ),
          ),
        );
      }
    }
  }
}

// ============== 8. EXPORTS ==============
/// 📤 导出定义
/// 
/// 本文件自动导出的公共类：
/// - JoinConfirmPage: 报名确认页面（public class）
///
/// 私有类（不会被导出）：
/// - _JoinConfirmController: 报名确认控制器
/// - _JoinConfirmAppBar: 报名确认导航栏
/// - _HostConfirmCard: 发起者确认卡片
/// - _PaymentDetailsCard: 支付详情卡片
/// - _PaymentButton: 支付按钮
/// - _JoinConfirmPageState: 页面状态类
/// - _JoinConfirmPageConstants: 页面私有常量
/// - UserBalance: 用户余额模型
/// - PaymentDetails: 支付详情模型
/// - JoinConfirmState: 页面状态模型
/// - PaymentService: 支付服务实现
///
/// 使用方式：
/// ```dart
/// import 'join_confirm_page.dart';
/// 
/// // 在路由中使用
/// MaterialPageRoute(builder: (context) => JoinConfirmPage(activityId: 'activity_id'))
/// ```
