// 🔝 顶部导航区域组件 - 位置选择和搜索功能
// 从unified_home_page.dart中提取的顶部导航组件

import 'package:flutter/material.dart';
import '../home_models.dart';
import '../search/index.dart';

/// 🔝 顶部导航区域组件（渐变紫色背景）
class TopNavigationWidget extends StatefulWidget {
  final String? currentLocation;
  final VoidCallback? onLocationTap;
  final ValueChanged<String>? onSearchSubmitted;

  const TopNavigationWidget({
    super.key,
    this.currentLocation,
    this.onLocationTap,
    this.onSearchSubmitted,
  });

  @override
  State<TopNavigationWidget> createState() => _TopNavigationWidgetState();
}

class _TopNavigationWidgetState extends State<TopNavigationWidget> {

  @override
  Widget build(BuildContext context) {
    return Container(
      // 渐变紫色背景 #8B5CF6 → #A855F7
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: [
                  // 位置和搜索栏（2:8比例布局）
                  Row(
                    children: [
                      // 左侧位置显示（2份）
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: widget.onLocationTap,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  widget.currentLocation ?? HomeConstants.defaultLocationText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // 右侧搜索框（8份）
                      Expanded(
                        flex: 8,
                        child: GestureDetector(
                          onTap: () => _navigateToSearchPage(context),
                          child: Container(
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.search,
                                  color: Color(0xFF9CA3AF),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '搜索词',
                                    style: const TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // 搜索功能已移至专用搜索页面
          ],
        ),
      ),
    );
  }

  /// 跳转到搜索页面
  void _navigateToSearchPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SearchEntryPage(),
      ),
    );
  }
}
