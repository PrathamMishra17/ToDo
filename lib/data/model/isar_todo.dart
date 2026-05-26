import 'package:isar/isar.dart';
import '../../Domain/Models/to_do.dart';

/**
 *
 * ISAR TODO MODEL  we are going to use isar database for the local storage also supabase will be added
 *
 */

//to generate the isar todo object ,run: dart run build_runner build

part 'isar_todo.g.dart';

@collection

class IsarToDo {
  Id id = Isar.autoIncrement;
  late String text; //late keyword tells the compiler that this variable can not be null but
  //i cannot initialize right now but i promise i will initialize in future
  late bool isCompleted;
 ///Unique cloud string key to map this local row to its Supabase row
  @Index(unique: true, replace: true)
  String? supabaseId;

  //sync tracking flag
  bool isSynced = false;
  DateTime lastModified = DateTime.now().toUtc();
  bool isDeleted = false; // Soft-delete flag so we know to remove it from the cloud later

   //  convert the isar object -> pure todo object to use in our app

 ToDo toDomain(){
   return ToDo(
     id: id,
     text: text,
     isCompleted: isCompleted
   );
 }


// Convert the todo object -> pure isar object to store in isar db
  // We add a 'uuid' string argument here so we can create a cloud link right at generation time
  static IsarToDo fromDomain(ToDo todo, String uuid) {
    return IsarToDo()
      ..id = todo.id == 0 ? Isar.autoIncrement : todo.id
      ..text = todo.text
      ..isCompleted = todo.isCompleted
      ..supabaseId = uuid          // Connect the UUID
      ..isSynced = false           // Mark as unsynced initially
      ..isDeleted = false          // It's a new living record
      ..lastModified = DateTime.now().toUtc(); // Timestamp it
  }

}