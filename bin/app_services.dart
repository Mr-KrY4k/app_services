#!/usr/bin/env dart
// ignore_for_file: avoid_print

import 'dart:io';

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
    print('\n❌ Не удалось удалить зависимости gms_services/hms_services из pubspec.yaml.');
    exit(1);
  }

  print('\n✅ Удаление настроек GMS и HMS завершено, зависимости из pubspec.yaml удалены.');
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
            'ref': 'dev',
          },
        },
      _Plugin.hms => {
          'git': {
            'url': 'https://github.com/Mr-KrY4k/hms_services.git',
            'ref': 'dev',
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



