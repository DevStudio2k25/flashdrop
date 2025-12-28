import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/database_service.dart';
import '../core/models/transfer_task.dart';

/// Database service provider
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

/// Transfer history provider
final transferHistoryProvider = FutureProvider<List<TransferTask>>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  return await db.getTransferHistory();
});

/// Sent files history provider
final sentFilesHistoryProvider = FutureProvider<List<TransferTask>>((
  ref,
) async {
  final db = ref.watch(databaseServiceProvider);
  return await db.getTransferHistoryByDirection(TransferDirection.send);
});

/// Received files history provider
final receivedFilesHistoryProvider = FutureProvider<List<TransferTask>>((
  ref,
) async {
  final db = ref.watch(databaseServiceProvider);
  return await db.getTransferHistoryByDirection(TransferDirection.receive);
});
