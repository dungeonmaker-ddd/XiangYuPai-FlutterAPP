/// 🏷️ 分类数据模型
/// 首页分类相关的数据结构

class CategoryModel {
  /// 分类ID
  final String categoryId;
  
  /// 分类名称
  final String name;
  
  /// 分类图标（emoji或图片URL）
  final String icon;
  
  /// 分类颜色
  final int color;
  
  /// 排序权重
  final int sortOrder;
  
  /// 是否启用
  final bool isEnabled;
  
  /// 描述
  final String? description;

  const CategoryModel({
    required this.categoryId,
    required this.name,
    required this.icon,
    required this.color,
    this.sortOrder = 0,
    this.isEnabled = true,
    this.description,
  });

  /// 工厂方法：从JSON创建
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId: json['category_id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as int,
      sortOrder: json['sort_order'] as int? ?? 0,
      isEnabled: json['is_enabled'] as bool? ?? true,
      description: json['description'] as String?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'name': name,
      'icon': icon,
      'color': color,
      'sort_order': sortOrder,
      'is_enabled': isEnabled,
      'description': description,
    };
  }

  /// 复制并修改部分属性
  CategoryModel copyWith({
    String? categoryId,
    String? name,
    String? icon,
    int? color,
    int? sortOrder,
    bool? isEnabled,
    String? description,
  }) {
    return CategoryModel(
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      isEnabled: isEnabled ?? this.isEnabled,
      description: description ?? this.description,
    );
  }

  @override
  String toString() => 'CategoryModel(categoryId: $categoryId, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModel &&
          runtimeType == other.runtimeType &&
          categoryId == other.categoryId;

  @override
  int get hashCode => categoryId.hashCode;
}

/// 🏪 分类数据源
class CategoryData {
  /// 预定义分类列表
  static const List<CategoryModel> categories = [
    CategoryModel(
      categoryId: 'wangzhe',
      name: '王者荣耀',
      icon: '👑',
      color: 0xFFFF6B35,
      sortOrder: 1,
    ),
    CategoryModel(
      categoryId: 'lol',
      name: '英雄联盟',
      icon: '⚔️',
      color: 0xFF4A90E2,
      sortOrder: 2,
    ),
    CategoryModel(
      categoryId: 'heping',
      name: '和平精英',
      icon: '🎯',
      color: 0xFF50C878,
      sortOrder: 3,
    ),
    CategoryModel(
      categoryId: 'huangye',
      name: '荒野乱斗',
      icon: '💥',
      color: 0xFFFFD700,
      sortOrder: 4,
    ),
    CategoryModel(
      categoryId: 'tandian',
      name: '探店',
      icon: '🏪',
      color: 0xFF9C27B0,
      sortOrder: 5,
    ),
    CategoryModel(
      categoryId: 'siying',
      name: '私影',
      icon: '📸',
      color: 0xFFE91E63,
      sortOrder: 6,
    ),
    CategoryModel(
      categoryId: 'taiqiu',
      name: '台球',
      icon: '🎱',
      color: 0xFF2E7D32,
      sortOrder: 7,
    ),
    CategoryModel(
      categoryId: 'kge',
      name: 'K歌',
      icon: '🎤',
      color: 0xFFFF5722,
      sortOrder: 8,
    ),
    CategoryModel(
      categoryId: 'hejiu',
      name: '喝酒',
      icon: '🍻',
      color: 0xFFFFC107,
      sortOrder: 9,
    ),
    CategoryModel(
      categoryId: 'anmo',
      name: '按摩',
      icon: '💆',
      color: 0xFF795548,
      sortOrder: 10,
    ),
  ];

  /// 获取所有启用的分类
  static List<CategoryModel> getEnabledCategories() {
    return categories.where((category) => category.isEnabled).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  /// 根据ID查找分类
  static CategoryModel? findById(String categoryId) {
    try {
      return categories.firstWhere((category) => category.categoryId == categoryId);
    } catch (e) {
      return null;
    }
  }

  /// 搜索分类
  static List<CategoryModel> searchCategories(String query) {
    if (query.isEmpty) return getEnabledCategories();
    
    final lowerQuery = query.toLowerCase();
    return getEnabledCategories().where((category) {
      return category.name.toLowerCase().contains(lowerQuery) ||
             category.description?.toLowerCase().contains(lowerQuery) == true;
    }).toList();
  }
}
