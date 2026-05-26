/*
DATABASE REPO (WITH SUPABASE SYNC INTEGRATION)

This implements the todo repo and handles storing, retrieving, updating, and soft-deleting in the Isar database.
It also kicks off background synchronization workers to keep Supabase in alignment.
*/

import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart'; // Run: flutter pub add uuid
import 'package:to_do_app/Domain/repository/to_do_repo.dart';
import 'package:to_do_app/data/model/isar_todo.dart';


import '../../Domain/Models/to_do.dart';
import '../model/sync_manager.dart';

class IsarTodoRepo implements ToDoRepo {
  final Isar db;
  final SyncManager syncManager; // 1. Pass the sync manager down here

  IsarTodoRepo(this.db, this.syncManager);

  // --- GET TODOS ---
  @override
  Future<List<ToDo>> getToDos() async {
    // We only fetch items that have NOT been soft-deleted locally by the user
    final todos = await db.isarToDos.filter().isDeletedEqualTo(false).findAll();

    return todos.map((isarTodo) => isarTodo.toDomain()).toList();
  }

  // --- ADD TODO ---
  @override
  Future<void> addToDos(ToDo newToDo) async {
    // Generate a fresh unique UUID string for Supabase tracking right at birth
    final String cloudUuid = const Uuid().v4();

    // Convert the domain model into an Isar record using the updated fromDomain mapping builder
    final todoisar = IsarToDo.fromDomain(newToDo, cloudUuid);

    // Save locally to disk instantly so the UI feels incredibly snappy
    await db.writeTxn(() => db.isarToDos.put(todoisar));

    // Kick off the cloud sync in the background (fire-and-forget)
    syncManager.uploadLocalChanges();
  }

  // --- UPDATE TODO ---
  @override
  Future<void> updateTodo(ToDo todo) async {
    // 1. Find the existing item in Isar first to preserve its permanent Supabase UUID
    final localRecord = await db.isarToDos.get(todo.id);

    if (localRecord != null) {
      await db.writeTxn(() {
        localRecord.text = todo.text;
        localRecord.isCompleted = todo.isCompleted;

        // Flag it as dirty so the sync engine knows it needs to be uploaded
        localRecord.isSynced = false;
        localRecord.lastModified = DateTime.now().toUtc();

        return db.isarToDos.put(localRecord);
      });

      // Synchronize the update out to the cloud in the background
      syncManager.uploadLocalChanges();
    }
  }

  // --- DELETE TODO ---
  @override
  Future<void> deleteTodo(ToDo todo) async {
    // Get the local item from Isar
    final localRecord = await db.isarToDos.get(todo.id);

    if (localRecord != null) {
      // Instead of hard-deleting it from disk instantly, we soft-delete it.
      // This preserves its supabaseId so our sync manager knows which cloud row to destroy.
      await db.writeTxn(() {
        localRecord.isDeleted = true;
        localRecord.isSynced = false;
        localRecord.lastModified = DateTime.now().toUtc();
        return db.isarToDos.put(localRecord);
      });

      // Tell the sync manager to process this removal on Supabase.
      // The sync manager will completely drop it from local Isar disk once the cloud deletion confirms!
      syncManager.uploadLocalChanges();
    }
  }

  //--- CLEAR TODO ---
 @override
  Future<void> clearAllToDos() async{
    //fetching all records for deleting
   final activeRecords = await db.isarToDos.filter().isDeletedEqualTo(false).findAll();

   if(activeRecords.isEmpty ) return;

 //for doing the batch operation at once , here we are deleting the list at once in a batch using a enhanced loop
   await db.writeTxn(()async{

     final now = DateTime.now().toUtc();
     for(var record in activeRecords){
       record.isDeleted = true;
       record.isSynced = false;
       record.lastModified = now;
     }
     
     await db.isarToDos.putAll(activeRecords);

     //for clearing the data from the supabase
     syncManager.uploadLocalChanges();

   });

 }



}