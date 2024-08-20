import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_list/main.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<Todo> todoBox;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    todoBox = Hive.box<Todo>("todo");
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1d2630),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        toolbarHeight: 150,
        foregroundColor: Colors.white,
        title: Text("To-do List",
        style: TextStyle(
          fontSize: 50,
        ),
        ),
        
      ),
      body: ValueListenableBuilder(
        valueListenable: todoBox.listenable(),
        builder: (context, Box<Todo> box, _){
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index){
            Todo todo = box.getAt(index)!;
            return Container(
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: todo.isCompleted ? Colors.white : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
             
              child:  Dismissible(
                key: Key(todo.dateTime.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.redAccent,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(
                    Icons.delete, 
                    color: Colors.white38
                    ),
                ),
                onDismissed: (direction){
                  setState(() {
                    todo.delete();
                  });
                },
                child: ListTile(
                title: Text(todo.title),
                subtitle: Text(todo.description),
                trailing: Text(
                  DateFormat.yMMMd().format(todo.dateTime)
                ),
                leading: Checkbox(
                  value: todo.isCompleted,
                 onChanged: (value){
                  setState(() {
                    todo.isCompleted = value!;
                    todo.save();
                  });
                 }
                 ),
                 onTap: () {
                      _editTodoDialog(context, todo);
                 }
              ),
              )
            );
          }
        );
      },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            _addTodoDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _addTodoDialog(BuildContext context){
    TextEditingController _titleController = TextEditingController();
    TextEditingController _descController = TextEditingController();

    showDialog(context: context, builder: (context)=>AlertDialog(
      title: Text ("Add Task"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: "Title"),
          ),
          TextField(
            controller: _descController,
            decoration: InputDecoration(labelText: "Description"),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed:() {
          Navigator.pop(context);
        }, 
        child: Text("Cancel"),
        ),
        TextButton(onPressed:() {
          _addTodo(_titleController.text, _descController.text);
          Navigator.pop(context);
        }, 
        child: Text("Add"),
        ),
      ]
    ),
   );
  }

  void _addTodo(String title, String description){
    if(title.isNotEmpty){
      todoBox.add(
        Todo(
          title: title,
          description: description, 
          dateTime: DateTime.now(),
          ),
      );
    }
  }
}void _editTodoDialog(BuildContext context, Todo todo){
    TextEditingController _titleController = TextEditingController(text: todo.title);
    TextEditingController _descController = TextEditingController(text: todo.description);

    showDialog(context: context, builder: (context)=>AlertDialog(
      title: Text ("Edit Task"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: "Title"),
          ),
          TextField(
            controller: _descController,
            decoration: InputDecoration(labelText: "Description"),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed:() {
          Navigator.pop(context);
        }, 
        child: Text("Cancel"),
        ),
        TextButton(onPressed:() {
          _editTodo(todo, _titleController.text, _descController.text);
          Navigator.pop(context);
        }, 
        child: Text("Save"),
        ),
      ]
    ),
  );
  }

  void _editTodo(Todo todo, String title, String description){
    todo.title = title;
    todo.description = description;
    todo.save();
  }