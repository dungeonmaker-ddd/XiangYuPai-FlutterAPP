// 📝 发布状态管理器 - 全局发布状态共享
// 用于在发现页面和发布页面之间同步发布状态

import 'dart:async';
import 'dart:developer' as developer;
import '../models/publish_models.dart';

/// 🔄 全局发布状态管理器
/// 
/// 单例模式，用于在不同页面间共享发布状态
/// 支持状态监听和实时更新
class PublishStateManager {
  // 单例实例
  static final PublishStateManager _instance = PublishStateManager._internal();
  factory PublishStateManager() => _instance;
  PublishStateManager._internal();

  // 状态流控制器
  final StreamController<PublishStateEvent> _stateController = 
      StreamController<PublishStateEvent>.broadcast();

  // 当前发布状态
  PublishStatus? _currentStatus;
  String? _currentMessage;
  bool _hasUnfinishedDraft = false;
  String? _currentDraftId;

  /// 状态事件流
  Stream<PublishStateEvent> get stateStream => _stateController.stream;

  /// 获取当前发布状态
  PublishStatus? get currentStatus => _currentStatus;

  /// 获取当前发布消息
  String? get currentMessage => _currentMessage;

  /// 是否有未完成的草稿
  bool get hasUnfinishedDraft => _hasUnfinishedDraft;

  /// 当前草稿ID
  String? get currentDraftId => _currentDraftId;

  /// 更新发布状态
  void updatePublishStatus(PublishStatus status, {String? message}) {
    developer.log('发布状态管理器: 更新状态 $status, 消息: $message');
    
    _currentStatus = status;
    _currentMessage = message;

    // 发送状态事件
    _stateController.add(PublishStateEvent(
      type: PublishEventType.statusChanged,
      status: status,
      message: message,
    ));

    // 发布成功后清除状态
    if (status == PublishStatus.success) {
      Timer(const Duration(seconds: 3), () {
        clearPublishStatus();
      });
    }
  }

  /// 更新草稿状态
  void updateDraftStatus(bool hasUnfinishedDraft, {String? draftId}) {
    developer.log('发布状态管理器: 更新草稿状态 $hasUnfinishedDraft, ID: $draftId');
    
    _hasUnfinishedDraft = hasUnfinishedDraft;
    _currentDraftId = draftId;

    // 发送草稿事件
    _stateController.add(PublishStateEvent(
      type: PublishEventType.draftChanged,
      hasUnfinishedDraft: hasUnfinishedDraft,
      draftId: draftId,
    ));
  }

  /// 清除发布状态
  void clearPublishStatus() {
    developer.log('发布状态管理器: 清除发布状态');
    
    _currentStatus = null;
    _currentMessage = null;

    // 发送清除事件
    _stateController.add(PublishStateEvent(
      type: PublishEventType.statusCleared,
    ));
  }

  /// 清除草稿状态
  void clearDraftStatus() {
    developer.log('发布状态管理器: 清除草稿状态');
    
    _hasUnfinishedDraft = false;
    _currentDraftId = null;

    // 发送草稿清除事件
    _stateController.add(PublishStateEvent(
      type: PublishEventType.draftCleared,
    ));
  }

  /// 开始发布流程
  void startPublishing(String? draftId) {
    developer.log('发布状态管理器: 开始发布流程');
    
    updatePublishStatus(PublishStatus.publishing, message: '正在发布动态...');
    
    // 如果是从草稿发布，清除草稿状态
    if (draftId != null && draftId == _currentDraftId) {
      clearDraftStatus();
    }
  }

  /// 发布成功
  void publishSuccess({String? message}) {
    developer.log('发布状态管理器: 发布成功');
    
    updatePublishStatus(
      PublishStatus.success, 
      message: message ?? '🎉 动态发布成功！',
    );
  }

  /// 发布失败
  void publishFailed({String? message}) {
    developer.log('发布状态管理器: 发布失败');
    
    updatePublishStatus(
      PublishStatus.failed, 
      message: message ?? '❌ 发布失败，请重试',
    );
  }

  /// 保存草稿
  void saveDraft(String draftId) {
    developer.log('发布状态管理器: 保存草稿 $draftId');
    
    updateDraftStatus(true, draftId: draftId);
  }

  /// 删除草稿
  void deleteDraft(String draftId) {
    developer.log('发布状态管理器: 删除草稿 $draftId');
    
    if (_currentDraftId == draftId) {
      clearDraftStatus();
    }
  }

  /// 获取当前完整状态
  PublishStateSnapshot getCurrentState() {
    return PublishStateSnapshot(
      status: _currentStatus,
      message: _currentMessage,
      hasUnfinishedDraft: _hasUnfinishedDraft,
      draftId: _currentDraftId,
    );
  }

  /// 销毁管理器
  void dispose() {
    _stateController.close();
  }
}

/// 📊 发布状态事件
class PublishStateEvent {
  final PublishEventType type;
  final PublishStatus? status;
  final String? message;
  final bool? hasUnfinishedDraft;
  final String? draftId;

  const PublishStateEvent({
    required this.type,
    this.status,
    this.message,
    this.hasUnfinishedDraft,
    this.draftId,
  });

  @override
  String toString() {
    return 'PublishStateEvent(type: $type, status: $status, message: $message)';
  }
}

/// 📋 发布事件类型枚举
enum PublishEventType {
  statusChanged('状态变更'),
  statusCleared('状态清除'),
  draftChanged('草稿变更'),
  draftCleared('草稿清除');

  const PublishEventType(this.displayName);
  final String displayName;
}

/// 📸 发布状态快照
class PublishStateSnapshot {
  final PublishStatus? status;
  final String? message;
  final bool hasUnfinishedDraft;
  final String? draftId;

  const PublishStateSnapshot({
    this.status,
    this.message,
    this.hasUnfinishedDraft = false,
    this.draftId,
  });

  @override
  String toString() {
    return 'PublishStateSnapshot(status: $status, hasUnfinishedDraft: $hasUnfinishedDraft)';
  }
}
