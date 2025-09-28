// 📍 附近标签组件 - 附近/推荐/最新标签和筛选功能
// 从unified_home_page.dart中提取的附近标签组件

import 'package:flutter/material.dart';
import '../home_models.dart';

/// 📍 附近标签组件
class NearbyTabsWidget extends StatelessWidget {
  final HomeState state;
  final ValueChanged<String>? onTabChanged;
  final VoidCallback? onLocationFilter;
  final VoidCallback? onMoreFilters;
  final VoidCallback? onClearFilters;

  const NearbyTabsWidget({
    super.key,
    required this.state,
    this.onTabChanged,
    this.onLocationFilter,
    this.onMoreFilters,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(HomeConstants.cardBorderRadius),
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
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabItem('附近', isSelected: state.selectedTab == '附近', onTap: () => onTabChanged?.call('附近')),
                _buildTabItem('推荐', isSelected: state.selectedTab == '推荐', onTap: () => onTabChanged?.call('推荐')),
                _buildTabItem('最新', isSelected: state.selectedTab == '最新', onTap: () => onTabChanged?.call('最新')),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 清除筛选按钮（仅在有筛选条件时显示）
                if (state.selectedRegion != null || state.activeFilters?.isNotEmpty == true)
                  GestureDetector(
                    onTap: onClearFilters,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red[300]!, width: 1),
                      ),
                      child: Icon(
                        Icons.clear,
                        size: 12,
                        color: Colors.red[600],
                      ),
                    ),
                  ),
                if (state.selectedRegion != null || state.activeFilters?.isNotEmpty == true)
                  const SizedBox(width: 4),
                Flexible(
                  child: _buildDropdownFilter(
                    state.selectedRegion ?? '区域',
                    Icons.location_on,
                    onTap: onLocationFilter,
                    isActive: state.selectedRegion != null,
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: _buildDropdownFilter(
                    state.activeFilters?.isNotEmpty == true ? '筛选(${state.activeFilters!.length})' : '筛选',
                    Icons.filter_list,
                    onTap: onMoreFilters,
                    isActive: state.activeFilters?.isNotEmpty == true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建标签项
  Widget _buildTabItem(String text, {required bool isSelected, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(HomeConstants.primaryPurple) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// 构建下拉筛选器
  Widget _buildDropdownFilter(String text, IconData icon, {VoidCallback? onTap, bool isActive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF8B5CF6).withValues(alpha: 0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: isActive ? Border.all(color: const Color(0xFF8B5CF6), width: 1) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: isActive ? const Color(0xFF8B5CF6) : Colors.grey[600],
            ),
            const SizedBox(width: 2),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  color: isActive ? const Color(0xFF8B5CF6) : Colors.grey[600],
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 1),
            Icon(
              Icons.keyboard_arrow_down,
              size: 12,
              color: isActive ? const Color(0xFF8B5CF6) : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }
}
