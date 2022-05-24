import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//models
import 'models.dart';

void main() {
  runApp(const MyApp());
}

SnackBar createInfoSnackbar(String message) {
  return SnackBar(content: Text(message));
}

//radius
const double borderRadius = 18;

//colors
const primaryColor = Color(0xFF5558da);
const primaryDarkColor = Color(0xFF6071D7);
const accentColor = Color(0xFF8671E1);
const darkColor = Color(0xFF333333);
const transparent = Color(0x00000000);
const whiteColor = Color(0xFFFFFFFF);
const grayColor = Color(0xFFCED0CE);
const complementColor = Color(0xFFC1CDF9);
const shadowColor = Color(0XFF999797);
const boxShadow = BoxShadow(
    color: shadowColor, offset: Offset(0, 0), blurRadius: 15, spreadRadius: -3);

const primaryGradient = [
  Color(0xFF5fd1f9),
  Color(0xFF5558da),
  Color(0xFF5558da)
];

//dummy data
final _teamSelection = [
  'Zelení',
  'Červení',
  'Modří',
  'Oranžoví',
  'Žlutí',
  'Hnědí',
  'Fialoví'
];

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppSate createState() => MyAppSate();
}

class MyAppSate extends State<MyApp> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  List<Match> matches = [];

  static const List<Widget> _pages = <Widget>[HomePage(), MatchCreator()];

  @override
  Widget build(BuildContext context) {
    Match.readData().then((value) => matches = value);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _selectedIndex = index);
          },
          children: _pages,
        ),
        extendBody: false,
        bottomNavigationBar: BottomNavigationBar(
            elevation: 10,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.flag),
                label: 'Match',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onNavItemTap,
            iconSize: 25,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            backgroundColor: whiteColor),
      ),
      theme: ThemeData(
          // Define the default brightness and colors.
          brightness: Brightness.light,
          canvasColor: Colors.white,
          scaffoldBackgroundColor: primaryColor,
          textTheme: GoogleFonts.comfortaaTextTheme(),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            selectedItemColor: darkColor,
            unselectedItemColor: grayColor,
          )),
    );
  }

  void _onNavItemTap(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(index,
          duration: const Duration(milliseconds: 150), curve: Curves.easeOut);
    });
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Match> activeMatches = [];
  List<Match> finishedMatches = [];

  void refreshUi() {
    Match.readData().then((value) {
      setState(() {
        activeMatches =
            value.where((element) => element.finished! == 'false').toList();
        finishedMatches =
            value.where((element) => element.finished! == 'true').toList();
        print('refreshing');
      });
    });
  }

  Future<List<Match>> getDataAsync() {
    return Match.readData();
  }

  void showSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(borderRadius),
                  topRight: Radius.circular(borderRadius),
                ),
              ),
              child: SettingsPage(
                notifyParent: refreshUi,
              ),
            );
          },
        );
      },
    ).then((value) => refreshUi());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getDataAsync(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Container(); // your widget while loading
        }

        if (!snapshot.hasData) {
          return Container(); //your widget when error happens
        }

        activeMatches = snapshot.data
            .where((element) => element.finished! == 'false')
            .toList();
        finishedMatches = snapshot.data
            .where((element) => element.finished! == 'true')
            .toList(); //your Map<String,dynamic>

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.only(
                      left: 30, top: 75, right: 25, bottom: 40),
                  child: Text(
                    'Welcome\nback !',
                    style: GoogleFonts.comfortaa(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        height: 0.9,
                        color: whiteColor),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(right: 30, top: 5),
                  child: IconButton(
                    icon: const Icon(Icons.settings),
                    color: whiteColor,
                    iconSize: 35,
                    onPressed: () {
                      showSettings();
                    },
                  ),
                )
              ],
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(borderRadius),
                    topLeft: Radius.circular(borderRadius),
                  ),
                ),
                padding: const EdgeInsets.only(left: 0, right: 0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(
                            left: 20, top: 25, right: 0, bottom: 18),
                        child: const Heading(
                          text: 'Active matches',
                        ),
                      ),
                      Container(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: (activeMatches.length > 0)
                              ? Row(
                                  children: activeMatches
                                      .map((e) => ActiveMatchCard(
                                            match: e,
                                            afterCallback: () => refreshUi(),
                                          ))
                                      .toList())
                              : Container(
                                  margin: const EdgeInsets.all(15),
                                  child: Text(
                                      'Tere are currently no active matches'),
                                ),
                        ),
                      ),
                      Container(
                          padding: const EdgeInsets.only(
                              left: 20, top: 25, right: 0, bottom: 18),
                          child: const Heading(
                            text: 'Recent results',
                          )),
                      Column(
                        children: finishedMatches.length > 0
                            ? finishedMatches
                                .map((e) => MatchCard(match: e))
                                .toList()
                            : [
                                Container(
                                  margin: const EdgeInsets.all(15),
                                  child: Text(
                                      'Tere are currently no match results'),
                                ),
                              ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}

class MatchCard extends StatelessWidget {
  MatchCard({Key? key, required this.match}) : super(key: key);

  final Match match;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.only(left: 8, right: 8,bottom: 8),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: grayColor, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                match.teamOne!,
                style: GoogleFonts.comfortaa(
                    fontWeight: FontWeight.w600, fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
                child: Text(
              '${match.score![0].toString()} : ${match.score![1].toString()}',
              style: GoogleFonts.comfortaa(
                fontWeight: FontWeight.w900,
                fontSize: 26,
                color: primaryDarkColor,
              ),
              textAlign: TextAlign.center,
            )),
            Expanded(
                child: Text(
              match.teamTwo!,
              style: GoogleFonts.comfortaa(
                  fontWeight: FontWeight.w600, fontSize: 20),
              textAlign: TextAlign.center,
            ))
          ],
        ));
  }
}

class ActiveMatchCard extends StatelessWidget {
  ActiveMatchCard({Key? key, required this.match, required this.afterCallback})
      : super(key: key);

  final Match match;
  VoidCallback afterCallback;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        MatchPage(match: match, notifyParent: () {})))
            .then((value) => afterCallback());
      },
      child: Container(
          width: 220,
          height: 300,
          padding: const EdgeInsets.only(left: 15, bottom: 15),
          margin: const EdgeInsets.only(left: 8, right: 8, top: 16, bottom: 16),
          decoration: BoxDecoration(
              gradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: primaryGradient),
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: const [boxShadow]),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Color(0x50FFFFFF),
                    size: 200,
                  ),
                ),
                Text(
                  '${match.teamOne}\n${match.teamTwo}',
                  style: GoogleFonts.comfortaa(
                      fontSize: 26,
                      color: whiteColor,
                      fontWeight: FontWeight.w900,
                      height: 1.3),
                ),
              ],
            ),
          )),
    );
  }
}

class Heading extends StatelessWidget {
  const Heading({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.comfortaa(fontSize: 26, fontWeight: FontWeight.w900),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key, required this.notifyParent}) : super(key: key);

  final VoidCallback notifyParent;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Heading(text: 'App Settings'),
            const Text(
                'Settings are saved automatically and will be synchronized once the settings page is closed'),
            Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 15),
              child: SecondaryButton(
                  text: 'Delete all saved data',
                  onTap: () {
                    Match.deleteSavedData().then((value) => () {
                          print('deleting');
                          notifyParent();
                        });
                  }),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 15),
              child: SecondaryButton(
                  text: 'Test message',
                  onTap: () {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(createInfoSnackbar('Hello world'));
                  }),
            )
          ],
        ));
  }
}

class MatchCreator extends StatefulWidget {
  const MatchCreator({Key? key}) : super(key: key);

  @override
  State<MatchCreator> createState() => _MatchCreatorState();
}

class _MatchCreatorState extends State<MatchCreator> {
  final Match match = Match();

  List<DropdownMenuItem<String>> _dropDownMenuItems = [];
  String _teamOneSelected = _teamSelection[0];
  String _teamTwoSelected = _teamSelection[1];

  @override
  Widget build(BuildContext context) {
    for (String team in _teamSelection) {
      _dropDownMenuItems.add(DropdownMenuItem(
        value: team,
        child: Text(team),
      ));
    }

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(
                  left: 25, top: 70, right: 0, bottom: 20),
              child: Text(
                'Match creator',
                style: GoogleFonts.comfortaa(
                    fontSize: 30,
                    color: whiteColor,
                    fontWeight: FontWeight.w900),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(15),
              child: Container(
                  child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      DecoratedBox(
                          decoration: const BoxDecoration(
                              color: whiteColor,
                              borderRadius: BorderRadius.all(
                                  Radius.circular(borderRadius))),
                          child: Container(
                            padding: const EdgeInsets.only(
                                left: 10, top: 8, bottom: 8, right: 10),
                            child: DropdownButton<String>(
                              underline: Container(),
                              value: _teamOneSelected,
                              icon: const Icon(Icons.arrow_drop_down),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _teamOneSelected = newValue!;
                                  match.teamOne = _teamOneSelected;
                                });
                              },
                              items: _teamSelection
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                    value: value, child: Text(value));
                              }).toList(),
                              style: GoogleFonts.comfortaa(
                                  color: Colors.black, fontSize: 20),
                            ),
                          ),),
                      Text(
                        'vs.',
                        style: GoogleFonts.comfortaa(
                            fontSize: 26, color: whiteColor),
                      ),
                      DecoratedBox(
                          decoration: const BoxDecoration(
                              color: whiteColor,
                              borderRadius: BorderRadius.all(
                                  Radius.circular(borderRadius))),
                          child: Container(
                            padding: const EdgeInsets.only(
                                left: 10, top: 8, bottom: 8, right: 10),
                            child: DropdownButton<String>(
                              underline: Container(),
                              value: _teamTwoSelected,
                              icon: const Icon(Icons.arrow_drop_down),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _teamTwoSelected = newValue!;
                                  match.teamTwo = _teamTwoSelected;
                                });
                              },
                              items: _teamSelection
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              style: GoogleFonts.comfortaa(
                                  color: Colors.black, fontSize: 20),
                            ),
                          ),),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    activeColor: whiteColor,
                    inactiveTrackColor: darkColor,
                    title: Text(
                      'Allow overtime',
                      style: GoogleFonts.comfortaa(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: whiteColor),
                    ),
                    value: match.allowOvertime! == "true",
                    onChanged: (bool value) {
                      setState(() {
                        match.allowOvertime = (value) ? "true" : "false";
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      match.teamOne = _teamOneSelected;
                      match.teamTwo = _teamTwoSelected;
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MatchPage(
                              match: match,
                              notifyParent: () {},
                            ),
                          )).then((value) {
                        setState(() {});
                      });
                    },
                    child: const MainButton(
                        text: 'Start the match', icon: Icons.arrow_forward),
                  )
                ],
              )),
            )
          ],
        ));
  }
}

class MainButton extends StatelessWidget {
  const MainButton({Key? key, required this.text, this.icon}) : super(key: key);

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        padding:
            const EdgeInsets.only(left: 25, top: 15, right: 25, bottom: 15),
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
            color: whiteColor),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              text,
              style: GoogleFonts.comfortaa(
                  fontSize: 22,
                  color: Colors.black,
                  fontWeight: FontWeight.w900),
            ),
            Icon(
              icon,
              color: Colors.black,
              size: 30,
            )
          ],
        ));
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({Key? key, required this.text, required this.onTap})
      : super(key: key);

  final Function() onTap;
  final String text;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => onTap(),
        child: Container(
          padding:
              const EdgeInsets.only(left: 25, top: 15, right: 25, bottom: 15),
          decoration: const BoxDecoration(
              color: primaryDarkColor,
              borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
              boxShadow: [boxShadow]),
          child: Text(
            text,
            style: GoogleFonts.comfortaa(
                fontSize: 20, fontWeight: FontWeight.w900, color: whiteColor),
          ),
        ));
  }
}

class MatchPage extends StatefulWidget {
  MatchPage({Key? key, required this.match, required this.notifyParent})
      : super(key: key);
  Match match;

  final VoidCallback notifyParent;

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  final ScrollController _controller = ScrollController();

  bool buttonEnabled = true;

  void _scrollDown() {
    _controller.animateTo(
      _controller.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }

  var snackBar = const SnackBar(
    content: Text("It's time to rotate players"),
  );

  void incerementNumberOfRound() {
    if ((widget.match.score![0] + widget.match.score![1]) % 3 == 0) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void _checkForWin() {
    if (widget.match.isWin) {
      String team = (widget.match.score![0] > widget.match.score![1])
          ? widget.match.teamOne!
          : widget.match.teamTwo!;
      setState(() {
        buttonEnabled = false;
      });
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Victory!',
              style: GoogleFonts.comfortaa(fontWeight: FontWeight.w900)),
          content: Text(
              'Team $team won the match ${widget.match.score![0]} - ${widget.match.score![1]}'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, 'OK');
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void addScore(int teamOne, int teamTwo) {
    setState(() {
      widget.match.addScore(teamOne, teamTwo);
    });
    _scrollDown();
    incerementNumberOfRound();
  }

  void undo() {
    setState(() {
      widget.match.undo();
    });
  }

  @override
  Widget build(BuildContext context) {
    print(widget.match.id);
    return Scaffold(
      body: Column(children: [
        PageTitleWithBackIcon(
            title: 'Match page',
            onTap: () {
              Navigator.pop(context);
            }),
        Scoreboard(
          teamOne: widget.match.score![0],
          teamTwo: widget.match.score![1],
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 20),
            decoration: const BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(borderRadius),
                  topRight: Radius.circular(borderRadius)),
            ),
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: (buttonEnabled)
                        ? [
                            SecondaryButton(
                                text: '2 - 0',
                                onTap: () {
                                  addScore(2, 0);
                                  _checkForWin();
                                  widget.match
                                      .saveMatch(widget.match)
                                      .then((value) => print('saved'));
                                }),
                            SecondaryButton(
                                text: '1 - 1',
                                onTap: () {
                                  addScore(1, 1);
                                  _checkForWin();
                                  widget.match
                                      .saveMatch(widget.match)
                                      .then((value) => print('saved'));
                                }),
                            SecondaryButton(
                                text: '0 - 2',
                                onTap: () {
                                  addScore(0, 2);
                                  _checkForWin();
                                  widget.match
                                      .saveMatch(widget.match)
                                      .then((value) => print('saved'));
                                })
                          ]
                        : [],
                  ),
                ),
                const Heading(text: 'History'),
                Expanded(
                    child: ListView.builder(
                        controller: _controller,
                        padding: const EdgeInsets.all(0),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: (widget.match.history!.length ~/ 2),
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${widget.match.history![index * 2].toString()} - ${widget.match.history![index * 2 + 1].toString()}',
                                    style: GoogleFonts.comfortaa(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900),
                                  )
                                ],
                              )
                            ],
                          );
                        })),
              ],
            ),
          ),
        )
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: (() {
          if (buttonEnabled) {
            undo();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(createInfoSnackbar(
                'Match is closed, edditing is no longer alowed.'));
          }
        }),
        backgroundColor: primaryDarkColor,
        child: const Icon(Icons.undo),
      ),
    );
  }
}

class Scoreboard extends StatelessWidget {
  Scoreboard({Key? key, this.teamOne = 0, this.teamTwo = 0}) : super(key: key);

  int teamOne;
  int teamTwo;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.only(left: 15, right: 15),
        decoration: const BoxDecoration(
            color: primaryDarkColor,
            borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
        width: double.infinity,
        child: Column(
          children: [
            const Heading(text: 'Scoreboard'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.only(
                      left: 35, right: 35, top: 15, bottom: 15),
                  decoration: const BoxDecoration(
                      color: whiteColor,
                      borderRadius:
                          BorderRadius.all(Radius.circular(borderRadius))),
                  child: Heading(text: teamOne.toString()),
                ),
                Container(
                  margin: const EdgeInsets.all(25),
                  child: const Heading(text: ':'),
                ),
                Container(
                  padding: const EdgeInsets.only(
                      left: 35, right: 35, top: 15, bottom: 15),
                  decoration: const BoxDecoration(
                      color: whiteColor,
                      borderRadius:
                          BorderRadius.all(Radius.circular(borderRadius))),
                  child: Heading(text: teamTwo.toString()),
                ),
              ],
            )
          ],
        ));
  }
}

class PageTitleWithBackIcon extends StatelessWidget {
  const PageTitleWithBackIcon(
      {Key? key, required this.title, required this.onTap})
      : super(key: key);

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.only(left: 5, top: 50, bottom: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () => onTap(),
              icon: const Icon(Icons.arrow_back),
              color: whiteColor,
            ),
            Text(
              title,
              style: GoogleFonts.comfortaa(
                  fontSize: 26, fontWeight: FontWeight.w900, color: whiteColor),
            )
          ],
        ));
  }
}
