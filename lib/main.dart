import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_scalable_ocr/flutter_scalable_ocr.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Scalable OCR',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Scalable OCR'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String text = "";
  final StreamController<String> controller = StreamController<String>();

  void setText(value) {
    controller.add(value);
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ScalableOCR(
                  paintboxCustom: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 4.0
                    ..color = const Color.fromARGB(153, 102, 160, 241),
                  boxLeftOff: 5,
                  boxBottomOff: 2.5,
                  boxRightOff: 5,
                  boxTopOff: 2.5,
                  boxHeight: MediaQuery.of(context).size.height / 3,
                  getRawData: (value) {
                    inspect(value);
                  },
                  getScannedText: (value) {
                    setText(value);
                  }),
              StreamBuilder<String>(
                stream: controller.stream,
                builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                  String x=extractCreditCardNumber(snapshot.data);
                  return Result(text: x );
                },
              )
            ],
          ),
        ));
  }

  String extractCreditCardNumber(String? input) {
    String? x=(input??"").replaceAll("b", "6");
    x=x.replaceAll("o", "0");
    x=x.replaceAll("O", "0");
    x=x.replaceAll("l", "1");
    x=x.replaceAll("L", "1");
    x=x.replaceAll("e", "5");

    print(x);
    // use a regular expression to match the pattern of a credit card number
    RegExp? regex = RegExp(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b');
    RegExpMatch? match = regex.firstMatch(x);

    if (match != null) {
      // remove all non-digit characters from the matched text
      String? digitsOnly = (match.group(0)??"").replaceAll(RegExp(r'\D+'), '');
      if(validateCreditCard(digitsOnly)){
        text=digitsOnly;
        return digitsOnly;
      }
    }
    return text;
  }

  bool validateCreditCard(String input) {
    // use the Luhn algorithm to check whether the credit card number is valid
    int sum = 0;
    bool isSecondDigit = false;
    for (int i = input.length - 1; i >= 0; i--) {
      int digit = int.parse(input[i]);
      if (isSecondDigit) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }
      sum += digit;
      isSecondDigit = !isSecondDigit;
    }
    return sum % 10 == 0;
  }
}

class Result extends StatelessWidget {
  const Result({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {

    return Text("Readed text: $text");
  }


}