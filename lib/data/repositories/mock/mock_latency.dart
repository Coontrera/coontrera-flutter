import 'dart:math';

/// Simulated network latency so the UI exercises real loading states even
/// though every repository here is backed by local Hive storage.
Future<void> simulateLatency() {
  final random = Random();
  return Future.delayed(Duration(milliseconds: 300 + random.nextInt(400)));
}
