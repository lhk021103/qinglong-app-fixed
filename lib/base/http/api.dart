import 'package:dio/dio.dart';
import 'package:qinglong_app/base/http/http.dart';
import 'package:qinglong_app/base/http/url.dart';
import 'package:qinglong_app/main.dart';
import 'package:qinglong_app/module/config/config_bean.dart';
import 'package:qinglong_app/module/env/env_bean.dart';
import 'package:qinglong_app/module/home/system_bean.dart';
import 'package:qinglong_app/module/login/login_bean.dart';
import 'package:qinglong_app/module/login/user_bean.dart';
import 'package:qinglong_app/module/others/LogDelBean.dart';
import 'package:qinglong_app/module/others/dependencies/dependency_bean.dart';
import 'package:qinglong_app/module/others/login_log/login_log_bean.dart';
import 'package:qinglong_app/module/others/scripts/script_bean.dart';
import 'package:qinglong_app/module/others/task_log/task_log_bean.dart';
import 'package:qinglong_app/module/others/update/check_update_bean.dart';
import 'package:qinglong_app/module/task/task_bean.dart';

import '../../module/task/TaskBean2.dart';
import '../ui/tree/models/script_data.dart';

class Api {
  int index;

  Api(this.index);

  /// 新版面板所有批量接口的 body 约束都是 Joi.array().items(Joi.number())，
  /// 老面板用的是 Mongo 字符串 _id。这里做一次归一化：
  /// 能解析成数字的（新版 id / 老版纯数字 _id）一律发数字，
  /// 解析不了的（老版 ObjectId）原样发字符串，保证新旧面板都能过校验。
  static List<dynamic> normalizeIds(List<dynamic> ids) {
    return ids.map((e) {
      if (e == null) return e;
      if (e is num) return e;
      if (e is String) {
        final n = int.tryParse(e);
        if (n != null) return n;
      }
      return e;
    }).toList();
  }

  static dynamic normalizeId(dynamic id) {
    if (id == null) return id;
    if (id is num) return id;
    if (id is String) {
      final n = int.tryParse(id);
      if (n != null) return n;
    }
    return id;
  }

  /// 新版面板：GET /system/config 返回完整系统配置（含 logRemoveFrequency）。
  Future<HttpResponse<LogDelBean>> logDel() async {
    return await getIt<Http>(instanceName: index.toString()).get<LogDelBean>(
      getIt<Url>(instanceName: index.toString()).logDel,
      {},
    );
  }

  /// 新版面板：PUT /system/config/log-remove-frequency，body 字段是 logRemoveFrequency。
  /// 老面板（<2.13）仍用 /system/log/remove + frequency，这里做双写回退。
  Future<HttpResponse<String>> logDelTime(int time) async {
    HttpResponse<String> response = await getIt<Http>(instanceName: index.toString()).put<String>(
      getIt<Url>(instanceName: index.toString()).logRemoveFrequency,
      {"logRemoveFrequency": time},
    );
    if (response.success == false && (response.code == 404 || response.code == 400 || response.code == 410)) {
      response = await getIt<Http>(instanceName: index.toString()).put<String>(
        "/api/system/log/remove",
        {"frequency": time},
      );
    }
    return response;
  }

  Future<HttpResponse<SystemBean>> system() async {
    return await getIt<Http>(instanceName: index.toString()).get<SystemBean>(
      Url.system,
      {},
    );
  }

  Future<HttpResponse<LoginBean>> login(
    String userName,
    String passWord,
  ) async {
    return await getIt<Http>(instanceName: index.toString()).post<LoginBean>(
      Url.login,
      {
        "username": userName,
        "password": passWord,
      },
    );
  }

  Future<HttpResponse<LoginBean>> loginOld(
    String userName,
    String passWord,
  ) async {
    return await getIt<Http>(instanceName: index.toString()).post<LoginBean>(
      Url.loginOld,
      {
        "username": userName,
        "password": passWord,
      },
    );
  }

  Future<HttpResponse<LoginBean>> loginTwo(
    String userName,
    String passWord,
    String code,
  ) async {
    return await getIt<Http>(instanceName: index.toString()).put<LoginBean>(
      Url.loginTwo,
      {
        "username": userName,
        "password": passWord,
        "code": code,
      },
    );
  }

  Future<HttpResponse<LoginBean>> loginByClientId(
    String id,
    String secret,
  ) async {
    return await getIt<Http>(instanceName: index.toString()).get<LoginBean>(
      Url.loginByClientId,
      {
        "client_id": id,
        "client_secret": secret,
      },
    );
  }

  Future<HttpResponse<UserBean>> user() async {
    return await getIt<Http>(instanceName: index.toString()).get<UserBean>(
      Url.user,
      null,
    );
  }

  Future<HttpResponse<TaskBean2>> crons2_13_09() async {
    return await getIt<Http>(instanceName: index.toString()).get<TaskBean2>(
      getIt<Url>(instanceName: index.toString()).tasks,
      {"page": "1", "size": "10000", "searchText": ""},
    );
  }

  Future<HttpResponse<List<TaskBean>>> crons() async {
    return await getIt<Http>(instanceName: index.toString()).get<List<TaskBean>>(
      getIt<Url>(instanceName: index.toString()).tasks,
      {"searchValue": ""},
    );
  }

  Future<HttpResponse<NullResponse>> deleteLogFold(String fileName, String path) async {
    return await getIt<Http>(instanceName: index.toString()).delete<NullResponse>(
      getIt<Url>(instanceName: index.toString()).logFoldDelete,
      {"filename": fileName, "path": path, "type": "directory"},
    );
  }

  Future<HttpResponse<NullResponse>> deleteLog(String fileName, String path) async {
    return await getIt<Http>(instanceName: index.toString()).delete<NullResponse>(
      getIt<Url>(instanceName: index.toString()).logFoldDelete,
      {"filename": fileName, "path": path, "type": "file"},
    );
  }

  Future<HttpResponse<String>> subscribes() async {
    return await getIt<Http>(instanceName: index.toString()).get<String>(
      getIt<Url>(instanceName: index.toString()).subscribes,
      {"searchValue": ""},
    );
  }

  Future<HttpResponse<NullResponse>> updateNotifcation(Map<String, dynamic> params) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).notifcations,
      params,
    );
  }

  Future<HttpResponse<String>> getNotifcation() async {
    return await getIt<Http>(instanceName: index.toString()).get<String>(
      getIt<Url>(instanceName: index.toString()).notifcations,
      {},
    );
  }

  Future<HttpResponse<String>> updateSubscribes(Map<String, dynamic> params) async {
    return await getIt<Http>(instanceName: index.toString()).put<String>(
      getIt<Url>(instanceName: index.toString()).subscribes,
      params,
    );
  }

  Future<HttpResponse<String>> addSubscribes(Map<String, dynamic> params) async {
    return await getIt<Http>(instanceName: index.toString()).post<String>(
      getIt<Url>(instanceName: index.toString()).subscribes,
      params,
    );
  }

  Future<HttpResponse<NullResponse>> startTasks(List<dynamic> crons) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).runTasks,
      normalizeIds(crons),
    );
  }

  Future<HttpResponse<NullResponse>> stopTasks(List<dynamic> crons) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).stopTasks,
      normalizeIds(crons),
    );
  }

  Future<HttpResponse<NullResponse>> startSubscribes(List<int> crons) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).runSubscribes,
      crons,
    );
  }

  Future<HttpResponse<NullResponse>> stopSubscribes(List<int> crons) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).stopSubscribes,
      crons,
    );
  }

  Future<HttpResponse<NullResponse>> updatePassword(String name, String password) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      Url.updatePassword,
      {
        "username": name,
        "password": password,
      },
    );
  }

  Future<HttpResponse<String>> inTimeLog(String cron) async {
    return await getIt<Http>(instanceName: index.toString()).get<String>(
      getIt<Url>(instanceName: index.toString()).intimeLog(cron),
      null,
    );
  }

  Future<HttpResponse<String>> inTimeDepLog(String cron) async {
    return await getIt<Http>(instanceName: index.toString()).get<String>(
      getIt<Url>(instanceName: index.toString()).intimeDepLog(cron),
      null,
    );
  }

  Future<HttpResponse<String>> inTimeSubscribeLog(int cron) async {
    return await getIt<Http>(instanceName: index.toString()).get<String>(
      getIt<Url>(instanceName: index.toString()).intimeSubscribeLog(cron),
      null,
    );
  }

  Future<HttpResponse<NullResponse>> addTask(
    String name,
    String command,
    String cron, {
    int? id,
    String? nId,
  }) async {
    var data = <String, dynamic>{"name": name, "command": command, "schedule": cron};

    if (id != null || nId != null) {
      // 新版面板 PUT /crons 的 schema 是 id: Joi.number().required()，
      // 老版本才认 Mongo 的 _id。这里优先发数字 id，无法解析时回退 _id。
      if (id != null) {
        data["id"] = id;
      } else if (nId != null) {
        final parsed = int.tryParse(nId);
        data[parsed != null ? "id" : "_id"] = parsed ?? nId;
      }
      return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
        getIt<Url>(instanceName: index.toString()).addTask,
        data,
      );
    }
    return await getIt<Http>(instanceName: index.toString()).post<NullResponse>(
      getIt<Url>(instanceName: index.toString()).addTask,
      data,
    );
  }

  Future<HttpResponse<NullResponse>> delSubscribe(int cron) async {
    return await getIt<Http>(instanceName: index.toString()).delete<NullResponse>(
      getIt<Url>(instanceName: index.toString()).addSubscribes,
      [cron],
    );
  }

  Future<HttpResponse<NullResponse>> delTask(List<dynamic> crons) async {
    return await getIt<Http>(instanceName: index.toString()).delete<NullResponse>(
      getIt<Url>(instanceName: index.toString()).addTask,
      normalizeIds(crons),
    );
  }

  Future<HttpResponse<NullResponse>> pinTask(List<dynamic> crons) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).pinTask,
      normalizeIds(crons),
    );
  }

  Future<HttpResponse<NullResponse>> unpinTask(List<dynamic> crons) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).unpinTask,
      normalizeIds(crons),
    );
  }

  Future<HttpResponse<NullResponse>> enableTask(List<dynamic> crons) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).enableTask,
      normalizeIds(crons),
    );
  }

  Future<HttpResponse<NullResponse>> disableTask(List<dynamic> crons) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).disableTask,
      normalizeIds(crons),
    );
  }

  Future<HttpResponse<NullResponse>> enableSubscribe(int id) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).enableSubscribes,
      [id],
    );
  }

  Future<HttpResponse<NullResponse>> disableSubscribe(int id) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).disableSubscribes,
      [id],
    );
  }

  Future<HttpResponse<List<ConfigBean>>> files() async {
    return await getIt<Http>(instanceName: index.toString()).get<List<ConfigBean>>(
      getIt<Url>(instanceName: index.toString()).files,
      null,
    );
  }

  Future<HttpResponse<String>> content(String name) async {
    return await getIt<Http>(instanceName: index.toString()).get<String>(
      getIt<Url>(instanceName: index.toString()).configContent + name,
      null,
    );
  }

  Future<HttpResponse<NullResponse>> saveFile(String name, String content) async {
    return await getIt<Http>(instanceName: index.toString()).post<NullResponse>(
      getIt<Url>(instanceName: index.toString()).saveFile,
      {"content": content, "name": name},
    );
  }

  Future<HttpResponse<List<EnvBean>>> envs(String search) async {
    return await getIt<Http>(instanceName: index.toString()).get<List<EnvBean>>(
      getIt<Url>(instanceName: index.toString()).envs,
      {"searchValue": search},
    );
  }

  Future<HttpResponse<NullResponse>> enableEnv(List<dynamic> ids) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).enableEnvs,
      normalizeIds(ids),
    );
  }

  Future<HttpResponse<NullResponse>> disableEnv(List<dynamic> ids) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).disableEnvs,
      normalizeIds(ids),
    );
  }

  Future<HttpResponse<NullResponse>> delEnvs(List<dynamic> ids) async {
    return await getIt<Http>(instanceName: index.toString()).delete<NullResponse>(
      getIt<Url>(instanceName: index.toString()).delEnv,
      normalizeIds(ids),
    );
  }

  Future<HttpResponse<NullResponse>> delEnv(dynamic id) async {
    return await getIt<Http>(instanceName: index.toString()).delete<NullResponse>(
      getIt<Url>(instanceName: index.toString()).delEnv,
      normalizeIds([id]),
    );
  }

  Future<HttpResponse<NullResponse>> addEnv(
    String name,
    String value,
    String remarks, {
    int? id,
    String? nId,
  }) async {
    var data = <String, dynamic>{
      "value": value,
      "remarks": remarks,
      "name": name,
    };

    if (id != null || nId != null) {
      if (id != null) {
        data["id"] = id;
      } else if (nId != null) {
        final parsed = int.tryParse(nId);
        data[parsed != null ? "id" : "_id"] = parsed ?? nId;
      }
      return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
        getIt<Url>(instanceName: index.toString()).addEnv,
        data,
      );
    }
    return await getIt<Http>(instanceName: index.toString()).post<NullResponse>(
      getIt<Url>(instanceName: index.toString()).addEnv,
      [data],
    );
  }

  Future<HttpResponse<NullResponse>> moveEnv(dynamic id, int fromIndex, int toIndex) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).envMove(normalizeId(id).toString()),
      {"fromIndex": fromIndex, "toIndex": toIndex},
    );
  }

  /// 环境变量改名（面板有、app 缺）
  Future<HttpResponse<NullResponse>> renameEnv(dynamic id, String name) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).envName,
      {"id": normalizeId(id), "name": name},
    );
  }

  /// 环境变量置顶 / 取消置顶（面板有、app 缺）
  Future<HttpResponse<NullResponse>> pinEnv(List<dynamic> ids) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).envPin,
      normalizeIds(ids),
    );
  }

  Future<HttpResponse<NullResponse>> unpinEnv(List<dynamic> ids) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).envUnpin,
      normalizeIds(ids),
    );
  }

  /// 环境变量批量上传（.env / .json / .yaml 文本，面板有、app 缺）
  Future<HttpResponse<NullResponse>> uploadEnvs(List<int> bytes, String fileName) async {
    final FormData form = FormData();
    form.files.add(MapEntry(
      "file",
      MultipartFile.fromBytes(bytes, filename: fileName),
    ));
    return await getIt<Http>(instanceName: index.toString()).post<NullResponse>(
      getIt<Url>(instanceName: index.toString()).envUpload,
      form,
    );
  }

  Future<HttpResponse<List<LoginLogBean>>> loginLog() async {
    return await getIt<Http>(instanceName: index.toString()).get<List<LoginLogBean>>(
      getIt<Url>(instanceName: index.toString()).loginLog,
      null,
    );
  }

  Future<HttpResponse<List<TaskLogBean>>> taskLog() async {
    return await getIt<Http>(instanceName: index.toString()).get<List<TaskLogBean>>(getIt<Url>(instanceName: index.toString()).taskLog, null,
        serializationName: getIt<SystemBean>(instanceName: index.toString()).isUpperVersion2_12_2() ? "data" : "dirs");
  }

  Future<HttpResponse<String>> taskLogDetail(String name, String path) async {
    if (getIt<SystemBean>(instanceName: index.toString()).isUpperVersion2_13_0()) {
      return await getIt<Http>(instanceName: index.toString()).get<String>(
        getIt<Url>(instanceName: index.toString()).taskLogDetail + name + "?path=" + path,
        null,
      );
    } else {
      return await getIt<Http>(instanceName: index.toString()).get<String>(
        getIt<Url>(instanceName: index.toString()).taskLogDetail + path + "/" + name,
        null,
      );
    }
  }

  Future<HttpResponse<List<ScriptData>>> scripts() async {
    return await getIt<Http>(instanceName: index.toString()).get<List<ScriptData>>(
      getIt<SystemBean>(instanceName: index.toString()).isUpperVersion2_13_0()
          ? getIt<Url>(instanceName: index.toString()).scripts2
          : getIt<Url>(instanceName: index.toString()).scripts,
      null,
    );
  }

  Future<HttpResponse<NullResponse>> updateScript(String name, String path, String content) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).scriptDetail,
      {
        "filename": name,
        "path": path,
        "content": content,
      },
    );
  }

  Future<HttpResponse<NullResponse>> delScript(String name, String path) async {
    return await getIt<Http>(instanceName: index.toString()).delete<NullResponse>(
      getIt<Url>(instanceName: index.toString()).scriptDetail,
      {
        "filename": name,
        "path": path,
      },
    );
  }

  Future<HttpResponse<NullResponse>> delScriptFold(String fileName, String path) async {
    return await getIt<Http>(instanceName: index.toString()).delete<NullResponse>(
      getIt<Url>(instanceName: index.toString()).scriptDetail,
      {"filename": fileName, "path": path, "type": "directory"},
    );
  }

  Future<HttpResponse<NullResponse>> addScriptFolder(String fileName, String path) async {
    return await getIt<Http>(instanceName: index.toString()).post<NullResponse>(
      getIt<Url>(instanceName: index.toString()).scriptDetail,
      {
        "directory": fileName,
        "path": path,
      },
    );
  }

  Future<HttpResponse<NullResponse>> delScriptNewVersion(String fileName, String path) async {
    return await getIt<Http>(instanceName: index.toString()).delete<NullResponse>(
      getIt<Url>(instanceName: index.toString()).scriptDetail,
      {"filename": fileName, "path": path, "type": "file"},
    );
  }

  /// 修复：GET /scripts/{name} 在新版面板已下线（返回 code 410 "接口已下线，请使用 /scripts/detail"），
  /// 改用 GET /scripts/detail?path=xxx&file=xxx。
  Future<HttpResponse<String>> scriptDetail(String name, String? path) async {
    HttpResponse<String> response = await getIt<Http>(instanceName: index.toString()).get<String>(
      getIt<Url>(instanceName: index.toString()).scriptDetailNew(path, name),
      null,
    );
    if (response.success == false && (response.code == 404 || response.code == 410 || response.code == 400)) {
      // 老面板回退
      response = await getIt<Http>(instanceName: index.toString()).get<String>(
        getIt<Url>(instanceName: index.toString()).scriptDetailForReadFile + name,
        {
          "path": path,
        },
      );
    }
    return response;
  }

  Future<HttpResponse<List<DependencyBean>>> dependencies(String type) async {
    return await getIt<Http>(instanceName: index.toString()).get<List<DependencyBean>>(
      getIt<Url>(instanceName: index.toString()).dependencies,
      {
        "type": type.toString(),
      },
    );
  }

  Future<HttpResponse<NullResponse>> dependencyReinstall(
    List<String?>? sId,
    List<int?>? id,
  ) async {
    // 新版面板依赖 id 是数字，优先用数字 id；只有新版 id 缺失时才退回老版字符串 _id。
    final bool useNumeric = id != null && id.isNotEmpty && id[0] != null;
    final List<dynamic> payload = normalizeIds(useNumeric ? id!.whereType<dynamic>().toList() : sId?.whereType<dynamic>().toList() ?? []);
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).dependenciesReinstall,
      payload,
    );
  }

  /// 取消正在安装的依赖（面板有、app 缺）
  Future<HttpResponse<NullResponse>> dependencyCancel(List<dynamic> ids) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).dependencyCancel,
      normalizeIds(ids),
    );
  }

  Future<HttpResponse<String>> dependencyLog(String id) async {
    return await getIt<Http>(instanceName: index.toString()).get<String>(
      getIt<Url>(instanceName: index.toString()).dependencies + "/" + id,
      null,
    );
  }

  Future<HttpResponse<String>> addDependency(List<Map<String, dynamic>> list) async {
    return await getIt<Http>(instanceName: index.toString()).post<String>(
      getIt<Url>(instanceName: index.toString()).dependencies,
      list,
    );
  }

  Future<HttpResponse<NullResponse>> addScript(String name, String path, String content) async {
    return await getIt<Http>(instanceName: index.toString()).post<NullResponse>(
      getIt<Url>(instanceName: index.toString()).addScript,
      {
        "filename": name,
        "path": path,
        "content": content,
      },
    );
  }

  /// 二进制脚本上传：走青龙后端 POST /scripts 的 multipart 分支（upload.single('file')），
  /// 后端直接 copyFile 落盘，不经 utf8 解码，.so/.zip 等任意文件可原样上传。
  Future<HttpResponse<NullResponse>> addScriptBinary(String name, String path, List<int> bytes) async {
    final FormData form = FormData();
    form.fields.add(MapEntry("filename", name));
    form.fields.add(MapEntry("path", path));
    form.files.add(MapEntry(
      "file",
      MultipartFile.fromBytes(bytes, filename: name),
    ));
    return await getIt<Http>(instanceName: index.toString()).post<NullResponse>(
      getIt<Url>(instanceName: index.toString()).addScript,
      form,
    );
  }

  Future<HttpResponse<NullResponse>> delDependency(List<String?>? sIds, List<int?>? ids) async {
    bool focus = getIt<SystemBean>(instanceName: index.toString()).isUpperVersion2_13_0();

    String url = "";
    if (focus) {
      url = getIt<Url>(instanceName: index.toString()).dependenciesDeleteFocus;
    } else {
      url = getIt<Url>(instanceName: index.toString()).dependencies;
    }

    final bool useNumeric = ids != null && ids.isNotEmpty && ids[0] != null;
    final List<dynamic> payload = normalizeIds(useNumeric ? ids!.whereType<dynamic>().toList() : sIds?.whereType<dynamic>().toList() ?? []);

    HttpResponse<NullResponse> response = await getIt<Http>(instanceName: index.toString()).delete<NullResponse>(
      url,
      payload,
    );

    if (response.success == false && focus) {
      url = getIt<Url>(instanceName: index.toString()).dependencies;
      response = await getIt<Http>(instanceName: index.toString()).delete<NullResponse>(
        url,
        payload,
      );
    }
    return response;
  }

  Future<HttpResponse<CheckUpdateBean>> checkUpdate() async {
    return await getIt<Http>(instanceName: index.toString()).put<CheckUpdateBean>(
      getIt<Url>(instanceName: index.toString()).checkUpdate,
      {},
    );
  }

  Future<HttpResponse<String>> appKeys() async {
    return await getIt<Http>(instanceName: index.toString()).get<String>(
      getIt<Url>(instanceName: index.toString()).appkeys,
      {},
    );
  }

  Future<HttpResponse<NullResponse>> addAppKey(Map<String, dynamic> data) async {
    return await getIt<Http>(instanceName: index.toString()).post<NullResponse>(
      getIt<Url>(instanceName: index.toString()).appkeys,
      data,
    );
  }

  Future<HttpResponse<NullResponse>> updateAppKey(Map<String, dynamic> data) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).appkeys,
      data,
    );
  }

  Future<HttpResponse<NullResponse>> deleteAppKey(List<dynamic> data) async {
    return await getIt<Http>(instanceName: index.toString()).delete<NullResponse>(
      getIt<Url>(instanceName: index.toString()).appkeys,
      normalizeIds(data),
    );
  }

  Future<HttpResponse<NullResponse>> resetAppKey(dynamic id) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).resetAppKey(id),
      {},
    );
  }

  // ==================== 以下为对照青龙面板补齐的接口（面板有、原 app 缺失） ====================

  // ---------- 系统设置 ----------
  Future<HttpResponse<String>> systemConfig() async {
    return await getIt<Http>(instanceName: index.toString()).get<String>(
      getIt<Url>(instanceName: index.toString()).systemConfig,
      null,
    );
  }

  Future<HttpResponse<NullResponse>> setCronConcurrency(int? concurrency) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).cronConcurrency,
      {"cronConcurrency": concurrency},
    );
  }

  Future<HttpResponse<NullResponse>> setDependenceProxy(String? proxy) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).dependenceProxy,
      {"dependenceProxy": proxy},
    );
  }

  Future<HttpResponse<NullResponse>> setNodeMirror(String? mirror) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).nodeMirror,
      {"nodeMirror": mirror},
    );
  }

  Future<HttpResponse<NullResponse>> setPythonMirror(String? mirror) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).pythonMirror,
      {"pythonMirror": mirror},
    );
  }

  Future<HttpResponse<NullResponse>> setLinuxMirror(String? mirror) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).linuxMirror,
      {"linuxMirror": mirror},
    );
  }

  Future<HttpResponse<NullResponse>> setTimezone(String? timezone) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).timezone,
      {"timezone": timezone},
    );
  }

  Future<HttpResponse<NullResponse>> setPanelTitle(String? title) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).panelTitle,
      {"panelTitle": title},
    );
  }

  Future<HttpResponse<NullResponse>> setDependenceClean(bool? clean) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).dependenceClean,
      {"dependenceClean": clean},
    );
  }

  Future<HttpResponse<NullResponse>> reloadSystem() async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).systemReload,
      {},
    );
  }

  Future<HttpResponse<NullResponse>> systemUpdate() async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).systemUpdate,
      {},
    );
  }

  Future<HttpResponse<String>> dataExport() async {
    return await getIt<Http>(instanceName: index.toString()).put<String>(
      getIt<Url>(instanceName: index.toString()).dataExport,
      {},
    );
  }

  Future<HttpResponse<NullResponse>> dataImport(List<int> bytes, String fileName) async {
    final FormData form = FormData();
    form.files.add(MapEntry(
      "file",
      MultipartFile.fromBytes(bytes, filename: fileName),
    ));
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).dataImport,
      form,
    );
  }

  Future<HttpResponse<String>> commandRun(String command, {String? id}) async {
    return await getIt<Http>(instanceName: index.toString()).put<String>(
      getIt<Url>(instanceName: index.toString()).commandRun,
      {"command": command, if (id != null) "id": id},
    );
  }

  Future<HttpResponse<NullResponse>> commandStop(String id) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).commandStop,
      {"id": id},
    );
  }

  // ---------- 定时任务：视图 / 标签 / 状态 / 实例 / 导入 ----------
  Future<HttpResponse<String>> cronViews() async {
    return await getIt<Http>(instanceName: index.toString()).get<String>(
      getIt<Url>(instanceName: index.toString()).cronViews,
      null,
    );
  }

  Future<HttpResponse<NullResponse>> addCronView(Map<String, dynamic> data) async {
    return await getIt<Http>(instanceName: index.toString()).post<NullResponse>(
      getIt<Url>(instanceName: index.toString()).cronViews,
      data,
    );
  }

  Future<HttpResponse<NullResponse>> updateCronView(Map<String, dynamic> data) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).cronViews,
      data,
    );
  }

  Future<HttpResponse<NullResponse>> delCronView(List<dynamic> ids) async {
    return await getIt<Http>(instanceName: index.toString()).delete<NullResponse>(
      getIt<Url>(instanceName: index.toString()).cronViews,
      normalizeIds(ids),
    );
  }

  Future<HttpResponse<NullResponse>> moveCronView(dynamic id, int fromIndex, int toIndex) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      "${getIt<Url>(instanceName: index.toString()).cronViews}/move",
      {"id": normalizeId(id), "fromIndex": fromIndex, "toIndex": toIndex},
    );
  }

  Future<HttpResponse<NullResponse>> enableCronView(List<dynamic> ids) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      "${getIt<Url>(instanceName: index.toString()).cronViews}/enable",
      normalizeIds(ids),
    );
  }

  Future<HttpResponse<NullResponse>> disableCronView(List<dynamic> ids) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      "${getIt<Url>(instanceName: index.toString()).cronViews}/disable",
      normalizeIds(ids),
    );
  }

  Future<HttpResponse<String>> cronLabels() async {
    return await getIt<Http>(instanceName: index.toString()).get<String>(
      getIt<Url>(instanceName: index.toString()).cronLabels,
      null,
    );
  }

  Future<HttpResponse<NullResponse>> updateCronLabels(dynamic id, List<String> labels) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).cronLabels,
      {"id": normalizeId(id), "labels": labels},
    );
  }

  Future<HttpResponse<String>> cronStatus(List<dynamic> ids) async {
    return await getIt<Http>(instanceName: index.toString()).put<String>(
      getIt<Url>(instanceName: index.toString()).cronStatus,
      normalizeIds(ids),
    );
  }

  Future<HttpResponse<String>> cronInstances(String id) async {
    return await getIt<Http>(instanceName: index.toString()).get<String>(
      getIt<Url>(instanceName: index.toString()).cronInstances(id),
      null,
    );
  }

  Future<HttpResponse<NullResponse>> stopCronInstance(String id, String instanceId) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).cronInstanceStop(id, instanceId),
      {},
    );
  }

  Future<HttpResponse<NullResponse>> importCrons(List<int> bytes, String fileName) async {
    final FormData form = FormData();
    form.files.add(MapEntry(
      "file",
      MultipartFile.fromBytes(bytes, filename: fileName),
    ));
    return await getIt<Http>(instanceName: index.toString()).post<NullResponse>(
      getIt<Url>(instanceName: index.toString()).cronImport,
      form,
    );
  }

  // ---------- 日志 ----------
  Future<HttpResponse<String>> downloadLog(String file, String? path) async {
    return await getIt<Http>(instanceName: index.toString()).get<String>(
      getIt<Url>(instanceName: index.toString()).logDownload,
      {"file": file, if (path != null) "path": path},
    );
  }

  // ---------- 配置文件 ----------
  Future<HttpResponse<String>> configSamples() async {
    return await getIt<Http>(instanceName: index.toString()).get<String>(
      getIt<Url>(instanceName: index.toString()).configSamples,
      null,
    );
  }

  Future<HttpResponse<String>> configDetail(String name, String? path) async {
    return await getIt<Http>(instanceName: index.toString()).get<String>(
      getIt<Url>(instanceName: index.toString()).configDetail,
      {"name": name, if (path != null) "path": path},
    );
  }

  // ---------- Dashboard ----------
  Future<HttpResponse<String>> dashboardOverview() async {
    return await getIt<Http>(instanceName: index.toString()).get<String>(
      getIt<Url>(instanceName: index.toString()).dashboardOverview,
      null,
    );
  }

  Future<HttpResponse<String>> dashboardTrend() async {
    return await getIt<Http>(instanceName: index.toString()).get<String>(
      getIt<Url>(instanceName: index.toString()).dashboardTrend,
      null,
    );
  }

  Future<HttpResponse<String>> dashboardTopTime() async {
    return await getIt<Http>(instanceName: index.toString()).get<String>(
      getIt<Url>(instanceName: index.toString()).dashboardTopTime,
      null,
    );
  }

  Future<HttpResponse<String>> dashboardTopCount() async {
    return await getIt<Http>(instanceName: index.toString()).get<String>(
      getIt<Url>(instanceName: index.toString()).dashboardTopCount,
      null,
    );
  }

  Future<HttpResponse<String>> dashboardRuntime() async {
    return await getIt<Http>(instanceName: index.toString()).get<String>(
      getIt<Url>(instanceName: index.toString()).dashboardRuntime,
      null,
    );
  }

  Future<HttpResponse<String>> dashboardLabels() async {
    return await getIt<Http>(instanceName: index.toString()).get<String>(
      getIt<Url>(instanceName: index.toString()).dashboardLabels,
      null,
    );
  }

  Future<HttpResponse<String>> dashboardSystem() async {
    return await getIt<Http>(instanceName: index.toString()).get<String>(
      getIt<Url>(instanceName: index.toString()).dashboardSystem,
      null,
    );
  }

  // ---------- 存储清理（retention） ----------
  Future<HttpResponse<String>> storageRetentionConfig() async {
    return await getIt<Http>(instanceName: index.toString()).get<String>(
      getIt<Url>(instanceName: index.toString()).storageRetentionConfig,
      null,
    );
  }

  Future<HttpResponse<NullResponse>> saveStorageRetentionConfig(Map<String, dynamic> data) async {
    return await getIt<Http>(instanceName: index.toString()).post<NullResponse>(
      getIt<Url>(instanceName: index.toString()).storageRetentionConfig,
      data,
    );
  }

  Future<HttpResponse<String>> storageRetentionPreview(Map<String, dynamic> data) async {
    return await getIt<Http>(instanceName: index.toString()).post<String>(
      getIt<Url>(instanceName: index.toString()).storageRetentionPreview,
      data,
    );
  }

  Future<HttpResponse<NullResponse>> storageRetentionCleanup(Map<String, dynamic> data) async {
    return await getIt<Http>(instanceName: index.toString()).post<NullResponse>(
      getIt<Url>(instanceName: index.toString()).storageRetentionCleanup,
      data,
    );
  }

  // ---------- 用户安全 ----------
  Future<HttpResponse<String>> twoFactorInit() async {
    return await getIt<Http>(instanceName: index.toString()).get<String>(
      getIt<Url>(instanceName: index.toString()).userTwoFactorInit,
      null,
    );
  }

  Future<HttpResponse<NullResponse>> twoFactorActive(String code, String secret) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).userTwoFactorActive,
      {"code": code, "secret": secret},
    );
  }

  Future<HttpResponse<NullResponse>> twoFactorDeactivate(String code) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).userTwoFactorDeactivate,
      {"code": code},
    );
  }

  Future<HttpResponse<NullResponse>> updateAvatar(List<int> bytes, String fileName) async {
    final FormData form = FormData();
    form.files.add(MapEntry(
      "file",
      MultipartFile.fromBytes(bytes, filename: fileName),
    ));
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).userAvatar,
      form,
    );
  }

  Future<HttpResponse<String>> ipBlacklist() async {
    return await getIt<Http>(instanceName: index.toString()).get<String>(
      getIt<Url>(instanceName: index.toString()).ipBlacklist,
      null,
    );
  }

  Future<HttpResponse<NullResponse>> addIpBlacklist(String ip) async {
    return await getIt<Http>(instanceName: index.toString()).post<NullResponse>(
      getIt<Url>(instanceName: index.toString()).ipBlacklist,
      {"ip": ip},
    );
  }

  Future<HttpResponse<NullResponse>> delIpBlacklist(String ip) async {
    return await getIt<Http>(instanceName: index.toString()).delete<NullResponse>(
      getIt<Url>(instanceName: index.toString()).ipBlacklist,
      {"ip": ip},
    );
  }

  Future<HttpResponse<String>> health() async {
    return await getIt<Http>(instanceName: index.toString()).get<String>(
      getIt<Url>(instanceName: index.toString()).health,
      null,
    );
  }
}
