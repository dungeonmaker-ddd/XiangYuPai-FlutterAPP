import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../config/home_config.dart';
import '../utils/home_routes.dart';
import 'svg_icon_widget.dart';

/// 🏷️ 分类网格组件
/// 显示分类图标网格，支持点击跳转
class CategoryGridWidget extends StatelessWidget {
  final List<CategoryModel> categories;
  final ValueChanged<CategoryModel>? onCategoryTap;

  const CategoryGridWidget({
    super.key,
    required this.categories,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(HomeConfig.cardBackgroundColor),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildCategoryGrid(context),
    );
  }

  /// 构建分类网格
  Widget _buildCategoryGrid(BuildContext context) {
    // 计算行数
    final rowCount = (categories.length / HomeConfig.categoryGridColumns).ceil();
    
    return Column(
      children: List.generate(rowCount, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildCategoryRow(context, rowIndex),
          ),
        );
      }),
    );
  }

  /// 构建单行分类
  List<Widget> _buildCategoryRow(BuildContext context, int rowIndex) {
    final startIndex = rowIndex * HomeConfig.categoryGridColumns;
    final endIndex = (startIndex + HomeConfig.categoryGridColumns).clamp(0, categories.length);
    
    final rowCategories = categories.sublist(startIndex, endIndex);
    final List<Widget> rowWidgets = [];

    // 添加实际的分类项
    for (final category in rowCategories) {
      rowWidgets.add(_buildCategoryItem(context, category));
    }

    // 如果不足一行，用空白填充保持对齐
    final remaining = HomeConfig.categoryGridColumns - rowCategories.length;
    for (int i = 0; i < remaining; i++) {
      rowWidgets.add(SizedBox(
        width: HomeConfig.categoryItemHeight,
        height: HomeConfig.categoryItemHeight,
      ));
    }

    return rowWidgets;
  }

  /// 构建单个分类项
  Widget _buildCategoryItem(BuildContext context, CategoryModel category) {
    return GestureDetector(
      onTap: () {
        onCategoryTap?.call(category);
        HomeRoutes.toCategoryPage(context, category.categoryId);
      },
      child: Container(
        width: HomeConfig.categoryItemHeight,
        height: HomeConfig.categoryItemHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SVG图标背景圆圈
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(category.color).withValues(alpha: 0.8),
                    Color(category.color).withValues(alpha: 0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Color(category.color).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: CategoryIcons.buildIcon(
                  category.name,
                  size: 28,
                  color: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // 分类名称
            Text(
              category.name,
              style: TextStyle(
                fontSize: 12,
                color: Color(HomeConfig.textPrimaryColor),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
