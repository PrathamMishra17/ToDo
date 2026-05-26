import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'isar_todo.dart'; // Point to your schema path

class SyncManager {
  final Isar isar;
  final _supabase = Supabase.instance.client;

  SyncManager(this.isar);

  // Push local updates up to Supabase
  Future<void> uploadLocalChanges() async {
    try {
      final unsynced = await isar.isarToDos.filter().isSyncedEqualTo(false).findAll();

      for (var localTodo in unsynced) {
        if (localTodo.isDeleted) {

          await _supabase.from('todos').upsert({
            'id': localTodo.supabaseId,
            'text': localTodo.text,
            'isCompleted': localTodo.isCompleted,
            'lastModified':localTodo.lastModified.toIso8601String(),
            'isDeleted' : true
          });

          // Then completely remove it from local Isar disk
          await isar.writeTxn(() => isar.isarToDos.delete(localTodo.id));
        } else {
          // Send to Supabase (inserts if new, updates text/completion if exists)
          await _supabase.from('todos').upsert({
            'id': localTodo.supabaseId,
            'text': localTodo.text,
            'isCompleted': localTodo.isCompleted,
            'lastModified': localTodo.lastModified.toIso8601String(),
            'isDeleted' : false
          });

          // --- FIX 2: Wrapped the put() correctly to return the transaction ---
          await isar.writeTxn(() async {
            localTodo.isSynced = true;
            await isar.isarToDos.put(localTodo);
          });
        }
      }
    } catch (e) {
      print("Sync upload deferred (waiting for network): $e");
    }
  }

  // Pull down fresh edits from Supabase
  Future<void> downloadCloudChanges() async {
    try {
      final latestLocal = await isar.isarToDos.where().sortByLastModifiedDesc().findFirst();
      final lastSyncTime = latestLocal?.lastModified.toIso8601String() ?? DateTime.fromMillisecondsSinceEpoch(0).toIso8601String();

      final List<dynamic> remoteChanges = await _supabase
          .from('todos')
          .select()
          .gt('lastModified', lastSyncTime);

      if (remoteChanges.isEmpty) return;

      await isar.writeTxn(() async {
        for (var row in remoteChanges) {
          final String sId = row['id'];
          final localMatch = await isar.isarToDos.filter().supabaseIdEqualTo(sId).findFirst();

          // Only overwrite if it's new, or if our local copy isn't currently waiting to push an update
          if (localMatch == null || localMatch.isSynced == true) {
            final updated = (localMatch ?? IsarToDo())
              ..supabaseId = sId
              ..text = row['text']
              ..isCompleted = row['isCompleted']
              ..isSynced = true
              ..isDeleted = false
              ..lastModified = DateTime.parse(row['lastModified']);

            await isar.isarToDos.put(updated);
          }
        }
      });
    } catch (e) {
      print("Sync download deferred (waiting for network): $e");
    }
  }
}