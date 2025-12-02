#!/usr/bin/env dart
// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:isolate';

import 'package:gms_services/gms_services_setup.dart' as gms;
import 'package:hms_services/hms_services_setup.dart' as hms;
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

/// Основная функция CLI‑утилиты.
///
/// Вынесена отдельно, чтобы её можно было переиспользовать
/// из разных entrypoint‑скриптов (например, app_services:setup).
Future<void> runCli(List<String> args) async {
  print('🔧 app_services: управление GMS/HMS‑настройками\n');

  print('Что вы хотите сделать?');
  print('  1) Установить GMS');
  print('  2) Установить HMS');
  print('  3) Удалить настройки (GMS и HMS)');
  print('  4) Ничего не делать / выход');
  stdout.write('\nВведите номер действия и нажмите Enter: ');

  final input = stdin.readLineSync()?.trim();

  switch (input) {
    case '1':
      await _installGms();
      break;
    case '2':
      await _installHms();
      break;
    case '3':
      await _cleanupOnly();
      break;
    default:
      print('\n🚪 Выход без изменений.');
  }
}

/// Точка входа по умолчанию для команды:
///
///   dart run app_services
Future<void> main(List<String> args) async {
  await runCli(args);
}

Future<void> _installGms() async {
  print('\n➡️  Выбрано: установка GMS');
  print('Сначала будет выполнено удаление настроек GMS и HMS...\n');

  final cleanupOk = await _runCleanupAll();
  if (!cleanupOk) {
    print('\n❌ Установка GMS прервана из‑за ошибок при удалении настроек.');
    exit(1);
  }

  final templatesOk = await _ensureAppServicesTemplates(
    selected: _Plugin.gms,
    projectRoot: Directory.current.path,
  );
  if (!templatesOk) {
    print('\n❌ Не удалось скопировать шаблоны app_services для GMS.');
    exit(1);
  }

  final pubspecOk = _updatePubspecFor(
    selected: _Plugin.gms,
    projectRoot: Directory.current.path,
  );
  if (!pubspecOk) {
    print('\n❌ Не удалось обновить pubspec.yaml для GMS.');
    exit(1);
  }

  print('\n🔧 Установка GMS...\n');
  final result = await gms.setupGmsServices();
  _printResult(result);

  if (!_isResultOk(result)) {
    print('\n❌ Установка GMS завершилась с ошибками.');
    exit(1);
  }

  print('\n✅ Установка GMS завершена успешно.');
}

Future<void> _installHms() async {
  print('\n➡️  Выбрано: установка HMS');
  print('Сначала будет выполнено удаление настроек GMS и HMS...\n');

  final cleanupOk = await _runCleanupAll();
  if (!cleanupOk) {
    print('\n❌ Установка HMS прервана из‑за ошибок при удалении настроек.');
    exit(1);
  }

  final templatesOk = await _ensureAppServicesTemplates(
    selected: _Plugin.hms,
    projectRoot: Directory.current.path,
  );
  if (!templatesOk) {
    print('\n❌ Не удалось скопировать шаблоны app_services для HMS.');
    exit(1);
  }

  final pubspecOk = _updatePubspecFor(
    selected: _Plugin.hms,
    projectRoot: Directory.current.path,
  );
  if (!pubspecOk) {
    print('\n❌ Не удалось обновить pubspec.yaml для HMS.');
    exit(1);
  }

  print('\n🔧 Установка HMS...\n');
  final result = await hms.setupHmsServices();
  _printResult(result);

  if (!_isResultOk(result)) {
    print('\n❌ Установка HMS завершилась с ошибками.');
    exit(1);
  }

  print('\n✅ Установка HMS завершена успешно.');
}

Future<void> _cleanupOnly() async {
  print('\n➡️  Выбрано: удаление настроек GMS и HMS\n');
  final cleanupOk = await _runCleanupAll();

  if (!cleanupOk) {
    print('\n❌ Удаление настроек завершилось с ошибками.');
    exit(1);
  }

  final pubspecOk = _removePluginsFromPubspec(
    projectRoot: Directory.current.path,
  );
  if (!pubspecOk) {
    print(
      '\n❌ Не удалось удалить зависимости gms_services/hms_services из '
      'pubspec.yaml.',
    );
    exit(1);
  }

  final templatesOk = _removeAppServicesTemplates(
    projectRoot: Directory.current.path,
  );
  if (!templatesOk) {
    print(
      '\n❌ Не удалось удалить шаблоны lib/app_services, проверьте проект '
      'вручную.',
    );
    exit(1);
  }

  print(
    '\n✅ Удаление настроек GMS и HMS завершено, зависимости и файлы '
    'lib/app_services удалены.',
  );
}

Future<bool> _runCleanupAll() async {
  print('🗑️  Удаление настроек HMS...\n');
  final hmsResult = await hms.cleanupHmsServices();
  _printResult(hmsResult);

  final hmsOk = _isResultOk(hmsResult);

  print('\n🗑️  Удаление настроек GMS...\n');
  final gmsResult = await gms.cleanupGmsServices();
  _printResult(gmsResult);

  final gmsOk = _isResultOk(gmsResult);

  return hmsOk && gmsOk;
}

void _printResult(dynamic result) {
  final messages = result.messages as List<String>;
  for (final message in messages) {
    print(message);
  }
}

bool _isResultOk(dynamic result) {
  final messages = result.messages as List<String>;
  final hasError = messages.any((m) => m.contains('❌'));
  final changesMade = result.changesMade as bool;

  // Повторяем логику bin‑скриптов GMS/HMS:
  // если изменений нет и при этом есть сообщение с ❌ — считаем, что это ошибка.
  return !(hasError && !changesMade);
}

enum _Plugin { gms, hms }

Future<bool> _ensureAppServicesTemplates({
  required _Plugin selected,
  required String projectRoot,
}) async {
  try {
    final genDir = Directory('$projectRoot/lib/gen');
    if (!genDir.existsSync()) {
      genDir.createSync(recursive: true);
    }
    final libDir = Directory('${genDir.path}/app_services');
    if (!libDir.existsSync()) {
      libDir.createSync(recursive: true);
    }

    // Общие файлы
    await _copyTemplate(
      packagePath: 'templates/common/messaging_api.dart',
      projectPath: '${libDir.path}/messaging_api.dart',
    );
    await _copyTemplate(
      packagePath: 'templates/common/ads_api.dart',
      projectPath: '${libDir.path}/ads_api.dart',
    );
    await _copyTemplate(
      packagePath: 'templates/common/app_services.dart',
      projectPath: '${libDir.path}/app_services.dart',
    );
    await _copyTemplate(
      packagePath: 'templates/common/analytics_api.dart',
      projectPath: '${libDir.path}/analytics_api.dart',
    );
    await _copyTemplate(
      packagePath: 'templates/common/remote_config_api.dart',
      projectPath: '${libDir.path}/remote_config_api.dart',
    );

    // Провайдер‑специфичные файлы
    switch (selected) {
      case _Plugin.gms:
        await _copyTemplate(
          packagePath: 'templates/gms/provider_bootstrap.dart',
          projectPath: '${libDir.path}/provider_bootstrap.dart',
        );
        await _copyTemplate(
          packagePath: 'templates/gms/gms_messaging_adapter.dart',
          projectPath: '${libDir.path}/gms_messaging_adapter.dart',
        );
        await _copyTemplate(
          packagePath: 'templates/gms/gms_ads_adapter.dart',
          projectPath: '${libDir.path}/gms_ads_adapter.dart',
        );
        await _copyTemplate(
          packagePath: 'templates/gms/gms_analytics_adapter.dart',
          projectPath: '${libDir.path}/gms_analytics_adapter.dart',
        );
        await _copyTemplate(
          packagePath: 'templates/gms/gms_remote_config_adapter.dart',
          projectPath: '${libDir.path}/gms_remote_config_adapter.dart',
        );

        // Пробуем удалить HMS‑файлы, если они были созданы ранее.
        for (final name in [
          'hms_messaging_adapter.dart',
          'hms_ads_adapter.dart',
          'hms_analytics_adapter.dart',
          'hms_remote_config_adapter.dart',
        ]) {
          final f = File('${libDir.path}/$name');
          if (f.existsSync()) {
            f.deleteSync();
          }
        }
      case _Plugin.hms:
        await _copyTemplate(
          packagePath: 'templates/hms/provider_bootstrap.dart',
          projectPath: '${libDir.path}/provider_bootstrap.dart',
        );
        await _copyTemplate(
          packagePath: 'templates/hms/hms_messaging_adapter.dart',
          projectPath: '${libDir.path}/hms_messaging_adapter.dart',
        );
        await _copyTemplate(
          packagePath: 'templates/hms/hms_ads_adapter.dart',
          projectPath: '${libDir.path}/hms_ads_adapter.dart',
        );
        await _copyTemplate(
          packagePath: 'templates/hms/hms_analytics_adapter.dart',
          projectPath: '${libDir.path}/hms_analytics_adapter.dart',
        );
        await _copyTemplate(
          packagePath: 'templates/hms/hms_remote_config_adapter.dart',
          projectPath: '${libDir.path}/hms_remote_config_adapter.dart',
        );

        // Пробуем удалить GMS‑файлы, если они были созданы ранее.
        for (final name in [
          'gms_messaging_adapter.dart',
          'gms_ads_adapter.dart',
          'gms_analytics_adapter.dart',
          'gms_remote_config_adapter.dart',
        ]) {
          final f = File('${libDir.path}/$name');
          if (f.existsSync()) {
            f.deleteSync();
          }
        }
    }

    print('✅ Шаблоны app_services скопированы в lib/gen/app_services.');
    return true;
  } catch (e) {
    print('❌ Ошибка при копировании шаблонов app_services: $e');
    return false;
  }
}

Future<void> _copyTemplate({
  required String packagePath,
  required String projectPath,
}) async {
  final templateFile = await _resolvePackageFile(packagePath);
  final targetFile = File(projectPath);

  final content = await templateFile.readAsString();
  await targetFile.writeAsString(content);
}

Future<File> _resolvePackageFile(String packageRelativePath) async {
  final uri = await Isolate.resolvePackageUri(
    Uri.parse('package:app_services/$packageRelativePath'),
  );
  if (uri == null) {
    throw StateError(
      'Не удалось найти ресурс в пакете app_services: $packageRelativePath',
    );
  }
  return File.fromUri(uri);
}

bool _updatePubspecFor({
  required _Plugin selected,
  required String projectRoot,
}) {
  final file = File('$projectRoot/pubspec.yaml');
  if (!file.existsSync()) {
    print('⚠️  pubspec.yaml не найден в $projectRoot. Пропускаю обновление.');
    return false;
  }

  try {
    final content = file.readAsStringSync();
    final editor = YamlEditor(content);
    final doc = loadYaml(content);

    const depsKey = 'dependencies';
    Map deps;

    if (doc is YamlMap && doc.containsKey(depsKey)) {
      final rawDeps = doc[depsKey];
      if (rawDeps is YamlMap) {
        deps = Map.from(rawDeps);
      } else if (rawDeps is Map) {
        deps = Map.from(rawDeps);
      } else {
        deps = <String, Object?>{};
      }
    } else {
      deps = <String, Object?>{};
      editor.update([depsKey], deps);
    }

    final selectedName = switch (selected) {
      _Plugin.gms => 'gms_services',
      _Plugin.hms => 'hms_services',
    };
    final otherName = switch (selected) {
      _Plugin.gms => 'hms_services',
      _Plugin.hms => 'gms_services',
    };

    final selectedSpec = switch (selected) {
      _Plugin.gms => {
          'git': {
            'url': 'https://github.com/Mr-KrY4k/gms_services.git',
            'ref': 'main',
          },
        },
      _Plugin.hms => {
          'git': {
            'url': 'https://github.com/Mr-KrY4k/hms_services.git',
            'ref': 'main',
          },
        },
    };

    editor.update([depsKey, selectedName], selectedSpec);

    try {
      editor.remove([depsKey, otherName]);
    } catch (_) {
      // Если зависимости нет — просто игнорируем.
    }

    file.writeAsStringSync(editor.toString());

    print(
      '✅ pubspec.yaml обновлён: включён $selectedName, удалён $otherName (если был).',
    );

    return true;
  } catch (e) {
    print('❌ Ошибка при обновлении pubspec.yaml: $e');
    return false;
  }
}

bool _removePluginsFromPubspec({required String projectRoot}) {
  final file = File('$projectRoot/pubspec.yaml');
  if (!file.existsSync()) {
    print('⚠️  pubspec.yaml не найден в $projectRoot. Пропускаю удаление зависимостей.');
    return false;
  }

  try {
    final content = file.readAsStringSync();
    final editor = YamlEditor(content);
    final doc = loadYaml(content);

    const depsKey = 'dependencies';

    if (doc is! YamlMap || !doc.containsKey(depsKey)) {
      // Нет секции dependencies — считать, что удалять нечего.
      return true;
    }

    var hadAny = false;

    for (final name in ['gms_services', 'hms_services']) {
      try {
        editor.remove([depsKey, name]);
        hadAny = true;
      } catch (_) {
        // Если зависимости нет — ничего страшного.
      }
    }

    if (!hadAny) {
      print('ℹ️  В pubspec.yaml уже нет зависимостей gms_services/hms_services.');
      return true;
    }

    file.writeAsStringSync(editor.toString());
    print('✅ Из pubspec.yaml удалены зависимости gms_services и hms_services.');
    return true;
  } catch (e) {
    print('❌ Ошибка при удалении зависимостей из pubspec.yaml: $e');
    return false;
  }
}

bool _removeAppServicesTemplates({required String projectRoot}) {
  try {
    final dir = Directory('$projectRoot/lib/gen/app_services');
    if (!dir.existsSync()) {
      // Нечего удалять — считаем успехом.
      return true;
    }

    // Удаляем только известные файлы, чтобы не сносить чужой код.
    const knownFiles = <String>[
      'messaging_api.dart',
      'ads_api.dart',
       'analytics_api.dart',
       'remote_config_api.dart',
      'app_services.dart',
      'provider_bootstrap.dart',
      'gms_messaging_adapter.dart',
      'gms_ads_adapter.dart',
       'gms_analytics_adapter.dart',
       'gms_remote_config_adapter.dart',
      'hms_messaging_adapter.dart',
      'hms_ads_adapter.dart',
       'hms_analytics_adapter.dart',
       'hms_remote_config_adapter.dart',
    ];

    for (final name in knownFiles) {
      final file = File('${dir.path}/$name');
      if (file.existsSync()) {
        file.deleteSync();
      }
    }

    // Если после этого директория пустая — удаляем её и, при необходимости,
    // всю директорию lib/gen.
    final remainingFiles =
        dir.existsSync() ? dir.listSync().whereType<File>().toList() : [];
    if (remainingFiles.isEmpty && dir.existsSync()) {
      dir.deleteSync(recursive: true);

      final genDir = Directory('$projectRoot/lib/gen');
      final genRemaining =
          genDir.existsSync() ? genDir.listSync().toList() : [];
      if (genRemaining.isEmpty && genDir.existsSync()) {
        genDir.deleteSync(recursive: true);
      }
    }

    print('✅ Файлы lib/gen/app_services очищены.');
    return true;
  } catch (e) {
    print('❌ Ошибка при удалении файлов lib/app_services: $e');
    return false;
  }
}
