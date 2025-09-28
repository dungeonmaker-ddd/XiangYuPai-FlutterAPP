// 🏠 主Tab页面 - 统一底部导航管理
// 基于IndexedStack实现类似Vue的父子组件机制，保持页面状态避免重复加载

// ============== 1. IMPORTS ==============
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

// 导入各个Tab页面
import 'home/unified_home_page_refactored.dart';
import 'discovery/index.dart' as discovery;
import 'messages/index.dart' as messages;
import 'profile/index.dart' as profile;

// ============== 2. CONSTANTS ==============
/// 🎨 主Tab页面常量
class _MainTabConstants {
  static const String pageTitle = '享语拍';
  static const int defaultTabIndex = 0; // 默认显示首页
  static const Duration tabSwitchDuration = Duration(milliseconds: 200);
  
  // Tab配置
  static const List<TabConfig> tabs = [
    TabConfig(
      index: 0,
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: '首页',
    ),
    TabConfig(
      index: 1, 
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore,
      label: '发现',
    ),
    TabConfig(
      index: 2,
      icon: Icons.message_outlined, 
      activeIcon: Icons.message,
      label: '消息',
    ),
    TabConfig(
      index: 3,
      icon: Icons.person_outline,
      activeIcon: Icons.person, 
      label: '我的',
    ),
  ];
}

/// 📋 Tab配置模型
class TabConfig {
  final int index;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  
  const TabConfig({
    required this.index,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

// ============== 3. CONTROLLER ==============
/// 🧠 主Tab控制器
class MainTabController extends ValueNotifier<int> {
  MainTabController() : super(_MainTabConstants.defaultTabIndex);
  
  /// 切换Tab
  void switchTab(int index) {
    if (value != index && index >= 0 && index < _MainTabConstants.tabs.length) {
      value = index;
      developer.log('主Tab切换到: ${_MainTabConstants.tabs[index].label}');
    }
  }
  
  /// 获取当前Tab配置
  TabConfig get currentTab => _MainTabConstants.tabs[value];
  
  /// 获取所有Tab配置
  List<TabConfig> get allTabs => _MainTabConstants.tabs;
}

// ============== 4. PAGES ==============
/// 🏠 主Tab页面 - 统一底部导航管理
/// 
/// 功能特性：
/// - 使用IndexedStack保持所有页面状态（类似Vue的keep-alive）
/// - 统一管理底部Tab导航，避免重复
/// - 支持Tab切换动画和状态管理
/// - 各个子页面无需单独管理底部导航
class MainTabPage extends StatefulWidget {
  const MainTabPage({super.key});

  @override
  State<MainTabPage> createState() => _MainTabPageState();
}

class _MainTabPageState extends State<MainTabPage> with TickerProviderStateMixin {
  late final MainTabController _tabController;
  late final AnimationController _animationController;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _tabController = MainTabController();
    _animationController = AnimationController(
      duration: _MainTabConstants.tabSwitchDuration,
      vsync: this,
    );
    
    // 初始化所有页面（只创建一次，保持状态）
    _pages = [
      const UnifiedHomePageWrapper(), // 首页（移除内部的底部导航）
      const discovery.DiscoveryMainPage(), // 发现页面
      const messages.MessageSystemProviders(
        child: messages.MessageMainPage(),
      ), // 消息系统页面
      profile.ProfilePageFactory.createMainPageWithWrapper(), // 我的页面 - 使用新架构工厂
    ];
    
    developer.log('主Tab页面初始化完成，默认显示：${_tabController.currentTab.label}');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    // 释放Profile模块资源（使用新架构快速访问接口）
    profile.Profile.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<int>(
        valueListenable: _tabController,
        builder: (context, currentIndex, child) {
          return IndexedStack(
            index: currentIndex,
            children: _pages,
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      // 发布动态浮动按钮（仅在首页和发现页显示）
      floatingActionButton: ValueListenableBuilder<int>(
        valueListenable: _tabController,
        builder: (context, currentIndex, child) {
          if (currentIndex == 0 || currentIndex == 1) {
            return FloatingActionButton(
              onPressed: _handlePublishContent,
              backgroundColor: const Color(0xFF8B5CF6), // 主题紫色
              foregroundColor: Colors.white,
              elevation: 6,
              child: const Icon(Icons.add, size: 28),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// 构建底部导航栏
  Widget _buildBottomNavigationBar() {
    return ValueListenableBuilder<int>(
      valueListenable: _tabController,
      builder: (context, currentIndex, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              height: 62, // 增加2像素避免溢出
              child: Row(
                children: _MainTabConstants.tabs.map((tab) {
                  return _buildTabItem(tab, currentIndex == tab.index);
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 构建Tab项
  Widget _buildTabItem(TabConfig tab, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _handleTabTap(tab.index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: _MainTabConstants.tabSwitchDuration,
          padding: const EdgeInsets.symmetric(vertical: 6), // 减少到6px避免溢出
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: _MainTabConstants.tabSwitchDuration,
                child: Icon(
                  isSelected ? tab.activeIcon : tab.icon,
                  key: ValueKey('${tab.index}_${isSelected}'),
                  size: 24,
                  color: isSelected 
                      ? const Color(0xFF8B5CF6) 
                      : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 3), // 减少间距
              AnimatedDefaultTextStyle(
                duration: _MainTabConstants.tabSwitchDuration,
                style: TextStyle(
                  fontSize: 11, // 减少字体大小确保不会溢出
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected 
                      ? const Color(0xFF8B5CF6) 
                      : Colors.grey[600],
                  height: 1.0, // 设置行高确保文字不会太高
                ),
                child: Text(
                  tab.label,
                  maxLines: 1, // 限制为单行
                  overflow: TextOverflow.ellipsis, // 防止文字溢出
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 处理Tab点击
  void _handleTabTap(int index) {
    if (_tabController.value == index) {
      // 如果点击当前Tab，执行特殊操作
      _handleCurrentTabTap(index);
    } else {
      // 切换到新Tab
      _tabController.switchTab(index);
      _animationController.forward(from: 0);
    }
  }

  /// 处理当前Tab点击（刷新或回到顶部）
  void _handleCurrentTabTap(int index) {
    switch (index) {
      case 0:
        // 首页：通知首页滚动到顶部
        _notifyHomePageScrollToTop();
        break;
      case 1:
        // 发现页：通知发现页刷新
        _notifyDiscoveryPageRefresh();
        break;
      case 2:
        // 消息页：刷新消息数据
        _notifyMessagesPageRefresh();
        break;
      case 3:
        // 我的页面：刷新用户数据
        _notifyProfilePageRefresh();
        break;
      default:
        developer.log('当前Tab点击: ${_MainTabConstants.tabs[index].label}');
    }
  }

  /// 通知首页滚动到顶部
  void _notifyHomePageScrollToTop() {
    // 这里可以通过EventBus或其他方式通知首页
    developer.log('通知首页滚动到顶部');
  }

  /// 通知发现页刷新
  void _notifyDiscoveryPageRefresh() {
    // 这里可以通过EventBus或其他方式通知发现页刷新
    developer.log('通知发现页刷新');
  }

  /// 通知消息页刷新
  void _notifyMessagesPageRefresh() {
    // 这里可以通过EventBus或其他方式通知消息页刷新
    developer.log('通知消息页刷新');
  }

  /// 通知Profile页面刷新
  void _notifyProfilePageRefresh() {
    try {
      // 使用新架构的快速访问接口刷新数据
      profile.Profile.refresh(forceRefresh: true);
      developer.log('通知Profile页面刷新数据');
    } catch (e) {
      developer.log('Profile页面刷新失败: $e');
    }
  }

  /// 处理发布动态
  void _handlePublishContent() async {
    developer.log('主Tab页面: 点击发布动态按钮');
    
    try {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => const discovery.PublishContentPage(),
          fullscreenDialog: true,
        ),
      );
      
      if (result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 发布成功！'),
            backgroundColor: Color(0xFF8B5CF6),
            duration: Duration(seconds: 2),
          ),
        );
        
        // 可以通知相关页面刷新
        _notifyPagesRefresh();
      }
    } catch (e) {
      developer.log('打开发布动态页面失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('打开发布页面失败，请重试'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 通知页面刷新
  void _notifyPagesRefresh() {
    // 这里可以通过EventBus或其他方式通知相关页面刷新
    developer.log('通知页面刷新数据');
  }
}

// ============== 5. WRAPPER WIDGETS ==============
/// 🏠 首页包装器 - 移除内部底部导航
class UnifiedHomePageWrapper extends StatelessWidget {
  const UnifiedHomePageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // 返回移除了底部导航栏的首页
    return const UnifiedHomePageWithoutBottomNav();
  }
}

// ProfilePageWrapper已移动到profile/index.dart中，作为ProfilePageWithInitialization

/// ⏳ 敬请期待页面
class _ComingSoonPage extends StatelessWidget {
  final String title;
  final IconData icon;

  const _ComingSoonPage({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                icon,
                size: 60,
                color: const Color(0xFF8B5CF6),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '$title功能',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '正在紧急开发中...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '敬请期待 🚀',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============== 6. EXPORTS ==============
/// 📤 导出定义
/// 
/// 主要导出：
/// - MainTabPage: 主Tab页面
/// - MainTabController: Tab控制器
/// - TabConfig: Tab配置模型
