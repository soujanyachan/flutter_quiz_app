import 'dart:convert';
import 'package:html_unescape/html_unescape.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:core';
import 'package:crypto/crypto.dart';

// final is a runtime constant
// const is compile time constant
// TODO: score calc
void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // only this is recreated
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _quizData = {};
  var qNum = 0;
  var _quizDataUpdated = false;
  var categoryList = <String>[
    "Any",
    "General Knowledge",
    "Entertainment: Books",
    "Entertainment: Film",
    "Entertainment: Music",
    "Entertainment: Musicals & Theatres",
    "Entertainment: Television",
    "Entertainment: Video Games",
    "Entertainment: Board Games",
    "Science & Nature",
    "Science: Computers",
    "Science: Mathematics",
    "Mythology",
    "Sports",
    "Geography",
    "History",
    "Politics",
    "Art",
    "Celebrities",
    "Animals",
    "Vehicles",
    "Entertainment: Comics",
    "Science: Gadgets",
    "Entertainment: Japanese Anime & Manga",
    "Entertainment: Cartoon & Animations"];

  var difficultyList = <String>['Any','Easy','Medium','Hard'];
  var typeList = <String>['Any', 'Multiple', 'Boolean'];
  var dropdownValueCategory = 'Any';
  var dropdownValueDifficulty = 'Any';
  var dropdownValueType = 'Any';
  var numQuestions = 10;
  var unescape = new HtmlUnescape();
  var ansNormalColor = 0xff0091EA;
  var correctAnswer = false;
  var hasUserSelectedAns = false;
  var firstClick = true;
  var endPage = false;
  var score = 0;

  String generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  List shuffle(List items) {
    items.sort((a,b) => generateMd5(a.child.child.data).compareTo(b.child.child.data));
    return items;
  }

  String generateLink() {
    var categories = jsonDecode('{"trivia_categories":[{"id":9,"name":"General Knowledge"},{"id":10,"name":"Entertainment: Books"},{"id":11,"name":"Entertainment: Film"},{"id":12,"name":"Entertainment: Music"},{"id":13,"name":"Entertainment: Musicals & Theatres"},{"id":14,"name":"Entertainment: Television"},{"id":15,"name":"Entertainment: Video Games"},{"id":16,"name":"Entertainment: Board Games"},{"id":17,"name":"Science & Nature"},{"id":18,"name":"Science: Computers"},{"id":19,"name":"Science: Mathematics"},{"id":20,"name":"Mythology"},{"id":21,"name":"Sports"},{"id":22,"name":"Geography"},{"id":23,"name":"History"},{"id":24,"name":"Politics"},{"id":25,"name":"Art"},{"id":26,"name":"Celebrities"},{"id":27,"name":"Animals"},{"id":28,"name":"Vehicles"},{"id":29,"name":"Entertainment: Comics"},{"id":30,"name":"Science: Gadgets"},{"id":31,"name":"Entertainment: Japanese Anime & Manga"},{"id":32,"name":"Entertainment: Cartoon & Animations"}]}');
    var matchingCategory = categories['trivia_categories'].where((f) => f['name'] == dropdownValueCategory);
    return 'https://opentdb.com/api.php?amount=' + numQuestions.toString() +
        (dropdownValueCategory != 'Any' ? ('&category=' + matchingCategory.first['id'].toString()) : '') +
        (dropdownValueDifficulty != 'Any' ? ('&difficulty=' + dropdownValueDifficulty.toLowerCase()) : '') +
        (dropdownValueType != 'Any' ? ('&type=' + dropdownValueType.toLowerCase()) : '');
  }

  void fetchQuiz() {
    var link = generateLink();
    print(link);
    final response = http.get(link);
    response.then((resp) {
      if (resp.statusCode == 200) {
        var quizData = (jsonDecode(resp.body));
        print(quizData);
        quizData = new Map<String, dynamic>.from(quizData);
        if (quizData['response_code'] == 0) {
          setState(() {
            _quizData = quizData;
            _quizDataUpdated = !_quizDataUpdated;
            numQuestions = _quizData['results'].length;
          });
        } else {
          throw Exception('Error in returning quiz');
        }
      } else {
        throw Exception('Failed to get quiz.');
      }
    });
  }

  selectHomeWidget() {
    if (endPage && _quizDataUpdated) {
      return Text('you did it! you made it to the end with a score of' + score.toString() + "!");
    } else if(!_quizDataUpdated) {
      return Container(
          padding: const EdgeInsets.all(40.0),
          child: Column(
              children: <Widget>[
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
                      hintText: 'Enter a number (default: 10)'
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
                  items: categoryList.map<DropdownMenuItem<String>>((
                      String value) {
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
                  items: difficultyList.map<DropdownMenuItem<String>>((
                      String value) {
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
      );
    } else if (_quizData.isNotEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Text(unescape.convert(_quizData['results'][qNum]['question']),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Flexible(
                  child: ButtonTheme(height: 12,
                      child: FlatButton(child: Text(
                        _quizData['results'][qNum]['category'],
                        style: TextStyle(fontSize: 12),),
                        color: Color.fromRGBO(240, 20, 20, 0.5),
                        onPressed: () {},)),
                ),
                Flexible(
                  child: ButtonTheme(height: 12,
                      child: FlatButton(child: Text(
                        _quizData['results'][qNum]['difficulty'],
                        style: TextStyle(fontSize: 12),),
                        color: Color.fromRGBO(240, 20, 20, 0.5),
                        onPressed: () {},)),
                ),
              ],
            ),
            ...shuffle([
              ButtonTheme(
                minWidth: double.infinity,
                child: RaisedButton(
                  child: Text(unescape.convert(
                      _quizData['results'][qNum]['correct_answer']),
                      style: TextStyle(fontSize: 16)),
                  onPressed: () {
                    print('correct');
                    print(firstClick);
                    if (firstClick) {
                      setState(() {
                        hasUserSelectedAns = true;
                        correctAnswer = true;
                        firstClick = false;
                        score++;
                      });
                    }
                  },
                  color: firstClick ? Color(ansNormalColor) : Colors.green,
                ),
              ),
              // if user not clicked everything blue, if user clicked then secondary colours
              ..._quizData['results'][qNum]['incorrect_answers'].map((ans) {
                return ButtonTheme(
                  minWidth: double.infinity,
                  child: new RaisedButton(
                    child: Text(unescape.convert(ans), style: TextStyle(
                        fontSize: 16)),
                    onPressed: () {
                      print(ans);
                      print(firstClick);
                      if (firstClick) {
                        setState(() {
                          hasUserSelectedAns = true;
                          correctAnswer = false;
                          firstClick = false;
                        });
                      }
                    },
                    color: firstClick ? Color(ansNormalColor) : Colors.red,
                  ),
                );
              }).toList(),
            ]),
          ],
        ),
      );
    } else if(_quizData.isEmpty){
      return Column(
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
    );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: (_quizData.isEmpty) ? Text('Select your quiz parameters:') : Text('Quiz Time!'),
          ),
        body:  selectHomeWidget(),
        floatingActionButton: (_quizDataUpdated && _quizData.isNotEmpty) ? (!endPage ? Padding(
          padding: const EdgeInsets.only(left: 31.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton.extended(onPressed: () {
              setState(() {
                if (qNum < numQuestions - 1) {
                  qNum++;
                  hasUserSelectedAns = false;
                  correctAnswer = false;
                  firstClick = true;
                }
                if (qNum == numQuestions - 1) endPage = true;
                else endPage = false;
              });
            }, label: Text('next'), heroTag: null,),
          ),
        ) : null) : null,
        bottomNavigationBar: (endPage) ? RaisedButton(
          child: Text('Exit Quiz'),
          onPressed: () {
            setState(() {
              _quizDataUpdated = !_quizDataUpdated;
              endPage = false;
              qNum = 0;
            });
          },
        ) : null,
      ),
    );
  }
}
