import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/file_transfer_engine.dart';
import '../core/models/transfer_task.dart';

/// File transfer engine provider
final fileTransferEngineProvider = Provider<FileTransferEngine>((ref) {
  return FileTransferEngine();
});

/// Active transfers provider
final activeTransfersProvider = StreamProvider<TransferTask>((ref) {
  final engine = ref.watch(fileTransferEngineProvider);
  return engine.onTaskUpdate;
});

/// Received files provider
final receivedFilesProvider = StreamProvider<TransferTask>((ref) {
  final engine = ref.watch(fileTransferEngineProvider);
  return engine.onFileReceived;
});

/// Sending tasks provider (list of all sending tasks)
final sendingTasksProvider = StreamProvider<List<TransferTask>>((ref) {
  final engine = ref.watch(fileTransferEngineProvider);
  return engine.onTaskUpdate.map((_) => engine.sendingTasks);
});

/// Receiving tasks provider (list of all receiving tasks)
final receivingTasksProvider = StreamProvider<List<TransferTask>>((ref) {
  final engine = ref.watch(fileTransferEngineProvider);
  return engine.onTaskUpdate.map((_) => engine.receivingTasks);
});
