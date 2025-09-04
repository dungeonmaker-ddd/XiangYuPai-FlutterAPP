// 🛍️ 服务系统数据模型预览
// 基于服务详情筛选下单模块架构设计的核心数据结构

// ============== 核心数据模型 ==============

/// 🎮 服务类型枚举
enum ServiceType {
  game('游戏陪玩'),
  entertainment('娱乐服务'),
  lifestyle('生活服务'),
  work('工作兼职');
  
  const ServiceType(this.displayName);
  final String displayName;
}

/// 🎯 游戏类型枚举
enum GameType {
  lol('英雄联盟'),
  pubg('和平精英'),
  brawlStars('荒野乱斗'),
  honorOfKings('王者荣耀');
  
  const GameType(this.displayName);
  final String displayName;
}

/// 👤 服务提供者模型
class ServiceProviderModel {
  final String id;
  final String nickname;
  final String? avatar;
  final bool isOnline;
  final bool isVerified;
  final double rating;
  final int reviewCount;
  final double distance;
  final List<String> tags;
  final String description;
  final ServiceType serviceType;
  final GameType? gameType;
  final String? gameRank;     // 游戏段位
  final String? gameRegion;   // 游戏大区
  final double pricePerGame;  // 单局价格
  final String currency;      // 货币类型（金币/人民币）
  
  const ServiceProviderModel({
    required this.id,
    required this.nickname,
    this.avatar,
    required this.isOnline,
    this.isVerified = false,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.tags,
    required this.description,
    required this.serviceType,
    this.gameType,
    this.gameRank,
    this.gameRegion,
    required this.pricePerGame,
    this.currency = '金币',
  });
}

/// 🔍 筛选条件模型
class ServiceFilterModel {
  final String? sortType;           // 排序类型：智能/音质/最近/人气
  final String? genderFilter;      // 性别筛选：不限/女生/男生
  final String? statusFilter;      // 状态筛选：在线/离线
  final String? regionFilter;      // 大区筛选：QQ区/微信区
  final String? rankFilter;        // 段位筛选
  final String? priceRange;        // 价格范围
  final String? positionFilter;    // 位置筛选（游戏位置）
  final List<String> selectedTags; // 选中的标签
  final bool? isLocal;             // 是否同城
  
  const ServiceFilterModel({
    this.sortType = '智能排序',
    this.genderFilter = '不限时别',
    this.statusFilter,
    this.regionFilter,
    this.rankFilter,
    this.priceRange,
    this.positionFilter,
    this.selectedTags = const [],
    this.isLocal,
  });
  
  ServiceFilterModel copyWith({
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
}

/// 📋 订单模型
class ServiceOrderModel {
  final String id;
  final String serviceProviderId;
  final ServiceProviderModel serviceProvider;
  final ServiceType serviceType;
  final GameType? gameType;
  final int quantity;              // 服务数量（局数）
  final double unitPrice;          // 单价
  final double totalPrice;         // 总价
  final String currency;           // 货币类型
  final OrderStatus status;        // 订单状态
  final DateTime createdAt;
  final DateTime? completedAt;
  
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
  });
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
  
  const PaymentInfoModel({
    required this.orderId,
    required this.paymentMethod,
    required this.amount,
    required this.currency,
    required this.status,
    this.transactionId,
    required this.createdAt,
    this.completedAt,
  });
}

/// 💳 支付状态枚举
enum PaymentStatus {
  pending('待支付'),
  processing('支付中'),
  success('支付成功'),
  failed('支付失败'),
  cancelled('已取消');
  
  const PaymentStatus(this.displayName);
  final String displayName;
}

/// 💬 评价模型
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
  });
}

/// 📊 页面状态模型
class ServicePageState {
  final bool isLoading;
  final String? errorMessage;
  final List<ServiceProviderModel> providers;
  final ServiceFilterModel filter;
  final bool hasMoreData;
  final int currentPage;
  
  const ServicePageState({
    this.isLoading = false,
    this.errorMessage,
    this.providers = const [],
    this.filter = const ServiceFilterModel(),
    this.hasMoreData = true,
    this.currentPage = 1,
  });
  
  ServicePageState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<ServiceProviderModel>? providers,
    ServiceFilterModel? filter,
    bool? hasMoreData,
    int? currentPage,
  }) {
    return ServicePageState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      providers: providers ?? this.providers,
      filter: filter ?? this.filter,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}