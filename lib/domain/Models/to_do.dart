/**
 *
 * consist of the logic of the application as the domain layer is only for the logic which will not change
 * even when the frameworks changes
 *
 * properties of my todo applications:
 * 1. id
 * 2.text
 * 3. is completed?
 *
 * Methods:
 *  toggle isCompletion on or off
 *
 *  actually this class defines what todo is and its objects are todos
 *
 */

class ToDo {
  final int id;
  final String text;
  final bool isCompleted;

  ToDo({
    required this.id,
    required this.text,
    this.isCompleted = false //inititally the text will be incomplete

});

  ToDo toggleCompletion(){
    return ToDo(
      id: id,
      text: text,
      isCompleted: !isCompleted
    );
  }

}
