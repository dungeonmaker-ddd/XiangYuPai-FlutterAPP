// 🔄 加载状态组件 - 通用加载状态展示组件
// 从unified_home_page.dart中提取的加载状态组件

import 'package:flutter/material.dart';
import '../../home_models.dart';

/// 🔄 加载状态组件集合
class LoadingStates {
  /// 构建加载视图
  static Widget buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(HomeConstants.primaryPurple)),
      ),
    );
  }

  /// 构建错误视图
  static Widget buildErrorView(String errorMessage, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(errorMessage, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(HomeConstants.primaryPurple),
              foregroundColor: Colors.white,
            ),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  /// 构建空状态视图
  static Widget buildEmptyView({
    String? title,
    String? subtitle,
    IconData? icon,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.inbox_outlined, 
            size: 64, 
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title ?? '暂无数据',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(HomeConstants.primaryPurple),
                foregroundColor: Colors.white,
              ),
              child: const Text('重新加载'),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建列表底部加载更多指示器
  static Widget buildLoadMoreIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(HomeConstants.primaryPurple)),
        ),
      ),
    );
  }

  /// 构建列表底部没有更多数据提示
  static Widget buildNoMoreDataIndicator() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          '没有更多数据了',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
