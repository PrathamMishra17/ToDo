
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:to_do_app/Domain/repository/to_do_repo.dart';
import 'package:to_do_app/app/services/supabase_service.dart';
import 'package:to_do_app/data/model/sync_manager.dart';
import 'package:to_do_app/data/repository/isar_todo_repo.dart';
import 'package:to_do_app/presentation/todo_page.dart';


import 'data/model/isar_todo.dart';

// const apiUrl = String.fromEnvironment('API_URL',
// defaultValue: '',
// );



void main()async{
  WidgetsFlutterBinding.ensureInitialized();

   await Get.putAsync(()=> SupabaseService().init());

  //get the directory path for storing the data
  final dir =await getApplicationDocumentsDirectory();

  //open isar database
  final isar = await Isar.open([IsarToDoSchema], directory: dir.path);
  final SyncManager syncManager = SyncManager(isar);
  final isarToDoRepo = IsarTodoRepo(isar, syncManager);

  syncManager.downloadCloudChanges().then((_) => syncManager.uploadLocalChanges());

  runApp(ToDoApp(toDoRepo: isarToDoRepo,));
}

class ToDoApp extends StatelessWidget{
  //database injection through app
  final ToDoRepo toDoRepo;
  const ToDoApp({super.key, required this.toDoRepo});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: TodoPage(toDoRepo: toDoRepo),
    );
  }
}