// 🔍 搜索模块UI组件 - 单文件架构完整实现
// 基于Flutter单文件架构规范的8段式结构设计

// ============== 1. IMPORTS ==============
// Flutter核心库
import 'package:flutter/material.dart';

// Dart核心库
import 'dart:math' as math;

// 项目内部文件
import '../models/search_models.dart';

// ============== 2. CONSTANTS ==============
/// 🎨 搜索组件私有常量
class _SearchWidgetConstants {
  const _SearchWidgetConstants._();
  
  // 卡片配置
  static const double contentCardMinHeight = 150.0;
  static const double contentCardMaxHeight = 300.0;
  static const double userCardHeight = 80.0;
  static const double orderCardHeight = 120.0;
  static const double topicCardHeight = 80.0;
  
  // 动画配置
  static const Duration hoverAnimationDuration = Duration(milliseconds: 150);
  static const Duration loadingAnimationDuration = Duration(milliseconds: 800);
  
  // 颜色配置
  static const Color shimmerBaseColor = Color(0xFFE0E0E0);
  static const Color shimmerHighlightColor = Color(0xFFF5F5F5);
}

// ============== 3. MODELS ==============
// 模型引用自 search_models.dart

// ============== 4. SERVICES ==============
// 服务引用自 search_services.dart

// ============== 5. CONTROLLERS ==============
// 控制器在各页面文件中定义

// ============== 6. WIDGETS ==============
/// 🖼️ 搜索内容卡片组件（瀑布流用）
/// 
/// 功能：展示图片/视频内容的搜索结果
/// 特性：自适应高度、悬停效果、关键词高亮
class SearchContentCard extends StatefulWidget {
  final SearchContentItem item;
  final String searchKeyword;
  final VoidCallback? onTap;
  final Function(String)? onAuthorTap;
  final Function(String)? onLike;
  
  const SearchContentCard({
    super.key,
    required this.item,
    this.searchKeyword = '',
    this.onTap,
    this.onAuthorTap,
    this.onLike,
  });

  @override
  State<SearchContentCard> createState() => _SearchContentCardState();
}

class _SearchContentCardState extends State<SearchContentCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: _SearchWidgetConstants.hoverAnimationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => _setHovered(true),
        onExit: (_) => _setHovered(false),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                margin: const EdgeInsets.all(4),
                height: _SearchWidgetConstants.contentCardMaxHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(SearchConstants.cardBorderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(_isHovered ? 0.15 : 0.08),
                      blurRadius: _isHovered ? 12 : 8,
                      offset: Offset(0, _isHovered ? 4 : 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 主图片/视频区域
                    Flexible(
                      flex: 3,
                      child: _buildMediaSection(),
                    ),
                    
                    // 内容信息区域
                    Flexible(
                      flex: 2,
                      child: _buildContentSection(),
                    ),
                    
                    // 底部用户信息区域
                    _buildAuthorSection(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _setHovered(bool hovered) {
    if (_isHovered != hovered) {
      setState(() => _isHovered = hovered);
      if (hovered) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  Widget _buildMediaSection() {
    final hasMedia = widget.item.images.isNotEmpty || widget.item.videoUrl != null;
    final aspectRatio = _calculateAspectRatio();
    
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(SearchConstants.cardBorderRadius),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 背景图片
            if (hasMedia)
              Image.network(
                widget.item.images.isNotEmpty 
                    ? widget.item.images.first 
                    : widget.item.videoThumbnail!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildImagePlaceholder();
                },
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder();
                },
              )
            else
              _buildImagePlaceholder(),
            
            // 视频播放标识
            if (widget.item.type == ContentType.video)
              const Center(
                child: Icon(
                  Icons.play_circle_filled,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            
            // 多图标识
            if (widget.item.images.length > 1)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '1/${widget.item.images.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题/内容
          _buildHighlightedText(
            widget.item.title.isNotEmpty ? widget.item.title : widget.item.content,
            maxLines: 3,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 互动数据
          Row(
            children: [
              Icon(Icons.favorite_border, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 2),
              Text(
                _formatCount(widget.item.likeCount),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(width: 12),
              Icon(Icons.comment_outlined, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 2),
              Text(
                _formatCount(widget.item.commentCount),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorSection() {
    return GestureDetector(
      onTap: () => widget.onAuthorTap?.call(widget.item.authorId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(SearchConstants.cardBorderRadius),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundImage: NetworkImage(widget.item.authorAvatar),
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.item.authorName,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              _formatTime(widget.item.createdAt),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          widget.item.type == ContentType.video 
              ? Icons.videocam_outlined 
              : Icons.image_outlined,
          size: 40,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildHighlightedText(
    String text, {
    int maxLines = 1,
    TextStyle? style,
  }) {
    if (widget.searchKeyword.isEmpty) {
      return Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }

    final spans = <TextSpan>[];
    final pattern = RegExp(widget.searchKeyword, caseSensitive: false);
    final matches = pattern.allMatches(text);
    
    int lastMatchEnd = 0;
    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: style,
        ));
      }
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: style?.copyWith(
          color: const Color(SearchConstants.primaryColor),
          fontWeight: FontWeight.bold,
        ),
      ));
      lastMatchEnd = match.end;
    }
    
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: style,
      ));
    }

    return RichText(
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(children: spans),
    );
  }

  double _calculateAspectRatio() {
    // 根据内容类型和随机因子生成不同的宽高比，模拟真实的瀑布流效果
    final random = math.Random(widget.item.id.hashCode);
    final baseRatio = widget.item.type == ContentType.video ? 16/9 : 3/4;
    final variance = 0.2 + random.nextDouble() * 0.6; // 0.2-0.8的变化范围
    return baseRatio * variance;
  }

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 10000) return '${(count / 1000).toStringAsFixed(1)}k';
    return '${(count / 10000).toStringAsFixed(1)}w';
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${time.month}月${time.day}日';
  }
}

/// 👤 搜索用户卡片组件
/// 
/// 功能：展示用户信息的搜索结果
/// 特性：状态指示、标签展示、距离显示
class SearchUserCard extends StatelessWidget {
  final SearchUserItem user;
  final String searchKeyword;
  final VoidCallback? onTap;
  final VoidCallback? onFollow;
  
  const SearchUserCard({
    super.key,
    required this.user,
    this.searchKeyword = '',
    this.onTap,
    this.onFollow,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: _SearchWidgetConstants.userCardHeight,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SearchConstants.cardBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 用户头像
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(user.avatar),
                  backgroundColor: Colors.grey[300],
                ),
                // 在线状态指示器
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: user.isOnline ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(width: 12),
            
            // 用户信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 昵称和认证标识
                  Row(
                    children: [
                      Flexible(
                        child: _buildHighlightedText(
                          user.nickname,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (user.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, size: 16, color: Colors.blue),
                      ],
                      const SizedBox(width: 8),
                      Text(
                        '${user.age}岁',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // 个人简介
                  if (user.bio != null)
                    _buildHighlightedText(
                      user.bio!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            
            // 右侧信息
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 距离信息
                if (user.distance != null)
                  Text(
                    user.distanceText,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                
                const SizedBox(height: 8),
                
                // 关注按钮
                SizedBox(
                  height: 24,
                  child: ElevatedButton(
                    onPressed: onFollow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(SearchConstants.primaryColor),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      minimumSize: const Size(60, 24),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    child: const Text('关注'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedText(String text, {TextStyle? style}) {
    if (searchKeyword.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final spans = <TextSpan>[];
    final pattern = RegExp(searchKeyword, caseSensitive: false);
    final matches = pattern.allMatches(text);
    
    int lastMatchEnd = 0;
    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: style,
        ));
      }
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: style?.copyWith(
          color: const Color(SearchConstants.primaryColor),
          fontWeight: FontWeight.bold,
        ),
      ));
      lastMatchEnd = match.end;
    }
    
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: style,
      ));
    }

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(children: spans),
    );
  }
}

/// 📋 搜索订单卡片组件
/// 
/// 功能：展示服务订单的搜索结果
/// 特性：价格突出、评分显示、状态标识
class SearchOrderCard extends StatelessWidget {
  final SearchOrderItem order;
  final String searchKeyword;
  final VoidCallback? onTap;
  final VoidCallback? onOrder;
  
  const SearchOrderCard({
    super.key,
    required this.order,
    this.searchKeyword = '',
    this.onTap,
    this.onOrder,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SearchConstants.cardBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 服务提供者信息
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(order.providerAvatar),
                  backgroundColor: Colors.grey[300],
                ),
                
                const SizedBox(width: 12),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.providerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 12, color: Colors.grey[600]),
                          const SizedBox(width: 2),
                          Text(
                            order.location,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // 价格
                Text(
                  order.priceText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // 服务标题
            _buildHighlightedText(
              order.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 4),
            
            // 服务描述
            _buildHighlightedText(
              order.description,
              maxLines: 2,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.3,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // 底部信息
            Row(
              children: [
                // 评分
                Icon(Icons.star, size: 14, color: Colors.amber[600]),
                const SizedBox(width: 2),
                Text(
                  order.ratingText,
                  style: const TextStyle(fontSize: 12),
                ),
                
                const SizedBox(width: 8),
                
                Text(
                  '${order.reviewCount}评价',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                
                const Spacer(),
                
                // 状态标识
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    order.status.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // 下单按钮
                SizedBox(
                  height: 28,
                  child: ElevatedButton(
                    onPressed: order.status == OrderStatus.available ? onOrder : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(SearchConstants.primaryColor),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      minimumSize: const Size(60, 28),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    child: const Text('下单'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedText(
    String text, {
    int maxLines = 1,
    TextStyle? style,
  }) {
    if (searchKeyword.isEmpty) {
      return Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }

    final spans = <TextSpan>[];
    final pattern = RegExp(searchKeyword, caseSensitive: false);
    final matches = pattern.allMatches(text);
    
    int lastMatchEnd = 0;
    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: style,
        ));
      }
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: style?.copyWith(
          color: const Color(SearchConstants.primaryColor),
          fontWeight: FontWeight.bold,
        ),
      ));
      lastMatchEnd = match.end;
    }
    
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: style,
      ));
    }

    return RichText(
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(children: spans),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.available:
        return Colors.green;
      case OrderStatus.busy:
        return Colors.orange;
      case OrderStatus.offline:
        return Colors.grey;
    }
  }
}

/// 🏷️ 搜索话题卡片组件
/// 
/// 功能：展示话题信息的搜索结果
/// 特性：热度显示、成员数量、关注状态
class SearchTopicCard extends StatelessWidget {
  final SearchTopicItem topic;
  final String searchKeyword;
  final VoidCallback? onTap;
  final VoidCallback? onFollow;
  
  const SearchTopicCard({
    super.key,
    required this.topic,
    this.searchKeyword = '',
    this.onTap,
    this.onFollow,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: _SearchWidgetConstants.topicCardHeight,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SearchConstants.cardBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 话题图标
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: topic.icon != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        topic.icon!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.topic, color: Colors.grey[400]);
                        },
                      ),
                    )
                  : Icon(Icons.topic, color: Colors.grey[400]),
            ),
            
            const SizedBox(width: 12),
            
            // 话题信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 话题名称和标识
                  Row(
                    children: [
                      Flexible(
                        child: _buildHighlightedText(
                          topic.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (topic.isOfficial) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: const Text(
                            '官方',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // 话题描述
                  _buildHighlightedText(
                    topic.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // 右侧信息
            SizedBox(
              width: 60,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 成员数量和热度
                  Text(
                    topic.memberCountText,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 1),
                  
                  Text(
                    topic.hotIndexText,
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey[500],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // 关注按钮
                  SizedBox(
                    height: 20,
                    width: 48,
                    child: ElevatedButton(
                      onPressed: onFollow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: topic.isFollowing 
                            ? Colors.grey[400] 
                            : const Color(SearchConstants.primaryColor),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: const TextStyle(fontSize: 10),
                      ),
                      child: Text(topic.isFollowing ? '已关注' : '关注'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedText(String text, {TextStyle? style}) {
    if (searchKeyword.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final spans = <TextSpan>[];
    final pattern = RegExp(searchKeyword, caseSensitive: false);
    final matches = pattern.allMatches(text);
    
    int lastMatchEnd = 0;
    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: style,
        ));
      }
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: style?.copyWith(
          color: const Color(SearchConstants.primaryColor),
          fontWeight: FontWeight.bold,
        ),
      ));
      lastMatchEnd = match.end;
    }
    
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: style,
      ));
    }

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(children: spans),
    );
  }
}

/// 🔄 加载骨架屏组件
/// 
/// 功能：在数据加载时显示占位动画
/// 特性：闪烁动画、多种布局支持
class SearchLoadingSkeleton extends StatefulWidget {
  final SearchType type;
  final int itemCount;
  
  const SearchLoadingSkeleton({
    super.key,
    required this.type,
    this.itemCount = 3,
  });

  @override
  State<SearchLoadingSkeleton> createState() => _SearchLoadingSkeletonState();
}

class _SearchLoadingSkeletonState extends State<SearchLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: _SearchWidgetConstants.loadingAnimationDuration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: _buildSkeletonLayout(),
        );
      },
    );
  }

  Widget _buildSkeletonLayout() {
    switch (widget.type) {
      case SearchType.all:
        return _buildContentSkeleton();
      case SearchType.user:
        return _buildUserSkeleton();
      case SearchType.order:
        return _buildOrderSkeleton();
      case SearchType.topic:
        return _buildTopicSkeleton();
    }
  }

  Widget _buildContentSkeleton() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _SearchWidgetConstants.shimmerBaseColor,
            borderRadius: BorderRadius.circular(SearchConstants.cardBorderRadius),
          ),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: _SearchWidgetConstants.shimmerHighlightColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(SearchConstants.cardBorderRadius),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Container(
                        height: 12,
                        color: _SearchWidgetConstants.shimmerHighlightColor,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 8,
                        width: double.infinity * 0.7,
                        color: _SearchWidgetConstants.shimmerHighlightColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserSkeleton() {
    return Column(
      children: List.generate(widget.itemCount, (index) {
        return Container(
          height: _SearchWidgetConstants.userCardHeight,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _SearchWidgetConstants.shimmerBaseColor,
            borderRadius: BorderRadius.circular(SearchConstants.cardBorderRadius),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: _SearchWidgetConstants.shimmerHighlightColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: double.infinity * 0.6,
                      color: _SearchWidgetConstants.shimmerHighlightColor,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: double.infinity * 0.8,
                      color: _SearchWidgetConstants.shimmerHighlightColor,
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 24,
                decoration: BoxDecoration(
                  color: _SearchWidgetConstants.shimmerHighlightColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildOrderSkeleton() {
    return Column(
      children: List.generate(widget.itemCount, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _SearchWidgetConstants.shimmerBaseColor,
            borderRadius: BorderRadius.circular(SearchConstants.cardBorderRadius),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: _SearchWidgetConstants.shimmerHighlightColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16,
                          width: double.infinity * 0.5,
                          color: _SearchWidgetConstants.shimmerHighlightColor,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 12,
                          width: double.infinity * 0.3,
                          color: _SearchWidgetConstants.shimmerHighlightColor,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 20,
                    width: 60,
                    color: _SearchWidgetConstants.shimmerHighlightColor,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 14,
                width: double.infinity,
                color: _SearchWidgetConstants.shimmerHighlightColor,
              ),
              const SizedBox(height: 8),
              Container(
                height: 12,
                width: double.infinity * 0.8,
                color: _SearchWidgetConstants.shimmerHighlightColor,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTopicSkeleton() {
    return Column(
      children: List.generate(widget.itemCount, (index) {
        return Container(
          height: _SearchWidgetConstants.topicCardHeight,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _SearchWidgetConstants.shimmerBaseColor,
            borderRadius: BorderRadius.circular(SearchConstants.cardBorderRadius),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _SearchWidgetConstants.shimmerHighlightColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: double.infinity * 0.6,
                      color: _SearchWidgetConstants.shimmerHighlightColor,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: double.infinity * 0.8,
                      color: _SearchWidgetConstants.shimmerHighlightColor,
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 24,
                decoration: BoxDecoration(
                  color: _SearchWidgetConstants.shimmerHighlightColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ============== 7. PAGES ==============
// 页面在 pages 文件夹中定义

// ============== 8. EXPORTS ==============
/// 📤 导出定义
/// 
/// 本文件自动导出的公共类：
/// - SearchContentCard: 搜索内容卡片组件
/// - SearchUserCard: 搜索用户卡片组件
/// - SearchOrderCard: 搜索订单卡片组件
/// - SearchTopicCard: 搜索话题卡片组件
/// - SearchLoadingSkeleton: 加载骨架屏组件
///
/// 私有类（不会被导出）：
/// - _SearchWidgetConstants: 组件私有常量
/// - _SearchContentCardState: 内容卡片状态类
/// - _SearchLoadingSkeletonState: 骨架屏状态类
///
/// 使用方式：
/// ```dart
/// import 'search_widgets.dart';
/// 
/// // 使用内容卡片
/// SearchContentCard(
///   item: contentItem,
///   searchKeyword: 'keyword',
///   onTap: () => {},
/// )
/// ```
