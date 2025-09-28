// 🛍️ 服务系统数据模型 - 通用数据结构定义
// 包含所有服务相关的数据模型和枚举类型

// ============== 核心枚举类型 ==============

/// 🎯 服务类型枚举
enum ServiceType {
  game('游戏陪玩'),
  entertainment('娱乐服务'),
  lifestyle('生活服务'),
  work('工作兼职');
  
  const ServiceType(this.displayName);
  final String displayName;
}

/// 🎮 游戏类型枚举
enum GameType {
  lol('英雄联盟'),
  pubg('和平精英'),
  brawlStars('荒野乱斗'),
  honorOfKings('王者荣耀');
  
  const GameType(this.displayName);
  final String displayName;
}

/// 📊 订单状态枚举
enum OrderStatus {
  pending('待确认'),
  confirmed('已确认'),
  paid('已支付'),
  inProgress('进行中'),
  completed('已完成'),
  cancelled('已取消');
  
  const OrderStatus(this.displayName);
  final String displayName;
}

/// 💳 支付方式枚举
enum PaymentMethod {
  coin('金币支付'),
  wechat('微信支付'),
  alipay('支付宝'),
  apple('Apple Pay');
  
  const PaymentMethod(this.displayName);
  final String displayName;
}

/// 💰 支付状态枚举
enum PaymentStatus {
  pending('待支付'),
  processing('支付中'),
  success('支付成功'),
  failed('支付失败'),
  cancelled('已取消');
  
  const PaymentStatus(this.displayName);
  final String displayName;
}

// ============== 核心数据模型 ==============

/// 👤 通用服务提供者模型
class ServiceProviderModel {
  final String id;
  final String nickname;
  final String? avatar;
  final ServiceType serviceType;
  final bool isOnline;
  final bool isVerified;
  final double rating;
  final int reviewCount;
  final double distance;
  final List<String> tags;
  final String description;
  final double pricePerService;
  final String currency;
  final DateTime lastActiveTime;
  final String gender;
  
  // 游戏服务专用字段
  final GameType? gameType;
  final String? gameRank;
  final String? gameRegion;
  final String? gamePosition;
  
  const ServiceProviderModel({
    required this.id,
    required this.nickname,
    this.avatar,
    required this.serviceType,
    required this.isOnline,
    this.isVerified = false,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.tags,
    required this.description,
    required this.pricePerService,
    this.currency = '金币',
    required this.lastActiveTime,
    this.gender = '未知',
    this.gameType,
    this.gameRank,
    this.gameRegion,
    this.gamePosition,
  });
  
  /// 获取距离文本
  String get distanceText {
    if (distance < 1) {
      return '${(distance * 1000).toInt()}m';
    } else {
      return '${distance.toStringAsFixed(1)}km';
    }
  }
  
  /// 获取价格文本
  String get priceText {
    switch (serviceType) {
      case ServiceType.game:
        return '$pricePerService $currency/局';
      case ServiceType.entertainment:
      case ServiceType.lifestyle:
        return '$pricePerService $currency/小时';
      case ServiceType.work:
        return '$pricePerService $currency/次';
    }
  }
  
  /// 获取评价文本
  String get reviewText => '($reviewCount+) 好评率${(rating * 20).toInt()}%';
  
  /// 获取服务单位
  String get serviceUnit {
    switch (serviceType) {
      case ServiceType.game:
        return '小时';
      case ServiceType.entertainment:
        return '小时';
      case ServiceType.lifestyle:
        return '次';
      case ServiceType.work:
        return '天';
    }
  }
  
  /// 获取最后活跃时间文本
  String get lastActiveText {
    final now = DateTime.now();
    final difference = now.difference(lastActiveTime);
    
    if (difference.inMinutes < 5) {
      return '刚刚活跃';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前活跃';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前活跃';
    } else {
      return '${difference.inDays}天前活跃';
    }
  }
  
  /// 复制并修改
  ServiceProviderModel copyWith({
    String? id,
    String? nickname,
    String? avatar,
    ServiceType? serviceType,
    bool? isOnline,
    bool? isVerified,
    double? rating,
    int? reviewCount,
    double? distance,
    List<String>? tags,
    String? description,
    double? pricePerService,
    String? currency,
    DateTime? lastActiveTime,
    String? gender,
    GameType? gameType,
    String? gameRank,
    String? gameRegion,
    String? gamePosition,
  }) {
    return ServiceProviderModel(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      serviceType: serviceType ?? this.serviceType,
      isOnline: isOnline ?? this.isOnline,
      isVerified: isVerified ?? this.isVerified,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      distance: distance ?? this.distance,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      pricePerService: pricePerService ?? this.pricePerService,
      currency: currency ?? this.currency,
      lastActiveTime: lastActiveTime ?? this.lastActiveTime,
      gender: gender ?? this.gender,
      gameType: gameType ?? this.gameType,
      gameRank: gameRank ?? this.gameRank,
      gameRegion: gameRegion ?? this.gameRegion,
      gamePosition: gamePosition ?? this.gamePosition,
    );
  }
}

/// 🔍 通用服务筛选条件模型
class ServiceFilterModel {
  final ServiceType serviceType;
  final String sortType;           // 排序类型：智能/音质/最近/人气
  final String genderFilter;      // 性别筛选：不限/女生/男生
  final String? statusFilter;     // 状态筛选：在线/离线
  final String? regionFilter;     // 大区筛选（游戏专用）
  final String? rankFilter;       // 段位筛选（游戏专用）
  final String? priceRange;       // 价格范围
  final String? positionFilter;   // 位置筛选（游戏专用）
  final List<String> selectedTags; // 选中的标签
  final bool isLocal;             // 是否同城
  
  const ServiceFilterModel({
    required this.serviceType,
    this.sortType = '智能排序',
    this.genderFilter = '不限性别',
    this.statusFilter,
    this.regionFilter,
    this.rankFilter,
    this.priceRange,
    this.positionFilter,
    this.selectedTags = const [],
    this.isLocal = false,
  });
  
  /// 创建默认筛选器
  factory ServiceFilterModel.defaultFilter(ServiceType serviceType) {
    return ServiceFilterModel(serviceType: serviceType);
  }
  
  ServiceFilterModel copyWith({
    ServiceType? serviceType,
    String? sortType,
    String? genderFilter,
    String? statusFilter,
    String? regionFilter,
    String? rankFilter,
    String? priceRange,
    String? positionFilter,
    List<String>? selectedTags,
    bool? isLocal,
  }) {
    return ServiceFilterModel(
      serviceType: serviceType ?? this.serviceType,
      sortType: sortType ?? this.sortType,
      genderFilter: genderFilter ?? this.genderFilter,
      statusFilter: statusFilter ?? this.statusFilter,
      regionFilter: regionFilter ?? this.regionFilter,
      rankFilter: rankFilter ?? this.rankFilter,
      priceRange: priceRange ?? this.priceRange,
      positionFilter: positionFilter ?? this.positionFilter,
      selectedTags: selectedTags ?? this.selectedTags,
      isLocal: isLocal ?? this.isLocal,
    );
  }
  
  /// 是否有高级筛选条件
  bool get hasAdvancedFilters {
    return statusFilter != null ||
           regionFilter != null ||
           rankFilter != null ||
           priceRange != null ||
           positionFilter != null ||
           selectedTags.isNotEmpty ||
           isLocal;
  }
  
  /// 获取筛选条件数量
  int get filterCount {
    int count = 0;
    if (statusFilter != null) count++;
    if (regionFilter != null) count++;
    if (rankFilter != null) count++;
    if (priceRange != null) count++;
    if (positionFilter != null) count++;
    count += selectedTags.length;
    if (isLocal) count++;
    return count;
  }
}

/// 📋 服务订单模型
class ServiceOrderModel {
  final String id;
  final String serviceProviderId;
  final ServiceProviderModel serviceProvider;
  final ServiceType serviceType;
  final GameType? gameType;
  final int quantity;              // 服务数量
  final double unitPrice;          // 单价
  final double totalPrice;         // 总价
  final String currency;           // 货币类型
  final OrderStatus status;        // 订单状态
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? notes;             // 订单备注
  
  const ServiceOrderModel({
    required this.id,
    required this.serviceProviderId,
    required this.serviceProvider,
    required this.serviceType,
    this.gameType,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.notes,
  });
  
  /// 获取服务单位
  String get serviceUnit {
    switch (serviceType) {
      case ServiceType.game:
        return '局';
      case ServiceType.entertainment:
      case ServiceType.lifestyle:
        return '小时';
      case ServiceType.work:
        return '次';
    }
  }
  
  ServiceOrderModel copyWith({
    String? id,
    String? serviceProviderId,
    ServiceProviderModel? serviceProvider,
    ServiceType? serviceType,
    GameType? gameType,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    String? currency,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    String? notes,
  }) {
    return ServiceOrderModel(
      id: id ?? this.id,
      serviceProviderId: serviceProviderId ?? this.serviceProviderId,
      serviceProvider: serviceProvider ?? this.serviceProvider,
      serviceType: serviceType ?? this.serviceType,
      gameType: gameType ?? this.gameType,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
    );
  }
}

/// 💰 支付信息模型
class PaymentInfoModel {
  final String orderId;
  final PaymentMethod paymentMethod;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final String? transactionId;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? errorMessage;
  
  const PaymentInfoModel({
    required this.orderId,
    required this.paymentMethod,
    required this.amount,
    required this.currency,
    required this.status,
    this.transactionId,
    required this.createdAt,
    this.completedAt,
    this.errorMessage,
  });
  
  PaymentInfoModel copyWith({
    String? orderId,
    PaymentMethod? paymentMethod,
    double? amount,
    String? currency,
    PaymentStatus? status,
    String? transactionId,
    DateTime? createdAt,
    DateTime? completedAt,
    String? errorMessage,
  }) {
    return PaymentInfoModel(
      orderId: orderId ?? this.orderId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// 💬 服务评价模型
class ServiceReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String serviceProviderId;
  final double rating;
  final String content;
  final List<String> tags;         // 评价标签
  final DateTime createdAt;
  final bool isHighlighted;        // 是否精选评价
  final String? reply;             // 服务者回复
  final DateTime? replyTime;       // 回复时间
  
  const ServiceReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.serviceProviderId,
    required this.rating,
    required this.content,
    required this.tags,
    required this.createdAt,
    this.isHighlighted = false,
    this.reply,
    this.replyTime,
  });
  
  /// 获取评价时间文本
  String get timeText {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 30) {
      return '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
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
  
  ServiceReviewModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? serviceProviderId,
    double? rating,
    String? content,
    List<String>? tags,
    DateTime? createdAt,
    bool? isHighlighted,
    String? reply,
    DateTime? replyTime,
  }) {
    return ServiceReviewModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      serviceProviderId: serviceProviderId ?? this.serviceProviderId,
      rating: rating ?? this.rating,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      reply: reply ?? this.reply,
      replyTime: replyTime ?? this.replyTime,
    );
  }
}

// ============== 页面状态模型 ==============

/// 📊 服务筛选页面状态模型
class ServicePageState {
  final ServiceType serviceType;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final List<ServiceProviderModel> providers;
  final ServiceFilterModel? filter;
  final bool hasMoreData;
  final int currentPage;
  
  const ServicePageState({
    required this.serviceType,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.providers = const [],
    this.filter,
    this.hasMoreData = true,
    this.currentPage = 1,
  });
  
  ServicePageState copyWith({
    ServiceType? serviceType,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    List<ServiceProviderModel>? providers,
    ServiceFilterModel? filter,
    bool? hasMoreData,
    int? currentPage,
  }) {
    return ServicePageState(
      serviceType: serviceType ?? this.serviceType,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
      providers: providers ?? this.providers,
      filter: filter ?? this.filter,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      currentPage: currentPage ?? this.currentPage,
    );
  }
  
  /// 获取有效的过滤器（如果为null则创建默认过滤器）
  ServiceFilterModel get effectiveFilter {
    return filter ?? ServiceFilterModel.defaultFilter(serviceType);
  }
}

/// 📋 服务详情页面状态模型
class ServiceDetailPageState {
  final bool isLoading;
  final String? errorMessage;
  final ServiceProviderModel? provider;
  final List<ServiceReviewModel> reviews;
  final String selectedReviewTag;
  final bool isLoadingReviews;
  final bool hasMoreReviews;
  final int reviewPage;
  
  const ServiceDetailPageState({
    this.isLoading = false,
    this.errorMessage,
    this.provider,
    this.reviews = const [],
    this.selectedReviewTag = '精选',
    this.isLoadingReviews = false,
    this.hasMoreReviews = true,
    this.reviewPage = 1,
  });
  
  ServiceDetailPageState copyWith({
    bool? isLoading,
    String? errorMessage,
    ServiceProviderModel? provider,
    List<ServiceReviewModel>? reviews,
    String? selectedReviewTag,
    bool? isLoadingReviews,
    bool? hasMoreReviews,
    int? reviewPage,
  }) {
    return ServiceDetailPageState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      provider: provider ?? this.provider,
      reviews: reviews ?? this.reviews,
      selectedReviewTag: selectedReviewTag ?? this.selectedReviewTag,
      isLoadingReviews: isLoadingReviews ?? this.isLoadingReviews,
      hasMoreReviews: hasMoreReviews ?? this.hasMoreReviews,
      reviewPage: reviewPage ?? this.reviewPage,
    );
  }
}

/// 🛒 订单确认页面状态模型
class OrderConfirmPageState {
  final bool isLoading;
  final String? errorMessage;
  final ServiceProviderModel? provider;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String currency;
  final String? notes;
  
  const OrderConfirmPageState({
    this.isLoading = false,
    this.errorMessage,
    this.provider,
    this.quantity = 1,
    this.unitPrice = 0.0,
    this.totalPrice = 0.0,
    this.currency = '金币',
    this.notes,
  });
  
  OrderConfirmPageState copyWith({
    bool? isLoading,
    String? errorMessage,
    ServiceProviderModel? provider,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    String? currency,
    String? notes,
  }) {
    return OrderConfirmPageState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      provider: provider ?? this.provider,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      currency: currency ?? this.currency,
      notes: notes ?? this.notes,
    );
  }
}

/// 💳 支付流程页面状态模型
class PaymentFlowPageState {
  final bool isLoading;
  final String? errorMessage;
  final ServiceOrderModel? order;
  final PaymentMethod? selectedPaymentMethod;
  final PaymentInfoModel? paymentInfo;
  final PaymentStep currentStep;
  final String? paymentPassword;
  
  const PaymentFlowPageState({
    this.isLoading = false,
    this.errorMessage,
    this.order,
    this.selectedPaymentMethod,
    this.paymentInfo,
    this.currentStep = PaymentStep.selectMethod,
    this.paymentPassword,
  });
  
  PaymentFlowPageState copyWith({
    bool? isLoading,
    String? errorMessage,
    ServiceOrderModel? order,
    PaymentMethod? selectedPaymentMethod,
    PaymentInfoModel? paymentInfo,
    PaymentStep? currentStep,
    String? paymentPassword,
  }) {
    return PaymentFlowPageState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      order: order ?? this.order,
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
      paymentInfo: paymentInfo ?? this.paymentInfo,
      currentStep: currentStep ?? this.currentStep,
      paymentPassword: paymentPassword ?? this.paymentPassword,
    );
  }
}

/// 💳 支付步骤枚举
enum PaymentStep {
  selectMethod('选择支付方式'),
  inputPassword('输入支付密码'),
  processing('处理支付'),
  success('支付成功'),
  failed('支付失败');
  
  const PaymentStep(this.displayName);
  final String displayName;
}
