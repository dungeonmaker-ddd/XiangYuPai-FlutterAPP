// 🔧 服务系统业务服务 - 统一的业务逻辑层
// 包含所有服务相关的API调用、数据处理和业务逻辑

// ============== IMPORTS ==============
import 'dart:async';
import 'dart:developer' as developer;
import 'service_models.dart';

// ============== 核心服务类 ==============

/// 🔧 服务系统统一服务类
/// 
/// 提供所有服务系统相关的业务逻辑，包括：
/// - 服务提供者管理
/// - 订单管理
/// - 支付处理
/// - 评价管理
/// - 数据缓存
class ServiceSystemService {
  ServiceSystemService._();
  
  /// 单例实例
  static final ServiceSystemService _instance = ServiceSystemService._();
  static ServiceSystemService get instance => _instance;
  
  // 缓存管理
  final Map<String, dynamic> _cache = {};
  final Map<String, Timer> _cacheTimers = {};
  
  /// 缓存过期时间（分钟）
  static const int cacheExpirationMinutes = 5;
  
  // ============== 服务提供者相关 ==============
  
  /// 获取服务提供者列表
  Future<List<ServiceProviderModel>> getServiceProviders({
    required ServiceType serviceType,
    ServiceFilterModel? filter,
    int page = 1,
    int limit = 20,
  }) async {
    final cacheKey = 'providers_${serviceType.name}_${filter?.filterHashCode ?? 0}_${page}_$limit';
    
    // 检查缓存
    if (_cache.containsKey(cacheKey)) {
      return List<ServiceProviderModel>.from(_cache[cacheKey]);
    }
    
    try {
      // 模拟网络请求
      await Future.delayed(const Duration(milliseconds: 800));
      
      final providers = _generateMockProviders(
        serviceType: serviceType,
        filter: filter,
        page: page,
        limit: limit,
      );
      
      // 缓存结果
      _cacheData(cacheKey, providers);
      
      return providers;
    } catch (e) {
      developer.log('获取服务提供者列表失败: $e');
      rethrow;
    }
  }
  
  /// 获取服务提供者详情
  Future<ServiceProviderModel> getServiceProviderDetail(String providerId) async {
    final cacheKey = 'provider_detail_$providerId';
    
    // 检查缓存
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey] as ServiceProviderModel;
    }
    
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      
      final provider = _generateMockProviderDetail(providerId);
      
      // 缓存结果
      _cacheData(cacheKey, provider);
      
      return provider;
    } catch (e) {
      developer.log('获取服务提供者详情失败: $e');
      rethrow;
    }
  }
  
  /// 搜索服务提供者
  Future<List<ServiceProviderModel>> searchServiceProviders({
    required String keyword,
    ServiceType? serviceType,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // 模拟搜索结果
      final allProviders = await getServiceProviders(
        serviceType: serviceType ?? ServiceType.game,
        page: page,
        limit: limit * 2, // 获取更多数据用于筛选
      );
      
      // 根据关键词筛选
      final searchResults = allProviders.where((provider) {
        return provider.nickname.toLowerCase().contains(keyword.toLowerCase()) ||
               provider.description.toLowerCase().contains(keyword.toLowerCase()) ||
               provider.tags.any((tag) => tag.toLowerCase().contains(keyword.toLowerCase()));
      }).take(limit).toList();
      
      return searchResults;
    } catch (e) {
      developer.log('搜索服务提供者失败: $e');
      rethrow;
    }
  }
  
  // ============== 订单管理相关 ==============
  
  /// 创建订单
  Future<ServiceOrderModel> createOrder({
    required ServiceProviderModel provider,
    required int quantity,
    String? notes,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 1200));
      
      // 验证订单数据
      _validateOrderData(provider, quantity);
      
      // 生成订单
      final orderId = 'order_${DateTime.now().millisecondsSinceEpoch}';
      final order = ServiceOrderModel(
        id: orderId,
        serviceProviderId: provider.id,
        serviceProvider: provider,
        serviceType: provider.serviceType,
        gameType: provider.gameType,
        quantity: quantity,
        unitPrice: provider.pricePerService,
        totalPrice: provider.pricePerService * quantity,
        currency: provider.currency,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        notes: notes,
      );
      
      // 缓存订单信息
      _cacheData('order_${order.id}', order);
      
      return order;
    } catch (e) {
      developer.log('创建订单失败: $e');
      rethrow;
    }
  }
  
  /// 获取订单详情
  Future<ServiceOrderModel> getOrderDetail(String orderId) async {
    final cacheKey = 'order_$orderId';
    
    // 检查缓存
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey] as ServiceOrderModel;
    }
    
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 模拟获取订单详情
      final order = _generateMockOrder(orderId);
      
      // 缓存结果
      _cacheData(cacheKey, order);
      
      return order;
    } catch (e) {
      developer.log('获取订单详情失败: $e');
      rethrow;
    }
  }
  
  /// 取消订单
  Future<ServiceOrderModel> cancelOrder(String orderId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      
      final order = await getOrderDetail(orderId);
      
      if (order.status != OrderStatus.pending) {
        throw '只能取消待确认的订单';
      }
      
      final updatedOrder = order.copyWith(status: OrderStatus.cancelled);
      
      // 更新缓存
      _cacheData('order_$orderId', updatedOrder);
      
      return updatedOrder;
    } catch (e) {
      developer.log('取消订单失败: $e');
      rethrow;
    }
  }
  
  // ============== 支付处理相关 ==============
  
  /// 获取用户余额
  Future<double> getUserBalance() async {
    final cacheKey = 'user_balance';
    
    // 检查缓存（余额缓存时间较短）
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey] as double;
    }
    
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      // 模拟获取用户余额
      final balance = 888.88 + (DateTime.now().millisecond % 1000) / 10;
      
      // 缓存余额（1分钟）
      _cacheData(cacheKey, balance, expirationMinutes: 1);
      
      return balance;
    } catch (e) {
      developer.log('获取用户余额失败: $e');
      rethrow;
    }
  }
  
  /// 验证支付密码
  Future<bool> verifyPaymentPassword(String password) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      
      // 模拟密码验证
      if (password.length != 6) {
        throw '支付密码必须是6位数字';
      }
      
      if (!RegExp(r'^\d{6}$').hasMatch(password)) {
        throw '支付密码只能包含数字';
      }
      
      // 模拟密码错误
      if (password == '000000' || password == '123456') {
        throw '支付密码错误，请重新输入';
      }
      
      return true;
    } catch (e) {
      developer.log('验证支付密码失败: $e');
      rethrow;
    }
  }
  
  /// 处理支付
  Future<PaymentInfoModel> processPayment({
    required ServiceOrderModel order,
    required PaymentMethod paymentMethod,
    required String paymentPassword,
  }) async {
    try {
      // 验证支付密码
      await verifyPaymentPassword(paymentPassword);
      
      // 模拟支付处理
      await Future.delayed(const Duration(milliseconds: 2000));
      
      // 检查余额（如果是金币支付）
      if (paymentMethod == PaymentMethod.coin) {
        final balance = await getUserBalance();
        if (balance < order.totalPrice) {
          throw '金币余额不足，请先充值';
        }
      }
      
      // 生成交易信息
      final transactionId = 'txn_${DateTime.now().millisecondsSinceEpoch}';
      
      // 模拟支付成功/失败（95%成功率）
      final isSuccess = DateTime.now().millisecond % 20 != 0;
      
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
      
      // 更新订单状态
      final updatedOrder = order.copyWith(status: OrderStatus.paid);
      _cacheData('order_${order.id}', updatedOrder);
      
      // 更新用户余额（如果是金币支付）
      if (paymentMethod == PaymentMethod.coin) {
        final currentBalance = await getUserBalance();
        _cacheData('user_balance', currentBalance - order.totalPrice, expirationMinutes: 1);
      }
      
      return paymentInfo;
    } catch (e) {
      developer.log('处理支付失败: $e');
      rethrow;
    }
  }
  
  /// 获取支付方式可用状态
  Future<Map<PaymentMethod, bool>> getPaymentMethodAvailability() async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      
      return {
        PaymentMethod.coin: true,
        PaymentMethod.wechat: true,
        PaymentMethod.alipay: true,
        PaymentMethod.apple: false, // 模拟Apple Pay不可用
      };
    } catch (e) {
      developer.log('获取支付方式可用状态失败: $e');
      rethrow;
    }
  }
  
  // ============== 评价管理相关 ==============
  
  /// 获取评价列表
  Future<List<ServiceReviewModel>> getReviews({
    required String serviceProviderId,
    String tag = '精选',
    int page = 1,
    int limit = 10,
  }) async {
    final cacheKey = 'reviews_${serviceProviderId}_${tag}_${page}_$limit';
    
    // 检查缓存
    if (_cache.containsKey(cacheKey)) {
      return List<ServiceReviewModel>.from(_cache[cacheKey]);
    }
    
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      
      final reviews = _generateMockReviews(
        serviceProviderId: serviceProviderId,
        tag: tag,
        page: page,
        limit: limit,
      );
      
      // 缓存结果
      _cacheData(cacheKey, reviews);
      
      return reviews;
    } catch (e) {
      developer.log('获取评价列表失败: $e');
      rethrow;
    }
  }
  
  /// 提交评价
  Future<ServiceReviewModel> submitReview({
    required String orderId,
    required String serviceProviderId,
    required double rating,
    required String content,
    required List<String> tags,
  }) async {
    try {
      // 验证评价数据
      _validateReviewData(rating, content, tags);
      
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // 模拟提交失败（5%概率）
      if (DateTime.now().millisecond % 20 == 0) {
        throw '评价提交失败，请重试';
      }
      
      // 生成评价
      final reviewId = 'review_${DateTime.now().millisecondsSinceEpoch}';
      final review = ServiceReviewModel(
        id: reviewId,
        userId: 'current_user_id',
        userName: '当前用户',
        serviceProviderId: serviceProviderId,
        rating: rating,
        content: content,
        tags: tags,
        createdAt: DateTime.now(),
        isHighlighted: rating >= 4.5,
      );
      
      // 清除相关缓存
      _clearReviewsCache(serviceProviderId);
      
      return review;
    } catch (e) {
      developer.log('提交评价失败: $e');
      rethrow;
    }
  }
  
  /// 检查是否已评价
  Future<bool> hasReviewed(String orderId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      
      // 模拟检查结果
      return false; // 假设还未评价
    } catch (e) {
      developer.log('检查评价状态失败: $e');
      rethrow;
    }
  }
  
  // ============== 数据验证相关 ==============
  
  /// 验证订单数据
  void _validateOrderData(ServiceProviderModel provider, int quantity) {
    if (!provider.isOnline) {
      throw '服务者当前不在线，无法下单';
    }
    
    if (quantity <= 0) {
      throw '订单数量必须大于0';
    }
    
    if (quantity > 99) {
      throw '订单数量不能超过99';
    }
  }
  
  /// 验证评价数据
  void _validateReviewData(double rating, String content, List<String> tags) {
    if (rating < 1.0 || rating > 5.0) {
      throw '评分必须在1-5星之间';
    }
    
    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty) {
      throw '请填写评价内容';
    }
    
    if (trimmedContent.length < 10) {
      throw '评价内容至少需要10个字符';
    }
    
    if (trimmedContent.length > 500) {
      throw '评价内容不能超过500个字符';
    }
    
    if (tags.length > 5) {
      throw '最多只能选择5个标签';
    }
  }
  
  // ============== 数据生成相关（模拟数据）==============
  
  /// 生成模拟服务提供者列表
  List<ServiceProviderModel> _generateMockProviders({
    required ServiceType serviceType,
    ServiceFilterModel? filter,
    required int page,
    required int limit,
  }) {
    final providers = List.generate(limit, (index) {
      final baseIndex = (page - 1) * limit + index;
      return ServiceProviderModel(
        id: '${serviceType.name}_provider_$baseIndex',
        nickname: '服务${100 + baseIndex}',
        serviceType: serviceType,
        isOnline: baseIndex % 3 == 0,
        isVerified: baseIndex % 5 == 0,
        rating: 4.0 + (baseIndex % 10) * 0.1,
        reviewCount: 50 + baseIndex * 10,
        distance: 1.0 + (baseIndex % 20) * 0.5,
        tags: _getRandomTags(serviceType, baseIndex),
        description: _getServiceDescription(serviceType),
        pricePerService: 8.0 + (baseIndex % 15) * 2.0,
        lastActiveTime: DateTime.now().subtract(Duration(hours: baseIndex % 24)),
        gender: baseIndex % 3 == 0 ? '女' : '男',
        gameType: serviceType == ServiceType.game ? GameType.lol : null,
        gameRank: serviceType == ServiceType.game ? _getRandomRank(baseIndex) : null,
        gameRegion: serviceType == ServiceType.game ? (baseIndex % 2 == 0 ? 'QQ区' : '微信区') : null,
        gamePosition: serviceType == ServiceType.game ? _getRandomPosition(baseIndex) : null,
      );
    });
    
    // 应用筛选条件
    return _applyFilters(providers, filter);
  }
  
  /// 生成模拟服务提供者详情
  ServiceProviderModel _generateMockProviderDetail(String providerId) {
    final random = providerId.hashCode % 100;
    
    return ServiceProviderModel(
      id: providerId,
      nickname: '服务${100 + random}',
      serviceType: ServiceType.game,
      isOnline: random % 3 == 0,
      isVerified: random % 5 == 0,
      rating: 4.0 + (random % 10) * 0.1,
      reviewCount: 100 + random * 5,
      distance: 1.0 + (random % 20) * 0.5,
      tags: ['专业', '技术好', '服务佳', '性价比高'],
      description: '专业服务提供者，技术过硬，服务态度好，能够根据您的需求提供最优质的服务体验。',
      pricePerService: 10.0 + (random % 10) * 2.0,
      lastActiveTime: DateTime.now().subtract(Duration(minutes: random % 60)),
      gender: random % 2 == 0 ? '女' : '男',
      gameType: GameType.lol,
      gameRank: _getRandomRank(random),
      gameRegion: random % 2 == 0 ? 'QQ区' : '微信区',
      gamePosition: _getRandomPosition(random),
    );
  }
  
  /// 生成模拟订单
  ServiceOrderModel _generateMockOrder(String orderId) {
    final provider = _generateMockProviderDetail('provider_123');
    
    return ServiceOrderModel(
      id: orderId,
      serviceProviderId: provider.id,
      serviceProvider: provider,
      serviceType: ServiceType.game,
      gameType: GameType.lol,
      quantity: 3,
      unitPrice: 12.0,
      totalPrice: 36.0,
      currency: '金币',
      status: OrderStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      completedAt: DateTime.now().subtract(const Duration(minutes: 30)),
    );
  }
  
  /// 生成模拟评价列表
  List<ServiceReviewModel> _generateMockReviews({
    required String serviceProviderId,
    required String tag,
    required int page,
    required int limit,
  }) {
    return List.generate(limit, (index) {
      final baseIndex = (page - 1) * limit + index;
      final ratings = [4.0, 4.5, 5.0, 4.8, 4.2];
      final contents = [
        '技术很好，服务态度也很棒，非常满意！',
        '专业度很高，体验很好，会推荐给朋友',
        '服务质量不错，价格也合理，值得推荐',
        '非常专业，服务周到，下次还会选择',
        '性价比很高，服务态度也很好，推荐',
      ];
      final userNames = ['用户${100 + baseIndex}', '玩家${200 + baseIndex}', '顾客${300 + baseIndex}'];
      final tagsList = [
        ['技术好', '专业'],
        ['声音甜美', '服务好'],
        ['有耐心', '认真'],
        ['准时', '可靠'],
        ['性价比高', '推荐'],
      ];
      
      return ServiceReviewModel(
        id: 'review_$baseIndex',
        userId: 'user_$baseIndex',
        userName: userNames[baseIndex % userNames.length],
        serviceProviderId: serviceProviderId,
        rating: ratings[baseIndex % ratings.length],
        content: contents[baseIndex % contents.length],
        tags: tagsList[baseIndex % tagsList.length],
        createdAt: DateTime.now().subtract(Duration(days: baseIndex % 30)),
        isHighlighted: tag == '精选' && baseIndex % 3 == 0,
      );
    });
  }
  
  // ============== 辅助方法 ==============
  
  /// 应用筛选条件
  List<ServiceProviderModel> _applyFilters(
    List<ServiceProviderModel> providers,
    ServiceFilterModel? filter,
  ) {
    if (filter == null) return providers;
    
    var filtered = providers.where((provider) {
      // 性别筛选
      if (filter.genderFilter == '只看女生' && provider.gender != '女') {
        return false;
      }
      if (filter.genderFilter == '只看男生' && provider.gender != '男') {
        return false;
      }
      
      // 状态筛选
      if (filter.statusFilter == '在线' && !provider.isOnline) {
        return false;
      }
      if (filter.statusFilter == '离线' && provider.isOnline) {
        return false;
      }
      
      // 标签筛选
      if (filter.selectedTags.isNotEmpty) {
        final hasMatchingTag = filter.selectedTags.any(
          (tag) => provider.tags.contains(tag),
        );
        if (!hasMatchingTag) return false;
      }
      
      return true;
    }).toList();
    
    // 应用排序
    switch (filter.sortType) {
      case '音质排序':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case '最近排序':
        filtered.sort((a, b) => b.lastActiveTime.compareTo(a.lastActiveTime));
        break;
      case '人气排序':
        filtered.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        break;
      case '智能排序':
      default:
        // 智能排序：综合评分、距离、活跃度
        filtered.sort((a, b) {
          final scoreA = a.rating * 0.4 + (1 / (a.distance + 1)) * 0.3 + 
                        (a.isOnline ? 1 : 0) * 0.3;
          final scoreB = b.rating * 0.4 + (1 / (b.distance + 1)) * 0.3 + 
                        (b.isOnline ? 1 : 0) * 0.3;
          return scoreB.compareTo(scoreA);
        });
        break;
    }
    
    return filtered;
  }
  
  /// 获取随机标签
  List<String> _getRandomTags(ServiceType serviceType, int seed) {
    List<String> tags;
    switch (serviceType) {
      case ServiceType.game:
        tags = ['王者', '专业', '上分', '高质量', '认证'];
        break;
      case ServiceType.entertainment:
        tags = ['专业', '有趣', '经验丰富', '服务好', '推荐'];
        break;
      case ServiceType.lifestyle:
        tags = ['专业', '技术好', '服务佳', '性价比高', '推荐'];
        break;
      case ServiceType.work:
        tags = ['可靠', '专业', '经验丰富', '效率高', '推荐'];
        break;
    }
    final random = seed % 5;
    return tags.take(2 + random % 3).toList();
  }
  
  /// 获取服务描述
  String _getServiceDescription(ServiceType serviceType) {
    switch (serviceType) {
      case ServiceType.game:
        return '专业陪练，技术过硬，声音甜美，带您上分';
      case ServiceType.entertainment:
        return '专业娱乐服务，经验丰富，让您享受美好时光';
      case ServiceType.lifestyle:
        return '专业生活服务，技术过硬，让您生活更便利';
      case ServiceType.work:
        return '专业工作服务，经验丰富，帮您解决工作难题';
    }
  }
  
  /// 获取随机段位
  String _getRandomRank(int seed) {
    final ranks = ['青铜', '白银', '黄金', '白金', '钻石', '星耀', '王者'];
    return ranks[seed % ranks.length];
  }
  
  /// 获取随机位置
  String _getRandomPosition(int seed) {
    final positions = ['打野', '上路', '中路', '下路', '辅助'];
    return positions[seed % positions.length];
  }
  
  // ============== 缓存管理 ==============
  
  /// 缓存数据
  void _cacheData(String key, dynamic data, {int expirationMinutes = cacheExpirationMinutes}) {
    _cache[key] = data;
    
    // 设置过期时间
    _cacheTimers[key]?.cancel();
    _cacheTimers[key] = Timer(Duration(minutes: expirationMinutes), () {
      _cache.remove(key);
      _cacheTimers.remove(key);
    });
  }
  
  /// 清除特定缓存
  void _clearCache(String key) {
    _cache.remove(key);
    _cacheTimers[key]?.cancel();
    _cacheTimers.remove(key);
  }
  
  /// 清除评价相关缓存
  void _clearReviewsCache(String serviceProviderId) {
    final keysToRemove = _cache.keys
        .where((key) => key.startsWith('reviews_$serviceProviderId'))
        .toList();
    
    for (final key in keysToRemove) {
      _clearCache(key);
    }
  }
  
  /// 清除所有缓存
  void clearAllCache() {
    for (final timer in _cacheTimers.values) {
      timer.cancel();
    }
    _cache.clear();
    _cacheTimers.clear();
  }
  
  /// 获取缓存统计信息
  Map<String, dynamic> getCacheStats() {
    return {
      'totalCacheItems': _cache.length,
      'activeTimers': _cacheTimers.length,
      'cacheKeys': _cache.keys.toList(),
    };
  }
}

// ============== 扩展方法 ==============

/// ServiceFilterModel 扩展方法
extension ServiceFilterModelExtensions on ServiceFilterModel {
  /// 生成哈希码用于缓存键
  int get filterHashCode {
    return Object.hash(
      serviceType,
      sortType,
      genderFilter,
      statusFilter,
      regionFilter,
      rankFilter,
      priceRange,
      positionFilter,
      selectedTags,
      isLocal,
    );
  }
  
  /// 检查是否相等
  bool isEqualTo(ServiceFilterModel other) {
    if (identical(this, other)) return true;
    
    return serviceType == other.serviceType &&
           sortType == other.sortType &&
           genderFilter == other.genderFilter &&
           statusFilter == other.statusFilter &&
           regionFilter == other.regionFilter &&
           rankFilter == other.rankFilter &&
           priceRange == other.priceRange &&
           positionFilter == other.positionFilter &&
           _listEquals(selectedTags, other.selectedTags) &&
           isLocal == other.isLocal;
  }
  
  /// 列表相等比较
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

// ============== 工具类 ==============

/// 🛠️ 服务系统工具类
class ServiceSystemUtils {
  ServiceSystemUtils._();
  
  /// 格式化价格
  static String formatPrice(double price, String currency) {
    return '${price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 1)} $currency';
  }
  
  /// 格式化距离
  static String formatDistance(double distance) {
    if (distance < 1) {
      return '${(distance * 1000).toInt()}m';
    } else {
      return '${distance.toStringAsFixed(1)}km';
    }
  }
  
  /// 格式化时间差
  static String formatTimeDifference(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 30) {
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
  
  /// 验证手机号
  static bool isValidPhoneNumber(String phoneNumber) {
    return RegExp(r'^1[3-9]\d{9}$').hasMatch(phoneNumber);
  }
  
  /// 验证邮箱
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  /// 生成随机字符串
  static String generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return String.fromCharCodes(
      Iterable.generate(length, (i) => chars.codeUnitAt((random + i) % chars.length)),
    );
  }
}
