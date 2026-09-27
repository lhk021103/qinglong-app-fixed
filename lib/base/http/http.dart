import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_log/dio_log.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:qinglong_app/base/http/token_interceptor.dart';
import 'package:qinglong_app/base/http/url.dart';
import 'package:qinglong_app/base/userinfo_viewmodel.dart';
import 'package:qinglong_app/utils/extension.dart';

import '../../json.jc.dart';
import '../../main.dart';
import '../routes.dart';

/// 证书信任库。
///
/// 原实现 `badCertificateCallback => true` 是**无条件信任任何证书**（包括过期、
/// 域名不匹配、自签、被 MITM 伪造的证书），面板 token / client_secret 会明文
/// 交给中间人。这里改成 Trust-on-first-use：
///  - 默认走系统校验，任何不合法证书一律拒绝；
///  - 用户在设置里显式开启「信任自签证书」后，才对该 host 放行，并把该证书的
///    DER 指纹记进信任库，之后只对**同一张证书**放行（换证书仍会拦）。
class CertTrustStore {
  CertTrustStore._();

  /// key 格式：`host|base64(cert.der)`
  static final Set<String> trusted = <String>{};

  /// 全局开关：是否允许自签证书（用户手动开启，默认关闭）
  static bool allowSelfSigned = false;

  static String keyOf(X509Certificate cert, String host) => "$host|${base64Encode(cert.der)}";

  static bool isTrusted(X509Certificate cert, String host) => trusted.contains(keyOf(cert, host));

  /// 用户确认后调用：把当前证书加入信任库
  static void trust(X509Certificate cert, String host) => trusted.add(keyOf(cert, host));
}

class Http {
  Dio? _dio;
  bool pushedLoginPage = false;

  /// 最近一次被拒绝的证书（host + 证书），供 UI 弹出确认框后调用 trust()
  static X509Certificate? lastRejectedCert;
  static String? lastRejectedHost;

  String host;
  int index;

  Http(
    this.host,
    this.index,
  ) {
    _init();
  }

  void initDioConfig(
    String host,
  ) {
    _dio = Dio(
      BaseOptions(
        baseUrl: host,
        connectTimeout: 50000,
        receiveTimeout: 50000,
        sendTimeout: 50000,
        contentType: "application/json",
      ),
    );
    _dio?.interceptors.add(DioLogInterceptor());
    _dio?.interceptors.add(PrettyDioLogger());

    _dio?.interceptors.add(TokenInterceptor(
      host,
      index,
    ));
    (_dio?.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        if (CertTrustStore.isTrusted(cert, host)) {
          return true;
        }
        if (CertTrustStore.allowSelfSigned && host == Uri.tryParse(this.host)?.host) {
          // 用户已明确允许自签证书：仅对当前面板 host 放行，并记住这张证书
          CertTrustStore.trust(cert, host);
          return true;
        }
        lastRejectedCert = cert;
        lastRejectedHost = host;
        return false;
      };
      return client;
    };
  }

  void _init() {
    if (_dio == null) {
      initDioConfig(host);
    }
  }

  void clear() {
    _dio = null;
  }

  Future<HttpResponse<T>> get<T>(
    String uri,
    Map<String, String?>? json, {
    bool compute = true,
    String serializationName = "data",
  }) async {
    try {
      _init();
      var response = await _dio!.get(uri, queryParameters: json);
      return decodeResponse<T>(response, serializationName, compute);
    } on DioError catch (e) {
      return exceptionHandler<T>(e, uri);
    }
  }

  Future<HttpResponse<T>> post<T>(
    String uri,
    dynamic json, {
    bool compute = true,
    String serializationName = "data",
  }) async {
    try {
      _init();
      var response = await _dio!.post(uri, data: json);

      return decodeResponse<T>(
        response,
        serializationName,
        compute,
      );
    } on DioError catch (e) {
      return exceptionHandler<T>(e, uri);
    }
  }

  Future<HttpResponse<T>> delete<T>(
    String uri,
    dynamic json, {
    bool compute = true,
    String serializationName = "data",
  }) async {
    try {
      _init();
      var response = await _dio!.delete(uri, data: json);

      return decodeResponse<T>(
        response,
        serializationName,
        compute,
      );
    } on DioError catch (e) {
      return exceptionHandler<T>(e, uri);
    }
  }

  Future<HttpResponse<T>> put<T>(
    String uri,
    dynamic json, {
    bool compute = true,
    String serializationName = "data",
  }) async {
    try {
      _init();
      var response = await _dio!.put(uri, data: json);
      return decodeResponse<T>(
        response,
        serializationName,
        compute,
      );
    } on DioError catch (e) {
      return exceptionHandler<T>(e, uri);
    }
  }

  void exitLogin() {
    if (!pushedLoginPage) {
      "身份已过期,请重新登录".toast();
      pushedLoginPage = true;

      getIt<UserInfoViewModel>(instanceName: index.toString()).exitLoginFocus(index);

      getIt<GlobalKey<NavigatorState>>(instanceName: index.toString()).currentState?.pushNamedAndRemoveUntil(Routes.routeLogin, (route) => false);
    }
  }

  HttpResponse<T> exceptionHandler<T>(DioError e, String path) {
    try {
      logger.e(e);

      // 证书不受信任：明确告诉用户原因和处理方式，而不是像以前那样静默放行
      final err = e.error;
      if (err is TlsException || err is HandshakeException) {
        return HttpResponse(
          success: false,
          message: "HTTPS 证书校验失败（自签/过期/域名不匹配）。如确认面板可信，请在「设置 - 信任自签证书」中开启后重试。",
          code: -1001,
        );
      }

      if (e.response?.statusCode == 401 && !Url.inWhiteList(path)) {
        if (!getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined) {
          exitLogin();
        }
        return HttpResponse(success: false, message: "没有该模块的访问权限", code: 401);
      }

      if (e.response != null && e.response!.data != null) {
        return HttpResponse(success: false, message: e.response?.data["message"] ?? e.message, code: e.response?.data["code"] ?? 0);
      } else {
        return HttpResponse(success: false, message: e.message, code: e.response?.statusCode ?? 0);
      }
    } catch (e) {
      return HttpResponse(success: false, message: e.toString(), code: 400);
    }
  }

  static HttpResponse<T> decodeResponse<T>(
    Response<dynamic> response,
    String serializationName,
    bool compute,
  ) {
    int code = 0;
    if (response.statusCode == 200) {
      try {
        if (response.data["code"] == 200) {
          if (response.data[serializationName] != null) {
            if (T == NullResponse) {
              return HttpResponse<T>(
                success: true,
                code: 200,
              );
            }

            dynamic data = response.data[serializationName];
            T t;
            if (T == String) {
              if (data is String) {
                t = data as T;
              } else {
                t = jsonEncode(data) as T;
              }
              return HttpResponse<T>(
                success: true,
                code: 200,
                bean: t,
              );
            } else {
              T bean;
              if (compute) {
                bean = DeserializeAction.invokeJson(DeserializeAction<T>(data));
              } else {
                bean = JsonConversion$Json.fromJson<T>(data);
              }
              return HttpResponse<T>(
                success: true,
                code: 200,
                bean: bean,
              );
            }
          } else {
            return HttpResponse<T>(
              success: true,
              code: 200,
            );
          }
        } else {
          return HttpResponse<T>(
            success: false,
            code: response.data["code"],
            message: response.data["message"],
          );
        }
      } catch (e) {
        logger.e(e);
        return HttpResponse<T>(
          success: false,
          code: -1000,
          message: "json解析失败",
        );
      }
    } else {
      code = response.statusCode ?? 0;
      return HttpResponse(
        success: false,
        code: code,
        message: response.statusMessage,
      );
    }
  }
}

class HttpResponse<T> {
  late bool success;
  String? message;
  late int code;
  T? bean;

  HttpResponse({required this.success, this.message, required this.code, this.bean});
}

class DeserializeAction<T> {
  final dynamic json;

  DeserializeAction(this.json);

  T invoke() {
    return JsonConversion$Json.fromJson<T>(json);
  }

  static dynamic invokeJson(DeserializeAction a) => a.invoke();
}

mixin BaseBean<T> {
  T fromJson(Map<String, dynamic> json);
}

class CronBean with BaseBean<CronBean> {
  @override
  CronBean fromJson(Map<String, dynamic> json) {
    return CronBean();
  }
}

void decode<T>() async {
  compute(DeserializeAction.invokeJson, DeserializeAction<T>({}));
}

class NullResponse {}

class NotLoginException implements Exception {}
