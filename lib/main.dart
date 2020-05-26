import 'dart:convert';
import 'package:html_unescape/html_unescape.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:core';

// final is a runtime constant
// const is compile time constant
// TODO: make a widget for the dropdowns
// TODO: randomise the answers
// TODO: next previous question
void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // only this is recreated
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _quizData = {};
  var _quizDataUpdated = false;
  var questions = ['fav color?', 'fav series?'];
  var categoryList = <String>['Any', 'Science: Computers', 'Sports', 'Mythology', 'History', 'Politics'];
  var difficultyList = <String>['Any','Easy','Medium','Hard'];
  var typeList = <String>['Any','Multiple Choice', 'True / False'];
  var dropdownValueCategory = 'Any';
  var dropdownValueDifficulty = 'Any';
  var dropdownValueType = 'Any';
  var numQuestions = 10;
  var unescape = new HtmlUnescape();


  void fetchQuiz() {
    final response =  http.get('https://opentdb.com/api.php?amount=10');
    response.then((resp) {
      if (resp.statusCode == 200) {
        var quizData = (jsonDecode(resp.body));
        setState(() {
          _quizData = new Map<String, dynamic>.from(quizData);
          _quizDataUpdated = !_quizDataUpdated;
        });
      } else {
        throw Exception('Failed to get quiz.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: (_quizData.isEmpty) ? Text('Select your quiz parameters:') : Text('Quiz Time!'),
          ),
        body:  !_quizDataUpdated ?
        Container(
          padding: const EdgeInsets.all(40.0),
          child: Column(
              children: <Widget> [
                Text(
                  'Number of questions:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                TextField(
                  onChanged: (text) {
                    setState(() {
                      numQuestions = int.tryParse(text);
                    });
                  },
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter a number'
                  ),
                ),
                Text(
                  'Select Category:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                DropdownButton(
                  value: dropdownValueCategory,
                  onChanged: (String newValue) {
                    setState(() {
                      dropdownValueCategory = newValue;
                    });
                  },
                  items: categoryList.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                Text(
                  'Select Difficulty:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                DropdownButton(
                  value: dropdownValueDifficulty,
                  onChanged: (String newValue) {
                    setState(() {
                      dropdownValueDifficulty = newValue;
                    });
                  },
                  items: difficultyList.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                Text(
                  'Select Type:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                DropdownButton(
                  value: dropdownValueType,
                  onChanged: (String newValue) {
                    setState(() {
                      dropdownValueType = newValue;
                    });
                  },
                  items: typeList.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                RaisedButton(
                  child: Text('Submit'),
                  onPressed: () {
                    fetchQuiz();
                  },
                ),
            ]
        )
        )
            : ( _quizData.isNotEmpty ?
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(40.0),
          child: Column(
              children: [
                Text(unescape.convert(_quizData['results'][0]['question']), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    ButtonTheme(height: 12, child: FlatButton(child: Text(_quizData['results'][0]['category'], style: TextStyle(fontSize: 12),), color: Color.fromRGBO(240, 20, 20, 0.5), onPressed: () {},)),
                    ButtonTheme(height: 12, child: FlatButton(child: Text(_quizData['results'][0]['difficulty'], style: TextStyle(fontSize: 12),), color: Color.fromRGBO(240, 20, 20, 0.5), onPressed: () {},)),
                  ],
                ),
                ButtonTheme(
                  minWidth: double.infinity,
                  child: RaisedButton(
                          child: Text(_quizData['results'][0]['correct_answer'], style: TextStyle(fontSize: 16)),
                          onPressed: () {print('correct');},
                          color: Color(0xff0091EA),
                      ),
                ),
                ..._quizData['results'][0]['incorrect_answers'].map((ans) {
                  return ButtonTheme(
                    minWidth: double.infinity,
                    child: new RaisedButton(
                              child: Text(ans, style: TextStyle(fontSize: 16)),
                              onPressed: () { print(ans);},
                              color: Color(0xff0091EA),
                            ),
                  );
                }).toList(),
              ],
          ),
        ) : Column(
            children: [
              Text('quiz data empty'),
              RaisedButton(
                child: Text('Done'),
                onPressed: () {
                  setState(() {
                    _quizDataUpdated = !_quizDataUpdated;
                  });
                },
              )
            ]
        )
        ),
        persistentFooterButtons: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                RaisedButton(
                  child: Text('Previous Question'),
                  onPressed: () {},
                ),
                RaisedButton(
                  child: Text('Next Question'),
                  onPressed: () {},
                )],
            ),
          )
        ],
        bottomNavigationBar: (_quizData.isNotEmpty) ? RaisedButton(
          child: Text('Exit Quiz'),
          onPressed: () {
            setState(() {
              _quizDataUpdated = !_quizDataUpdated;
            });
          },
        ) : null,
      ),
    );
  }
}
