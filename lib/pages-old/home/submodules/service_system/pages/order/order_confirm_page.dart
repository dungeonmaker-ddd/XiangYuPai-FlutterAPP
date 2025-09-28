// 🛒 订单确认页面 - 单文件架构完整实现
// 基于Flutter单文件架构规范的8段式结构设计
// 完整的订单确认和支付入口页面

// ============== 1. IMPORTS ==============
// Flutter核心库
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Dart核心库
import 'dart:async';
import 'dart:developer' as developer;

// 项目内部文件
import '../../models/service_models.dart';        // 服务系统数据模型
import 'payment_flow_page.dart';                  // 支付流程页面

// ============== 2. CONSTANTS ==============
/// 🎨 订单确认页私有常量
class _OrderConfirmConstants {
  const _OrderConfirmConstants._();
  
  // 页面标识
  static const String pageTitle = '确认订单';
  static const String routeName = '/order-confirm';
  
  // UI配置
  static const double cardBorderRadius = 12.0;
  static const double sectionSpacing = 16.0;
  static const double bottomBarHeight = 80.0;
  static const double minQuantity = 1;
  static const double maxQuantity = 99;
  
  // 颜色配置
  static const int primaryPurple = 0xFF8B5CF6;
  static const int backgroundGray = 0xFFF9FAFB;
  static const int cardWhite = 0xFFFFFFFF;
  static const int textPrimary = 0xFF1F2937;
  static const int textSecondary = 0xFF6B7280;
  static const int successGreen = 0xFF10B981;
  static const int errorRed = 0xFFEF4444;
  static const int borderGray = 0xFFE5E7EB;
  
  // 订单配置
  static const Map<ServiceType, List<int>> defaultQuantityRange = {
    ServiceType.game: [1, 10],        // 游戏：1-10局
    ServiceType.entertainment: [1, 8], // 娱乐：1-8小时
    ServiceType.lifestyle: [1, 5],     // 生活：1-5小时
    ServiceType.work: [1, 3],          // 工作：1-3次
  };
}

// ============== 3. MODELS ==============
// 使用 service_models.dart 中定义的通用模型

// ============== 4. SERVICES ==============
/// 🔧 订单确认服务
class _OrderConfirmService {
  /// 创建订单
  static Future<ServiceOrderModel> createOrder({
    required ServiceProviderModel provider,
    required int quantity,
    String? notes,
  }) async {
    // 模拟网络请求
    await Future.delayed(const Duration(milliseconds: 1200));
    
    // 计算价格
    final unitPrice = provider.pricePerService;
    final totalPrice = unitPrice * quantity;
    
    // 生成订单ID
    final orderId = 'order_${DateTime.now().millisecondsSinceEpoch}';
    
    return ServiceOrderModel(
      id: orderId,
      serviceProviderId: provider.id,
      serviceProvider: provider,
      serviceType: provider.serviceType,
      gameType: provider.gameType,
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
      currency: provider.currency,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
      notes: notes,
    );
  }
  
  /// 获取用户金币余额
  static Future<double> getUserBalance() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // 模拟用户余额
    return 888.88;
  }
  
  /// 验证订单信息
  static Future<bool> validateOrder({
    required ServiceProviderModel provider,
    required int quantity,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    // 模拟验证逻辑
    if (!provider.isOnline) {
      throw '服务者当前不在线，无法下单';
    }
    
    if (quantity <= 0) {
      throw '订单数量必须大于0';
    }
    
    final maxQuantity = _OrderConfirmConstants.defaultQuantityRange[provider.serviceType]?[1] ?? 10;
    if (quantity > maxQuantity) {
      throw '订单数量不能超过$maxQuantity${provider.serviceUnit}';
    }
    
    return true;
  }
}

// ============== 5. CONTROLLERS ==============
/// 🧠 订单确认页面控制器
class _OrderConfirmController extends ValueNotifier<OrderConfirmPageState> {
  _OrderConfirmController(this.provider) 
      : super(OrderConfirmPageState(provider: provider)) {
    _initialize();
  }

  final ServiceProviderModel provider;
  final TextEditingController notesController = TextEditingController();

  /// 初始化数据
  Future<void> _initialize() async {
    try {
      value = value.copyWith(isLoading: true, errorMessage: null);
      
      // 并发获取用户余额和初始化订单信息
      final results = await Future.wait([
        _OrderConfirmService.getUserBalance(),
        Future.value(provider.pricePerService), // 获取单价
      ]);
      
      final userBalance = results[0] as double;
      final unitPrice = results[1] as double;
      
      value = value.copyWith(
        isLoading: false,
        unitPrice: unitPrice,
        totalPrice: unitPrice * value.quantity,
        currency: provider.currency,
      );
      
      // 检查余额是否充足
      _checkBalance(userBalance);
    } catch (e) {
      value = value.copyWith(
        isLoading: false,
        errorMessage: '初始化失败: $e',
      );
      developer.log('订单确认页初始化失败: $e');
    }
  }

  /// 检查余额
  void _checkBalance(double userBalance) {
    if (userBalance < value.totalPrice) {
      value = value.copyWith(
        errorMessage: '金币余额不足，请先充值',
      );
    }
  }

  /// 更新订单数量
  void updateQuantity(int newQuantity) {
    if (newQuantity < _OrderConfirmConstants.minQuantity || 
        newQuantity > _OrderConfirmConstants.maxQuantity) {
      return;
    }
    
    final newTotalPrice = value.unitPrice * newQuantity;
    value = value.copyWith(
      quantity: newQuantity,
      totalPrice: newTotalPrice,
      errorMessage: null,
    );
    
    // 重新检查余额
    _OrderConfirmService.getUserBalance().then(_checkBalance);
  }

  /// 增加数量
  void increaseQuantity() {
    updateQuantity(value.quantity + 1);
  }

  /// 减少数量
  void decreaseQuantity() {
    updateQuantity(value.quantity - 1);
  }

  /// 更新备注
  void updateNotes(String notes) {
    value = value.copyWith(notes: notes.trim().isEmpty ? null : notes.trim());
  }

  /// 确认下单
  Future<void> confirmOrder(BuildContext context) async {
    if (value.isLoading) return;
    
    try {
      value = value.copyWith(isLoading: true, errorMessage: null);
      
      // 验证订单
      await _OrderConfirmService.validateOrder(
        provider: provider,
        quantity: value.quantity,
      );
      
      // 创建订单
      final order = await _OrderConfirmService.createOrder(
        provider: provider,
        quantity: value.quantity,
        notes: value.notes,
      );
      
      value = value.copyWith(isLoading: false);
      
      // 跳转到支付页面
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentFlowPage(order: order),
          ),
        );
      }
    } catch (e) {
      value = value.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      developer.log('确认订单失败: $e');
    }
  }

  /// 返回上一页
  void goBack(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }
}

// ============== 6. WIDGETS ==============
/// 👤 服务者信息确认卡片
class _ProviderConfirmCard extends StatelessWidget {
  final ServiceProviderModel provider;

  const _ProviderConfirmCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(_OrderConfirmConstants.cardWhite),
        borderRadius: BorderRadius.circular(_OrderConfirmConstants.cardBorderRadius),
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
          // 头像
          _buildAvatar(),
          const SizedBox(width: 12),
          
          // 基本信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNameAndStatus(),
                const SizedBox(height: 6),
                _buildServiceInfo(),
                const SizedBox(height: 6),
                _buildPriceInfo(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建头像
  Widget _buildAvatar() {
    return Stack(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 30),
        ),
        if (provider.isOnline)
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(_OrderConfirmConstants.successGreen),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  /// 构建姓名和状态
  Widget _buildNameAndStatus() {
    return Row(
      children: [
        Text(
          provider.nickname,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(_OrderConfirmConstants.textPrimary),
          ),
        ),
        const SizedBox(width: 6),
        if (provider.isVerified)
          const Icon(Icons.verified, color: Colors.blue, size: 16),
        const Spacer(),
        if (provider.isOnline)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(_OrderConfirmConstants.successGreen),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '在线',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  /// 构建服务信息
  Widget _buildServiceInfo() {
    return Text(
      '${provider.serviceType.displayName}${provider.gameType != null ? ' · ${provider.gameType!.displayName}' : ''}',
      style: const TextStyle(
        fontSize: 13,
        color: Color(_OrderConfirmConstants.textSecondary),
      ),
    );
  }

  /// 构建价格信息
  Widget _buildPriceInfo() {
    return Row(
      children: [
        Text(
          provider.priceText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(_OrderConfirmConstants.errorRed),
          ),
        ),
        const Spacer(),
        Row(
          children: [
            Icon(Icons.star, size: 14, color: Colors.amber[600]),
            const SizedBox(width: 2),
            Text(
              '${provider.rating}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(_OrderConfirmConstants.textSecondary),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${provider.reviewCount}+评价',
              style: const TextStyle(
                fontSize: 12,
                color: Color(_OrderConfirmConstants.textSecondary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 📊 订单详情卡片
class _OrderDetailsCard extends StatelessWidget {
  final ServiceProviderModel provider;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String currency;
  final VoidCallback? onIncreaseQuantity;
  final VoidCallback? onDecreaseQuantity;

  const _OrderDetailsCard({
    required this.provider,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.currency,
    this.onIncreaseQuantity,
    this.onDecreaseQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(_OrderConfirmConstants.cardWhite),
        borderRadius: BorderRadius.circular(_OrderConfirmConstants.cardBorderRadius),
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
            '订单详情',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(_OrderConfirmConstants.textPrimary),
            ),
          ),
          const SizedBox(height: 16),
          
          // 服务项目
          _buildOrderItem(),
          
          const Divider(height: 24, color: Color(_OrderConfirmConstants.borderGray)),
          
          // 价格明细
          _buildPriceDetails(),
        ],
      ),
    );
  }

  /// 构建订单项目
  Widget _buildOrderItem() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getServiceTitle(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(_OrderConfirmConstants.textPrimary),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$unitPrice $currency/${provider.serviceUnit}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(_OrderConfirmConstants.textSecondary),
                ),
              ),
            ],
          ),
        ),
        
        // 数量选择器
        _buildQuantitySelector(),
      ],
    );
  }

  /// 获取服务标题
  String _getServiceTitle() {
    switch (provider.serviceType) {
      case ServiceType.game:
        return '${provider.gameType?.displayName ?? '游戏'} 陪练服务';
      case ServiceType.entertainment:
        return '娱乐陪伴服务';
      case ServiceType.lifestyle:
        return '生活服务';
      case ServiceType.work:
        return '工作服务';
    }
  }

  /// 构建数量选择器
  Widget _buildQuantitySelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(_OrderConfirmConstants.borderGray)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 减少按钮
          GestureDetector(
            onTap: quantity > _OrderConfirmConstants.minQuantity ? onDecreaseQuantity : null,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(color: Color(_OrderConfirmConstants.borderGray)),
                ),
              ),
              child: Icon(
                Icons.remove,
                size: 16,
                color: quantity > _OrderConfirmConstants.minQuantity 
                    ? const Color(_OrderConfirmConstants.textPrimary)
                    : const Color(_OrderConfirmConstants.textSecondary),
              ),
            ),
          ),
          
          // 数量显示
          Container(
            width: 50,
            height: 32,
            alignment: Alignment.center,
            child: Text(
              quantity.toString(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(_OrderConfirmConstants.textPrimary),
              ),
            ),
          ),
          
          // 增加按钮
          GestureDetector(
            onTap: quantity < _OrderConfirmConstants.maxQuantity ? onIncreaseQuantity : null,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: Color(_OrderConfirmConstants.borderGray)),
                ),
              ),
              child: Icon(
                Icons.add,
                size: 16,
                color: quantity < _OrderConfirmConstants.maxQuantity 
                    ? const Color(_OrderConfirmConstants.textPrimary)
                    : const Color(_OrderConfirmConstants.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建价格明细
  Widget _buildPriceDetails() {
    return Column(
      children: [
        _buildPriceRow('单价', '$unitPrice $currency/${provider.serviceUnit}', false),
        const SizedBox(height: 8),
        _buildPriceRow('数量', '$quantity ${provider.serviceUnit}', false),
        const SizedBox(height: 8),
        _buildPriceRow('小计', '$totalPrice $currency', true),
      ],
    );
  }

  /// 构建价格行
  Widget _buildPriceRow(String label, String value, bool isTotal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            color: const Color(_OrderConfirmConstants.textPrimary),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal 
                ? const Color(_OrderConfirmConstants.errorRed)
                : const Color(_OrderConfirmConstants.textPrimary),
          ),
        ),
      ],
    );
  }
}

/// 📝 订单备注卡片
class _OrderNotesCard extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const _OrderNotesCard({
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(_OrderConfirmConstants.cardWhite),
        borderRadius: BorderRadius.circular(_OrderConfirmConstants.cardBorderRadius),
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
          const Text(
            '订单备注',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(_OrderConfirmConstants.textPrimary),
            ),
          ),
          const SizedBox(height: 12),
          
          TextField(
            controller: controller,
            onChanged: onChanged,
            maxLines: 3,
            maxLength: 200,
            decoration: const InputDecoration(
              hintText: '请输入您的需求或特殊说明（选填）',
              hintStyle: TextStyle(
                color: Color(_OrderConfirmConstants.textSecondary),
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Color(_OrderConfirmConstants.borderGray)),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(_OrderConfirmConstants.primaryPurple)),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              contentPadding: EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🔻 底部确认栏
class _BottomConfirmBar extends StatelessWidget {
  final double totalPrice;
  final String currency;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onConfirm;

  const _BottomConfirmBar({
    required this.totalPrice,
    required this.currency,
    this.isLoading = false,
    this.errorMessage,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _OrderConfirmConstants.bottomBarHeight,
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
      decoration: BoxDecoration(
        color: const Color(_OrderConfirmConstants.cardWhite),
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
            // 价格信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '合计',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(_OrderConfirmConstants.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Flexible(
                    child: Text(
                      '$totalPrice $currency',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(_OrderConfirmConstants.errorRed),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            
            // 确认按钮
            SizedBox(
              width: 120,
              height: 40,
              child: ElevatedButton(
                onPressed: isLoading || errorMessage != null ? null : onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(_OrderConfirmConstants.primaryPurple),
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
                        '确认下单',
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
/// 🛒 订单确认页面
class OrderConfirmPage extends StatefulWidget {
  final ServiceProviderModel provider;

  const OrderConfirmPage({
    super.key,
    required this.provider,
  });

  @override
  State<OrderConfirmPage> createState() => _OrderConfirmPageState();
}

class _OrderConfirmPageState extends State<OrderConfirmPage> {
  late final _OrderConfirmController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _OrderConfirmController(widget.provider);
    _controller.notesController.addListener(() {
      _controller.updateNotes(_controller.notesController.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(_OrderConfirmConstants.backgroundGray),
      appBar: AppBar(
        title: const Text(_OrderConfirmConstants.pageTitle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _controller.goBack(context),
        ),
      ),
      body: ValueListenableBuilder<OrderConfirmPageState>(
        valueListenable: _controller,
        builder: (context, state, child) {
          return Column(
            children: [
              // 主要内容区域
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // 服务者信息确认
                      _ProviderConfirmCard(provider: widget.provider),
                      
                      // 订单详情
                      _OrderDetailsCard(
                        provider: widget.provider,
                        quantity: state.quantity,
                        unitPrice: state.unitPrice,
                        totalPrice: state.totalPrice,
                        currency: state.currency,
                        onIncreaseQuantity: _controller.increaseQuantity,
                        onDecreaseQuantity: _controller.decreaseQuantity,
                      ),
                      
                      // 订单备注
                      _OrderNotesCard(
                        controller: _controller.notesController,
                        onChanged: _controller.updateNotes,
                      ),
                      
                      // 错误提示
                      if (state.errorMessage != null)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(_OrderConfirmConstants.errorRed).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(_OrderConfirmConstants.errorRed).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Color(_OrderConfirmConstants.errorRed),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  state.errorMessage!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(_OrderConfirmConstants.errorRed),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      // 底部占位
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      
      // 底部确认栏
      bottomNavigationBar: ValueListenableBuilder<OrderConfirmPageState>(
        valueListenable: _controller,
        builder: (context, state, child) {
          return _BottomConfirmBar(
            totalPrice: state.totalPrice,
            currency: state.currency,
            isLoading: state.isLoading,
            errorMessage: state.errorMessage,
            onConfirm: () => _controller.confirmOrder(context),
          );
        },
      ),
    );
  }
}

// ============== 8. EXPORTS ==============
/// 📤 导出定义
