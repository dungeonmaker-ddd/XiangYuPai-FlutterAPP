/// 🧪 筛选功能集成测试页面
/// 
/// 用于测试首页筛选功能的集成效果

import 'package:flutter/material.dart';
import '../../../home/unified_home_page.dart';

/// 筛选功能测试页面
class FilterIntegrationTestPage extends StatelessWidget {
  const FilterIntegrationTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('筛选功能测试'),
        backgroundColor: const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TestInfoCard(),
            SizedBox(height: 16),
            _FeatureListCard(),
            SizedBox(height: 16),
            _NavigationCard(),
          ],
        ),
      ),
    );
  }
}

/// 测试信息卡片
class _TestInfoCard extends StatelessWidget {
  const _TestInfoCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue[600]),
                const SizedBox(width: 8),
                const Text(
                  '筛选功能集成状态',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '✅ 首页已成功集成区域筛选和条件筛选功能\n'
              '✅ 支持区域选择和多维度筛选条件\n'
              '✅ 筛选状态实时显示和管理\n'
              '✅ 一键清除所有筛选条件',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

/// 功能列表卡片
class _FeatureListCard extends StatelessWidget {
  const _FeatureListCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.featured_play_list, color: Colors.green[600]),
                const SizedBox(width: 8),
                const Text(
                  '已实现功能',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildFeatureItem('🌍', '区域筛选', '支持深圳各区域选择'),
            _buildFeatureItem('🔍', '条件筛选', '年龄、性别、技能等多维度筛选'),
            _buildFeatureItem('📊', '状态显示', '筛选按钮实时显示当前状态'),
            _buildFeatureItem('🗑️', '一键清除', '快速清除所有筛选条件'),
            _buildFeatureItem('💾', '状态管理', '筛选状态持久化管理'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 导航卡片
class _NavigationCard extends StatelessWidget {
  const _NavigationCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.navigation, color: Colors.purple[600]),
                const SizedBox(width: 8),
                const Text(
                  '测试导航',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UnifiedHomePage(),
                    ),
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text('进入首页测试筛选功能'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '💡 测试提示：\n'
              '1. 点击"区域"按钮测试区域选择\n'
              '2. 点击"筛选"按钮测试条件筛选\n'
              '3. 观察按钮状态变化和清除功能',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
