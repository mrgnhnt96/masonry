// ignore_for_file: unnecessary_cast

import 'package:brick_oven/domain/brick.dart';
import 'package:brick_oven/domain/brick_file.dart';
import 'package:brick_oven/domain/brick_path.dart';
import 'package:brick_oven/domain/brick_source.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:test/test.dart';

import '../utils/fakes.dart';
import '../utils/to_yaml.dart';

void main() {
  group('#fromYaml', () {
    test('parses when provided', () {
      final brick = Brick(
        configuredDirs: [BrickPath(name: 'name', path: 'path/to/dir')],
        configuredFiles: const [BrickFile('file/path/name.dart')],
        name: 'brick',
        source: const BrickSource(localPath: 'localPath'),
      );

      final data = brick.toYaml();

      final result = Brick.fromYaml(brick.name, data);

      expectLater(result, brick);
    });

    test('throws argument error when extra keys are provided', () {
      final brick = Brick(
        configuredDirs: [BrickPath(name: 'name', path: 'path/to/dir')],
        configuredFiles: const [BrickFile('file/path/name.dart')],
        name: 'brick',
        source: const BrickSource(localPath: 'localPath'),
      );

      final data = brick.toJson();
      data['extra'] = 'extra';
      final yaml = FakeYamlMap(data);

      expect(() => Brick.fromYaml(brick.name, yaml), throwsArgumentError);
    });
  });

  group('#writeBrick', () {
    const brickName = 'super_awesome';
    const localPath = 'localPath';
    const brickPath = 'bricks/$brickName/__brick__';
    const dirName = 'director_of_shield';
    const newDirName = 'director_of_world';
    const fileName = 'nick_fury.dart';
    const dirPath = 'path/to/$dirName';
    const filePath = '$dirPath/$fileName';

    late FileSystem fs;

    setUp(() {
      fs = MemoryFileSystem();
    });

    Brick brick({
      bool createFile = false,
      bool createDir = false,
      List<String>? fileNames,
    }) {
      return Brick.memory(
        name: brickName,
        source: const BrickSource(localPath: localPath),
        configuredDirs: [
          if (createDir) BrickPath(name: newDirName, path: dirPath),
        ],
        configuredFiles: [
          if (createFile && fileNames != null) const BrickFile(filePath),
          if (fileNames != null)
            for (final name in fileNames) BrickFile('$dirPath/$name'),
        ],
        fileSystem: fs,
      );
    }

    test('should not create the bricks folder when no files are provided', () {
      brick().writeBrick();
    });

    test('checks for directory bricks/{name}/__brick__', () {
      final testBrick = brick(createFile: true);

      final fakeSourcePath = fs.file(
        testBrick.source.fromSourcePath(testBrick.configuredFiles.single),
      );

      expect(fs.file('$brickPath/$filePath').existsSync(), isFalse);

      fs.file(fakeSourcePath).createSync(recursive: true);

      testBrick.writeBrick();

      expect(fs.file('$brickPath/$filePath').existsSync(), isTrue);
    });

    test('deletes directory if exists', () {
      final testBrick = brick(createFile: true);

      final fakeSourcePath = fs.file(
        testBrick.source.fromSourcePath(testBrick.configuredFiles.single),
      );

      final fakeUnneededFile = fs.file('$brickPath/unneeded.dart');

      expect(fakeUnneededFile.existsSync(), isFalse);

      fakeUnneededFile.createSync(recursive: true);

      expect(fakeUnneededFile.existsSync(), isTrue);

      fs.file(fakeSourcePath).createSync(recursive: true);

      testBrick.writeBrick();

      expect(fakeUnneededFile.existsSync(), isFalse);
    });

    test('loops through files to write', () {
      const files = ['file1.dart', 'file2.dart', 'file3.dart'];

      final testBrick = brick(createFile: true, fileNames: files);

      for (final file in testBrick.configuredFiles) {
        final fakeSourcePath = fs.file(
          testBrick.source.fromSourcePath(file),
        );

        fs.file(fakeSourcePath).createSync(recursive: true);
      }

      for (final file in testBrick.configuredFiles) {
        expect(fs.file('$brickPath/${file.path}').existsSync(), isFalse);
      }

      testBrick.writeBrick();

      for (final file in testBrick.configuredFiles) {
        expect(fs.file('$brickPath/${file.path}').existsSync(), isTrue);
      }
    });
  });
}
