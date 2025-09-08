// 🎨 服务系统通用组件 - 可复用的UI组件库
// 包含服务系统中使用的所有通用UI组件

// ============== IMPORTS ==============
import 'package:flutter/material.dart';
import '../models/service_models.dart';

// ============== 常量定义 ==============

/// 🎨 服务组件样式常量
class ServiceWidgetStyles {
  const ServiceWidgetStyles._();
  
  // 颜色
  static const int primaryPurple = 0xFF8B5CF6;
  static const int backgroundGray = 0xFFF9FAFB;
  static const int cardWhite = 0xFFFFFFFF;
  static const int textPrimary = 0xFF1F2937;
  static const int textSecondary = 0xFF6B7280;
  static const int successGreen = 0xFF10B981;
  static const int errorRed = 0xFFEF4444;
  static const int warningOrange = 0xFFF59E0B;
  static const int borderGray = 0xFFE5E7EB;
  
  // 尺寸
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;
  static const double tagBorderRadius = 16.0;
  static const double avatarSizeSmall = 32.0;
  static const double avatarSizeMedium = 48.0;
  static const double avatarSizeLarge = 80.0;
  
  // 间距
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 20.0;
  static const double spacingXxl = 24.0;
}

// ============== 基础组件 ==============

/// 📦 服务卡片容器
class ServiceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color? backgroundColor;

  const ServiceCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.onTap,
    this.isSelected = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(ServiceWidgetStyles.spacingLg),
      child: Material(
        color: backgroundColor ?? const Color(ServiceWidgetStyles.cardWhite),
        borderRadius: BorderRadius.circular(ServiceWidgetStyles.cardBorderRadius),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ServiceWidgetStyles.cardBorderRadius),
          child: Container(
            padding: padding ?? const EdgeInsets.all(ServiceWidgetStyles.spacingLg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ServiceWidgetStyles.cardBorderRadius),
              border: isSelected
                  ? Border.all(
                      color: const Color(ServiceWidgetStyles.primaryPurple),
                      width: 2,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 👤 用户头像组件
class ServiceAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final bool showOnlineStatus;
  final bool isOnline;
  final bool showVerified;
  final bool isVerified;
  final String? placeholderText;

  const ServiceAvatar({
    super.key,
    this.imageUrl,
    this.size = ServiceWidgetStyles.avatarSizeMedium,
    this.showOnlineStatus = false,
    this.isOnline = false,
    this.showVerified = false,
    this.isVerified = false,
    this.placeholderText,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 头像主体
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(size / 2),
            image: imageUrl != null
                ? DecorationImage(
                    image: NetworkImage(imageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: imageUrl == null
              ? Icon(
                  Icons.person,
                  color: Colors.white,
                  size: size * 0.6,
                )
              : null,
        ),
        
        // 在线状态指示器
        if (showOnlineStatus)
          Positioned(
            right: size * 0.05,
            bottom: size * 0.05,
            child: Container(
              width: size * 0.25,
              height: size * 0.25,
              decoration: BoxDecoration(
                color: isOnline
                    ? const Color(ServiceWidgetStyles.successGreen)
                    : Colors.grey,
                borderRadius: BorderRadius.circular(size * 0.125),
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        
        // 认证标识
        if (showVerified && isVerified)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: size * 0.3,
              height: size * 0.3,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(size * 0.15),
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: size * 0.2,
              ),
            ),
          ),
      ],
    );
  }
}

/// 🏷️ 服务标签组件
class ServiceTag extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isSelected;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;

  const ServiceTag({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.isSelected = false,
    this.onTap,
    this.padding,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = isSelected
        ? const Color(ServiceWidgetStyles.primaryPurple)
        : backgroundColor ?? const Color(ServiceWidgetStyles.backgroundGray);
    
    final effectiveTextColor = isSelected
        ? Colors.white
        : textColor ?? const Color(ServiceWidgetStyles.textPrimary);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ??
            const EdgeInsets.symmetric(
              horizontal: ServiceWidgetStyles.spacingMd,
              vertical: ServiceWidgetStyles.spacingSm,
            ),
        decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          borderRadius: BorderRadius.circular(ServiceWidgetStyles.tagBorderRadius),
          border: isSelected
              ? null
              : Border.all(color: const Color(ServiceWidgetStyles.borderGray)),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize ?? 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: effectiveTextColor,
          ),
        ),
      ),
    );
  }
}

/// ⭐ 评分显示组件
class ServiceRating extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final double starSize;
  final bool showCount;
  final MainAxisAlignment alignment;

  const ServiceRating({
    super.key,
    required this.rating,
    this.reviewCount = 0,
    this.starSize = 16.0,
    this.showCount = true,
    this.alignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 星级显示
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            return Icon(
              index < rating ? Icons.star : Icons.star_border,
              size: starSize,
              color: Colors.amber,
            );
          }),
        ),
        
        if (showCount && reviewCount > 0) ...[
          const SizedBox(width: ServiceWidgetStyles.spacingSm),
          Text(
            '($reviewCount)',
            style: TextStyle(
              fontSize: starSize * 0.75,
              color: const Color(ServiceWidgetStyles.textSecondary),
            ),
          ),
        ],
      ],
    );
  }
}

/// 💰 价格显示组件
class ServicePrice extends StatelessWidget {
  final double price;
  final String currency;
  final String? unit;
  final bool showLowestPriceTag;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;

  const ServicePrice({
    super.key,
    required this.price,
    required this.currency,
    this.unit,
    this.showLowestPriceTag = false,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.bold,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$price $currency${unit != null ? '/$unit' : ''}',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color ?? const Color(ServiceWidgetStyles.errorRed),
          ),
        ),
        
        if (showLowestPriceTag) ...[
          const SizedBox(width: ServiceWidgetStyles.spacingSm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ServiceWidgetStyles.spacingSm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: const Color(ServiceWidgetStyles.errorRed).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '最低价',
              style: TextStyle(
                fontSize: fontSize * 0.6,
                color: const Color(ServiceWidgetStyles.errorRed),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// 📊 状态指示器组件
class ServiceStatusIndicator extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final double fontSize;

  const ServiceStatusIndicator({
    super.key,
    required this.text,
    required this.backgroundColor,
    this.textColor = Colors.white,
    this.icon,
    this.fontSize = 12.0,
  });

  /// 在线状态指示器
  factory ServiceStatusIndicator.online() {
    return const ServiceStatusIndicator(
      text: '在线',
      backgroundColor: Color(ServiceWidgetStyles.successGreen),
      icon: Icons.circle,
    );
  }

  /// 离线状态指示器
  factory ServiceStatusIndicator.offline() {
    return const ServiceStatusIndicator(
      text: '离线',
      backgroundColor: Colors.grey,
      icon: Icons.circle,
    );
  }

  /// 忙碌状态指示器
  factory ServiceStatusIndicator.busy() {
    return const ServiceStatusIndicator(
      text: '忙碌',
      backgroundColor: Color(ServiceWidgetStyles.warningOrange),
      icon: Icons.circle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ServiceWidgetStyles.spacingSm,
        vertical: ServiceWidgetStyles.spacingXs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(ServiceWidgetStyles.buttonBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: fontSize,
              color: textColor,
            ),
            const SizedBox(width: ServiceWidgetStyles.spacingXs),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// 🔄 加载指示器组件
class ServiceLoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;

  const ServiceLoadingIndicator({
    super.key,
    this.message,
    this.size = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? const Color(ServiceWidgetStyles.primaryPurple),
            ),
          ),
        ),
        
        if (message != null) ...[
          const SizedBox(height: ServiceWidgetStyles.spacingMd),
          Text(
            message!,
            style: TextStyle(
              fontSize: 14,
              color: const Color(ServiceWidgetStyles.textSecondary),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// ❌ 错误显示组件
class ServiceErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;
  final double iconSize;

  const ServiceErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.iconSize = 64.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: iconSize,
          color: Colors.grey[400],
        ),
        
        const SizedBox(height: ServiceWidgetStyles.spacingLg),
        
        Text(
          message,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        
        if (onRetry != null) ...[
          const SizedBox(height: ServiceWidgetStyles.spacingLg),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(ServiceWidgetStyles.primaryPurple),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ServiceWidgetStyles.buttonBorderRadius),
              ),
            ),
            child: const Text('重试'),
          ),
        ],
      ],
    );
  }
}

/// 🔘 服务按钮组件
class ServiceButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final ServiceButtonType type;
  final double? width;
  final double height;
  final IconData? icon;

  const ServiceButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.type = ServiceButtonType.primary,
    this.width,
    this.height = 48.0,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveEnabled = isEnabled && !isLoading && onPressed != null;
    
    return SizedBox(
      width: width,
      height: height,
      child: _buildButton(effectiveEnabled),
    );
  }

  Widget _buildButton(bool effectiveEnabled) {
    switch (type) {
      case ServiceButtonType.primary:
        return ElevatedButton(
          onPressed: effectiveEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(ServiceWidgetStyles.primaryPurple),
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey[300],
            disabledForegroundColor: Colors.grey[600],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ServiceWidgetStyles.cardBorderRadius),
            ),
            elevation: 0,
          ),
          child: _buildButtonContent(),
        );
        
      case ServiceButtonType.secondary:
        return OutlinedButton(
          onPressed: effectiveEnabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: effectiveEnabled 
                  ? const Color(ServiceWidgetStyles.primaryPurple)
                  : Colors.grey,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ServiceWidgetStyles.cardBorderRadius),
            ),
          ),
          child: _buildButtonContent(
            color: effectiveEnabled 
                ? const Color(ServiceWidgetStyles.primaryPurple)
                : Colors.grey,
          ),
        );
        
      case ServiceButtonType.text:
        return TextButton(
          onPressed: effectiveEnabled ? onPressed : null,
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ServiceWidgetStyles.cardBorderRadius),
            ),
          ),
          child: _buildButtonContent(
            color: effectiveEnabled 
                ? const Color(ServiceWidgetStyles.primaryPurple)
                : Colors.grey,
          ),
        );
    }
  }

  Widget _buildButtonContent({Color? color}) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? Colors.white,
          ),
        ),
      );
    }

    final children = <Widget>[];
    
    if (icon != null) {
      children.add(Icon(icon, size: 18));
      children.add(const SizedBox(width: ServiceWidgetStyles.spacingSm));
    }
    
    children.add(
      Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}

/// 按钮类型枚举
enum ServiceButtonType {
  primary,
  secondary,
  text,
}

// ============== 复合组件 ==============

/// 👤 服务提供者卡片组件
class ServiceProviderCard extends StatelessWidget {
  final ServiceProviderModel provider;
  final VoidCallback? onTap;
  final bool showDistance;
  final bool showPrice;
  final bool showRating;

  const ServiceProviderCard({
    super.key,
    required this.provider,
    this.onTap,
    this.showDistance = true,
    this.showPrice = true,
    this.showRating = true,
  });

  @override
  Widget build(BuildContext context) {
    return ServiceCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头像
          ServiceAvatar(
            imageUrl: provider.avatar,
            size: ServiceWidgetStyles.avatarSizeMedium,
            showOnlineStatus: true,
            isOnline: provider.isOnline,
            showVerified: true,
            isVerified: provider.isVerified,
          ),
          
          const SizedBox(width: ServiceWidgetStyles.spacingMd),
          
          // 信息区域
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 姓名和状态
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        provider.nickname,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(ServiceWidgetStyles.textPrimary),
                        ),
                      ),
                    ),
                    if (provider.isOnline)
                      ServiceStatusIndicator.online(),
                  ],
                ),
                
                const SizedBox(height: ServiceWidgetStyles.spacingSm),
                
                // 标签
                if (provider.tags.isNotEmpty)
                  Wrap(
                    spacing: ServiceWidgetStyles.spacingSm,
                    children: provider.tags.take(3).map((tag) {
                      return ServiceTag(
                        text: tag,
                        fontSize: 10,
                        padding: const EdgeInsets.symmetric(
                          horizontal: ServiceWidgetStyles.spacingSm,
                          vertical: 2,
                        ),
                      );
                    }).toList(),
                  ),
                
                const SizedBox(height: ServiceWidgetStyles.spacingSm),
                
                // 描述
                Text(
                  provider.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: ServiceWidgetStyles.spacingSm),
                
                // 评分和距离
                Row(
                  children: [
                    if (showRating) ...[
                      Flexible(
                        child: ServiceRating(
                          rating: provider.rating,
                          reviewCount: provider.reviewCount,
                          starSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    
                    if (showDistance)
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                provider.distanceText,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          // 价格区域
          if (showPrice) ...[
            const SizedBox(width: ServiceWidgetStyles.spacingMd),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ServicePrice(
                  price: provider.pricePerService,
                  currency: provider.currency,
                  unit: provider.serviceUnit,
                  showLowestPriceTag: provider.pricePerService <= 10,
                  fontSize: 16,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// 📝 评价卡片组件
class ServiceReviewCard extends StatelessWidget {
  final ServiceReviewModel review;
  final bool showReply;

  const ServiceReviewCard({
    super.key,
    required this.review,
    this.showReply = true,
  });

  @override
  Widget build(BuildContext context) {
    return ServiceCard(
      margin: const EdgeInsets.symmetric(
        horizontal: ServiceWidgetStyles.spacingLg,
        vertical: ServiceWidgetStyles.spacingSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户信息和评分
          Row(
            children: [
              ServiceAvatar(
                imageUrl: review.userAvatar,
                size: ServiceWidgetStyles.avatarSizeSmall,
              ),
              
              const SizedBox(width: ServiceWidgetStyles.spacingMd),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(ServiceWidgetStyles.textPrimary),
                      ),
                    ),
                    Text(
                      review.timeText,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(ServiceWidgetStyles.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              
              // 星级评分
              ServiceRating(
                rating: review.rating,
                showCount: false,
                starSize: 16,
              ),
            ],
          ),
          
          const SizedBox(height: ServiceWidgetStyles.spacingMd),
          
          // 评价内容
          Text(
            review.content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(ServiceWidgetStyles.textPrimary),
            ),
          ),
          
          // 评价标签
          if (review.tags.isNotEmpty) ...[
            const SizedBox(height: ServiceWidgetStyles.spacingSm),
            Wrap(
              spacing: ServiceWidgetStyles.spacingSm,
              children: review.tags.map((tag) {
                return ServiceTag(
                  text: tag,
                  backgroundColor: const Color(ServiceWidgetStyles.primaryPurple).withOpacity(0.1),
                  textColor: const Color(ServiceWidgetStyles.primaryPurple),
                  fontSize: 10,
                  padding: const EdgeInsets.symmetric(
                    horizontal: ServiceWidgetStyles.spacingSm,
                    vertical: 2,
                  ),
                );
              }).toList(),
            ),
          ],
          
          // 回复内容
          if (showReply && review.reply != null) ...[
            const SizedBox(height: ServiceWidgetStyles.spacingMd),
            Container(
              padding: const EdgeInsets.all(ServiceWidgetStyles.spacingMd),
              decoration: BoxDecoration(
                color: const Color(ServiceWidgetStyles.backgroundGray),
                borderRadius: BorderRadius.circular(ServiceWidgetStyles.buttonBorderRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '服务者回复',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(ServiceWidgetStyles.textSecondary),
                    ),
                  ),
                  const SizedBox(height: ServiceWidgetStyles.spacingSm),
                  Text(
                    review.reply!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(ServiceWidgetStyles.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 📋 空状态组件
class ServiceEmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionText;

  const ServiceEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          
          const SizedBox(height: ServiceWidgetStyles.spacingLg),
          
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          
          if (subtitle != null) ...[
            const SizedBox(height: ServiceWidgetStyles.spacingSm),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
          
          if (onAction != null && actionText != null) ...[
            const SizedBox(height: ServiceWidgetStyles.spacingLg),
            ServiceButton(
              text: actionText!,
              onPressed: onAction,
              type: ServiceButtonType.secondary,
            ),
          ],
        ],
      ),
    );
  }
}

// ============== 扩展组件 ==============

/// 🔍 搜索框组件
class ServiceSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final bool readOnly;
  final VoidCallback? onTap;

  const ServiceSearchBar({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(ServiceWidgetStyles.spacingLg),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        readOnly: readOnly,
        decoration: InputDecoration(
          hintText: hintText ?? '搜索服务或服务者',
          hintStyle: const TextStyle(
            color: Color(ServiceWidgetStyles.textSecondary),
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(ServiceWidgetStyles.textSecondary),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ServiceWidgetStyles.cardBorderRadius),
            borderSide: const BorderSide(color: Color(ServiceWidgetStyles.borderGray)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ServiceWidgetStyles.cardBorderRadius),
            borderSide: const BorderSide(color: Color(ServiceWidgetStyles.primaryPurple)),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: ServiceWidgetStyles.spacingLg,
            vertical: ServiceWidgetStyles.spacingMd,
          ),
        ),
      ),
    );
  }
}

/// 🏷️ 标签选择器组件
class ServiceTagSelector extends StatelessWidget {
  final List<String> availableTags;
  final List<String> selectedTags;
  final ValueChanged<String>? onTagToggle;
  final int? maxSelection;
  final bool enabled;

  const ServiceTagSelector({
    super.key,
    required this.availableTags,
    required this.selectedTags,
    this.onTagToggle,
    this.maxSelection,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: ServiceWidgetStyles.spacingSm,
      runSpacing: ServiceWidgetStyles.spacingSm,
      children: availableTags.map((tag) {
        final isSelected = selectedTags.contains(tag);
        final canSelect = enabled && 
            (isSelected || maxSelection == null || selectedTags.length < maxSelection!);
        
        return ServiceTag(
          text: tag,
          isSelected: isSelected,
          onTap: canSelect ? () => onTagToggle?.call(tag) : null,
        );
      }).toList(),
    );
  }
}

/// 📊 统计信息组件
class ServiceStatsRow extends StatelessWidget {
  final List<ServiceStatItem> stats;

  const ServiceStatsRow({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: stats.map((stat) => _ServiceStatItemWidget(stat: stat)).toList(),
    );
  }
}

class ServiceStatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const ServiceStatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _ServiceStatItemWidget extends StatelessWidget {
  final ServiceStatItem stat;

  const _ServiceStatItemWidget({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(stat.icon, color: stat.color, size: 20),
        const SizedBox(height: ServiceWidgetStyles.spacingXs),
        Text(
          stat.value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(ServiceWidgetStyles.textPrimary),
          ),
        ),
        Text(
          stat.label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(ServiceWidgetStyles.textSecondary),
          ),
        ),
      ],
    );
  }
}
