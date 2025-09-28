// 📝 发布动态页面主页面 - 单文件架构完整实现
// 基于Flutter单文件架构规范的8段式结构设计
// 实现超大型多功能编辑模块：文字编辑+媒体处理+话题选择+地点选择+草稿管理

// ============== 1. IMPORTS ==============
// Flutter核心库
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

// Dart核心库
import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;

// 第三方库
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

// 项目内部文件 - 按依赖关系排序
import '../models/publish_models.dart';        // 发布相关数据模型
import '../services/publish_services.dart';      // 发布业务服务
import '../utils/publish_state_manager.dart'; // 发布状态管理器
import 'topic_selector_page.dart';   // 话题选择页面
import 'location_picker_page.dart';  // 地点选择页面

// ============== 2. CONSTANTS ==============
/// 🎨 发布页面私有常量（页面级别）
class _PublishPageConstants {
  // 私有构造函数，防止实例化
  const _PublishPageConstants._();
  
  // 页面标识
  static const String pageTitle = '发布动态';
  static const String routeName = '/publish';
  
  // UI尺寸配置（像素级精确规格）
  static const double appBarHeight = 56.0;
  static const double userInfoBarHeight = 56.0;
  static const double textInputMinHeight = 120.0;
  static const double textInputMaxHeight = 400.0;
  static const double mediaGridItemSize = 80.0;
  static const double mediaGridSpacing = 8.0;
  static const double contentPadding = 16.0;
  static const double buttonHeight = 48.0;
  static const double userAvatarSize = 40.0;
  
  // 内容限制配置
  static const int maxTextLength = 2000;
  static const int minTextLength = 10;
  static const int maxImageCount = 9;
  static const int maxTopicCount = 5;
  static const int maxVideoLength = 60; // 秒
  static const int maxFileSize = 50 * 1024 * 1024; // 50MB
  
  // 动画时长配置
  static const Duration autoSaveInterval = Duration(seconds: 30);
  static const Duration inputDebounceDelay = Duration(milliseconds: 300);
  static const Duration animationDuration = Duration(milliseconds: 200);
  static const Duration longAnimationDuration = Duration(milliseconds: 300);
  
  // 颜色配置（精确颜色值）
  static const Color primaryPurple = Color(0xFF6C5CE7);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundGray = Color(0xFFF9FAFB);
  static const Color borderGray = Color(0xFFE5E7EB);
  static const Color textBlack = Color(0xFF2D3748);
  static const Color textGray = Color(0xFF74798C);
  static const Color textLightGray = Color(0xFF9CA3AF);
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
}

// 全局常量引用：PublishConstants 在 publish_models.dart 中定义

// ============== 3. MODELS ==============
/// 📋 数据模型引用
/// 主要模型定义在 publish_models.dart 中：
/// - PublishConstants: 全局发布常量配置
/// - DraftModel: 草稿数据模型
/// - MediaModel: 媒体文件模型
/// - TopicModel: 话题数据模型
/// - LocationModel: 地理位置模型
/// - PublishState: 发布页面状态模型
/// - MediaType: 媒体类型枚举（图片/视频/文件）
/// - PublishStatus: 发布状态枚举（草稿/发布中/成功/失败）

// ============== 4. SERVICES ==============
/// 🔧 业务服务引用
/// 主要服务定义在 publish_services.dart 中：
/// - PublishContentService: 发布页面数据服务
/// - DraftService: 草稿管理服务
/// - MediaService: 媒体处理服务
/// - TopicService: 话题管理服务
/// - PublishLocationService: 地理位置服务
/// 
/// 服务功能包括：
/// - 内容发布和草稿管理
/// - 媒体文件上传和处理
/// - 话题搜索和创建
/// - 地理位置获取和搜索
/// - 敏感词检测和内容审核

// ============== 5. CONTROLLERS ==============
/// 🧠 发布页面控制器
class _PublishController extends ValueNotifier<PublishState> {
  _PublishController() : super(const PublishState()) {
    _textController = TextEditingController();
    _scrollController = ScrollController();
    _initialize();
  }

  late TextEditingController _textController;
  late ScrollController _scrollController;
  final PublishStateManager _publishStateManager = PublishStateManager();
  Timer? _autoSaveTimer;
  Timer? _debounceTimer;

  TextEditingController get textController => _textController;
  ScrollController get scrollController => _scrollController;

  /// 初始化页面数据
  Future<void> _initialize() async {
    try {
      value = value.copyWith(isLoading: true);

      // 并发加载初始化数据
      final results = await Future.wait([
        _loadUserInfo(),
        _loadDraftIfExists(),
        _checkPermissions(),
        _initializeAutoSave(),
      ]);

      value = value.copyWith(
        isLoading: false,
      );

      // 设置文本监听器
      _textController.addListener(_onTextChanged);
      
      developer.log('发布页面初始化完成');
    } catch (e) {
      value = value.copyWith(
        isLoading: false,
        errorMessage: '初始化失败，请重试',
      );
      developer.log('发布页面初始化失败: $e');
    }
  }

  /// 加载用户信息
  Future<PublishUserModel?> _loadUserInfo() async {
    try {
      return await PublishContentService.getCurrentUser();
    } catch (e) {
      developer.log('加载用户信息失败: $e');
      return null;
    }
  }

  /// 加载存在的草稿
  Future<void> _loadDraftIfExists() async {
    try {
      final draft = await DraftService.getLatestDraft();
      if (draft != null) {
        _restoreDraft(draft);
      }
    } catch (e) {
      developer.log('加载草稿失败: $e');
    }
  }

  /// 检查权限状态
  Future<bool> _checkPermissions() async {
    try {
      final cameraStatus = await Permission.camera.status;
      final storageStatus = await Permission.storage.status;
      return cameraStatus.isGranted && storageStatus.isGranted;
    } catch (e) {
      developer.log('检查权限失败: $e');
      return false;
    }
  }

  /// 初始化自动保存
  Future<void> _initializeAutoSave() async {
    _autoSaveTimer = Timer.periodic(
      _PublishPageConstants.autoSaveInterval,
      (_) => _autoSaveDraft(),
    );
  }

  /// 文本变化监听
  void _onTextChanged() {
    final text = _textController.text;
    final characterCount = text.length;
    
    // 更新字数统计
    value = value.copyWith(
      textContent: text,
      characterCount: characterCount,
      isTextValid: _validateTextContent(text),
    );

    // 防抖保存草稿
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      _PublishPageConstants.inputDebounceDelay,
      () => _autoSaveDraft(),
    );

    // 检测话题标签
    _detectTopicTags(text);
  }

  /// 验证文本内容
  bool _validateTextContent(String text) {
    if (text.trim().isEmpty && value.mediaFiles.isEmpty) {
      return false;
    }
    if (text.length > _PublishPageConstants.maxTextLength) {
      return false;
    }
    return true;
  }

  /// 检测话题标签
  void _detectTopicTags(String text) {
    final RegExp topicRegex = RegExp(r'#([^\s#]+)#?');
    final matches = topicRegex.allMatches(text);
    
    final detectedTopics = matches
        .map((match) => match.group(1))
        .where((topic) => topic != null)
        .cast<String>()
        .take(_PublishPageConstants.maxTopicCount)
        .toList();

    if (detectedTopics.isNotEmpty) {
      // 将字符串列表转换为 TopicModel 列表
      final topicModels = detectedTopics.map((topic) => TopicModel(
        id: topic.hashCode.toString(),
        name: topic,
        displayName: topic,
        category: 'auto', // 使用字符串而不是 TopicCategoryModel
        isHot: false,
        contentCount: 0,
        createdAt: DateTime.now(),
      )).toList();
      
      value = value.copyWith(detectedTopics: topicModels.cast<TopicModel>());
    }
  }

  /// 自动保存草稿
  Future<void> _autoSaveDraft() async {
    if (!_shouldSaveDraft()) return;

    try {
      final draft = DraftModel(
        id: value.draftId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        content: PublishContentModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: value.textContent,
          textContent: value.textContent,
          mediaItems: value.mediaItems,
          mediaFiles: value.mediaFiles,
          topics: value.selectedTopics,
          location: value.selectedLocation,
          user: PublishUserModel(
            id: 'current_user',
            nickname: 'Current User',
            avatar: '',
            avatarUrl: '',
          ),
          createdAt: DateTime.now(),
        ),
        textContent: value.textContent,
        mediaFiles: value.mediaFiles,
        selectedTopics: value.selectedTopics,
        selectedLocation: value.selectedLocation,
        privacy: value.privacy,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastModified: DateTime.now(),
      );

      await DraftService.saveDraft(draft);
      
      value = value.copyWith(
        draftId: draft.id,
        lastSaved: DateTime.now(),
      );

      // 更新全局草稿状态
      _publishStateManager.saveDraft(draft.id);

      developer.log('草稿自动保存成功: ${draft.id}');
    } catch (e) {
      developer.log('自动保存草稿失败: $e');
    }
  }

  /// 判断是否需要保存草稿
  bool _shouldSaveDraft() {
    return value.textContent.trim().isNotEmpty ||
           value.mediaFiles.isNotEmpty ||
           value.selectedTopics.isNotEmpty ||
           value.selectedLocation != null;
  }

  /// 恢复草稿内容
  void _restoreDraft(DraftModel draft) {
    _textController.text = draft.textContent;
    
    value = value.copyWith(
      draftId: draft.id,
      textContent: draft.textContent,
      mediaFiles: draft.mediaFiles,
      selectedTopics: draft.selectedTopics,
      selectedLocation: draft.selectedLocation,
      privacy: draft.privacy,
      characterCount: draft.textContent.length,
      isTextValid: _validateTextContent(draft.textContent),
      lastSaved: draft.lastModified,
    );
  }

  /// 添加媒体文件
  Future<void> addMediaFiles() async {
    if (value.mediaFiles.length >= _PublishPageConstants.maxImageCount) {
      _showError('最多只能添加${_PublishPageConstants.maxImageCount}个媒体文件');
      return;
    }

    try {
      // 显示媒体选择菜单
      final source = await _showMediaSourceSelector();
      if (source == null) return;

      value = value.copyWith(isMediaProcessing: true);

      List<XFile>? files;
      switch (source) {
        case MediaSource.camera:
          final file = await ImagePicker().pickImage(source: ImageSource.camera);
          files = file != null ? [file] : null;
          break;
        case MediaSource.gallery:
          files = await ImagePicker().pickMultiImage();
          break;
        case MediaSource.video:
          final file = await ImagePicker().pickVideo(source: ImageSource.camera);
          files = file != null ? [file] : null;
          break;
        case MediaSource.file:
          files = await ImagePicker().pickMultiImage();
          break;
      }

      if (files == null || files.isEmpty) {
        value = value.copyWith(isMediaProcessing: false);
        return;
      }

      // 处理选择的文件
      final mediaFiles = <MediaModel>[];
      for (final file in files) {
        if (mediaFiles.length + value.mediaFiles.length >= _PublishPageConstants.maxImageCount) {
          break;
        }

        final mediaFile = await _processMediaFile(file);
        if (mediaFile != null) {
          mediaFiles.add(mediaFile);
        }
      }

      final updatedMediaFiles = List<MediaModel>.from(value.mediaFiles)
        ..addAll(mediaFiles);

      value = value.copyWith(
        mediaFiles: updatedMediaFiles,
        isMediaProcessing: false,
      );

      developer.log('添加媒体文件成功: ${mediaFiles.length}个');
    } catch (e) {
      value = value.copyWith(isMediaProcessing: false);
      _showError('添加媒体文件失败: $e');
      developer.log('添加媒体文件失败: $e');
    }
  }

  /// 显示媒体来源选择器
  Future<MediaSource?> _showMediaSourceSelector() async {
    // TODO: 实现媒体来源选择弹窗
    return MediaSource.gallery; // 临时返回
  }

  /// 处理媒体文件
  Future<MediaModel?> _processMediaFile(XFile file) async {
    try {
      // 验证文件大小
      final fileSize = await file.length();
      if (fileSize > _PublishPageConstants.maxFileSize) {
        _showError('文件大小超过限制(${_PublishPageConstants.maxFileSize ~/ 1024 ~/ 1024}MB)');
        return null;
      }

      // 创建媒体模型
      final mediaModel = MediaModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: _getMediaTypeFromPath(file.path),
        source: MediaSource.gallery,
        localPath: file.path,
        filePath: file.path,
        fileSize: fileSize,
        uploadStatus: UploadStatus.pending,
        createdAt: DateTime.now(),
      );

      // 开始上传处理
      _uploadMediaFile(mediaModel);

      return mediaModel;
    } catch (e) {
      developer.log('处理媒体文件失败: $e');
      return null;
    }
  }

  /// 根据文件路径获取媒体类型
  MediaType _getMediaTypeFromPath(String path) {
    final extension = path.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'webp':
      case 'heic':
        return MediaType.image;
      case 'mp4':
      case 'mov':
      case 'avi':
        return MediaType.video;
      default:
        return MediaType.image; // 默认作为图片处理
    }
  }

  /// 上传媒体文件
  Future<void> _uploadMediaFile(MediaModel media) async {
    try {
      // 更新上传状态
      _updateMediaUploadStatus(media.id, UploadStatus.uploading);

      // 调用上传服务
      final uploadedMedia = await MediaService.uploadFile(
        File(media.filePath),
        onProgress: (progress) {
          _updateMediaUploadProgress(media.id, progress);
        },
      );

      // 更新为上传成功
      _updateMediaUploadStatus(media.id, UploadStatus.completed);
      _updateMediaUrl(media.id, uploadedMedia.url);

      developer.log('媒体文件上传成功: ${media.id}');
    } catch (e) {
      _updateMediaUploadStatus(media.id, UploadStatus.failed);
      developer.log('媒体文件上传失败: ${media.id}, $e');
    }
  }

  /// 更新媒体上传状态
  void _updateMediaUploadStatus(String mediaId, UploadStatus status) {
    final updatedMediaFiles = value.mediaFiles.map((media) {
      if (media.id == mediaId) {
        return media.copyWith(uploadStatus: status);
      }
      return media;
    }).toList();

    value = value.copyWith(mediaFiles: updatedMediaFiles);
  }

  /// 更新媒体上传进度
  void _updateMediaUploadProgress(String mediaId, double progress) {
    final updatedMediaFiles = value.mediaFiles.map((media) {
      if (media.id == mediaId) {
        return media.copyWith(uploadProgress: progress);
      }
      return media;
    }).toList();

    value = value.copyWith(mediaFiles: updatedMediaFiles);
  }

  /// 更新媒体URL
  void _updateMediaUrl(String mediaId, String? url) {
    final updatedMediaFiles = value.mediaFiles.map((media) {
      if (media.id == mediaId) {
        return media.copyWith(url: url);
      }
      return media;
    }).toList();

    value = value.copyWith(mediaFiles: updatedMediaFiles);
  }

  /// 删除媒体文件
  void removeMediaFile(String mediaId) {
    final updatedMediaFiles = value.mediaFiles
        .where((media) => media.id != mediaId)
        .toList();

    value = value.copyWith(mediaFiles: updatedMediaFiles);
    developer.log('删除媒体文件: $mediaId');
  }

  /// 打开话题选择页面
  Future<void> openTopicSelector(BuildContext context) async {
    try {
      final selectedTopics = await Navigator.push<List<TopicModel>>(
        context,
        MaterialPageRoute(
          builder: (context) => const TopicSelectorPage(),
        ),
      );

      if (selectedTopics != null) {
        value = value.copyWith(selectedTopics: selectedTopics);
        developer.log('选择话题完成: ${selectedTopics.length}个');
      }
    } catch (e) {
      _showError('打开话题选择失败: $e');
      developer.log('打开话题选择失败: $e');
    }
  }

  /// 打开地点选择页面
  Future<void> openLocationPicker(BuildContext context) async {
    try {
      final selectedLocation = await Navigator.push<LocationModel>(
        context,
        MaterialPageRoute(
          builder: (context) => const LocationPickerPage(),
        ),
      );

      if (selectedLocation != null) {
        value = value.copyWith(selectedLocation: selectedLocation);
        developer.log('选择地点完成: ${selectedLocation.name}');
      }
    } catch (e) {
      _showError('打开地点选择失败: $e');
      developer.log('打开地点选择失败: $e');
    }
  }

  /// 发布内容
  Future<void> publishContent() async {
    if (!_validatePublishContent()) {
      return;
    }

    try {
      // 开始发布流程
      _publishStateManager.startPublishing(value.draftId);
      
      value = value.copyWith(
        publishStatus: PublishStatus.publishing,
        errorMessage: null,
      );

      // 构建发布内容
      final content = PublishContentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: value.textContent.trim(),
        textContent: value.textContent.trim(),
        mediaItems: value.mediaItems,
        mediaFiles: value.mediaFiles.where((m) => m.uploadStatus == UploadStatus.completed).toList(),
        topics: value.selectedTopics,
        location: value.selectedLocation,
        user: PublishUserModel(
          id: 'current_user',
          nickname: 'Current User',
          avatar: '',
          avatarUrl: '',
        ),
        createdAt: DateTime.now(),
      );

      // 调用发布服务
      await PublishContentService.publishContent(content);

      // 发布成功
      _publishStateManager.publishSuccess();
      value = value.copyWith(publishStatus: PublishStatus.success);

      // 清理草稿
      if (value.draftId != null) {
        await DraftService.deleteDraft(value.draftId!);
        _publishStateManager.deleteDraft(value.draftId!);
      }

      // 清空表单
      _clearForm();

      developer.log('内容发布成功: ${content.id}');
    } catch (e) {
      // 发布失败
      _publishStateManager.publishFailed(message: '发布失败: $e');
      
      value = value.copyWith(
        publishStatus: PublishStatus.failed,
        errorMessage: '发布失败: $e',
      );
      developer.log('内容发布失败: $e');
    }
  }

  /// 验证发布内容
  bool _validatePublishContent() {
    final text = value.textContent.trim();
    
    // 检查是否有内容
    if (text.isEmpty && value.mediaFiles.isEmpty) {
      _showError('请输入文字内容或添加媒体文件');
      return false;
    }

    // 检查文字长度
    if (text.isNotEmpty && text.length < _PublishPageConstants.minTextLength) {
      _showError('文字内容至少需要${_PublishPageConstants.minTextLength}个字符');
      return false;
    }

    if (text.length > _PublishPageConstants.maxTextLength) {
      _showError('文字内容不能超过${_PublishPageConstants.maxTextLength}个字符');
      return false;
    }

    // 检查媒体文件上传状态
    final pendingUploads = value.mediaFiles.where((m) => 
        m.uploadStatus == UploadStatus.uploading || 
        m.uploadStatus == UploadStatus.pending).toList();
        
    if (pendingUploads.isNotEmpty) {
      _showError('请等待媒体文件上传完成');
      return false;
    }

    final failedUploads = value.mediaFiles.where((m) => 
        m.uploadStatus == UploadStatus.failed).toList();
        
    if (failedUploads.isNotEmpty) {
      _showError('部分媒体文件上传失败，请重新上传');
      return false;
    }

    return true;
  }

  /// 清空表单
  void _clearForm() {
    _textController.clear();
    value = value.copyWith(
      draftId: null,
      textContent: '',
      mediaFiles: [],
      selectedTopics: [],
      selectedLocation: null,
      characterCount: 0,
      isTextValid: false,
      publishStatus: PublishStatus.draft,
      lastSaved: null,
    );
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

  /// 取消编辑
  Future<bool> cancelEditing() async {
    if (!_shouldSaveDraft()) {
      return true; // 没有内容，直接返回
    }

    // TODO: 显示确认对话框
    // final shouldSave = await _showCancelConfirmDialog();
    // if (shouldSave == true) {
    //   await _autoSaveDraft();
    // } else if (shouldSave == false) {
    //   // 放弃编辑，清理草稿
    //   if (value.draftId != null) {
    //     await DraftService.deleteDraft(value.draftId!);
    //   }
    // } else {
    //   return false; // 继续编辑
    // }

    return true;
  }

  /// 获取字数统计颜色
  Color getCharacterCountColor() {
    final count = value.characterCount;
    if (count > _PublishPageConstants.maxTextLength) {
      return _PublishPageConstants.dangerRed;
    } else if (count > _PublishPageConstants.maxTextLength * 0.9) {
      return _PublishPageConstants.dangerRed;
    } else if (count > _PublishPageConstants.maxTextLength * 0.8) {
      return _PublishPageConstants.warningOrange;
    }
    return _PublishPageConstants.textLightGray;
  }

  /// 获取发布按钮状态
  bool get canPublish {
    return value.publishStatus != PublishStatus.publishing &&
           _validateTextContent(value.textContent) &&
           value.mediaFiles.every((m) => m.uploadStatus != UploadStatus.uploading);
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _debounceTimer?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// ============== 6. WIDGETS ==============
/// 🧩 UI组件定义
/// 
/// 本段包含发布页面专用的UI组件：
/// - _PublishAppBar: 发布页面导航栏组件
/// - _UserInfoBar: 用户信息栏组件
/// - _TextInputArea: 文字输入区域组件
/// - _MediaUploadArea: 媒体上传区域组件
/// - _TopicLocationBar: 话题地点选择栏组件
/// - _PublishButton: 发布按钮组件
///
/// 设计原则：
/// - 像素级精确UI规格实现
/// - 复杂交互状态管理
/// - 动画效果流畅自然
/// - 响应式布局适配

/// 🔝 发布页面导航栏
class _PublishAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onCancel;
  final VoidCallback? onPublish;
  final bool canPublish;
  final PublishStatus publishStatus;

  const _PublishAppBar({
    this.onCancel,
    this.onPublish,
    required this.canPublish,
    required this.publishStatus,
  });

  @override
  Size get preferredSize => const Size.fromHeight(_PublishPageConstants.appBarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: _PublishPageConstants.backgroundWhite,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: _buildCancelButton(),
      title: _buildTitle(),
      actions: [_buildPublishButton()],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: _PublishPageConstants.borderGray,
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return TextButton(
      onPressed: onCancel,
      style: TextButton.styleFrom(
        foregroundColor: _PublishPageConstants.textGray,
        padding: EdgeInsets.zero,
      ),
      child: const Text(
        '取消',
        style: TextStyle(
          fontSize: _PublishPageConstants.bodyFontSize,
          fontFamily: _PublishPageConstants.fontFamily,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      _PublishPageConstants.pageTitle,
      style: TextStyle(
        fontSize: _PublishPageConstants.titleFontSize,
        fontWeight: FontWeight.w600,
        color: _PublishPageConstants.textBlack,
        fontFamily: _PublishPageConstants.fontFamily,
      ),
    );
  }

  Widget _buildPublishButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: TextButton(
        onPressed: canPublish ? onPublish : null,
        style: TextButton.styleFrom(
          foregroundColor: canPublish 
              ? _PublishPageConstants.primaryPurple 
              : _PublishPageConstants.textLightGray,
          padding: EdgeInsets.zero,
        ),
        child: _buildPublishButtonContent(),
      ),
    );
  }

  Widget _buildPublishButtonContent() {
    switch (publishStatus) {
      case PublishStatus.publishing:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _PublishPageConstants.primaryPurple,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Text('发布中...'),
          ],
        );
      case PublishStatus.success:
        return const Text('发布成功');
      case PublishStatus.failed:
        return const Text('发布失败');
      default:
        return const Text(
          '发布',
          style: TextStyle(
            fontSize: _PublishPageConstants.bodyFontSize,
            fontWeight: FontWeight.w600,
            fontFamily: _PublishPageConstants.fontFamily,
          ),
        );
    }
  }
}

/// 👤 用户信息栏组件
class _UserInfoBar extends StatelessWidget {
  final PublishUserModel? user;

  const _UserInfoBar({this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _PublishPageConstants.userInfoBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: _PublishPageConstants.contentPadding),
      color: _PublishPageConstants.backgroundWhite,
      child: Row(
        children: [
          _buildUserAvatar(),
          const SizedBox(width: 12),
          Expanded(child: _buildUserInfo()),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: _PublishPageConstants.userAvatarSize,
      height: _PublishPageConstants.userAvatarSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_PublishPageConstants.userAvatarSize / 2),
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
        borderRadius: BorderRadius.circular(_PublishPageConstants.userAvatarSize / 2),
        child: user?.avatarUrl != null
            ? Image.network(
                user!.avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultAvatar();
                },
              )
            : _buildDefaultAvatar(),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Text(
              user?.nickname ?? '用户',
              style: const TextStyle(
                fontSize: _PublishPageConstants.captionFontSize,
                fontWeight: FontWeight.w600,
                color: _PublishPageConstants.textBlack,
                fontFamily: _PublishPageConstants.fontFamily,
              ),
            ),
            if (user?.isVerified == true) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.verified,
                color: Colors.blue,
                size: 16,
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '已发布 ${user?.contentCount ?? 0} 条动态',
          style: const TextStyle(
            fontSize: _PublishPageConstants.smallFontSize,
            color: _PublishPageConstants.textGray,
            fontFamily: _PublishPageConstants.fontFamily,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        _buildActionButton(Icons.palette_outlined, '模板'),
        const SizedBox(width: 8),
        _buildActionButton(Icons.settings_outlined, '设置'),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String tooltip) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _PublishPageConstants.borderGray),
      ),
      child: IconButton(
        onPressed: () {
          // TODO: 实现按钮功能
        },
        icon: Icon(
          icon,
          size: 16,
          color: _PublishPageConstants.textGray,
        ),
        padding: EdgeInsets.zero,
        tooltip: tooltip,
      ),
    );
  }
}

/// 📝 文字输入区域组件
class _TextInputArea extends StatelessWidget {
  final TextEditingController controller;
  final int characterCount;
  final bool isValid;
  final String? errorMessage;
  final Color characterCountColor;

  const _TextInputArea({
    required this.controller,
    required this.characterCount,
    required this.isValid,
    this.errorMessage,
    required this.characterCountColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_PublishPageConstants.contentPadding),
      color: _PublishPageConstants.backgroundWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextInput(),
          const SizedBox(height: 8),
          _buildBottomBar(),
          if (errorMessage != null) ...[
            const SizedBox(height: 8),
            _buildErrorMessage(),
          ],
        ],
      ),
    );
  }

  Widget _buildTextInput() {
    return Container(
      constraints: const BoxConstraints(
        minHeight: _PublishPageConstants.textInputMinHeight,
        maxHeight: _PublishPageConstants.textInputMaxHeight,
      ),
      child: TextField(
        controller: controller,
        maxLines: null,
        maxLength: _PublishPageConstants.maxTextLength,
        style: const TextStyle(
          fontSize: _PublishPageConstants.bodyFontSize,
          height: _PublishPageConstants.lineHeight,
          color: _PublishPageConstants.textBlack,
          fontFamily: _PublishPageConstants.fontFamily,
        ),
        decoration: const InputDecoration(
          hintText: '分享你的生活...',
          hintStyle: TextStyle(
            color: _PublishPageConstants.textLightGray,
            fontStyle: FontStyle.italic,
            fontFamily: _PublishPageConstants.fontFamily,
          ),
          border: InputBorder.none,
          counterText: '', // 隐藏默认计数器
        ),
        cursorColor: _PublishPageConstants.primaryPurple,
        cursorWidth: 2,
        autofocus: true,
      ),
    );
  }

  Widget _buildBottomBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTopicTrigger(),
        _buildCharacterCount(),
      ],
    );
  }

  Widget _buildTopicTrigger() {
    return Text(
      '输入 # 添加话题',
      style: TextStyle(
        fontSize: _PublishPageConstants.smallFontSize,
        color: _PublishPageConstants.textLightGray,
        fontFamily: _PublishPageConstants.fontFamily,
      ),
    );
  }

  Widget _buildCharacterCount() {
    return Text(
      '$characterCount/${_PublishPageConstants.maxTextLength}',
      style: TextStyle(
        fontSize: _PublishPageConstants.smallFontSize,
        color: characterCountColor,
        fontFamily: _PublishPageConstants.fontFamily,
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _PublishPageConstants.dangerRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _PublishPageConstants.dangerRed.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 16,
            color: _PublishPageConstants.dangerRed,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMessage!,
              style: const TextStyle(
                fontSize: _PublishPageConstants.smallFontSize,
                color: _PublishPageConstants.dangerRed,
                fontFamily: _PublishPageConstants.fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🖼️ 媒体上传区域组件
class _MediaUploadArea extends StatelessWidget {
  final List<MediaModel> mediaFiles;
  final bool isProcessing;
  final VoidCallback? onAddMedia;
  final Function(String)? onRemoveMedia;

  const _MediaUploadArea({
    required this.mediaFiles,
    required this.isProcessing,
    this.onAddMedia,
    this.onRemoveMedia,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_PublishPageConstants.contentPadding),
      color: _PublishPageConstants.backgroundWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMediaGrid(),
          if (isProcessing) ...[
            const SizedBox(height: 12),
            _buildProcessingIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _buildMediaGrid() {
    const itemsPerRow = 3;
    final itemCount = mediaFiles.length + (mediaFiles.length < _PublishPageConstants.maxImageCount ? 1 : 0);
    final rows = (itemCount / itemsPerRow).ceil();

    return Column(
      children: List.generate(rows, (rowIndex) {
        final startIndex = rowIndex * itemsPerRow;
        final endIndex = (startIndex + itemsPerRow).clamp(0, itemCount);
        
        return Padding(
          padding: EdgeInsets.only(bottom: rowIndex < rows - 1 ? _PublishPageConstants.mediaGridSpacing : 0),
          child: Row(
            children: List.generate(itemsPerRow, (colIndex) {
              final itemIndex = startIndex + colIndex;
              
              if (itemIndex >= endIndex) {
                return Expanded(child: Container());
              }
              
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: colIndex < itemsPerRow - 1 ? _PublishPageConstants.mediaGridSpacing : 0,
                  ),
                  child: itemIndex < mediaFiles.length
                      ? _buildMediaItem(mediaFiles[itemIndex])
                      : _buildAddButton(),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildMediaItem(MediaModel media) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Stack(
        children: [
          _buildMediaPreview(media),
          _buildMediaOverlay(media),
          _buildDeleteButton(media),
        ],
      ),
    );
  }

  Widget _buildMediaPreview(MediaModel media) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[300],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: media.type == MediaType.image
            ? Image.file(
                File(media.filePath),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return _buildErrorPlaceholder();
                },
              )
            : _buildVideoPreview(media),
      ),
    );
  }

  Widget _buildVideoPreview(MediaModel media) {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Icon(
          Icons.play_circle_outline,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(
          Icons.error_outline,
          color: Colors.grey,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildMediaOverlay(MediaModel media) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: media.uploadStatus == UploadStatus.uploading 
              ? Colors.black.withOpacity(0.3)
              : Colors.transparent,
        ),
        child: _buildUploadStatus(media),
      ),
    );
  }

  Widget _buildUploadStatus(MediaModel media) {
    switch (media.uploadStatus) {
      case UploadStatus.uploading:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                value: media.uploadProgress,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
              const SizedBox(height: 4),
              Text(
                '${(media.uploadProgress * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      case UploadStatus.failed:
        return const Center(
          child: Icon(
            Icons.error,
            color: Colors.red,
            size: 24,
          ),
        );
      case UploadStatus.completed:
        return const Positioned(
          right: 4,
          bottom: 4,
          child: Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 16,
          ),
        );
      default:
        return Container();
    }
  }

  Widget _buildDeleteButton(MediaModel media) {
    return Positioned(
      right: -4,
      top: -4,
      child: GestureDetector(
        onTap: () => onRemoveMedia?.call(media.id),
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: _PublishPageConstants.dangerRed,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white, width: 1),
          ),
          child: const Icon(
            Icons.close,
            color: Colors.white,
            size: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return AspectRatio(
      aspectRatio: 1.0,
      child: GestureDetector(
        onTap: onAddMedia,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _PublishPageConstants.borderGray,
              width: 2,
              style: BorderStyle.solid,
            ),
            color: Colors.transparent,
          ),
          child: const Center(
            child: Icon(
              Icons.add,
              color: _PublishPageConstants.textLightGray,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _PublishPageConstants.primaryPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                _PublishPageConstants.primaryPurple,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            '正在处理媒体文件...',
            style: TextStyle(
              fontSize: _PublishPageConstants.smallFontSize,
              color: _PublishPageConstants.primaryPurple,
              fontFamily: _PublishPageConstants.fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}

/// 🏷️ 话题地点选择栏组件
class _TopicLocationBar extends StatelessWidget {
  final List<TopicModel> selectedTopics;
  final LocationModel? selectedLocation;
  final VoidCallback? onTopicTap;
  final VoidCallback? onLocationTap;

  const _TopicLocationBar({
    required this.selectedTopics,
    this.selectedLocation,
    this.onTopicTap,
    this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_PublishPageConstants.contentPadding),
      color: _PublishPageConstants.backgroundWhite,
      child: Column(
        children: [
          _buildTopicSection(),
          const SizedBox(height: 12),
          _buildLocationSection(),
        ],
      ),
    );
  }

  Widget _buildTopicSection() {
    return GestureDetector(
      onTap: onTopicTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: _PublishPageConstants.borderGray),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.tag,
              color: _PublishPageConstants.textGray,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: _buildTopicContent()),
            const Icon(
              Icons.chevron_right,
              color: _PublishPageConstants.textGray,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicContent() {
    if (selectedTopics.isEmpty) {
      return const Text(
        '选择话题',
        style: TextStyle(
          fontSize: _PublishPageConstants.captionFontSize,
          color: _PublishPageConstants.textLightGray,
          fontFamily: _PublishPageConstants.fontFamily,
        ),
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: selectedTopics.map((topic) => _buildTopicChip(topic)).toList(),
    );
  }

  Widget _buildTopicChip(TopicModel topic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _PublishPageConstants.primaryPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '#${topic.name}',
        style: const TextStyle(
          fontSize: _PublishPageConstants.smallFontSize,
          color: _PublishPageConstants.primaryPurple,
          fontFamily: _PublishPageConstants.fontFamily,
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return GestureDetector(
      onTap: onLocationTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: _PublishPageConstants.borderGray),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: _PublishPageConstants.textGray,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: _buildLocationContent()),
            const Icon(
              Icons.chevron_right,
              color: _PublishPageConstants.textGray,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationContent() {
    if (selectedLocation == null) {
      return const Text(
        '选择地点',
        style: TextStyle(
          fontSize: _PublishPageConstants.captionFontSize,
          color: _PublishPageConstants.textLightGray,
          fontFamily: _PublishPageConstants.fontFamily,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          selectedLocation!.name,
          style: const TextStyle(
            fontSize: _PublishPageConstants.captionFontSize,
            color: _PublishPageConstants.textBlack,
            fontWeight: FontWeight.w500,
            fontFamily: _PublishPageConstants.fontFamily,
          ),
        ),
        if (selectedLocation!.address?.isNotEmpty == true) ...[
          const SizedBox(height: 2),
          Text(
            selectedLocation!.address!,
            style: const TextStyle(
              fontSize: _PublishPageConstants.smallFontSize,
              color: _PublishPageConstants.textGray,
              fontFamily: _PublishPageConstants.fontFamily,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

// ============== 7. PAGES ==============
/// 📱 页面定义
/// 
/// 本段包含主要的页面类：
/// - PublishContentPage: 发布动态主页面类
/// - _PublishContentPageState: 发布页面状态管理类
///
/// 页面功能：
/// - 多媒体内容编辑和上传
/// - 文字内容输入和话题标签
/// - 地理位置选择和隐私设置
/// - 草稿自动保存和恢复
/// - 发布状态管理和错误处理
///
/// 技术特性：
/// - 基于ValueNotifier的复杂状态管理
/// - 像素级精确UI实现
/// - 流畅的动画效果和交互反馈
/// - 完善的错误处理和用户引导

/// 📝 发布动态主页面
/// 
/// 应用的核心内容创作功能页面
/// 包含：文字编辑+媒体上传+话题选择+地点选择+草稿管理
class PublishContentPage extends StatefulWidget {
  const PublishContentPage({super.key});

  @override
  State<PublishContentPage> createState() => _PublishContentPageState();
}

class _PublishContentPageState extends State<PublishContentPage> {
  late final _PublishController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _PublishController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Scaffold(
        backgroundColor: _PublishPageConstants.backgroundGray,
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  Future<bool> _handleWillPop() async {
    return await _controller.cancelEditing();
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ValueListenableBuilder<PublishState>(
        valueListenable: _controller,
        builder: (context, state, child) {
          return _PublishAppBar(
            onCancel: _handleCancel,
            onPublish: _handlePublish,
            canPublish: _controller.canPublish,
            publishStatus: state.publishStatus ?? PublishStatus.draft,
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    return ValueListenableBuilder<PublishState>(
      valueListenable: _controller,
      builder: (context, state, child) {
        if (state.isLoading) {
          return _buildLoadingView();
        }

        return SingleChildScrollView(
          controller: _controller.scrollController,
          child: Column(
            children: [
              _buildUserInfoBar(state),
              _buildDivider(),
              _buildTextInputArea(state),
              _buildDivider(),
              _buildMediaUploadArea(state),
              _buildDivider(),
              _buildTopicLocationBar(state),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(_PublishPageConstants.primaryPurple),
      ),
    );
  }

  Widget _buildUserInfoBar(PublishState state) {
    return _UserInfoBar(user: state.user);
  }

  Widget _buildTextInputArea(PublishState state) {
    return _TextInputArea(
      controller: _controller.textController,
      characterCount: state.characterCount,
      isValid: state.isTextValid,
      errorMessage: state.errorMessage,
      characterCountColor: _controller.getCharacterCountColor(),
    );
  }

  Widget _buildMediaUploadArea(PublishState state) {
    return _MediaUploadArea(
      mediaFiles: state.mediaFiles,
      isProcessing: state.isMediaProcessing,
      onAddMedia: _controller.addMediaFiles,
      onRemoveMedia: _controller.removeMediaFile,
    );
  }

  Widget _buildTopicLocationBar(PublishState state) {
    return _TopicLocationBar(
      selectedTopics: state.selectedTopics,
      selectedLocation: state.selectedLocation,
      onTopicTap: () => _controller.openTopicSelector(context),
      onLocationTap: () => _controller.openLocationPicker(context),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 8,
      color: _PublishPageConstants.backgroundGray,
    );
  }

  void _handleCancel() async {
    final shouldExit = await _controller.cancelEditing();
    if (shouldExit) {
      Navigator.of(context).pop();
    }
  }

  void _handlePublish() async {
    await _controller.publishContent();
    
    // 监听发布状态
    _controller.addListener(() {
      final state = _controller.value;
      if (state.publishStatus == PublishStatus.success) {
        // 发布成功，返回上一页
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('发布成功！'),
            backgroundColor: _PublishPageConstants.successGreen,
          ),
        );
      } else if (state.publishStatus == PublishStatus.failed) {
        // 发布失败，显示错误信息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage ?? '发布失败，请重试'),
            backgroundColor: _PublishPageConstants.dangerRed,
          ),
        );
      }
    });
  }
}

// ============== 8. EXPORTS ==============
/// 📤 导出定义
/// 
/// 本文件自动导出的公共类：
/// - PublishContentPage: 发布动态主页面（public class）
///
/// 私有类（不会被导出）：
/// - _PublishController: 发布页面控制器
/// - _PublishAppBar: 发布页面导航栏组件
/// - _UserInfoBar: 用户信息栏组件
/// - _TextInputArea: 文字输入区域组件
/// - _MediaUploadArea: 媒体上传区域组件
/// - _TopicLocationBar: 话题地点选择栏组件
/// - _PublishContentPageState: 发布页面状态类
/// - _PublishPageConstants: 页面私有常量
///
/// 使用方式：
/// ```dart
/// import 'publish_content_page.dart';
/// 
/// // 在路由中使用
/// MaterialPageRoute(builder: (context) => const PublishContentPage())
/// ```
