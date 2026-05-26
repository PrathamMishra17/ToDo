import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_app/Domain/Models/to_do.dart';
import 'package:to_do_app/Domain/repository/to_do_repo.dart';


class TodoCubit extends Cubit<List<ToDo>>{
  //creating the ToDoRepo object for getting all the methods template from the
  //domain layer and which are implemented in data layer

  final ToDoRepo toDoRepo;

  //Constructor for intializing the cubit

   TodoCubit(this.toDoRepo): super([]){
     loadtodos();
   }

   //Loading the todo
    Future<void> loadtodos()async{
      final todolist = await toDoRepo.getToDos();
      //emiting for the state
      emit(todolist);
    }
  //Adding the todo

  Future<void> addtodos(String content)async{
     final addedtodo = ToDo(
         id:DateTime.now().millisecondsSinceEpoch ,
         text: content);
     await toDoRepo.addToDos(addedtodo);
     //reload without this the added todo will not be appeared in state
    loadtodos();
  }

  //deleting the todo

Future<void> deletetodo(ToDo todo)async{

     await toDoRepo.deleteTodo(todo);
     //reload
     loadtodos();
}

  //toggling the todo
Future<void> toggletodo(ToDo todo) async{
      final updatedTodo =  todo.toggleCompletion();
     //updating the ToDo in the repository
       await toDoRepo.updateTodo(updatedTodo);
   //reloading
      loadtodos();
}


//editing the existing todo

Future<void> editToDo(ToDo todo, String newText) async{
     if(newText.isEmpty || todo.text == newText) return;

     //creating the new todo
  final updatedTodo = ToDo(
      id: todo.id,
      text: newText);

  //updating the todo

  await toDoRepo.updateTodo(updatedTodo);

  //reloading
  loadtodos();
}

Future<void> cleartodo() async{
     //clearing all todos
     await toDoRepo.clearAllToDos();

     //loading
  loadtodos();

}

}