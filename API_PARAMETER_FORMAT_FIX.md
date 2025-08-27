# 🔧 API参数格式修复说明

## 📋 问题描述

原代码发送的是JSON格式的请求体，但后端期望的是表单参数（`@RequestParam`），导致后端接收不到参数。

## ❌ 修复前的问题

### 错误的请求格式：
```dart
// JSON格式 - 后端无法通过@RequestParam接收
headers: {
  'Content-Type': 'application/json',
},
body: jsonEncode({
  'mobile': mobile,
  'clientType': clientType,
}),
```

### 发送的数据：
```
Content-Type: application/json
Body: {"mobile":"15888888888","clientType":"app"}
```

## ✅ 修复后的解决方案

### 正确的请求格式：
```dart
// 表单格式 - 后端可以通过@RequestParam接收
headers: {
  'Content-Type': 'application/x-www-form-urlencoded',
},
body: {
  'mobile': mobile,
  'clientType': clientType,
}, // 直接传Map，不用jsonEncode
```

### 发送的数据：
```
Content-Type: application/x-www-form-urlencoded
Body: mobile=15888888888&clientType=app
```

## 🔧 主要修改内容

### 1. Content-Type 改变
- **修复前**: `application/json`
- **修复后**: `application/x-www-form-urlencoded`

### 2. 请求体格式改变
- **修复前**: `jsonEncode(Map)` → `{"key":"value"}`
- **修复后**: 直接传`Map` → `key=value&key2=value2`

### 3. 添加辅助方法

```dart
/// 发送表单格式请求（适用于@RequestParam）
static Future<http.Response> _postForm(String url, Map<String, String> params)

/// 发送JSON格式请求（适用于@RequestBody）
static Future<http.Response> _postJson(String url, Map<String, dynamic> data)

/// 响应格式兼容检查
static bool _isResponseSuccess(Map<String, dynamic> data)
```

## 🎯 对应的后端接口

### Spring Boot 表单参数接收：
```java
@PostMapping("/sms/send")
public Result sendSms(@RequestParam String mobile, 
                      @RequestParam String clientType) {
    // 现在可以正确接收到参数
    log.info("收到参数: mobile={}, clientType={}", mobile, clientType);
    return Result.success();
}

@PostMapping("/login")
public Result login(@RequestParam String mobile,
                    @RequestParam String code,
                    @RequestParam String clientType,
                    @RequestParam String loginType) {
    // 登录逻辑
    return Result.success();
}
```

### 如果后端使用JSON格式：
```java
@PostMapping("/sms/send")
public Result sendSms(@RequestBody SmsRequest request) {
    // 此时需要使用 _postJson() 方法
    return Result.success();
}
```

## 📊 响应格式兼容

新代码支持多种响应格式：

```dart
// 支持的成功响应格式：
{"success": true, "message": "操作成功"}
{"code": 200, "msg": "操作成功"}
{"code": 0, "data": {...}}
{"status": "ok", "result": {...}}
```

## 🔍 调试输出示例

### 发送验证码请求：
```
🚀 发送短信验证码请求:
   URL: http://10.0.2.2:8080/auth/sms/send
   Method: POST (表单格式)
   Params: mobile=15888888888&clientType=app

📡 HTTP响应:
   Status: 200
   Body: {"code":200,"msg":"验证码发送成功"}
   
✅ 短信发送成功
```

### 登录请求：
```
🔐 手机号登录请求:
   URL: http://10.0.2.2:8080/auth/login
   Method: POST (表单格式)
   Params: mobile=15888888888&code=123456&clientType=app&loginType=mobile

📡 HTTP响应:
   Status: 200
   Body: {"success":true,"data":{"token":"jwt_token","user":{...}}}
   
✅ 登录成功: 用户昵称
```

## 🚀 使用建议

1. **表单格式** - 当后端使用 `@RequestParam` 时
2. **JSON格式** - 当后端使用 `@RequestBody` 时
3. **灵活切换** - 根据不同接口需求选择合适的方法

## 🔧 如果需要切换回JSON格式

如果某个接口需要JSON格式，可以这样修改：

```dart
// 改为使用JSON格式
final response = await _postJson('${apiUrl}/some-endpoint', {
  'mobile': mobile,
  'clientType': clientType,
});
```

## ✅ 验证方法

1. **查看控制台日志** - 确认发送的参数格式
2. **检查后端日志** - 确认后端是否接收到参数
3. **使用网络抓包工具** - 查看实际的HTTP请求内容

现在您的Flutter应用应该能够正确向后端发送表单格式的参数了！🎉
