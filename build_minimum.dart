import 'dart:io';

import 'package:path/path.dart' as path;

void main() async {
  const kDebugInfoDir = 'build/debug_info';
  const kGradleProjectVar = 'ORG_GRADLE_PROJECT';

  final debugInfoDirExists = await Directory(kDebugInfoDir).exists();
  if (!debugInfoDirExists) {
    await Directory(kDebugInfoDir).create(recursive: true);
  }

  stdout.write([
    'Choose build type:',
    '1. APK',
    '2. Github APK',
    '3. AAB',
    'Select build type: ',
  ].join('\n'));

  final buildType = stdin.readLineSync();
  final environment = <String, String>{};

  Process? process;
  String outputDir;

  switch (buildType) {
    case '1' || '2':
      stdout.writeln('Building APK...');
      environment.addAll({
        if (buildType == '2')
          '${kGradleProjectVar}_KEYSTORE_PROPERTIES_FILE':
              'key.github.properties'
      });
      process = await Process.start(
        'flutter',
        [
          'build',
          'apk',
          '--split-per-abi',
          '--obfuscate',
          '--split-debug-info=$kDebugInfoDir'
        ],
        environment: environment,
        runInShell: true,
      );
      outputDir = path.join('build', 'app', 'outputs', 'flutter-apk');
    case '3':
      stdout.writeln('Building AAB...');
      process = await Process.start(
        'flutter',
        [
          'build',
          'appbundle',
          '--obfuscate',
          '--split-debug-info=$kDebugInfoDir'
        ],
        environment: environment,
        runInShell: true,
      );
      outputDir = path.join('build', 'app', 'outputs', 'bundle', 'release');
    default:
      stdout.writeln('Invalid choice. The script will exit.');
      exit(1);
  }

  stdout.addStream(process.stdout);
  stderr.addStream(process.stderr);
  await process.exitCode;
  Process.start(
    'start',
    [outputDir],
    environment: environment,
    runInShell: true,
  );
}
