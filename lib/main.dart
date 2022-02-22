import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:awesome_notifications/awesome_notifications.dart';


Future<void> main() async {
  AwesomeNotifications().initialize(
    'resource://drawable/app_icon',
    [
      NotificationChannel(
        icon:'resource://drawable/app_icon',
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        defaultColor: Colors.teal,
        importance: NotificationImportance.High,
        channelShowBadge: true,
        channelDescription: 'Notification channel for basic tests',
      ),
    ],
  );

  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());


}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      home: ReminderScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ReminderScreen extends StatefulWidget {
  @override
  ReminderScreenState createState() => ReminderScreenState();
}

class ReminderScreenState extends State<ReminderScreen> {

  TextEditingController topicText = TextEditingController();

  var timerList = <Timer>[];
  var selectedTimes = [];
  static Timer? timerObj;

  var idBox;
  var timeBox;
  var contentBox;

  TimeOfDay selectedTime = TimeOfDay.now();
  DateTime selectedDate = DateTime.now();

  checkNotificationPermission()
  {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) => {
      if(!isAllowed){
        AwesomeNotifications().requestPermissionToSendNotifications()
      }
      else{}
    });
  }

  selectTime(BuildContext context) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      initialEntryMode: TimePickerEntryMode.dial,

    );
    if(timeOfDay != null && timeOfDay != selectedTime)
    {
      setState(() {
        selectedTime = timeOfDay;
      });
    }
  }

  deleteTimer(int index)
  {
    print("INDEX $index");
    timerList[index].cancel();
    timerList.removeAt(index);
    selectedTimes.removeAt(index);
  }

  setTimer(int index){
    timerList.add(Timer.periodic(const Duration(minutes: 1), (timer) async {

      print(index);
      if(TimeOfDay.now() == selectedTimes[0])
      {
        AwesomeNotifications().createNotification(content: NotificationContent(id: 10, channelKey: 'basic_channel',
            title: 'HATIRLATICI',
            body: contentBox.getAt(0),
            notificationLayout:NotificationLayout.Messaging,
            color: Colors.redAccent
        ),
            actionButtons: [
              NotificationActionButton(key: "REPLY", label: "Reply", enabled: true, autoDismissible: true, buttonType: ActionButtonType.InputField, icon: "resource://drawable/app_icon"),
            ]
        );
        deleteTimer(0);
        deleteRecord(0, info: "timer");

      }
    }
    ));
}

/*
  chooseDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2025),
      );
      if (picked != null && picked != selectedDate)
        setState(() {
          selectedDate = picked;
          selectedDate2= DateFormat('yyyy-MM-dd').format(selectedDate);

          print(selectedDate2);
        });
  }
  */

  addRecord()
  {
    selectedTimes.add(selectedTime);
    setTimer(contentBox.length);
    setState(() {
      idBox.add(contentBox.length);
      timeBox.add(selectedTime.toString());
      contentBox.add(topicText.text);
      selectedTime = TimeOfDay.now();
      topicText.text="";
    });

  }

  deleteRecord(int index, {info=""})
  {
    setState(() {
      idBox.deleteAt(index);
      timeBox.deleteAt(index);
      contentBox.deleteAt(index);
    });

    if(info!="timer")
      {
        deleteTimer(index);
      }

  }

  @override
  Future<void> didChangeDependencies() async {
    await Hive.initFlutter(); // Flutter uygulamaları için
    await Hive.openBox('id');
    await Hive.openBox('time');
    await Hive.openBox('content');

    idBox = await Hive.box("id");
    timeBox = await Hive.box("time");
    contentBox = await Hive.box("content");


    /*contentBox.deleteAll(contentBox.keys);
    idBox.deleteAll(idBox.keys);
    timeBox.deleteAll(timeBox.keys);*/
    super.didChangeDependencies();
  }


  @override
  initState() {
    AwesomeNotifications().actionStream.listen((event) {
      print("Çalışıyor!");
      print(event.toMap().toString());

    });
    super.initState();
  }

  rememberList()
  {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height*0.6,
      child: ListView.builder(

          itemCount:contentBox.length,

          itemBuilder: (context, index) => Card(
              elevation: 6,
              margin: EdgeInsets.all(10),
              child: ListTile(
                title: Container(
                  width: 250,
                  height: 70,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 240,
                        child: Text(contentBox.getAt(index).toString()),
                      ),
                    ],

                  ),
                ),
                //map["topics"][0]["content"] ?? ""
                subtitle: Text(timeBox.getAt(index).toString()),
                leading:IconButton(
                  color: Colors.deepOrange,
                  hoverColor: Colors.greenAccent,
                  iconSize: 30,
                  icon: Icon(Icons.remove_circle_outline),
                  onPressed: (){
                    deleteRecord(index);
                  },
                ),
                isThreeLine: true,

              )
          )),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(

          title: Text("MY REMINDER APP", style: TextStyle(fontSize: 25),),
          centerTitle: true,
          shadowColor: Colors.lightBlue,
          backgroundColor: Colors.deepOrangeAccent,
          toolbarHeight: 120,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(70),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height*0.85,
            child: Column(
              children: [

                Card(
                    elevation: 6,
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      title: Container(
                        width: 100,
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 220,
                              child: TextField(
                                controller: topicText,


                              ),
                            ),
                            Container(
                              child: IconButton(
                                icon: Icon(Icons.date_range), onPressed: () {
                                selectTime(context);
                              },
                              ),
                            )
                          ],

                        ),
                      ),
                      trailing:IconButton(
                        color: Colors.green,
                        hoverColor: Colors.greenAccent,
                        iconSize: 30,
                        icon: Icon(Icons.add_box_rounded),
                        onPressed: (){
                          addRecord();
                        },
                      ),

                      subtitle: Text("Hatırlamak istediğiniz konuyu yazın."),
                      isThreeLine: true,

                    )
                ),
                Divider(
                  height: 15,
                  thickness: 3,
                  indent: 0,
                  endIndent: 0,
                  color: Colors.brown,
                ),


                contentBox != null ? rememberList() : Container(),


              ],
            ),
          ),
        ));
  }
}