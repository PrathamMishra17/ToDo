
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_app/presentation/todo_cubit.dart';

import '../Domain/Models/to_do.dart';

/**
 * this is reponsible for building the ui hence blocbuilder will be used here
 */

class TodoViewPage extends StatelessWidget{
  const TodoViewPage({super.key});
  void _addToDoBox(BuildContext context){
    final todocubit = context.read<TodoCubit>();
    final TextEditingController textEditingController = TextEditingController();

    
    showDialog(
        context: context,
        builder:(context)=>AlertDialog(
          content: TextField(
            controller: textEditingController,
            decoration: InputDecoration(
              hint: Text("Enter task...")
            ),
          ),
          actions: [
            //cancel 
            TextButton(onPressed: ()=> Navigator.of(context).pop(), child: Text("cancel")),

            //add button
            TextButton(onPressed: (){
              if(textEditingController.text.isEmpty) return;
              todocubit.addtodos(textEditingController.text);
              Navigator.of(context).pop();

    }, child: Text("add"))

          ],
        )
    );
  }
  void _editToDoBox(BuildContext context, ToDo todo){
    final todocubit = context.read<TodoCubit>();
    final TextEditingController editingController = TextEditingController(text: todo.text);
   // editingController.selection = TextSelection.fromPosition(TextPosition(offset: editingController.text.length));
    showDialog(
        context: context,
        builder: (context)=> AlertDialog(
          content: TextField(
            controller: editingController,
            autofocus: true,

          ),
          actions: [
            //cancel
            TextButton(onPressed: ()=>Navigator.of(context).pop(), child: Text("cancel")),
            //add box
            TextButton(onPressed: (){
              if(editingController.text.isEmpty ) return;
              todocubit.editToDo(todo, editingController.text);
              Navigator.of(context).pop();
            }, child: Text("edit"))
          ],
        )
    );
  }

  void _confirmClear(BuildContext context) {
    final todocubit = context.read<TodoCubit>();

    showDialog(
        context:context,
        builder: (context)=> AlertDialog(
          title: Text("Clear All Tasks?"),
          content:  Text("This will permanently clear all your tasks "),
          actions: [
            //cancel
            TextButton(onPressed: ()=>Navigator.of(context).pop(), child: Text("cancel")),
            //clear
            TextButton(onPressed: (){
              todocubit.cleartodo();
              Navigator.of(context).pop();
            }, child: Text("clear"))
          ],
        ));
  }

  void _confirmDelete(BuildContext context, ToDo todo) {
    final todocubit = context.read<TodoCubit>();

    showDialog(
        context: context,
        builder: (context)=> AlertDialog(
          title: Text("Clear Task?"),
          content: Text("This action will delete your task"),
          //delete
          actions: [
            //cancel
            TextButton(onPressed: ()=>Navigator.of(context).pop(), child: Text("cancel")),
            //delete
            TextButton(onPressed: (){
              todocubit.deletetodo(todo);
              Navigator.of(context).pop();
            },
                child: Text("Delete"))

          ],
        )
    );
  }
  @override
  Widget build(BuildContext context) {
    final todocubit = context.read<TodoCubit>();
    return Scaffold(
      appBar: AppBar(
        title: Text("My tasks ..."),
        actions: [
                BlocBuilder<TodoCubit, List<ToDo>>(

                    builder:(context, todolist){
                      if(todolist.isEmpty) return const SizedBox.shrink();

                      return IconButton(onPressed: (){
                            _confirmClear(context);
                      }, icon: Icon(Icons.delete_sweep_rounded),
                        tooltip: 'Clear All tasks',

                      );
                    })
        ],

      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        _addToDoBox(context);
      },
      child: Icon(Icons.add),
      ),
      body: BlocBuilder<TodoCubit,List<ToDo>>(
          builder: ((context, todos) {
        //list view
            return SafeArea(child: todos.isEmpty?Padding(padding: EdgeInsetsGeometry.only(top: 20,left: 15),
            child: Text("No tasks yet...",style: TextStyle(fontSize: 20),),
            ):
            ListView.builder(
                itemCount: todos.length,
                itemBuilder: (context,index){
                  //if item count is 0 item builder will not return anything
                  //get individual todo from list
                  final todo = todos[index];
                  return ListTile(
                    title: GestureDetector(
                      child: Text(todo.text),
                      onLongPress: ()=>_editToDoBox(context,todo),
                    ),
                    leading: Checkbox(
                        value: todo.isCompleted,
                        onChanged:(value)=>todocubit.toggletodo(todo)),

                    trailing: IconButton(onPressed: (){
                      _confirmDelete(context, todo);
                    }, icon: Icon(Icons.delete)),
                  );
                })
            );
      })),
    );
  }
}