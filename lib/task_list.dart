import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:task_management/category_list.dart';
import 'package:task_management/services/notification_service.dart';
import 'core/models/category_model.dart';
import 'core/models/task_model.dart';
import 'core/widgets/add_task.dart';
import 'core/widgets/category_provider.dart';
import 'core/widgets/task_detail.dart';
import 'core/widgets/task_provider.dart';
import 'main.dart';

class TaskList extends StatefulWidget {
  const TaskList({Key? key}) : super(key: key);

  @override
  State createState() => _ListTileExample();
}

class InnerList {
  String category;
  List<Task> tasks;

  InnerList({
    required this.category,
    required this.tasks,
  });
}


class _ListTileExample extends State<TaskList> with RestorationMixin {
  final TaskProvider taskProvider = TaskProvider();
  final CategoryProvider categoryProvider = CategoryProvider();
  List<InnerList> _lists = [];
  late List<Task> tasks;
  late List<Category> categories;

  // Restoration properties
  final RestorableInt _selectedTabIndex = RestorableInt(0);

  @override
  String get restorationId => 'taskList';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedTabIndex, 'selected_tab_index');
  }


  @override
  void initState() {
    super.initState();
    fetchDataFromHive();
  }


  // void checkDueDateAndScheduleNotification(NotificationManager notificationManager) {
  //   for(Task task in tasks){
  //     DateTime dueDate = task.dueDate;
  //
  //     if (isDueDateToday(dueDate)) {
  //       notificationManager.scheduleNotification(
  //         task.title,
  //         'Your task is due today!',
  //         dueDate,
  //       );
  //     }
  //   }
  // }
  //
  // bool isDueDateToday(DateTime dueDate) {
  //   DateTime now = DateTime.now();
  //   return dueDate.year == now.year && dueDate.month == now.month && dueDate.day == now.day;
  // }

  Future<void> fetchDataFromHive() async {

    tasks = tasksBox.values.toList();
    categories = categoriesBox.values.toList();

    if (tasks.isEmpty) {
      setState(() {
        _lists = [];
      });
    } else {
      final categoryNames = ['All Tasks', ...categories.map((category) => category.category).toList()];

      setState(() {
        _lists = List.generate(categoryNames.length, (categoryIndex) {
          final categoryName = categoryNames[categoryIndex];
          final categoryTasks = (categoryName == 'All Tasks')
              ? tasks
              : tasks.where((task) => task.category == categoryName).toList();

          return InnerList(
            tasks: categoryTasks,
            category: categoryName,
          );
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List'),
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryList()));
          }, icon: Icon(Icons.category_outlined))
        ],
        elevation: 4,
      ),
      body: DragAndDropLists(
        children: List.generate(_lists.length, (index) => _buildList(index)),
        onItemReorder: _onItemReorder,
        onListReorder: _onListReorder,
        // listGhost is mandatory when using expansion tiles to prevent multiple widgets using the same globalkey
        listGhost: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 100.0),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(7.0),
              ),
              child: const Icon(Icons.add_box),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  _buildList(int outerIndex) {
    var innerList = _lists[outerIndex];
    return DragAndDropListExpansion(
      title: Text('${innerList.category}'),
      children: List.generate(
        innerList.tasks.length,
            (index) => _buildItem(innerList.tasks[index]),
      ),
      listKey: ObjectKey(innerList.category),
    );
  }

  _buildItem(Task task) {
    int taskdate = task.dueDate.day;
    int currentDate = DateTime.now().day;
    int taskMonth = task.dueDate.month;
    int currentMonth =  DateTime.now().month;

    Color itemColor;
    if (task.category == 'Completed') {
      itemColor = Colors.green;
    } else {
      itemColor = taskdate == currentDate && taskMonth == currentMonth
          ? Colors.orange
          : (taskdate < currentDate && taskMonth == currentMonth ? Colors.red : Colors.black);
    }
    return DragAndDropItem(
      child: ListTile(
        title: Text(task.title, style: TextStyle(color: itemColor),),
        onTap: () {
          print(task.title);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TaskDetailsPage(task: task)),
          );
        },
      ),
    );
  }


  _onItemReorder(int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    setState(() {
      if (oldListIndex == newListIndex) {

        var innerList = _lists[oldListIndex];
        var movedList = innerList.tasks.removeAt(oldItemIndex);
        innerList.tasks.insert(newItemIndex, movedList);

        List<Task> listToAdd = innerList.tasks;
        for( Task task in listToAdd){
          print(task.title);
        }

        int i =0;
        tasks.where((element) =>
        element.category == _lists[oldListIndex].category)
            .forEach((element1) {
              tasksBox.putAt(tasks.indexOf(element1), listToAdd[i]);
              i++;

        });

        print(tasks.length);



        for( Task task in listToAdd){
          print(task.title);
        }


      } else {
        var innerList = _lists[oldListIndex];
        var innerList2 = _lists[newListIndex];
        var movedList = innerList.tasks.removeAt(oldItemIndex);
        innerList2.tasks.insert(newItemIndex, movedList);
        innerList2.tasks[newItemIndex].category = innerList2.category;
        print(innerList2.tasks[newItemIndex].category);
        print(innerList2.tasks[newItemIndex].title);

        tasks.where((element) =>
        element.title == innerList2.tasks[newItemIndex].title)
            .forEach((element) {
          tasksBox.deleteAt(tasks.indexOf(element));
          tasksBox.add(innerList2.tasks[newItemIndex]);
        });
      }
    });
  }

  _onListReorder(int oldListIndex, int newListIndex) {
    setState(() {
      var movedList = _lists.removeAt(oldListIndex);
      _lists.insert(newListIndex, movedList);

      List<String> categoryToAdd = [];
      for (int i = 0; i < _lists.length; i++) {
        var innerList = _lists[i];
        categoryToAdd.add(innerList.category);
      }
      categoryToAdd.removeWhere((category) => category == 'All Tasks');
      print(categoryToAdd);
      categoriesBox.deleteAll(categoriesBox.keys);
      for(String i in categoryToAdd){
        categoriesBox.add(Category(category: i));
      }
    });
  }
}
