#!/usr/bin/env dart
// ignore_for_file: avoid_print

import 'dart:io';

import 'package:gms_services/gms_services_setup.dart' as gms;
import 'package:hms_services/hms_services_setup.dart' as hms;

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

  print('\n✅ Удаление настроек GMS и HMS завершено.');
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


