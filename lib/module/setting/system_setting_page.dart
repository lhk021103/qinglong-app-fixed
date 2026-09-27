import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/commit_button.dart';
import 'package:qinglong_app/base/http/http.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:qinglong_app/base/single_account_page.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/module/subscribe/add_subscribe_page.dart';
import 'package:qinglong_app/utils/extension.dart';

/// 系统设置页。
///
/// 青龙面板「系统设置」里的这一整块（并发数 / 三种镜像源 / 代理 / 时区 / 面板标题 /
/// 重载配置 / 数据导入导出 / 更新）在原 app 里完全没有，接口层也没接。
/// 这里补齐为一个页面，端点全部对应 back/api/system.ts。
class SystemSettingPage extends ConsumerStatefulWidget {
  const SystemSettingPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SystemSettingPage> createState() => _SystemSettingPageState();
}

class _SystemSettingPageState extends ConsumerState<SystemSettingPage> {
  bool loading = true;
  Map<String, dynamic> config = {};

  final TextEditingController _concurrencyController = TextEditingController();
  final TextEditingController _nodeMirrorController = TextEditingController();
  final TextEditingController _pythonMirrorController = TextEditingController();
  final TextEditingController _linuxMirrorController = TextEditingController();
  final TextEditingController _proxyController = TextEditingController();
  final TextEditingController _timezoneController = TextEditingController();
  final TextEditingController _panelTitleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadConfig();
  }

  void loadConfig() async {
    var response = await SingleAccountPageState.ofApi(context).systemConfig();
    if (response.success && response.bean != null) {
      try {
        dynamic data = jsonDecode(response.bean!);
        if (data is Map<String, dynamic>) {
          config = data;
        }
      } catch (e) {
        config = {};
      }
      _concurrencyController.text = config["cronConcurrency"]?.toString() ?? "";
      _nodeMirrorController.text = config["nodeMirror"]?.toString() ?? "";
      _pythonMirrorController.text = config["pythonMirror"]?.toString() ?? "";
      _linuxMirrorController.text = config["linuxMirror"]?.toString() ?? "";
      _proxyController.text = config["dependenceProxy"]?.toString() ?? "";
      _timezoneController.text = config["timezone"]?.toString() ?? "";
      _panelTitleController.text = config["panelTitle"]?.toString() ?? "";
    } else {
      (response.message ?? "读取系统配置失败").toast();
    }
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  void submit() async {
    final api = SingleAccountPageState.ofApi(context);
    await EasyLoading.show(status: " 提交中");

    List<Future<HttpResponse<NullResponse>>> tasks = [];

    int? concurrency = int.tryParse(_concurrencyController.text.trim());
    if (concurrency != null) {
      tasks.add(api.setCronConcurrency(concurrency));
    }

    String nodeMirror = _nodeMirrorController.text.trim();
    if (nodeMirror.isNotEmpty && nodeMirror != config["nodeMirror"]?.toString()) {
      tasks.add(api.setNodeMirror(nodeMirror));
    }

    String pythonMirror = _pythonMirrorController.text.trim();
    if (pythonMirror.isNotEmpty && pythonMirror != config["pythonMirror"]?.toString()) {
      tasks.add(api.setPythonMirror(pythonMirror));
    }

    String linuxMirror = _linuxMirrorController.text.trim();
    if (linuxMirror.isNotEmpty && linuxMirror != config["linuxMirror"]?.toString()) {
      tasks.add(api.setLinuxMirror(linuxMirror));
    }

    String proxy = _proxyController.text.trim();
    if (proxy != config["dependenceProxy"]?.toString()) {
      tasks.add(api.setDependenceProxy(proxy.isEmpty ? null : proxy));
    }

    String timezone = _timezoneController.text.trim();
    if (timezone.isNotEmpty && timezone != config["timezone"]?.toString()) {
      tasks.add(api.setTimezone(timezone));
    }

    String title = _panelTitleController.text.trim();
    if (title != config["panelTitle"]?.toString()) {
      tasks.add(api.setPanelTitle(title));
    }

    if (tasks.isEmpty) {
      await EasyLoading.dismiss();
      "没有需要保存的改动".toast();
      return;
    }

    List<HttpResponse<NullResponse>> results = await Future.wait(tasks);
    await EasyLoading.dismiss();

    HttpResponse<NullResponse>? failed;
    for (var r in results) {
      if (!r.success) {
        failed = r;
        break;
      }
    }

    if (failed == null) {
      "保存成功".toast();
      loadConfig();
    } else {
      (failed.message ?? "保存失败").toast();
    }
  }

  void reloadSystem() async {
    await EasyLoading.show(status: " 重载中");
    var response = await SingleAccountPageState.ofApi(context).reloadSystem();
    await EasyLoading.dismiss();
    if (response.success) {
      "已重载配置".toast();
    } else {
      (response.message ?? "重载失败").toast();
    }
  }

  void exportData() async {
    await EasyLoading.show(status: " 导出中");
    var response = await SingleAccountPageState.ofApi(context).dataExport();
    await EasyLoading.dismiss();
    if (response.success) {
      "导出任务已创建,请在日志中查看进度".toast();
    } else {
      (response.message ?? "导出失败").toast();
    }
  }

  void importData() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty || result.files.single.path == null) {
      return;
    }
    File file = File(result.files.single.path!);
    await EasyLoading.show(status: " 导入中");
    var response = await SingleAccountPageState.ofApi(context).dataImport(
          await file.readAsBytes(),
          result.files.single.name,
        );
    await EasyLoading.dismiss();
    if (response.success) {
      "导入成功".toast();
    } else {
      (response.message ?? "导入失败").toast();
    }
  }

  Widget _field(String title, TextEditingController controller, String hint, {bool number = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          TitleWidget(title),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            keyboardType: number ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(hintText: hint),
            autofocus: false,
          ),
        ],
      ),
    );
  }

  Widget _action(String text, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      child: SizedBox(
        width: double.infinity,
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: color.withOpacity(0.12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          onPressed: onTap,
          child: Text(
            text,
            style: TextStyle(color: color, fontSize: 15),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QlAppBar(
        canBack: true,
        actions: [
          CommitButton(
            onTap: () {
              submit();
            },
          ),
        ],
        title: "系统设置",
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              primary: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _field("任务并发数", _concurrencyController, "同时运行的任务数量", number: true),
                  _field("Node 镜像源", _nodeMirrorController, "如 https://npmmirror.com/mirrors/node"),
                  _field("Python 镜像源", _pythonMirrorController, "如 https://npmmirror.com/mirrors/python"),
                  _field("Linux 镜像源", _linuxMirrorController, "如 https://npmmirror.com/mirrors/alpine"),
                  _field("依赖安装代理", _proxyController, "留空则不使用代理"),
                  _field("时区", _timezoneController, "如 Asia/Shanghai"),
                  _field("面板标题", _panelTitleController, "自定义面板标题"),
                  const SizedBox(height: 20),
                  _action("重载系统配置", ref.watch(themeProvider).primaryColor, reloadSystem),
                  _action("导出数据", ref.watch(themeProvider).primaryColor, exportData),
                  _action("导入数据", ref.watch(themeProvider).primaryColor, importData),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}
