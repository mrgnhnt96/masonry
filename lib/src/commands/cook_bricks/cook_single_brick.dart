// ignore_for_file: overridden_fields

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:brick_oven/domain/brick.dart';
import 'package:brick_oven/domain/brick_oven_yaml.dart';
import 'package:brick_oven/src/commands/brick_oven_cooker.dart';
import 'package:brick_oven/src/exception.dart';
import 'package:brick_oven/src/key_press_listener.dart';
import 'package:brick_oven/utils/config_watcher_mixin.dart';
import 'package:brick_oven/utils/extensions.dart';
import 'package:brick_oven/utils/oven_mixin.dart';
import 'package:file/file.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:watcher/watcher.dart';

/// {@template cook_single_brick_command}
/// Writes a single brick from the configuration file
/// {@endtemplate}
class CookSingleBrick extends BrickOvenCooker
    with ConfigWatcherMixin, OvenMixin {
  /// {@macro cook_single_brick_command}
  CookSingleBrick(
    this.brick, {
    FileSystem? fileSystem,
    required Logger logger,
    FileWatcher? configWatcher,
    KeyPressListener? keyPressListener,
  })  : keyPressListener = keyPressListener ??
            KeyPressListener(
              stdin: stdin,
              logger: logger,
              toExit: exit,
            ),
        configWatcher = configWatcher ?? FileWatcher(BrickOvenYaml.file),
        super(fileSystem: fileSystem, logger: logger) {
    argParser
      ..addFlagsAndOptions()
      ..addSeparator('${'-' * 79}\n');
  }

  /// The brick to cook
  final Brick brick;

  @override
  final FileWatcher configWatcher;

  @override
  final KeyPressListener keyPressListener;

  @override
  String get description => 'Cook the brick: $name.';

  @override
  String get name => brick.name;

  @override
  Future<int> run() async {
    logger.cooking();

    if (!isWatch) {
      brick.cook(output: outputDir);

      logger.cooked();

      return ExitCode.success.code;
    }

    brick.source.watcher
      ?..addEvent(
        () => logger.fileChanged(brick.name),
        runBefore: true,
      )
      ..addEvent(logger.cooking, runBefore: true)
      ..addEvent(logger.watching, runAfter: true)
      ..addEvent(logger.keyStrokes, runAfter: true);

    try {
      brick.cook(output: outputDir, watch: true);
    } on ConfigException catch (e) {
      logger.err(e.message);
      return ExitCode.config.code;
    } catch (e) {
      logger.err('$e');
      return ExitCode.software.code;
    }

    logger
      ..cooked()
      ..watching();

    keyPressListener.listenToKeystrokes();

    if (brick.configPath != null) {
      unawaited(
        watchForConfigChanges(
          brick.configPath!,
          onChange: () async {
            logger.configChanged();

            await cancelConfigWatchers();
            await brick.source.watcher?.stop();
          },
        ),
      );
    }

    await watchForConfigChanges(
      BrickOvenYaml.file,
      onChange: () async {
        logger.configChanged();

        await brick.source.watcher?.stop();
      },
    );

    return ExitCode.tempFail.code;
  }

  @override
  bool get isWatch => argResults['watch'] == true;

  @override
  String get outputDir => argResults['output'] as String? ?? 'bricks';
}

extension on ArgParser {
  void addFlagsAndOptions() {
    output();

    watch();

    quitAfter();
  }
}
