import 'package:to_do_app/Domain/Models/to_do.dart';

/**
 *  here you define what application will do and not how application will do
 *

 */

abstract class ToDoRepo {
  //get the list of the todo

  Future<List<ToDo>>  getToDos();

  //add a new todo

Future<void> addToDos(ToDo newToDo);

  //update a existing todo

Future<void> updateTodo(ToDo todo);

  //delete the todo

Future<void> deleteTodo(ToDo todo);

  //clearing all ToDos
Future<void> clearAllToDos();

}





/**
 * Notes:
 *
 *   - the repo in the domain layer outlines what operations the app can do , but does not worry about the
 *   implementation details. That's for the data layer , in data layer we actually implements them and make them operational
 *
 *   -Technology Agnostic: this layer independent of any technology or framework
 */


