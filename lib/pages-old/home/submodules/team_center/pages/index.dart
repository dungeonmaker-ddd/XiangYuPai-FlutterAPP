/// 🎯 组局中心页面模块统一导出文件
/// 
/// 页面文件夹结构：
/// - main/: 主页相关页面
/// - create/: 创建组局相关页面
/// - join/: 报名相关页面  
/// - detail/: 详情相关页面

// 主页模块
// export 'main/team_center_main_page.dart'; // 文件不存在，暂时注释

// 创建模块
export 'create/create_team_page.dart';
export 'create/create_team_page_enhanced.dart';
export 'create/create_team_dialogs.dart';

// 报名模块
export 'join/join_confirm_page.dart';
export 'join/join_status_page.dart';
export 'join/join_waiting_page.dart';
export 'join/join_success_page.dart';
export 'join/join_failed_page.dart';
export 'join/join_payment_dialog.dart';

// 详情模块
export 'detail/team_detail_page.dart';
