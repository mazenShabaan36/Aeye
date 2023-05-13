import 'package:divergent/screens/blind/blind_home.dart';
import 'package:divergent/screens/blind/blind_search/blind_search.dart';
import 'package:divergent/screens/blind/blind_search/blind_search_home.dart';
import 'package:divergent/screens/blind/blind_search/speach_text.dart';
import 'package:divergent/screens/blind/sos/sos_dialog.dart';
import 'package:divergent/screens/color_blind/color_blind_home.dart';
import 'package:divergent/screens/deaf/deaf_home.dart';
import 'package:divergent/sos_activate.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shake/shake.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:tflite/tflite.dart';
import 'package:telephony/telephony.dart';

sosDialog sd = new sosDialog();
final Telephony telephony = Telephony.instance;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
    camerasSearch = await availableCameras();
  } on CameraException catch (e) {
    print('Error: $e.code\nError Message: $e.message');
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MySplash(),
    );
  }
}

class MySplash extends StatefulWidget {
  @override
  _MySplashState createState() => _MySplashState();
}

class _MySplashState extends State<MySplash> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 3,
      navigateAfterSeconds: MyHomePage(),
      gradientBackground: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.4, 0.7],
        colors: [
          Color(0xff1c4257),
          Color(0xff253340),
        ],
      ),

      photoSize: 50,
      useLoader: true,
      loaderColor: Colors.white70,
      image: Image.asset(
        'assets/Aeye.png',
        height: MediaQuery.of(context).size.height * 0.2,
        width: MediaQuery.of(context).size.width * 0.2,
      ), //Image.asset('assets/icon-circle.png'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var sosCount = 0;
  var initTime;

  @override
  // ignore: missing_return
  Future<void> initState() {
    super.initState();
    smsPermission();
    loadModel();
    ShakeDetector detector = ShakeDetector.waitForStart(onPhoneShake: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SOSActivate()),
      );
    });

    detector.startListening();
  }

  void sendSms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String n1 = prefs.getString('n1');
    String n2 = prefs.getString('n2');
    String n3 = prefs.getString('n3');
    String name = prefs.getString('name');
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    if (position == null) {
      position = await Geolocator.getLastKnownPosition();
    }
    String lat = (position.latitude).toString();
    String long = (position.longitude).toString();
    String alt = (position.altitude).toString();
    String speed = (position.speed).toString();
    String timestamp = (position.timestamp).toIso8601String();
    print(n2);
    telephony.sendSms(
        to: n1,
        message:
            "$name needs you help, last seen at: Latitude: $lat, Longitude: $long, Altitude: $alt, Speed: $speed, Time: $timestamp");
    telephony.sendSms(
        to: n2,
        message:
            "$name needs you help, last seen at:  Latitude: $lat, Longitude: $long, Altitude: $alt, Speed: $speed, Time: $timestamp");
    telephony.sendSms(
        to: n3,
        message:
            "$name needs you help, last seen at:  Latitude: $lat, Longitude: $long, Altitude: $alt, Speed: $speed, Time: $timestamp");
  }

  void smsPermission() async {
    //bool permissionsGranted = await telephony.requestPhoneAndSmsPermissions;
  }

  loadModel() async {
    String res = await Tflite.loadModel(
        model: "assets/ssd_mobilenet.tflite",
        labels: "assets/ssd_mobilenet.txt");
    print("MODEL" + res);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff1c4257), //Colors.lightBlue.shade100,
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Color(0xff1c4257), // Colors.lightBlue.shade100,
        elevation: 0,
        title: Text(
          'Choose your mood',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 21,
              letterSpacing: 1.2),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40)),
            // color: Colors.cyan,
            gradient: LinearGradient(colors: [
              // Colors.blueGrey[800],
              //  Colors.lightBlue.shade300,
              //Colors.blueGrey[600],
              Color(0xff1c4257),
              Color(0xff253340),
            ], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(
                Icons.contact_page,
                color: Colors.white,
                size: 33,
              ),
              onPressed: () {
                sd.sosDialogBox(context);
              },
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BlindHome()),
                    );
                  },
                  child: Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      /*   border: Border(
                        top: BorderSide(color: Colors.blueGrey[800], width: 10),
                        left:
                            BorderSide(color: Colors.blueGrey[800], width: 10),
                        bottom:
                            BorderSide(color: Colors.blueGrey[800], width: 10),
                        right:
                            BorderSide(color: Colors.blueGrey[800], width: 10),
                        //    color: Colors.white,
                        //  width: 8,
                      ),
                      */
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Card(
                      //   color:  Color(0xff253340).blue,

                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: <Widget>[
                            new Container(
                                child: new CircleAvatar(
                              backgroundImage: new AssetImage(
                                'assets/images/blind_image.png',
                              ),
                              radius: 80.0,
                              backgroundColor: Colors.lightBlue[200],
                            )),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: new Container(
                                child: new Text(
                                  'Blind',
                                  style: TextStyle(
                                      color: Color(0xff375079),
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => blind_searchHome(),
                      ),
                    );
                  },
                  child: Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      /*  border: Border.all(
                        color: Colors.white,
                        width: 8,
                      ),
                      */
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: <Widget>[
                            new Container(
                              child: new CircleAvatar(
                                backgroundImage: new AssetImage(
                                    'assets/images/deaf_image.png'),
                                radius: 80.0,
                                backgroundColor: Colors.lightBlue[200],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: new Container(
                                child: new Text(
                                  'Search',
                                  style: TextStyle(
                                    color: Color(0xff375079),
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ColorBlindHome()),
                    );
                  },
                  child: Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      /*  border: Border.all(
                        color: Colors.white,
                        width: 8,
                      ),
                      */
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: <Widget>[
                              new Container(
                                child: new CircleAvatar(
                                  backgroundImage: new AssetImage(
                                      'assets/images/colour_blind_image.png'),
                                  radius: 80.0,
                                  backgroundColor: Colors.lightBlue[200],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: new Container(
                                  child: new Text(
                                    'Colour\nBlind',
                                    style: TextStyle(
                                        color: Color(0xff375079),
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )
                            ],
                          )),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
