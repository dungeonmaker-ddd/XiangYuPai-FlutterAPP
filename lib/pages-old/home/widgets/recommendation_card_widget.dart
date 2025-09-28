// 💝 推荐卡片组件 - 限时专享用户推荐展示
// 从unified_home_page.dart中提取的推荐卡片组件

import 'package:flutter/material.dart';
import '../home_models.dart';
import 'common/countdown_widget.dart';

/// 💝 推荐卡片组件
class RecommendationCardWidget extends StatelessWidget {
  final List<HomeUserModel> users;
  final String title;
  final DateTime? promoEndTime;
  final ValueChanged<HomeUserModel>? onUserTap;

  const RecommendationCardWidget({
    super.key,
    required this.users,
    required this.title,
    this.promoEndTime,
    this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题和标签
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8A65),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '优质陪玩',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                const Text(
                  '更多',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                  size: 16,
                ),
              ],
            ),
          ),

          // 用户列表
          SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(0, 12, 16, 12),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return GestureDetector(
                  onTap: () => onUserTap?.call(user),
                  child: Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 三级父容器结构 - 垂直布局
                        // 第一级：最外层容器
                        Container(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 第二级：中间容器
                              Container(
                                padding: const EdgeInsets.all(4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 第三级：内层容器 - 头像区域
                                    Container(
                                      padding: const EdgeInsets.all(2),
                                      child: Stack(
                                        children: [
                                          // 主头像容器 - 125x125
                                          Container(
                                            width: 125,
                                            height: 125,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(16),
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
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      Color(0xFFB39DDB),
                                                      Color(0xFF9C88D4),
                                                    ],
                                                  ),
                                                ),
                                                child: Stack(
                                                  fit: StackFit.expand,
                                                  children: [
                                                    // 模拟人物照片的渐变背景
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        gradient: RadialGradient(
                                                          center: const Alignment(0.3, -0.4),
                                                          radius: 0.8,
                                                          colors: [
                                                            const Color(0xFFE1BEE7).withOpacity(0.8),
                                                            const Color(0xFF9C88D4).withOpacity(0.9),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    // 人物轮廓
                                                    const Positioned(
                                                      bottom: 0,
                                                      left: 0,
                                                      right: 0,
                                                      child: Icon(
                                                        Icons.person,
                                                        color: Colors.white,
                                                        size: 70,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          // 底部标签 - 精确定位
                                          Positioned(
                                            bottom: 10,
                                            left: 6,
                                            right: 6,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.8),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                index % 3 == 0 ? '近期89人下单' : index % 3 == 1 ? '距离你最近' : '近期88',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    const SizedBox(height: 8),
                                    
                                    // 文字信息在头像下方 - 左对齐
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // 昵称
                                        Text(
                                          user.nickname.isNotEmpty ? user.nickname : '用户${index + 1}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          textAlign: TextAlign.left,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        
                                        const SizedBox(height: 4),
                                        
                                        // 地区标签
                                        Text(
                                          '微信区 荣耀王者',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                          textAlign: TextAlign.left,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
