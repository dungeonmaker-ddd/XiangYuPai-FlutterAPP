/// 🎨 分类图标组件
/// 用于显示分类的图标（暂时使用emoji和Material Icons）
library svg_icon_widget;

import 'package:flutter/material.dart';

class SvgIconWidget extends StatelessWidget {
  final String categoryName;
  final double? size;
  final Color? color;

  const SvgIconWidget({
    super.key,
    required this.categoryName,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = CategoryIcons.getIconData(categoryName);
    final finalSize = size ?? 24;
    
    return Icon(
      iconData,
      size: finalSize,
      color: color ?? Colors.white,
    );
  }
}

/// 🎯 分类图标映射
class CategoryIcons {
  static const Map<String, IconData> iconMappings = {
    '王者荣耀': Icons.sports_esports,
    '英雄联盟': Icons.videogame_asset,
    '和平精英': Icons.gps_fixed,
    '荒野乱斗': Icons.whatshot,
    '探店': Icons.store,
    '私影': Icons.photo_camera,
    '台球': Icons.sports_tennis,
    'K歌': Icons.mic,
    '喝酒': Icons.local_bar,
    '按摩': Icons.spa,
  };
  
  /// 获取分类对应的图标数据
  static IconData getIconData(String categoryName) {
    return iconMappings[categoryName] ?? Icons.store;
  }
  
  /// 构建图标组件
  static Widget buildIcon(String categoryName, {
    double size = 32,
    Color? color,
  }) {
    return SvgIconWidget(
      categoryName: categoryName,
      size: size,
      color: color,
    );
  }
}
