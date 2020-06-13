import 'package:flutter/material.dart';
import 'package:flutter_isolates_fetchdata/fetch_photos.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Isolates',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FatchPhotoScreen(),
    );
  }
}
