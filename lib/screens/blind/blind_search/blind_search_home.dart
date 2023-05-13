import 'package:divergent/screens/blind/blind_search/blind_search.dart';
import 'package:divergent/screens/blind/blind_search/speach_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../home.dart';

//List<CameraDescription> camerasSearch;
class blind_searchHome extends StatefulWidget {
  //const blind_searchHome({ Key? key }) : super(key: key);

  @override
  State<blind_searchHome> createState() => _blind_searchHomeState();
}

class _blind_searchHomeState extends State<blind_searchHome> {
  @override
 Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Helping Hands',
        debugShowCheckedModeBanner: false,
        home: SpeechScreen(),// blind_search(camerasSearch),
    );
  }
}