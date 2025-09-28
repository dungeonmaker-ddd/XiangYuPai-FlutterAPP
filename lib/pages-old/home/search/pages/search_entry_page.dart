// 🔍 搜索入口页面 - 单文件架构完整实现
// 基于Flutter单文件架构规范的8段式结构设计

// ============== 1. IMPORTS ==============
// Flutter核心库
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Dart核心库
import 'dart:async';
import 'dart:developer' as developer;

// 项目内部文件
import '../models/search_models.dart';
import '../services/search_services.dart';
import 'search_results_page.dart';

// ============== 2. CONSTANTS ==============
/// 🎨 搜索入口页面私有常量
class _SearchEntryPageConstants {
  const _SearchEntryPageConstants._();
  
  // UI配置
  static const double searchBarMargin = 16.0;
  static const double sectionSpacing = 24.0;
  static const double historyItemHeight = 44.0;
  static const double suggestionItemHeight = 48.0;
  
  // 动画配置
  static const Duration suggestionAnimationDuration = Duration(milliseconds: 200);
  static const Duration searchDebounceDelay = Duration(milliseconds: 300);
}

// ============== 3. MODELS ==============
/// 📋 搜索入口页面状态模型
class _SearchEntryState {
  final String inputText;
  final List<String> searchHistory;
  final List<String> suggestions;
  final bool isLoadingSuggestions;
  final bool showSuggestions;
  final String? errorMessage;
  
  const _SearchEntryState({
    this.inputText = '',
    this.searchHistory = const [],
    this.suggestions = const [],
    this.isLoadingSuggestions = false,
    this.showSuggestions = false,
    this.errorMessage,
  });
  
  _SearchEntryState copyWith({
    String? inputText,
    List<String>? searchHistory,
    List<String>? suggestions,
    bool? isLoadingSuggestions,
    bool? showSuggestions,
    String? errorMessage,
  }) {
    return _SearchEntryState(
      inputText: inputText ?? this.inputText,
      searchHistory: searchHistory ?? this.searchHistory,
      suggestions: suggestions ?? this.suggestions,
      isLoadingSuggestions: isLoadingSuggestions ?? this.isLoadingSuggestions,
      showSuggestions: showSuggestions ?? this.showSuggestions,
      errorMessage: errorMessage,
    );
  }
}

// ============== 4. SERVICES ==============
// 服务在 search_services.dart 中定义

// ============== 5. CONTROLLERS ==============
/// 🧠 搜索入口控制器
class _SearchEntryController extends ValueNotifier<_SearchEntryState> {
  _SearchEntryController() : super(const _SearchEntryState()) {
    _initialize();
  }
  
  final TextEditingController textController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final SearchService _searchService = SearchService();
  Timer? _debounceTimer;
  
  /// 初始化
  Future<void> _initialize() async {
    try {
      // 加载搜索历史
      final history = await _searchService.getSearchHistory();
      value = value.copyWith(searchHistory: history);
      
      // 监听输入变化
      textController.addListener(_onTextChanged);
      focusNode.addListener(_onFocusChanged);
      
      developer.log('SearchEntryController: 初始化完成');
    } catch (e) {
      value = value.copyWith(errorMessage: '初始化失败');
      developer.log('SearchEntryController: 初始化失败 - $e');
    }
  }
  
  /// 文本变化处理
  void _onTextChanged() {
    final text = textController.text;
    value = value.copyWith(inputText: text);
    
    // 防抖处理搜索建议
    _debounceTimer?.cancel();
    if (text.trim().isNotEmpty) {
      _debounceTimer = Timer(_SearchEntryPageConstants.searchDebounceDelay, () {
        _loadSuggestions(text);
      });
    } else {
      value = value.copyWith(
        suggestions: [],
        showSuggestions: false,
      );
    }
  }
  
  /// 焦点变化处理
  void _onFocusChanged() {
    if (focusNode.hasFocus && textController.text.isNotEmpty) {
      value = value.copyWith(showSuggestions: true);
    }
  }
  
  /// 加载搜索建议
  Future<void> _loadSuggestions(String keyword) async {
    if (keyword.trim().isEmpty) return;
    
    try {
      value = value.copyWith(isLoadingSuggestions: true);
      
      final suggestions = await _searchService.getSuggestions(keyword);
      
      value = value.copyWith(
        suggestions: suggestions,
        isLoadingSuggestions: false,
        showSuggestions: true,
        errorMessage: null,
      );
    } catch (e) {
      value = value.copyWith(
        isLoadingSuggestions: false,
        errorMessage: '获取建议失败',
      );
      developer.log('SearchEntryController: 加载建议失败 - $e');
    }
  }
  
  /// 执行搜索
  void performSearch(String keyword) {
    if (keyword.trim().isEmpty) return;
    
    // 保存搜索历史
    _searchService.saveSearchHistory(keyword);
    
    // 隐藏建议
    value = value.copyWith(showSuggestions: false);
    
    developer.log('SearchEntryController: 执行搜索 - $keyword');
  }
  
  /// 选择历史记录
  void selectHistory(String keyword) {
    textController.text = keyword;
    performSearch(keyword);
  }
  
  /// 选择建议
  void selectSuggestion(String suggestion) {
    textController.text = suggestion;
    performSearch(suggestion);
  }
  
  /// 清空输入
  void clearInput() {
    textController.clear();
    value = value.copyWith(
      inputText: '',
      suggestions: [],
      showSuggestions: false,
    );
  }
  
  /// 清空历史记录
  Future<void> clearHistory() async {
    try {
      await _searchService.clearSearchHistory();
      value = value.copyWith(searchHistory: []);
      developer.log('SearchEntryController: 历史记录已清空');
    } catch (e) {
      value = value.copyWith(errorMessage: '清空历史失败');
      developer.log('SearchEntryController: 清空历史失败 - $e');
    }
  }
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}

// ============== 6. WIDGETS ==============
/// 🔍 搜索栏组件
class _SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback? onSearch;
  final VoidCallback? onClear;
  final VoidCallback? onBack;
  
  const _SearchBarWidget({
    required this.controller,
    required this.focusNode,
    this.onSearch,
    this.onClear,
    this.onBack,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(_SearchEntryPageConstants.searchBarMargin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SearchConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 返回按钮
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
            color: const Color(SearchConstants.textColor),
          ),
          
          // 搜索输入框
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: const InputDecoration(
                hintText: '搜索用户、内容、话题...',
                hintStyle: TextStyle(color: Color(SearchConstants.hintColor)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 16),
              ),
              style: const TextStyle(
                fontSize: 16,
                color: Color(SearchConstants.textColor),
              ),
              onSubmitted: (_) => onSearch?.call(),
            ),
          ),
          
          // 清空按钮
          if (controller.text.isNotEmpty)
            IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.clear),
              color: const Color(SearchConstants.hintColor),
            ),
          
          // 搜索按钮
          IconButton(
            onPressed: onSearch,
            icon: const Icon(Icons.search),
            color: const Color(SearchConstants.primaryColor),
          ),
        ],
      ),
    );
  }
}

/// 📝 搜索历史组件
class _SearchHistoryWidget extends StatelessWidget {
  final List<String> history;
  final ValueChanged<String>? onHistoryTap;
  final VoidCallback? onClearHistory;
  
  const _SearchHistoryWidget({
    required this.history,
    this.onHistoryTap,
    this.onClearHistory,
  });
  
  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '历史记录',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(SearchConstants.textColor),
                ),
              ),
              TextButton(
                onPressed: onClearHistory,
                child: const Text(
                  '清空',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(SearchConstants.hintColor),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // 历史记录列表
          ...history.map((item) => _buildHistoryItem(item)),
        ],
      ),
    );
  }
  
  Widget _buildHistoryItem(String item) {
    return GestureDetector(
      onTap: () => onHistoryTap?.call(item),
      child: Container(
        height: _SearchEntryPageConstants.historyItemHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.history,
              size: 16,
              color: Color(SearchConstants.hintColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(SearchConstants.textColor),
                ),
              ),
            ),
            const Icon(
              Icons.north_west,
              size: 16,
              color: Color(SearchConstants.hintColor),
            ),
          ],
        ),
      ),
    );
  }
}

/// 💡 搜索建议组件
class _SearchSuggestionWidget extends StatelessWidget {
  final List<String> suggestions;
  final bool isLoading;
  final ValueChanged<String>? onSuggestionTap;
  
  const _SearchSuggestionWidget({
    required this.suggestions,
    this.isLoading = false,
    this.onSuggestionTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: _SearchEntryPageConstants.suggestionAnimationDuration,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SearchConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('正在加载建议...'),
                ],
              ),
            )
          else
            ...suggestions.map((item) => _buildSuggestionItem(item)),
        ],
      ),
    );
  }
  
  Widget _buildSuggestionItem(String item) {
    return GestureDetector(
      onTap: () => onSuggestionTap?.call(item),
      child: Container(
        height: _SearchEntryPageConstants.suggestionItemHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFE5E5E5), width: 0.5),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              size: 18,
              color: Color(SearchConstants.hintColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(SearchConstants.textColor),
                ),
              ),
            ),
            const Icon(
              Icons.north_west,
              size: 16,
              color: Color(SearchConstants.hintColor),
            ),
          ],
        ),
      ),
    );
  }
}

// ============== 7. PAGES ==============
/// 🔍 搜索入口页面
/// 
/// 提供搜索输入、历史记录和搜索建议功能
class SearchEntryPage extends StatefulWidget {
  const SearchEntryPage({super.key});
  
  static const String routeName = '/search/entry';
  
  @override
  State<SearchEntryPage> createState() => _SearchEntryPageState();
}

class _SearchEntryPageState extends State<SearchEntryPage> {
  late final _SearchEntryController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = _SearchEntryController();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // 设置状态栏样式
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 透明状态栏
      statusBarIconBrightness: Brightness.dark, // 深色图标
      statusBarBrightness: Brightness.light, // iOS状态栏亮度
    ));
    
    return Scaffold(
      backgroundColor: const Color(SearchConstants.backgroundColor),
      body: SafeArea(
        child: ValueListenableBuilder<_SearchEntryState>(
          valueListenable: _controller,
          builder: (context, state, child) {
            return Column(
              children: [
                // 搜索栏
                _SearchBarWidget(
                  controller: _controller.textController,
                  focusNode: _controller.focusNode,
                  onSearch: () => _handleSearch(state.inputText),
                  onClear: _controller.clearInput,
                  onBack: () => Navigator.pop(context),
                ),
                
                // 内容区域
                Expanded(
                  child: Stack(
                    children: [
                      // 主要内容
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: _SearchEntryPageConstants.sectionSpacing),
                            
                            // 搜索历史
                            if (!state.showSuggestions)
                              _SearchHistoryWidget(
                                history: state.searchHistory,
                                onHistoryTap: _controller.selectHistory,
                                onClearHistory: _showClearHistoryDialog,
                              ),
                            
                            const SizedBox(height: _SearchEntryPageConstants.sectionSpacing),
                            
                            // 功能区域占位
                            if (!state.showSuggestions)
                              _buildFunctionArea(),
                          ],
                        ),
                      ),
                      
                      // 搜索建议覆盖层
                      if (state.showSuggestions)
                        Positioned.fill(
                          child: Container(
                            color: const Color(SearchConstants.backgroundColor),
                            child: Column(
                              children: [
                                const SizedBox(height: 16),
                                _SearchSuggestionWidget(
                                  suggestions: state.suggestions,
                                  isLoading: state.isLoadingSuggestions,
                                  onSuggestionTap: _controller.selectSuggestion,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
  
  /// 处理搜索
  void _handleSearch(String keyword) {
    if (keyword.trim().isEmpty) return;
    
    _controller.performSearch(keyword);
    
    // 跳转到搜索结果页面
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsPage(initialKeyword: keyword),
      ),
    );
  }
  
  /// 显示清空历史确认对话框
  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空历史记录'),
        content: const Text('确定要清空所有搜索历史吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _controller.clearHistory();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
  
  /// 构建功能区域
  Widget _buildFunctionArea() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SearchConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '搜索功能',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(SearchConstants.textColor),
            ),
          ),
          SizedBox(height: 12),
          Text(
            '支持搜索用户、内容、服务订单和话题等多种类型',
            style: TextStyle(
              fontSize: 14,
              color: Color(SearchConstants.hintColor),
            ),
          ),
        ],
      ),
    );
  }
}

// ============== 8. EXPORTS ==============
/// 📤 导出定义
/// 
/// 本文件自动导出的公共类：
/// - SearchEntryPage: 搜索入口页面（public class）
///
/// 私有类（不会被导出）：
/// - _SearchEntryController: 搜索入口控制器
/// - _SearchBarWidget: 搜索栏组件
/// - _SearchHistoryWidget: 搜索历史组件
/// - _SearchSuggestionWidget: 搜索建议组件
/// - _SearchEntryPageConstants: 页面私有常量
/// - _SearchEntryState: 页面状态模型
///
/// 使用方式：
/// ```dart
/// import 'search_entry_page.dart';
/// 
/// // 在路由中使用
/// Navigator.pushNamed(context, SearchEntryPage.routeName);
/// ```
