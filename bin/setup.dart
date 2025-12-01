#!/usr/bin/env dart
// ignore_for_file: avoid_print

import 'app_services.dart' as cli;

/// Entry‑point для команды:
///
///   dart run app_services:setup
///
/// Делегирует выполнение в общий CLI (`runCli`), чтобы логика
/// оставалась единой для app_services и app_services:setup.
Future<void> main(List<String> args) async {
  await cli.runCli(args);
}


