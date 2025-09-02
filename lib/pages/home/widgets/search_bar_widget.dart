import 'package:flutter/material.dart';
import '../config/home_config.dart';
import '../utils/home_routes.dart';

/// 🔍 搜索栏组件
/// 提供搜索功能和位置选择
class SearchBarWidget extends StatelessWidget {
  final String? currentLocation;
  final VoidCallback? onLocationTap;
  final ValueChanged<String>? onSearchSubmitted;
  final String? searchHint;

  const SearchBarWidget({
    super.key,
    this.currentLocation,
    this.onLocationTap,
    this.onSearchSubmitted,
    this.searchHint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(HomeConfig.gradientStartColor),
            Color(HomeConfig.gradientEndColor),
          ],
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 位置选择按钮
            _buildLocationButton(context),
            
            const SizedBox(width: 12),
            
            // 搜索输入框
            Expanded(
              child: _buildSearchInput(context),
            ),
          ],
        ),
      ),
    );
  }

  /// 📍 位置选择按钮
  Widget _buildLocationButton(BuildContext context) {
    return GestureDetector(
      onTap: onLocationTap ?? () async {
        final result = await HomeRoutes.toLocationPickerPage(context);
        if (result != null) {
          // 这里可以通过回调通知父组件位置已更改
          // onLocationChanged?.call(result);
        }
      },
      child: Container(
        height: HomeConfig.locationButtonHeight,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_on,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              currentLocation ?? HomeConfig.defaultLocationText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  /// 🔍 搜索输入框
  Widget _buildSearchInput(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Color(HomeConfig.searchBarColor),
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextField(
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            onSearchSubmitted?.call(value.trim());
            HomeRoutes.toSearchPage(context, keyword: value.trim());
          }
        },
        decoration: InputDecoration(
          hintText: searchHint ?? HomeConfig.defaultSearchHint,
          hintStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[600],
            size: 20,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }
}
