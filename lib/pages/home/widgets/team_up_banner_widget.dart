// 🤝 组队聚会横幅组件 - 组局中心功能展示
// 从unified_home_page.dart中提取的组队横幅组件

import 'package:flutter/material.dart';

/// 🤝 组队聚会横幅组件
class TeamUpBannerWidget extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String? buttonText;
  final String? userCountText;
  final VoidCallback? onButtonTap;

  const TeamUpBannerWidget({
    super.key,
    this.title,
    this.subtitle,
    this.buttonText,
    this.userCountText,
    this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 16, 4, 12),
            child: Text(
              '组队聚会',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          
          // 组局中心卡片
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // 背景装饰
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  
                  // 左侧文字内容
                  Positioned(
                    left: 24,
                    top: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title ?? '组局中心',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle ?? '找到志同道合的伙伴',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 右上角用户数量
                  Positioned(
                    right: 20,
                    top: 20,
                    child: Text(
                      userCountText ?? '+12',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  // 底部按钮和头像
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 进入组局按钮
                        GestureDetector(
                          onTap: onButtonTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.groups, color: Color(0xFF6366F1), size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  buttonText ?? '进入组局',
                                  style: const TextStyle(
                                    color: Color(0xFF6366F1),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // 用户头像列表
                        Row(
                          children: List.generate(4, (index) {
                            return Container(
                              margin: EdgeInsets.only(left: index > 0 ? 4 : 0),
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: _getAvatarColor(index),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.person, color: Colors.white, size: 14),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 获取头像颜色
  Color _getAvatarColor(int index) {
    final colors = [Colors.red, Colors.green, Colors.blue, Colors.orange];
    return colors[index % colors.length];
  }
}
