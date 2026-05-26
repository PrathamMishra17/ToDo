import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_app/Domain/repository/to_do_repo.dart';
import 'package:to_do_app/presentation/todo_cubit.dart';
import 'package:to_do_app/presentation/todo_view_page.dart';


/**
 * this file is responisble for providing the cubit to ui
 */
class TodoPage extends StatelessWidget{
  final ToDoRepo toDoRepo;
  const TodoPage({super.key,required this.toDoRepo });
  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context)=>TodoCubit(toDoRepo),
    child:TodoViewPage() ,
    );
  }
}