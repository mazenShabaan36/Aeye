import 'dart:async';
import 'dart:io';
import 'package:divergent/screens/blind/blind_search/bndbox_search.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
//import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:divergent/screens/blind/currency_detection/currency.dart';
import 'package:divergent/screens/blind/ocr/dialog_ocr.dart';
import 'package:divergent/screens/blind/sos/sos_dialog.dart';
//import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shake/shake.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:simple_ocr_plugin/simple_ocr_plugin.dart';
import 'package:tflite/tflite.dart';
import 'package:telephony/telephony.dart';
import 'dart:math' as math;
import 'package:vibration/vibration.dart';

import 'package:divergent/screens/blind/live_labelling/bndbox.dart';
import 'package:divergent/screens/blind/live_labelling/camera.dart';

class blind_search extends StatefulWidget {
  final List<CameraDescription> cameras_search;
  final String searched;

  blind_search(this.cameras_search,this.searched);
  @override
  State<blind_search> createState() => _blind_searchState();
}

class _blind_searchState extends State<blind_search> {
  List<dynamic> _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  String _model = "SSD MobileNet";
  // ignore: unused_field
  File _capImage;
  // ignore: unused_field
  File _currImage;
  final FlutterTts flutterTts = FlutterTts();
  final Telephony telephony = Telephony.instance;

  PageController _controller = PageController(
    initialPage: 0,
  );
  Future getCurrImage() async {
    // ignore: deprecated_member_use
    final currImage = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _currImage = currImage;
    });
    if (currImage != null) {
      CurrPage.currencyDetect(context, currImage);
    }
  }

  var sosCount = 0;
  var initTime;
  @override
  // ignore: missing_return
  Future<void> initState() {
    super.initState();
    // smsPermission();
    loadModel();
    ShakeDetector detector = ShakeDetector.waitForStart(onPhoneShake: () {
      if (sosCount == 0) {
        initTime = DateTime.now();
        ++sosCount;
      } else {
        if (DateTime.now().difference(initTime).inSeconds < 4) {
          ++sosCount;
          if (sosCount == 6) {
            // sendSms();
            sosCount = 0;
          }
          print(sosCount);
        } else {
          sosCount = 0;
          print(sosCount);
        }
      }
    });

    detector.startListening();
  }

  loadModel() async {
    String res = await Tflite.loadModel(
        model: "assets/ssd_mobilenet.tflite",
        labels: "assets/ssd_mobilenet.txt");
    print("MODEL" + res);
  }

  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    // ignore: unused_local_variable
    sosDialog sd = new sosDialog();
    ocrDialog od = new ocrDialog();
    return Scaffold(
      body: PageView(
        //make the pages view by swapping
        controller: _controller,
        onPageChanged: _speakPage,
        children: <Widget>[
          Container(
            child: Stack(
              children: [
                Camera(
                  widget.cameras_search,
                  _model,
                  setRecognitions,
                ),
                BndBoxSearch(
                    _recognitions == null ? [] : _recognitions,
                    math.max(_imageHeight, _imageWidth),
                    math.min(_imageHeight, _imageWidth),
                    screen.height,
                    screen.width,
                    _model,
                    widget.searched),
              ],
            ),
          ),
        ],
        /*    Container(
              child: Center(
                  child: SizedBox.expand(
                      // ignore: deprecated_member_use
                      child: FlatButton(
                          highlightColor: Color(0xFFA8DEE0),
                          splashColor: Color(0xffF9E2AE),
                          onPressed: () => od.optionsDialogBox(context),
                          child: Text("Text Extraction from Images",
                              style: TextStyle(
                                  fontSize: 27.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))))),
              color: Color(0xffb56576)),
          Container(
              child: Center(
                  child: SizedBox.expand(
                      // ignore: deprecated_member_use
                      child: FlatButton(
                          highlightColor: Color(0xFFF9E2E),
                          splashColor: Color(0xFFFBC78D),
                          onPressed: () => getCurrImage(),
                          child: Text("Currency Identifier",
                              style: TextStyle(
                                  fontSize: 27.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))))),
              color: Color(0xffe56b6f)),
        ],
        */
        scrollDirection: Axis.horizontal,
        pageSnapping: true,
        physics: BouncingScrollPhysics(),
      ),
    );
  }

  _speakPage(int a) async {
    if (a == 0) {
      await flutterTts.speak("Live object detection");
    } else if (a == 1) {
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(amplitude: 128, duration: 1000);
      }
      await flutterTts.speak("Image Captioning");
    } else if (a == 2) {
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(amplitude: 128, duration: 1400);
      }
      await flutterTts.speak("Text Extraction from images");
    } else if (a == 3) {
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(amplitude: 128, duration: 1800);
      }
      await flutterTts.speak("Currency Identifier");
    } else if (a == 4) {
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(amplitude: 128, duration: 2200);
      }
      await flutterTts.speak("SOS Settings");
    }
  }
}
