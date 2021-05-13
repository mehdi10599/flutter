import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class LocationList extends StatefulWidget {
  static String id = 'location_list';
  LocationList({Key key}) : super(key: key);

  @override
  _LocationListState createState() => _LocationListState();
}

class _LocationListState extends State<LocationList> {
  final DatabaseReference dbRef =
      FirebaseDatabase.instance.reference().child('Locations');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Location List')),
      body: StreamBuilder(
        stream: dbRef.orderByChild('dateTime').onValue,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          Map allItems={};
          if (snapshot.hasData) {
            Event event = snapshot.data;
            DataSnapshot snap = event.snapshot;
            allItems = snap.value;
            print(allItems);
            List items =[];
            if(allItems != null){
              for(Map each in allItems.values){
                items.add({
                  'dateTime':each['dateTime'],
                  'latitude':each['latitude'],
                  'longitude':each['longitude'],
                });
              }
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context,index){
                  return Card(
                    elevation: 3,
                    child: ListTile(
                      title: Text('Lat: ${items[index]['latitude']} , Lng: ${items[index]['longitude']}'),
                      subtitle: Text('time: ${items[index]['dateTime']} '),
                      trailing: Text(' ${index+1} ',style: TextStyle(color: Colors.blue,fontSize: 20,),),
                    ),
                  );
                },
              );
            }else{
              return Center(
                child: Text('No Items Found'),
              );
            }
          }
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.red,
            ),
          );
        },
      ),
    );
  }

}
