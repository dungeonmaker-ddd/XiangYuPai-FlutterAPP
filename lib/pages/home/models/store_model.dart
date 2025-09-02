/// 🏪 店铺数据模型
/// 首页店铺推荐相关的数据结构

class StoreModel {
  /// 店铺ID
  final String storeId;
  
  /// 店铺名称
  final String name;
  
  /// 店铺头像/封面
  final String? coverUrl;
  
  /// 店铺描述
  final String? description;
  
  /// 所属分类
  final String categoryId;
  
  /// 位置信息
  final String? location;
  
  /// 距离（米）
  final double? distance;
  
  /// 评分 (1-5)
  final double rating;
  
  /// 评价数量
  final int reviewCount;
  
  /// 价格等级 (1-5, $越多越贵)
  final int priceLevel;
  
  /// 是否营业
  final bool isOpen;
  
  /// 营业时间
  final String? businessHours;
  
  /// 标签
  final List<String> tags;
  
  /// 特色服务
  final List<String> features;
  
  /// 创建时间
  final DateTime createdAt;
  
  /// 是否推荐
  final bool isRecommended;

  const StoreModel({
    required this.storeId,
    required this.name,
    this.coverUrl,
    this.description,
    required this.categoryId,
    this.location,
    this.distance,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.priceLevel = 1,
    this.isOpen = true,
    this.businessHours,
    this.tags = const [],
    this.features = const [],
    required this.createdAt,
    this.isRecommended = false,
  });

  /// 工厂方法：从JSON创建
  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      storeId: json['store_id'] as String,
      name: json['name'] as String,
      coverUrl: json['cover_url'] as String?,
      description: json['description'] as String?,
      categoryId: json['category_id'] as String,
      location: json['location'] as String?,
      distance: (json['distance'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      priceLevel: json['price_level'] as int? ?? 1,
      isOpen: json['is_open'] as bool? ?? true,
      businessHours: json['business_hours'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      features: (json['features'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['created_at'] as String),
      isRecommended: json['is_recommended'] as bool? ?? false,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'store_id': storeId,
      'name': name,
      'cover_url': coverUrl,
      'description': description,
      'category_id': categoryId,
      'location': location,
      'distance': distance,
      'rating': rating,
      'review_count': reviewCount,
      'price_level': priceLevel,
      'is_open': isOpen,
      'business_hours': businessHours,
      'tags': tags,
      'features': features,
      'created_at': createdAt.toIso8601String(),
      'is_recommended': isRecommended,
    };
  }

  /// 获取距离文本
  String get distanceText {
    if (distance == null) return '';
    
    if (distance! < 1000) {
      return '${distance!.toInt()}m';
    } else {
      return '${(distance! / 1000).toStringAsFixed(1)}km';
    }
  }

  /// 获取价格等级文本
  String get priceLevelText {
    return '\$' * priceLevel;
  }

  /// 获取评分文本
  String get ratingText {
    if (rating <= 0) return '暂无评分';
    return rating.toStringAsFixed(1);
  }

  /// 获取营业状态文本
  String get businessStatusText {
    return isOpen ? '营业中' : '已打烊';
  }

  /// 复制并修改部分属性
  StoreModel copyWith({
    String? storeId,
    String? name,
    String? coverUrl,
    String? description,
    String? categoryId,
    String? location,
    double? distance,
    double? rating,
    int? reviewCount,
    int? priceLevel,
    bool? isOpen,
    String? businessHours,
    List<String>? tags,
    List<String>? features,
    DateTime? createdAt,
    bool? isRecommended,
  }) {
    return StoreModel(
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      coverUrl: coverUrl ?? this.coverUrl,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      location: location ?? this.location,
      distance: distance ?? this.distance,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      priceLevel: priceLevel ?? this.priceLevel,
      isOpen: isOpen ?? this.isOpen,
      businessHours: businessHours ?? this.businessHours,
      tags: tags ?? this.tags,
      features: features ?? this.features,
      createdAt: createdAt ?? this.createdAt,
      isRecommended: isRecommended ?? this.isRecommended,
    );
  }

  @override
  String toString() => 'StoreModel(storeId: $storeId, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoreModel &&
          runtimeType == other.runtimeType &&
          storeId == other.storeId;

  @override
  int get hashCode => storeId.hashCode;
}
