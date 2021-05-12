import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:working_with_map/screens/home_screen.dart';
import 'package:working_with_map/screens/location_list.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        HomeScreen.id : (context)=>HomeScreen(),
        LocationList.id : (context)=>LocationList(),
      },
      initialRoute: HomeScreen.id,
    );
  }


}
