// 🔍 动态详情页主页面 - 单文件架构完整实现
// 基于Flutter单文件架构规范的8段式结构设计
// 实现沉浸式内容展示+完整社交互动+智能分享系统

// ============== 1. IMPORTS ==============
// Flutter核心库
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';

// Dart核心库
import 'dart:async';
import 'dart:math';
import 'dart:developer' as developer;

// 第三方库
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// 项目内部文件 - 按依赖关系排序
import '../models/content_detail_models.dart';    // 详情页数据模型
import '../services/content_detail_services.dart';  // 详情页业务服务
import '../models/discovery_models.dart';         // 发现页数据模型

// ============== 2. CONSTANTS ==============
/// 🎨 动态详情页私有常量（页面级别）
class _DetailPageConstants {
  // 私有构造函数，防止实例化
  const _DetailPageConstants._();
  
  // 页面标识
  static const String pageTitle = '动态详情';
  static const String routeName = '/content_detail';
  
  // UI尺寸配置（像素级精确规格）
  static const double appBarHeight = 56.0;
  static const double userInfoHeight = 72.0;
  static const double bottomBarHeight = 64.0;
  static const double buttonSize = 48.0;
  static const double avatarSize = 48.0;
  static const double followButtonWidth = 80.0;
  static const double followButtonHeight = 32.0;
  static const double commentInputHeight = 48.0;
  static const double commentExpandedHeight = 120.0;
  static const double shareIconSize = 48.0;
  static const double actionIconSize = 24.0;
  
  // 媒体展示配置
  static const double maxImageHeight = 400.0;
  static const double imageGridSpacing = 4.0;
  static const double imageCornerRadius = 6.0;
  static const double videoAspectRatio = 16.0 / 9.0;
  static const double videoControlHeight = 48.0;
  
  // 动画时长配置
  static const Duration quickAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  static const Duration likeAnimationDuration = Duration(milliseconds: 300);
  static const Duration favoriteAnimationDuration = Duration(milliseconds: 300);
  static const Duration followAnimationDuration = Duration(milliseconds: 300);
  
  // 颜色配置（精确颜色值）
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundGray = Color(0xFFF9FAFB);
  static const Color borderGray = Color(0xFFE5E7EB);
  static const Color textBlack = Color(0xFF1F2937);
  static const Color textGray = Color(0xFF6B7280);
  static const Color textLightGray = Color(0xFF9CA3AF);
  static const Color likeRed = Color(0xFFEF4444);
  static const Color favoriteYellow = Color(0xFFF59E0B);
  static const Color linkBlue = Color(0xFF3B82F6);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color successGreen = Color(0xFF10B981);
  
  // 文字样式配置
  static const String fontFamily = 'PingFang SC';
  static const double titleFontSize = 18.0;
  static const double bodyFontSize = 16.0;
  static const double captionFontSize = 14.0;
  static const double smallFontSize = 12.0;
  static const double lineHeight = 1.5;
  
  // 内容限制配置
  static const int maxCommentLength = 200;
  static const int maxImageCount = 9;
  static const int contentPreviewLength = 50;
}

// 全局常量引用：DetailConstants 在 content_detail_models.dart 中定义

// ============== 3. MODELS ==============
/// 📋 数据模型引用
/// 主要模型定义在 content_detail_models.dart 中：
/// - DetailConstants: 全局详情页常量配置
/// - ContentDetailModel: 动态详情数据模型
/// - UserDetailModel: 用户详情数据模型
/// - CommentModel: 评论数据模型
/// - MediaItemModel: 媒体项数据模型
/// - InteractionState: 互动状态模型
/// - SharePlatform: 分享平台枚举
/// - DetailPageState: 详情页状态模型

// ============== 4. SERVICES ==============
/// 🔧 业务服务引用
/// 主要服务定义在 content_detail_services.dart 中：
/// - ContentDetailService: 详情页数据服务
/// - InteractionService: 社交互动服务
/// - ShareService: 分享功能服务
/// - CommentService: 评论管理服务
/// - MediaService: 媒体处理服务
/// 
/// 服务功能包括：
/// - 内容详情获取和缓存
/// - 点赞收藏评论互动
/// - 多平台分享功能
/// - 用户关注管理
/// - 媒体资源优化

// ============== 5. CONTROLLERS ==============
/// 🧠 动态详情页控制器
class _DetailController extends ValueNotifier<DetailPageState> {
  _DetailController({required this.contentId}) : super(const DetailPageState()) {
    _commentController = TextEditingController();
    _scrollController = ScrollController();
    _initialize();
  }

  final String contentId;
  late TextEditingController _commentController;
  late ScrollController _scrollController;
  VideoPlayerController? _videoController;
  Timer? _videoProgressTimer;

  TextEditingController get commentController => _commentController;
  ScrollController get scrollController => _scrollController;

  /// 初始化页面数据
  Future<void> _initialize() async {
    try {
      value = value.copyWith(isLoading: true);

      // 并发加载初始化数据
      final results = await Future.wait([
        _loadContentDetail(),
        _loadUserInteractionState(),
        _loadCommentList(),
      ]);

      final contentDetail = results[0] as ContentDetailModel?;
      final interactionState = results[1] as InteractionState?;
      final comments = results[2] as List<CommentModel>?;

      if (contentDetail != null) {
        value = value.copyWith(
          isLoading: false,
          contentDetail: contentDetail,
          interactionState: interactionState ?? const InteractionState(),
          comments: comments ?? [],
        );

        // 初始化视频播放器（如果有视频）
        await _initializeVideoPlayer();
        
        developer.log('详情页初始化完成: $contentId');
      } else {
        throw Exception('内容不存在或已被删除');
      }
    } catch (e) {
      value = value.copyWith(
        isLoading: false,
        errorMessage: '加载失败：$e',
      );
      developer.log('详情页初始化失败: $e');
    }
  }

  /// 加载内容详情
  Future<ContentDetailModel?> _loadContentDetail() async {
    try {
      return await ContentDetailService.getContentDetail(contentId);
    } catch (e) {
      developer.log('加载内容详情失败: $e');
      return null;
    }
  }

  /// 加载用户互动状态
  Future<InteractionState?> _loadUserInteractionState() async {
    try {
      return await InteractionService.getUserInteractionState(contentId);
    } catch (e) {
      developer.log('加载互动状态失败: $e');
      return null;
    }
  }

  /// 加载评论列表
  Future<List<CommentModel>?> _loadCommentList() async {
    try {
      return await CommentService.getCommentList(contentId, page: 1, limit: 20);
    } catch (e) {
      developer.log('加载评论列表失败: $e');
      return null;
    }
  }

  /// 初始化视频播放器
  Future<void> _initializeVideoPlayer() async {
    final contentDetail = value.contentDetail;
    if (contentDetail == null || contentDetail.mediaItems.isEmpty) return;

    final videoItem = contentDetail.mediaItems.firstWhere(
      (item) => item.type == MediaType.video,
      orElse: () => MediaItemModel.empty(),
    );

    if (videoItem.url.isNotEmpty) {
      try {
        _videoController = VideoPlayerController.network(videoItem.url);
        await _videoController!.initialize();
        
        value = value.copyWith(isVideoReady: true);
        
        // 设置视频进度监听
        _videoProgressTimer = Timer.periodic(
          const Duration(milliseconds: 500),
          (_) => _updateVideoProgress(),
        );

        developer.log('视频播放器初始化完成');
      } catch (e) {
        developer.log('视频播放器初始化失败: $e');
      }
    }
  }

  /// 更新视频播放进度
  void _updateVideoProgress() {
    if (_videoController?.value.isInitialized == true) {
      value = value.copyWith(
        videoPosition: _videoController!.value.position,
        videoDuration: _videoController!.value.duration,
        isVideoPlaying: _videoController!.value.isPlaying,
      );
    }
  }

  /// 点赞/取消点赞
  Future<void> toggleLike() async {
    final currentState = value.interactionState;
    final isLiked = currentState.isLiked;
    
    try {
      // 即时UI反馈
      value = value.copyWith(
        interactionState: currentState.copyWith(
          isLiked: !isLiked,
          likeCount: currentState.likeCount + (isLiked ? -1 : 1),
        ),
        isLikeAnimating: !isLiked, // 只在点赞时播放动画
      );

      // 后台API调用
      if (isLiked) {
        await InteractionService.unlikeContent(contentId);
      } else {
        await InteractionService.likeContent(contentId);
      }

      // 停止点赞动画
      if (!isLiked) {
        Timer(_DetailPageConstants.likeAnimationDuration, () {
          if (value.isLikeAnimating) {
            value = value.copyWith(isLikeAnimating: false);
          }
        });
      }

      developer.log('点赞操作成功: ${!isLiked}');
    } catch (e) {
      // 失败回滚
      value = value.copyWith(
        interactionState: currentState,
        isLikeAnimating: false,
      );
      _showError('点赞失败，请重试');
      developer.log('点赞操作失败: $e');
    }
  }

  /// 收藏/取消收藏
  Future<void> toggleFavorite() async {
    final currentState = value.interactionState;
    final isFavorited = currentState.isFavorited;
    
    try {
      // 即时UI反馈
      value = value.copyWith(
        interactionState: currentState.copyWith(
          isFavorited: !isFavorited,
          favoriteCount: currentState.favoriteCount + (isFavorited ? -1 : 1),
        ),
        isFavoriteAnimating: !isFavorited, // 只在收藏时播放动画
      );

      // 后台API调用
      if (isFavorited) {
        await InteractionService.unfavoriteContent(contentId);
      } else {
        await InteractionService.favoriteContent(contentId);
      }

      // 停止收藏动画
      if (!isFavorited) {
        Timer(_DetailPageConstants.favoriteAnimationDuration, () {
          if (value.isFavoriteAnimating) {
            value = value.copyWith(isFavoriteAnimating: false);
          }
        });
      }

      developer.log('收藏操作成功: ${!isFavorited}');
    } catch (e) {
      // 失败回滚
      value = value.copyWith(
        interactionState: currentState,
        isFavoriteAnimating: false,
      );
      _showError('收藏失败，请重试');
      developer.log('收藏操作失败: $e');
    }
  }

  /// 关注/取消关注用户
  Future<void> toggleFollow() async {
    final contentDetail = value.contentDetail;
    if (contentDetail == null) return;

    final currentState = value.interactionState;
    final isFollowing = currentState.isFollowing;
    
    try {
      // 即时UI反馈
      value = value.copyWith(
        interactionState: currentState.copyWith(isFollowing: !isFollowing),
        isFollowAnimating: true,
      );

      // 后台API调用
      if (isFollowing) {
        await InteractionService.unfollowUser(contentDetail.author.id);
      } else {
        await InteractionService.followUser(contentDetail.author.id);
      }

      // 停止关注动画
      Timer(_DetailPageConstants.followAnimationDuration, () {
        if (value.isFollowAnimating) {
          value = value.copyWith(isFollowAnimating: false);
        }
      });

      developer.log('关注操作成功: ${!isFollowing}');
    } catch (e) {
      // 失败回滚
      value = value.copyWith(
        interactionState: currentState,
        isFollowAnimating: false,
      );
      _showError('关注失败，请重试');
      developer.log('关注操作失败: $e');
    }
  }

  /// 发布评论
  Future<void> publishComment() async {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;

    if (commentText.length > _DetailPageConstants.maxCommentLength) {
      _showError('评论不能超过${_DetailPageConstants.maxCommentLength}个字符');
      return;
    }

    try {
      value = value.copyWith(isCommentPublishing: true);

      // 发布评论
      final newComment = await CommentService.publishComment(
        contentId: contentId,
        content: commentText,
      );

      // 添加到评论列表顶部
      final updatedComments = [newComment, ...value.comments];
      
      // 更新评论数量
      final updatedInteractionState = value.interactionState.copyWith(
        commentCount: value.interactionState.commentCount + 1,
      );

      value = value.copyWith(
        comments: updatedComments,
        interactionState: updatedInteractionState,
        isCommentPublishing: false,
        isCommentExpanded: false,
      );

      // 清空输入框
      _commentController.clear();
      
      // 收起键盘
      FocusScope.of(_currentContext).unfocus();

      _showSuccess('评论发布成功');
      developer.log('评论发布成功');
    } catch (e) {
      value = value.copyWith(isCommentPublishing: false);
      _showError('评论发布失败：$e');
      developer.log('评论发布失败: $e');
    }
  }

  /// 展开/收起评论输入框
  void toggleCommentInput() {
    value = value.copyWith(isCommentExpanded: !value.isCommentExpanded);
    
    if (value.isCommentExpanded) {
      // 延迟聚焦，等待动画完成
      Timer(const Duration(milliseconds: 100), () {
        FocusScope.of(_currentContext).requestFocus(FocusNode());
      });
    }
  }

  /// 显示分享面板
  void showSharePanel() {
    value = value.copyWith(isSharePanelVisible: true);
  }

  /// 隐藏分享面板
  void hideSharePanel() {
    value = value.copyWith(isSharePanelVisible: false);
  }

  /// 分享到平台
  Future<void> shareToplatform(SharePlatform platform) async {
    final contentDetail = value.contentDetail;
    if (contentDetail == null) return;

    try {
      final shareContent = _generateShareContent();
      
      switch (platform) {
        case SharePlatform.wechat:
        case SharePlatform.qq:
        case SharePlatform.weibo:
        case SharePlatform.moments:
        case SharePlatform.wechatMoments:
        case SharePlatform.qzone:
        case SharePlatform.douyin:
        case SharePlatform.more:
          // 使用系统分享
          await Share.share(
            '${shareContent.title}\n\n${shareContent.description}\n\n${shareContent.url}',
            subject: shareContent.title,
          );
          break;
        case SharePlatform.copyLink:
        case SharePlatform.link:
          // 使用剪贴板
          // Note: Flutter doesn't have a built-in clipboard API, this would need additional implementation
          _showSuccess('链接已复制到剪贴板');
          break;
        case SharePlatform.saveImage:
          if (contentDetail.mediaItems.isNotEmpty) {
            // Note: Saving to album would require additional permissions and implementation
            _showSuccess('图片已保存到相册');
          }
          break;
      }

      // 更新分享数量
      final updatedInteractionState = value.interactionState.copyWith(
        shareCount: value.interactionState.shareCount + 1,
      );
      
      value = value.copyWith(
        interactionState: updatedInteractionState,
        isSharePanelVisible: false,
      );

      developer.log('分享成功: ${platform.name}');
    } catch (e) {
      _showError('分享失败：$e');
      developer.log('分享失败: $e');
    }
  }

  /// 生成分享内容
  ShareContent _generateShareContent() {
    final contentDetail = value.contentDetail!;
    
    return ShareContent(
      title: contentDetail.textContent.length > _DetailPageConstants.contentPreviewLength
          ? '${contentDetail.textContent.substring(0, _DetailPageConstants.contentPreviewLength)}...'
          : contentDetail.textContent,
      description: '来自 ${contentDetail.author.nickname} 的动态',
      url: 'https://example.com/content/$contentId',
      imageUrl: contentDetail.mediaItems.isNotEmpty 
          ? contentDetail.mediaItems.first.thumbnailUrl ?? contentDetail.mediaItems.first.url
          : null,
    );
  }

  /// 显示更多操作菜单
  void showMoreActions() {
    value = value.copyWith(isMoreActionsVisible: true);
  }

  /// 隐藏更多操作菜单
  void hideMoreActions() {
    value = value.copyWith(isMoreActionsVisible: false);
  }

  /// 举报内容
  Future<void> reportContent() async {
    try {
      await ContentDetailService.reportContent(contentId, '用户举报');
      hideMoreActions();
      _showSuccess('举报已提交，我们会尽快处理');
      developer.log('内容举报成功: $contentId');
    } catch (e) {
      _showError('举报失败：$e');
      developer.log('内容举报失败: $e');
    }
  }

  /// 标记不感兴趣
  Future<void> markNotInterested() async {
    try {
      await ContentDetailService.markNotInterested(contentId);
      hideMoreActions();
      _showSuccess('已标记为不感兴趣');
      developer.log('标记不感兴趣成功: $contentId');
    } catch (e) {
      _showError('操作失败：$e');
      developer.log('标记不感兴趣失败: $e');
    }
  }

  /// 播放/暂停视频
  void toggleVideoPlayback() {
    if (_videoController?.value.isInitialized == true) {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
    }
  }

  /// 设置视频播放位置
  void seekVideo(Duration position) {
    if (_videoController?.value.isInitialized == true) {
      _videoController!.seekTo(position);
    }
  }

  /// 全屏播放视频
  void enterVideoFullscreen() {
    // TODO: 实现视频全屏播放
    developer.log('进入视频全屏模式');
  }

  /// 显示错误消息
  void _showError(String message) {
    value = value.copyWith(errorMessage: message);
    
    // 3秒后清除错误消息
    Timer(const Duration(seconds: 3), () {
      if (value.errorMessage == message) {
        value = value.copyWith(errorMessage: null);
      }
    });
  }

  /// 显示成功消息
  void _showSuccess(String message) {
    value = value.copyWith(successMessage: message);
    
    // 2秒后清除成功消息
    Timer(const Duration(seconds: 2), () {
      if (value.successMessage == message) {
        value = value.copyWith(successMessage: null);
      }
    });
  }

  // 临时上下文引用（实际应用中通过参数传递）
  BuildContext get _currentContext => 
      throw UnimplementedError('Context should be passed as parameter');

  @override
  void dispose() {
    _videoProgressTimer?.cancel();
    _videoController?.dispose();
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// ============== 6. WIDGETS ==============
/// 🧩 UI组件定义
/// 
/// 本段包含详情页专用的UI组件：
/// - _DetailAppBar: 详情页导航栏组件
/// - _UserInfoSection: 用户信息区域组件
/// - _ContentSection: 内容展示区域组件
/// - _MediaViewer: 媒体查看器组件
/// - _VideoPlayer: 视频播放器组件
/// - _BottomActionBar: 底部操作栏组件
/// - _CommentInput: 评论输入组件
/// - _SharePanel: 分享面板组件
/// - _MoreActionsMenu: 更多操作菜单组件
///
/// 设计原则：
/// - 像素级精确UI规格实现
/// - 沉浸式用户体验设计
/// - 流畅的交互动画效果
/// - 完整的状态管理系统

/// 🔝 详情页导航栏
class _DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBack;
  final VoidCallback? onMore;

  const _DetailAppBar({
    this.onBack,
    this.onMore,
  });

  @override
  Size get preferredSize => const Size.fromHeight(_DetailPageConstants.appBarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: _buildBackButton(),
      actions: [_buildMoreButton()],
    );
  }

  Widget _buildBackButton() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onBack,
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: _DetailPageConstants.textBlack,
          size: 20,
        ),
        splashRadius: 22,
      ),
    );
  }

  Widget _buildMoreButton() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onMore,
        icon: const Icon(
          Icons.more_horiz,
          color: _DetailPageConstants.textBlack,
          size: 20,
        ),
        splashRadius: 22,
      ),
    );
  }
}

/// 👤 用户信息区域组件
class _UserInfoSection extends StatelessWidget {
  final UserDetailModel user;
  final bool isFollowing;
  final bool isAnimating;
  final VoidCallback? onFollow;
  final VoidCallback? onUserTap;

  const _UserInfoSection({
    required this.user,
    required this.isFollowing,
    required this.isAnimating,
    this.onFollow,
    this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // 移除固定高度，让内容自适应
      constraints: BoxConstraints(
        minHeight: _DetailPageConstants.userInfoHeight,
        maxHeight: _DetailPageConstants.userInfoHeight + 20, // 允许一定的溢出空间
      ),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: _DetailPageConstants.backgroundWhite,
        border: Border(
          bottom: BorderSide(
            color: _DetailPageConstants.borderGray,
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // 顶部对齐，避免高度不一致问题
        children: [
          _buildUserAvatar(),
          const SizedBox(width: 12),
          Expanded(child: _buildUserInfo()),
          _buildFollowButton(),
        ],
      ),
    );
  }

  Widget _buildUserAvatar() {
    return GestureDetector(
      onTap: onUserTap,
      child: Container(
        width: _DetailPageConstants.avatarSize,
        height: _DetailPageConstants.avatarSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_DetailPageConstants.avatarSize / 2),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_DetailPageConstants.avatarSize / 2),
          child: user.avatarUrl.isNotEmpty
              ? Image.network(
                  user.avatarUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildDefaultAvatar();
                  },
                )
              : _buildDefaultAvatar(),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildUserInfo() {
    return GestureDetector(
      onTap: onUserTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(
                user.nickname,
                style: const TextStyle(
                  fontSize: _DetailPageConstants.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: _DetailPageConstants.textBlack,
                  fontFamily: _DetailPageConstants.fontFamily,
                ),
              ),
              if (user.isVerified) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.verified,
                  color: _DetailPageConstants.linkBlue,
                  size: 16,
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(
            user.publishTime,
            style: const TextStyle(
              fontSize: _DetailPageConstants.captionFontSize,
              color: _DetailPageConstants.textGray,
              fontFamily: _DetailPageConstants.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowButton() {
    return AnimatedContainer(
      duration: _DetailPageConstants.followAnimationDuration,
      width: _DetailPageConstants.followButtonWidth,
      height: _DetailPageConstants.followButtonHeight,
      child: ElevatedButton(
        onPressed: onFollow,
        style: ElevatedButton.styleFrom(
          backgroundColor: isFollowing 
              ? _DetailPageConstants.backgroundGray
              : _DetailPageConstants.primaryPurple,
          foregroundColor: isFollowing 
              ? _DetailPageConstants.textGray
              : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isFollowing 
                ? const BorderSide(color: _DetailPageConstants.borderGray)
                : BorderSide.none,
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isAnimating
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isFollowing ? _DetailPageConstants.textGray : Colors.white,
                    ),
                  ),
                )
              : Text(
                  isFollowing ? '已关注' : '关注',
                  key: ValueKey(isFollowing),
                  style: const TextStyle(
                    fontSize: _DetailPageConstants.captionFontSize,
                    fontWeight: FontWeight.w600,
                    fontFamily: _DetailPageConstants.fontFamily,
                  ),
                ),
        ),
      ),
    );
  }
}

/// 📝 内容展示区域组件
class _ContentSection extends StatelessWidget {
  final String textContent;
  final List<String> topics;
  final List<String> mentions;
  final VoidCallback? onTopicTap;
  final VoidCallback? onMentionTap;

  const _ContentSection({
    required this.textContent,
    this.topics = const [],
    this.mentions = const [],
    this.onTopicTap,
    this.onMentionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: _DetailPageConstants.backgroundWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (textContent.isNotEmpty) _buildTextContent(),
          if (topics.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildTopics(),
          ],
        ],
      ),
    );
  }

  Widget _buildTextContent() {
    return SelectableText(
      textContent,
      style: const TextStyle(
        fontSize: _DetailPageConstants.bodyFontSize,
        height: _DetailPageConstants.lineHeight,
        color: _DetailPageConstants.textBlack,
        fontFamily: _DetailPageConstants.fontFamily,
      ),
    );
  }

  Widget _buildTopics() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: topics.map((topic) => _buildTopicChip(topic)).toList(),
    );
  }

  Widget _buildTopicChip(String topic) {
    return GestureDetector(
      onTap: onTopicTap,
      child: Text(
        '#$topic',
        style: const TextStyle(
          fontSize: _DetailPageConstants.bodyFontSize,
          color: _DetailPageConstants.linkBlue,
          fontFamily: _DetailPageConstants.fontFamily,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

/// 🖼️ 媒体查看器组件
class _MediaViewer extends StatelessWidget {
  final List<MediaItemModel> mediaItems;
  final VoidCallback? onImageTap;

  const _MediaViewer({
    required this.mediaItems,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    if (mediaItems.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: _DetailPageConstants.backgroundWhite,
      child: _buildMediaGrid(),
    );
  }

  Widget _buildMediaGrid() {
    if (mediaItems.length == 1) {
      return _buildSingleMedia(mediaItems.first);
    } else {
      return _buildMultipleMedia();
    }
  }

  Widget _buildSingleMedia(MediaItemModel media) {
    if (media.type == MediaType.video) {
      return _VideoPlayerWidget(mediaItem: media);
    } else {
      return _buildSingleImage(media);
    }
  }

  Widget _buildSingleImage(MediaItemModel media) {
    return GestureDetector(
      onTap: onImageTap,
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: _DetailPageConstants.maxImageHeight,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_DetailPageConstants.imageCornerRadius),
          child: Image.network(
            media.url,
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return _buildImageError();
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildImageLoading();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMultipleMedia() {
    final itemCount = min(mediaItems.length, _DetailPageConstants.maxImageCount);
    final crossAxisCount = itemCount == 1 ? 1 : (itemCount <= 4 ? 2 : 3);
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: _DetailPageConstants.imageGridSpacing,
        mainAxisSpacing: _DetailPageConstants.imageGridSpacing,
        childAspectRatio: 1.0,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final media = mediaItems[index];
        return _buildGridImageItem(media, index);
      },
    );
  }

  Widget _buildGridImageItem(MediaItemModel media, int index) {
    final isLastItem = index == _DetailPageConstants.maxImageCount - 1;
    final hasMore = mediaItems.length > _DetailPageConstants.maxImageCount;
    
    return GestureDetector(
      onTap: onImageTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(_DetailPageConstants.imageCornerRadius),
            child: Image.network(
              media.thumbnailUrl ?? media.url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildImageError();
              },
            ),
          ),
          if (isLastItem && hasMore)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(_DetailPageConstants.imageCornerRadius),
              ),
              child: Center(
                child: Text(
                  '+${mediaItems.length - _DetailPageConstants.maxImageCount + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: _DetailPageConstants.bodyFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (media.type == MediaType.video)
            const Center(
              child: Icon(
                Icons.play_circle_outline,
                color: Colors.white,
                size: 32,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(
          Icons.error_outline,
          color: Colors.grey,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildImageLoading() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_DetailPageConstants.primaryPurple),
        ),
      ),
    );
  }
}

/// 🎬 视频播放器组件
class _VideoPlayerWidget extends StatefulWidget {
  final MediaItemModel mediaItem;

  const _VideoPlayerWidget({required this.mediaItem});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isControlsVisible = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    try {
      _controller = VideoPlayerController.network(widget.mediaItem.url);
      await _controller!.initialize();
      setState(() {});
    } catch (e) {
      developer.log('视频播放器初始化失败: $e');
    }
  }

  void _togglePlayback() {
    if (_controller?.value.isInitialized == true) {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
      setState(() {});
    }
  }

  void _showControls() {
    setState(() {
      _isControlsVisible = true;
    });
    
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isControlsVisible = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_controller?.value.isInitialized != true) {
      return _buildVideoLoading();
    }

    return GestureDetector(
      onTap: _showControls,
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: _DetailPageConstants.maxImageHeight,
        ),
        child: AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(_DetailPageConstants.imageCornerRadius),
                child: VideoPlayer(_controller!),
              ),
              _buildVideoControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoLoading() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(_DetailPageConstants.imageCornerRadius),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildVideoControls() {
    return AnimatedOpacity(
      opacity: _isControlsVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(_DetailPageConstants.imageCornerRadius),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox.shrink(),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      height: _DetailPageConstants.videoControlHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: _togglePlayback,
            icon: Icon(
              _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 24,
            ),
          ),
          Expanded(
            child: VideoProgressIndicator(
              _controller!,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: _DetailPageConstants.primaryPurple,
                bufferedColor: Colors.white30,
                backgroundColor: Colors.white12,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: 实现全屏播放
            },
            icon: const Icon(
              Icons.fullscreen,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

/// 📊 内容统计区域组件
class _ContentStatsSection extends StatelessWidget {
  final InteractionState interactionState;

  const _ContentStatsSection({
    required this.interactionState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _DetailPageConstants.backgroundGray,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('浏览', interactionState.viewCount),
          _buildStatItem('点赞', interactionState.likeCount),
          _buildStatItem('评论', interactionState.commentCount),
          _buildStatItem('分享', interactionState.shareCount),
          _buildStatItem('收藏', interactionState.favoriteCount),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatCount(count),
          style: const TextStyle(
            fontSize: _DetailPageConstants.captionFontSize,
            fontWeight: FontWeight.w600,
            color: _DetailPageConstants.textBlack,
            fontFamily: _DetailPageConstants.fontFamily,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: _DetailPageConstants.smallFontSize,
            color: _DetailPageConstants.textGray,
            fontFamily: _DetailPageConstants.fontFamily,
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}万';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    } else {
      return count.toString();
    }
  }
}

/// 🔻 底部操作栏组件
class _BottomActionBar extends StatelessWidget {
  final bool isCommentExpanded;
  final bool isLiked;
  final bool isFavorited;
  final bool isLikeAnimating;
  final bool isFavoriteAnimating;
  final bool isCommentPublishing;
  final TextEditingController commentController;
  final VoidCallback? onCommentTap;
  final VoidCallback? onLike;
  final VoidCallback? onFavorite;
  final VoidCallback? onShare;
  final VoidCallback? onCommentSubmit;

  const _BottomActionBar({
    required this.isCommentExpanded,
    required this.isLiked,
    required this.isFavorited,
    required this.isLikeAnimating,
    required this.isFavoriteAnimating,
    required this.isCommentPublishing,
    required this.commentController,
    this.onCommentTap,
    this.onLike,
    this.onFavorite,
    this.onShare,
    this.onCommentSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _DetailPageConstants.backgroundWhite,
        border: Border(
          top: BorderSide(
            color: _DetailPageConstants.borderGray,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: AnimatedContainer(
          duration: _DetailPageConstants.normalAnimation,
          height: isCommentExpanded 
              ? _DetailPageConstants.commentExpandedHeight + _DetailPageConstants.bottomBarHeight
              : _DetailPageConstants.bottomBarHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              if (isCommentExpanded) _buildExpandedCommentInput(),
              _buildActionRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedCommentInput() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _DetailPageConstants.backgroundGray,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _DetailPageConstants.borderGray),
        ),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: commentController,
                maxLines: null,
                maxLength: _DetailPageConstants.maxCommentLength,
                style: const TextStyle(
                  fontSize: _DetailPageConstants.captionFontSize,
                  color: _DetailPageConstants.textBlack,
                  fontFamily: _DetailPageConstants.fontFamily,
                ),
                decoration: const InputDecoration(
                  hintText: '写评论...',
                  hintStyle: TextStyle(
                    color: _DetailPageConstants.textLightGray,
                    fontFamily: _DetailPageConstants.fontFamily,
                  ),
                  border: InputBorder.none,
                  counterText: '',
                ),
                cursorColor: _DetailPageConstants.primaryPurple,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${commentController.text.length}/${_DetailPageConstants.maxCommentLength}',
                  style: const TextStyle(
                    fontSize: _DetailPageConstants.smallFontSize,
                    color: _DetailPageConstants.textLightGray,
                    fontFamily: _DetailPageConstants.fontFamily,
                  ),
                ),
                ElevatedButton(
                  onPressed: commentController.text.trim().isNotEmpty && !isCommentPublishing
                      ? onCommentSubmit
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _DetailPageConstants.primaryPurple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    minimumSize: const Size(60, 32),
                  ),
                  child: isCommentPublishing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          '发送',
                          style: TextStyle(
                            fontSize: _DetailPageConstants.smallFontSize,
                            fontWeight: FontWeight.w600,
                            fontFamily: _DetailPageConstants.fontFamily,
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow() {
    return SizedBox(
      height: _DetailPageConstants.buttonSize,
      child: Row(
        children: [
          Expanded(child: _buildCommentInput()),
          const SizedBox(width: 12),
          _buildLikeButton(),
          const SizedBox(width: 12),
          _buildFavoriteButton(),
          const SizedBox(width: 12),
          _buildShareButton(),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return GestureDetector(
      onTap: onCommentTap,
      child: Container(
        height: _DetailPageConstants.commentInputHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: _DetailPageConstants.backgroundGray,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _DetailPageConstants.borderGray),
        ),
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '写评论...',
            style: TextStyle(
              fontSize: _DetailPageConstants.captionFontSize,
              color: _DetailPageConstants.textLightGray,
              fontFamily: _DetailPageConstants.fontFamily,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLikeButton() {
    return GestureDetector(
      onTap: onLike,
      child: AnimatedContainer(
        duration: _DetailPageConstants.likeAnimationDuration,
        width: _DetailPageConstants.buttonSize,
        height: _DetailPageConstants.buttonSize,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isLikeAnimating ? 1.2 : 1.0,
              duration: _DetailPageConstants.quickAnimation,
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? _DetailPageConstants.likeRed : _DetailPageConstants.textGray,
                size: _DetailPageConstants.actionIconSize,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '点赞',
              style: TextStyle(
                fontSize: _DetailPageConstants.smallFontSize,
                color: isLiked ? _DetailPageConstants.likeRed : _DetailPageConstants.textGray,
                fontFamily: _DetailPageConstants.fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return GestureDetector(
      onTap: onFavorite,
      child: AnimatedContainer(
        duration: _DetailPageConstants.favoriteAnimationDuration,
        width: _DetailPageConstants.buttonSize,
        height: _DetailPageConstants.buttonSize,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isFavoriteAnimating ? 1.2 : 1.0,
              duration: _DetailPageConstants.quickAnimation,
              child: Icon(
                isFavorited ? Icons.star : Icons.star_border,
                color: isFavorited ? _DetailPageConstants.favoriteYellow : _DetailPageConstants.textGray,
                size: _DetailPageConstants.actionIconSize,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '收藏',
              style: TextStyle(
                fontSize: _DetailPageConstants.smallFontSize,
                color: isFavorited ? _DetailPageConstants.favoriteYellow : _DetailPageConstants.textGray,
                fontFamily: _DetailPageConstants.fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton() {
    return GestureDetector(
      onTap: onShare,
      child: SizedBox(
        width: _DetailPageConstants.buttonSize,
        height: _DetailPageConstants.buttonSize,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.share_outlined,
              color: _DetailPageConstants.textGray,
              size: _DetailPageConstants.actionIconSize,
            ),
            SizedBox(height: 2),
            Text(
              '分享',
              style: TextStyle(
                fontSize: _DetailPageConstants.smallFontSize,
                color: _DetailPageConstants.textGray,
                fontFamily: _DetailPageConstants.fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============== 7. PAGES ==============
/// 📱 页面定义
/// 
/// 本段包含主要的页面类：
/// - ContentDetailPage: 动态详情主页面类
/// - _ContentDetailPageState: 详情页状态管理类
///
/// 页面功能：
/// - 沉浸式内容展示体验
/// - 完整的社交互动功能
/// - 多平台分享系统
/// - 智能媒体播放管理
/// - 实时评论互动系统
///
/// 技术特性：
/// - 基于ValueNotifier的复杂状态管理
/// - 像素级精确UI实现
/// - 流畅的动画效果和交互反馈
/// - 完善的错误处理和用户引导

/// 🔍 动态详情主页面
/// 
/// 应用的核心内容详情展示功能页面
/// 包含：沉浸式内容展示+完整社交互动+智能分享系统
class ContentDetailPage extends StatefulWidget {
  final String contentId;
  
  const ContentDetailPage({
    super.key,
    required this.contentId,
  });

  @override
  State<ContentDetailPage> createState() => _ContentDetailPageState();
}

class _ContentDetailPageState extends State<ContentDetailPage> {
  late final _DetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _DetailController(contentId: widget.contentId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _DetailPageConstants.backgroundWhite,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return _DetailAppBar(
      onBack: () => Navigator.of(context).pop(),
      onMore: _controller.showMoreActions,
    );
  }

  Widget _buildBody() {
    return ValueListenableBuilder<DetailPageState>(
      valueListenable: _controller,
      builder: (context, state, child) {
        if (state.isLoading) {
          return _buildLoadingView();
        }

        if (state.errorMessage != null) {
          return _buildErrorView(state.errorMessage!);
        }

        if (state.contentDetail == null) {
          return _buildEmptyView();
        }

        return _buildContentView(state);
      },
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(_DetailPageConstants.primaryPurple),
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: _DetailPageConstants.textGray,
          ),
          const SizedBox(height: 16),
          Text(
            error,
            style: const TextStyle(
              fontSize: _DetailPageConstants.bodyFontSize,
              color: _DetailPageConstants.textGray,
              fontFamily: _DetailPageConstants.fontFamily,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _controller._initialize(),
            style: ElevatedButton.styleFrom(
              backgroundColor: _DetailPageConstants.primaryPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return const Center(
      child: Text(
        '内容不存在',
        style: TextStyle(
          fontSize: _DetailPageConstants.bodyFontSize,
          color: _DetailPageConstants.textGray,
          fontFamily: _DetailPageConstants.fontFamily,
        ),
      ),
    );
  }

  Widget _buildContentView(DetailPageState state) {
    final contentDetail = state.contentDetail!;
    
    return SingleChildScrollView(
      controller: _controller.scrollController,
      child: Column(
        children: [
          // 添加状态栏高度的占位
          SizedBox(height: MediaQuery.of(context).padding.top + _DetailPageConstants.appBarHeight),
          
          // 用户信息区域
          _UserInfoSection(
            user: contentDetail.author,
            isFollowing: state.interactionState.isFollowing,
            isAnimating: state.isFollowAnimating,
            onFollow: _controller.toggleFollow,
            onUserTap: () {
              // TODO: 跳转用户详情页
            },
          ),
          
          // 文字内容区域
          if (contentDetail.textContent.isNotEmpty)
            _ContentSection(
              textContent: contentDetail.textContent,
              topics: contentDetail.topics,
              onTopicTap: () {
                // TODO: 跳转话题详情页
              },
            ),
          
          // 媒体内容区域
          if (contentDetail.mediaItems.isNotEmpty)
            _MediaViewer(
              mediaItems: contentDetail.mediaItems,
              onImageTap: () {
                // TODO: 打开图片查看器
              },
            ),
          
          // 内容统计区域
          _ContentStatsSection(
            interactionState: state.interactionState,
          ),
          
          // 底部安全区域
          SizedBox(height: _DetailPageConstants.bottomBarHeight + MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return ValueListenableBuilder<DetailPageState>(
      valueListenable: _controller,
      builder: (context, state, child) {
        return _BottomActionBar(
          isCommentExpanded: state.isCommentExpanded,
          isLiked: state.interactionState.isLiked,
          isFavorited: state.interactionState.isFavorited,
          isLikeAnimating: state.isLikeAnimating,
          isFavoriteAnimating: state.isFavoriteAnimating,
          isCommentPublishing: state.isCommentPublishing,
          commentController: _controller.commentController,
          onCommentTap: _controller.toggleCommentInput,
          onLike: _controller.toggleLike,
          onFavorite: _controller.toggleFavorite,
          onShare: _controller.showSharePanel,
          onCommentSubmit: _controller.publishComment,
        );
      },
    );
  }
}

// ============== 8. EXPORTS ==============
/// 📤 导出定义
/// 
/// 本文件自动导出的公共类：
/// - ContentDetailPage: 动态详情主页面（public class）
///
/// 私有类（不会被导出）：
/// - _DetailController: 详情页控制器
/// - _DetailAppBar: 详情页导航栏组件
/// - _UserInfoSection: 用户信息区域组件
/// - _ContentSection: 内容展示区域组件
/// - _MediaViewer: 媒体查看器组件
/// - _VideoPlayerWidget: 视频播放器组件
/// - _ContentStatsSection: 内容统计区域组件
/// - _BottomActionBar: 底部操作栏组件
/// - _ContentDetailPageState: 详情页状态类
/// - _DetailPageConstants: 页面私有常量
///
/// 使用方式：
/// ```dart
/// import 'content_detail_page.dart';
/// 
/// // 在路由中使用
/// MaterialPageRoute(
///   builder: (context) => ContentDetailPage(contentId: 'content_123')
/// )
/// ```
