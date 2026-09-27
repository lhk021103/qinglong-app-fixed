import 'package:flutter/cupertino.dart';
import 'package:qinglong_app/base/base_viewmodel.dart';
import 'package:qinglong_app/base/http/http.dart';
import 'package:qinglong_app/base/single_account_page.dart';
import 'package:qinglong_app/module/others/dependencies/dependency_bean.dart';
import 'package:qinglong_app/module/others/dependencies/dependency_page.dart';
import 'package:qinglong_app/utils/extension.dart';



class DependencyViewModel extends BaseViewModel {
  List<DependencyBean> nodeJsList = [];
  List<DependencyBean> python3List = [];
  List<DependencyBean> linuxList = [];

  @override
  void retry(BuildContext context, {bool showLoading = true}) async {
    await loadData(
        context, DepedencyEnum.NodeJS.name.toLowerCase().toString(), true);
    await loadData(
        context, DepedencyEnum.Python3.name.toLowerCase().toString(), true);
    await loadData(
        context, DepedencyEnum.Linux.name.toLowerCase().toString(), true);
  }

  List<DependencyBean> getListByType(int index) {
    if (DependcyPageState.types[index].name ==
        DepedencyEnum.NodeJS.name.toString()) {
      return nodeJsList;
    } else if (DependcyPageState.types[index].name ==
        DepedencyEnum.Python3.name.toString()) {
      return python3List;
    }
    return linuxList;
  }

  Future<void> loadData(BuildContext context, String type,
      [bool showLoading = false]) async {
    type = type.toLowerCase();
    if (showLoading &&
        ((type == "nodejs" && nodeJsList.isEmpty) ||
            (type == "python3" && python3List.isEmpty) ||
            (type == "linux" && linuxList.isEmpty))) {
      loading(notify: true);
    }

    HttpResponse<List<DependencyBean>> response =
        await SingleAccountPageState.ofApi(context).dependencies(type);
    if (response.success) {
      if (type == "nodejs") {
        nodeJsList.clear();
        nodeJsList.addAll(response.bean!);
      }
      if (type == "python3") {
        python3List.clear();
        python3List.addAll(response.bean!);
      }
      if (type == "linux") {
        linuxList.clear();
        linuxList.addAll(response.bean!);
      }
      success();
    } else {
      response.message?.toast();
    }
  }

  void reInstall(
    BuildContext context,
    String type,
    List<String?>? sId,
    List<int?>? id,
  ) async {
    await SingleAccountPageState.ofApi(context).dependencyReinstall(sId, id);
    await loadData(context, type);
  }

  Future<void> del(
    BuildContext context,
    String type,
    List<String?>? sId,
    List<int?>? ids,
  ) async {
    await SingleAccountPageState.ofApi(context).delDependency(sId, ids);
  }

  /// 取消正在安装的依赖。面板有这条（PUT /dependencies/cancel），原 app 缺，
  /// 依赖卡在「安装中」时只能干等超时。
  Future<void> cancel(
    BuildContext context,
    String type,
    List<String?>? sId,
    List<int?>? ids,
  ) async {
    final bool useNumeric = ids != null && ids.isNotEmpty && ids[0] != null;
    final List<dynamic> payload = useNumeric ? ids!.whereType<int>().toList() : sId?.whereType<String>().toList() ?? [];
    var response = await SingleAccountPageState.ofApi(context).dependencyCancel(payload);
    if (response.success) {
      "已取消安装".toast();
      await loadData(context, type);
    } else {
      response.message?.toast();
    }
  }
}

enum DepedencyEnum { NodeJS, Python3, Linux }
