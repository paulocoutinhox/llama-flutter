import 'dart:async';
import 'dart:convert';
import 'dart:io';

class ProcessRunner {
  final String executable;
  final List<String> arguments;
  Process? _process;

  ProcessRunner(this.executable, this.arguments);

  Future<void> run({
    required Function(String) onOutput,
    void Function()? onCancel,
  }) async {
    final process = await Process.start(executable, arguments);

    _process = process;

    final subscription = process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) => onOutput(line));

    if (onCancel != null) {
      final cancelSubscription =
          Stream<void>.fromFuture(process.exitCode.then((_) => null))
              .listen((_) => onCancel());
      await Future.any([cancelSubscription.asFuture(), process.exitCode]);
    } else {
      await process.exitCode;
    }

    await subscription.cancel();
  }

  void cancel() {
    _process?.kill();
  }
}
