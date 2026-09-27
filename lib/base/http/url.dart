import 'package:qinglong_app/base/userinfo_viewmodel.dart';
import 'package:qinglong_app/main.dart';

class Url {
  int index;

  Url(this.index);

  static get login => "/api/user/login";

  static get system => "/api/system";

  static get loginOld => "/api/login";

  static get loginTwo => "/api/user/two-factor/login";
  static const loginByClientId = "/open/auth/token";
  static const user = "/api/user";

  static const updatePassword = "/api/user";

  /// 旧端点 /system/log/remove 已在新版面板下线：
  /// 读取走 GET /system/config（返回体含 logRemoveFrequency），
  /// 写入走 PUT /system/config/log-remove-frequency（body: {logRemoveFrequency}）。
  get logDel => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/system/config" : "/api/system/config";

  get logRemoveFrequency =>
      getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/system/config/log-remove-frequency" : "/api/system/config/log-remove-frequency";

  get systemConfig => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/system/config" : "/api/system/config";

  get cronConcurrency =>
      getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/system/config/cron-concurrency" : "/api/system/config/cron-concurrency";

  get dependenceProxy =>
      getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/system/config/dependence-proxy" : "/api/system/config/dependence-proxy";

  get nodeMirror => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/system/config/node-mirror" : "/api/system/config/node-mirror";

  get pythonMirror =>
      getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/system/config/python-mirror" : "/api/system/config/python-mirror";

  get linuxMirror => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/system/config/linux-mirror" : "/api/system/config/linux-mirror";

  get timezone => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/system/config/timezone" : "/api/system/config/timezone";

  get panelTitle => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/system/config/panel-title" : "/api/system/config/panel-title";

  get dependenceClean =>
      getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/system/config/dependence-clean" : "/api/system/config/dependence-clean";

  get systemReload => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/system/reload" : "/api/system/reload";

  get systemUpdate => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/system/update" : "/api/system/update";

  get dataExport => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/system/data/export" : "/api/system/data/export";

  get dataImport => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/system/data/import" : "/api/system/data/import";

  get commandRun => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/system/command-run" : "/api/system/command-run";

  get commandStop => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/system/command-stop" : "/api/system/command-stop";

  get cronViews => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/crons/views" : "/api/crons/views";

  get cronLabels => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/crons/labels" : "/api/crons/labels";

  get cronStatus => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/crons/status" : "/api/crons/status";

  get cronImport => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/crons/import" : "/api/crons/import";

  get envUpload => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/envs/upload" : "/api/envs/upload";

  get envMoveTo => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/envs/move" : "/api/envs/move";

  get envName => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/envs/name" : "/api/envs/name";

  get envPin => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/envs/pin" : "/api/envs/pin";

  get envUnpin => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/envs/unpin" : "/api/envs/unpin";

  get dependencyCancel =>
      getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/dependencies/cancel" : "/api/dependencies/cancel";

  get logDownload => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/logs/download" : "/api/logs/download";

  get configSamples => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/configs/samples" : "/api/configs/samples";

  get configDetail => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/configs/detail" : "/api/configs/detail";

  get dashboardOverview =>
      getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/dashboard/overview" : "/api/dashboard/overview";

  get dashboardTrend => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/dashboard/trend" : "/api/dashboard/trend";

  get dashboardTopTime =>
      getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/dashboard/top-time" : "/api/dashboard/top-time";

  get dashboardTopCount =>
      getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/dashboard/top-count" : "/api/dashboard/top-count";

  get dashboardRuntime =>
      getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/dashboard/runtime" : "/api/dashboard/runtime";

  get dashboardLabels => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/dashboard/labels" : "/api/dashboard/labels";

  get dashboardSystem => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/dashboard/system" : "/api/dashboard/system";

  get storageRetentionConfig =>
      getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/system/storage-retention/config" : "/api/system/storage-retention/config";

  get storageRetentionPreview =>
      getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/system/storage-retention/preview" : "/api/system/storage-retention/preview";

  get storageRetentionCleanup =>
      getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/system/storage-retention/cleanup" : "/api/system/storage-retention/cleanup";

  get userTwoFactorInit =>
      getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/user/two-factor/init" : "/api/user/two-factor/init";

  get userTwoFactorActive =>
      getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/user/two-factor/active" : "/api/user/two-factor/active";

  get userTwoFactorDeactivate =>
      getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/user/two-factor/deactivate" : "/api/user/two-factor/deactivate";

  get userAvatar => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/user/avatar" : "/api/user/avatar";

  get ipBlacklist => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/user/ip-blacklist" : "/api/user/ip-blacklist";

  get health => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/health" : "/api/health";

  cronInstances(String id) {
    return getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/crons/$id/instances" : "/api/crons/$id/instances";
  }

  cronInstanceStop(String id, String instanceId) {
    return getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined
        ? "/open/crons/$id/instances/$instanceId/stop"
        : "/api/crons/$id/instances/$instanceId/stop";
  }

  scriptDetailNew(String? path, String file) {
    final base = getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/scripts/detail" : "/api/scripts/detail";
    return "$base?path=${Uri.encodeComponent(path ?? "")}&file=${Uri.encodeComponent(file)}";
  }

  get tasks => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/crons" : "/api/crons";

  get subscribes => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/subscriptions" : "/api/subscriptions";

  get notifcations => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/user/notification" : "/api/user/notification";

  get runSubscribes => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/subscriptions/run" : "/api/subscriptions/run";

  get stopSubscribes => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/subscriptions/stop" : "/api/subscriptions/stop";

  get addSubscribes => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/subscriptions" : "/api/subscriptions";

  get enableSubscribes =>
      getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/subscriptions/enable" : "/api/subscriptions/enable";

  get disableSubscribes =>
      getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/subscriptions/disable" : "/api/subscriptions/disable";

  get runTasks => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/crons/run" : "/api/crons/run";

  get stopTasks => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/crons/stop" : "/api/crons/stop";

  get taskDetail => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/crons/" : "/api/crons/";

  get addTask => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/crons" : "/api/crons";

  get pinTask => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/crons/pin" : "/api/crons/pin";

  get unpinTask => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/crons/unpin" : "/api/crons/unpin";

  get enableTask => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/crons/enable" : "/api/crons/enable";

  get disableTask => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/crons/disable" : "/api/crons/disable";

  get files => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/configs/files" : "/api/configs/files";

  get configContent => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/configs/" : "/api/configs/";

  get saveFile => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/configs/save" : "/api/configs/save";

  get envs => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/envs" : "/api/envs";

  get addEnv => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/envs" : "/api/envs";

  get delEnv => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/envs" : "/api/envs";

  get disableEnvs => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/envs/disable" : "/api/envs/disable";

  get enableEnvs => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/envs/enable" : "/api/envs/enable";

  get loginLog => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/user/login-log" : "/api/user/login-log";

  get logFoldDelete => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/logs" : "/api/logs";

  get taskLog => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/logs" : "/api/logs";

  get taskLogDetail => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/logs/" : "/api/logs/";

  get scripts => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/scripts/files" : "/api/scripts/files";

  get scripts2 => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/scripts" : "/api/scripts";

  get scriptUpdate => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/scripts" : "/api/scripts";

  get scriptDetail => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/scripts" : "/api/scripts";
  get scriptDetailForReadFile => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/scripts/" : "/api/scripts/";

  get dependencies => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/dependencies" : "/api/dependencies";

  get dependenciesDeleteFocus =>
      getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/dependencies/force" : "/api/dependencies/force";

  get dependenciesReinstall =>
      getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/dependencies/reinstall" : "/api/dependencies/reinstall";

  get addScript => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/scripts" : "/api/scripts";

  get dependencyReinstall =>
      getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/dependencies/reinstall" : "/api/dependencies/reinstall";

  get checkUpdate => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/system/update-check" : "/api/system/update-check";

  get appkeys => getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/apps" : "/api/apps";

  /// 修复：原实现三元两个分支完全相同，client_id 登录时本该打 /open 前缀，
  /// 却始终打 /api，open token 不被该路由接受 -> 重置密钥必然失败。
  resetAppKey(dynamic id) {
    return getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined
        ? "/open/apps/${id.toString()}/reset-secret"
        : "/api/apps/${id.toString()}/reset-secret";
  }

  intimeLog(String cronId) {
    return getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/crons/$cronId/log" : "/api/crons/$cronId/log";
  }

  intimeDepLog(String id) {
    return getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/dependencies/$id" : "/api/dependencies/$id";
  }

  intimeSubscribeLog(int cronId) {
    return getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/subscriptions/$cronId/log" : "/api/subscriptions/$cronId/log";
  }

  envMove(String envId) {
    return getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined ? "/open/envs/$envId/move" : "/api/envs/$envId/move";
  }

  static bool inWhiteList(String path) {
    if (path == login || path == loginByClientId || path == loginTwo || path == loginOld) {
      return true;
    }
    return false;
  }

  static bool inLoginList(String path) {
    if (path == login || path == loginByClientId || path == loginOld) {
      return true;
    }
    return false;
  }
}
