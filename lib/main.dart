
import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const StudyFocusGarden());
}

class StudyFocusGarden extends StatelessWidget {
  const StudyFocusGarden({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Study Focus Garden',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.green.shade50,
      ),
      home: const HomePage(),
    );
  }
}

// DATA


class StudyActivity {
  String name;
  int minutes;
  bool completed;
  bool confirmed;

  StudyActivity({
    required this.name,
    required this.minutes,
    this.completed = false,
    this.confirmed = false,
  });
}

class StudyData extends ChangeNotifier {
  final List<StudyActivity> activities = [];

  int todayMinutes = 0;
  int todaySessions = 0;
  int totalMinutes = 0;
  int totalSessions = 0;

  final List<int> weeklyMinutes = [0, 0, 0, 0, 0, 0, 0];


  DateTime _lastTrackedDate = DateTime.now();

  int get todayIndex => DateTime.now().weekday - 1;

  void _checkDate() {
    final DateTime now = DateTime.now();

    final bool newDay =
        now.year != _lastTrackedDate.year ||
            now.month != _lastTrackedDate.month ||
            now.day != _lastTrackedDate.day;

    if (newDay) {
      todayMinutes = 0;
      todaySessions = 0;
      _lastTrackedDate = now;
    }
  }

  int get confirmedActivities {
    int count = 0;

    for (StudyActivity activity in activities) {
      if (activity.confirmed) {
        count++;
      }
    }

    return count;
  }

  int get level {
    if (confirmedActivities >= 20) return 5;
    if (confirmedActivities >= 15) return 4;
    if (confirmedActivities >= 10) return 3;
    if (confirmedActivities >= 5) return 2;

    return 1;
  }

  double get goalProgress {
    double value = todayMinutes / 300.0;

    if (value > 1.0) return 1.0;
    if (value < 0.0) return 0.0;

    return value;
  }

  void addActivity(String name, int minutes) {
    activities.add(
      StudyActivity(
        name: name,
        minutes: minutes,
      ),
    );

    notifyListeners();
  }

  void changeActivity(
      StudyActivity activity,
      bool value,
      ) {
    if (activity.confirmed) return;

    activity.completed = value;

    notifyListeners();
  }

  int get selectedCount {
    int count = 0;

    for (StudyActivity activity in activities) {
      if (activity.completed && !activity.confirmed) {
        count++;
      }
    }

    return count;
  }

  void confirmActivities() {
    _checkDate();

    int addedMinutes = 0;
    int addedSessions = 0;

    for (StudyActivity activity in activities) {
      if (activity.completed && !activity.confirmed) {
        activity.confirmed = true;

        addedMinutes += activity.minutes;
        addedSessions++;
      }
    }

    if (addedMinutes > 0) {
      todayMinutes += addedMinutes;
      todaySessions += addedSessions;

      totalMinutes += addedMinutes;
      totalSessions += addedSessions;

      weeklyMinutes[todayIndex] += addedMinutes;
    }

    notifyListeners();
  }

  void addFocusSession(int minutes) {
    _checkDate();

    todayMinutes += minutes;
    todaySessions++;

    totalMinutes += minutes;
    totalSessions++;

    weeklyMinutes[todayIndex] += minutes;

    notifyListeners();
  }
}


// FIRST PAGE


class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.eco,
                size: 90,
                color: Colors.green,
              ),

              const SizedBox(height: 20),

              Text(
                'Study Focus Garden',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                'Focus more, study better,\ngrow your garden!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainPage(),
                    ),
                  );
                },
                child: const Text(
                  'Start Studying 🌱',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// MAIN NAVIGATION


class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final StudyData data = StudyData();

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: data,
      builder: (context, child) {
        return Scaffold(
          body: _getPage(),

          bottomNavigationBar: BottomNavigationBar(
            currentIndex: selectedIndex,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.green,

            onTap: (int index) {
              setState(() {
                selectedIndex = index;
              });
            },

            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.timer),
                label: 'Focus',
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.eco),
                label: 'Garden',
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.task),
                label: 'Tasks',
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: 'Progress',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _getPage() {
    if (selectedIndex == 0) {
      return DashboardPage(data: data);
    }

    if (selectedIndex == 1) {
      return FocusPage(data: data);
    }

    if (selectedIndex == 2) {
      return GardenPage(data: data);
    }

    if (selectedIndex == 3) {
      return TasksPage(data: data);
    }

    return ProgressPage(data: data);
  }
}

// DASHBOARD / HOMEPAGE


class DashboardPage extends StatelessWidget {
  final StudyData data;

  const DashboardPage({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Good Morning! 🌱',
        ),

        actions: [
          IconButton(
            icon: const Icon(
              Icons.emoji_events,
            ),

            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AchievementsPage(
                    data: data,
                  ),
                ),
              );
            },
          ),

          IconButton(
            icon: const Icon(
              Icons.person,
            ),

            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(
                    data: data,
                  ),
                ),
              );
            },
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(18),

        children: [
          const Text(
            "Today's Overview",
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              _statCard(
                '${(data.todayMinutes / 60).toStringAsFixed(1)} h',
                'Studied',
                Icons.access_time,
              ),

              _statCard(
                '${data.todaySessions}',
                'Sessions',
                Icons.timer,
              ),

              _statCard(
                '${data.confirmedActivities}',
                'Activities',
                Icons.check_circle,
              ),
            ],
          ),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    "Today's Goal",
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '${(data.todayMinutes / 60).toStringAsFixed(1)} / 5 Hours',
                  ),

                  const SizedBox(height: 10),

                  LinearProgressIndicator(
                    value: data.goalProgress,
                    minHeight: 9,
                  ),
                ],
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.eco,
                size: 42,
                color: Colors.green,
              ),

              title: const Text(
                'Your Garden',
              ),

              subtitle: Text(
                'Level ${data.level} • ${data.totalSessions} total sessions',
              ),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TasksPage(
                    data: data,
                  ),
                ),
              );
            },

            icon: const Icon(
              Icons.add,
            ),

            label: const Text(
              'Add Activity',
            ),
          ),

          const SizedBox(height: 15),

          const Text(
            'Today',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.school,
              ),

              title: Text(
                '${data.todaySessions} sessions completed',
              ),

              subtitle: Text(
                '${data.todayMinutes} minutes studied',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(
      String value,
      String label,
      IconData icon,
      ) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 14,
          ),

          child: Column(
            children: [
              Icon(
                icon,
                color: Colors.green,
              ),

              const SizedBox(height: 5),

              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              Text(
                label,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// FOCUS TIMER


class FocusPage extends StatefulWidget {
  final StudyData data;

  const FocusPage({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> {
  Timer? timer;

  int selectedMinutes = 25;

  int remainingSeconds = 25 * 60;

  bool running = false;

  void startTimer() {
    if (running) return;

    setState(() {
      running = true;
    });

    timer = Timer.periodic(
      const Duration(seconds: 1),
          (Timer timer) {
        if (remainingSeconds > 0) {
          setState(() {
            remainingSeconds--;
          });
        } else {
          timer.cancel();

          setState(() {
            running = false;
          });

          widget.data.addFocusSession(
            selectedMinutes,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Session completed! Your progress was updated.',
              ),
            ),
          );
        }
      },
    );
  }

  void pauseTimer() {
    timer?.cancel();

    setState(() {
      running = false;
    });
  }

  void resetTimer() {
    timer?.cancel();

    setState(() {
      running = false;

      remainingSeconds = selectedMinutes * 60;
    });
  }

  void chooseTime(int minutes) {
    if (running) return;

    setState(() {
      selectedMinutes = minutes;

      remainingSeconds = minutes * 60;
    });
  }

  String get timeText {
    int minutes = remainingSeconds ~/ 60;

    int seconds = remainingSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Focus Timer',
        ),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              const Icon(
                Icons.eco,
                size: 75,
                color: Colors.green,
              ),

              const SizedBox(height: 10),

              const Text(
                'Focus Time',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),

              Text(
                timeText,

                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Choose session length',
              ),

              const SizedBox(height: 10),

              Wrap(
                spacing: 8,

                children: [
                  ChoiceChip(
                    label: const Text(
                      '25 min',
                    ),

                    selected: selectedMinutes == 25,

                    onSelected: (value) {
                      chooseTime(25);
                    },
                  ),

                  ChoiceChip(
                    label: const Text(
                      '45 min',
                    ),

                    selected: selectedMinutes == 45,

                    onSelected: (value) {
                      chooseTime(45);
                    },
                  ),

                  ChoiceChip(
                    label: const Text(
                      '60 min',
                    ),

                    selected: selectedMinutes == 60,

                    onSelected: (value) {
                      chooseTime(60);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: startTimer,

                child: Text(
                  running
                      ? 'Running...'
                      : 'Start Session 🌱',
                ),
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  ElevatedButton(
                    onPressed: pauseTimer,

                    child: const Text(
                      'Pause',
                    ),
                  ),

                  const SizedBox(width: 12),

                  ElevatedButton(
                    onPressed: resetTimer,

                    child: const Text(
                      'Reset',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// GARDEN


class GardenPage extends StatelessWidget {
  final StudyData data;

  const GardenPage({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: data,
      builder: (context, child) {
        int activities = data.confirmedActivities;

        String plants = '🌰';
        String message = 'Complete activities to grow your garden!';

        if (activities >= 5 && activities < 10) {
          plants = '🌱';
          message = 'Your plant is growing!';
        }

        if (activities >= 10 && activities < 15) {
          plants = '🌿';
          message = 'Your plant is growing bigger!';
        }

        if (activities >= 15 && activities < 20) {
          plants = '🌳';
          message = 'Your study tree has grown!';
        }

        if (activities >= 20) {
          plants = '🌳🌳';
          message = 'Your study garden is fully grown!';
        }

        int growth;

        if (activities < 5) {
          growth = activities;
        } else if (activities < 10) {
          growth = activities - 5;
        } else if (activities < 15) {
          growth = activities - 10;
        } else if (activities < 20) {
          growth = activities - 15;
        } else {
          growth = 5;
        }

        String nextText;

        if (activities < 5) {
          nextText = '$growth / 5 activities to next growth';
        } else if (activities < 10) {
          nextText = '$growth / 5 activities to next growth';
        } else if (activities < 15) {
          nextText = '$growth / 5 activities to next growth';
        } else if (activities < 20) {
          nextText = '$growth / 5 activities to next growth';
        } else {
          nextText = 'Garden fully grown 🌳';
        }

        double progress = growth / 5.0;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'My Garden',
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        plants,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 80,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Study Garden 🌱',
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$activities activities completed',
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Plant Growth',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(nextText),

              const SizedBox(height: 10),

              LinearProgressIndicator(
                value: progress,
                minHeight: 10,
              ),

              const SizedBox(height: 25),

              Card(
                child: ListTile(
                  leading: const Text(
                    '🌰',
                    style: TextStyle(fontSize: 30),
                  ),
                  title: const Text('Seed'),
                  subtitle: const Text('Complete 1 activity'),
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Text(
                    '🌱',
                    style: TextStyle(fontSize: 30),
                  ),
                  title: const Text('Growing Plant'),
                  subtitle: const Text('Complete 5 activities'),
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Text(
                    '🌿',
                    style: TextStyle(fontSize: 30),
                  ),
                  title: const Text('Growing Bigger'),
                  subtitle: const Text('Complete 10 activities'),
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Text(
                    '🌳',
                    style: TextStyle(fontSize: 30),
                  ),
                  title: const Text('Study Tree'),
                  subtitle: const Text('Complete 15 activities'),
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Text(
                    '🌳🌳',
                    style: TextStyle(fontSize: 30),
                  ),
                  title: const Text('Full Garden'),
                  subtitle: const Text('Complete 20 activities'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


// ACTIVITIES


class TasksPage extends StatelessWidget {
  final StudyData data;

  const TasksPage({
    Key? key,
    required this.data,
  }) : super(key: key);


  // ADD ACTIVITY


  Future<void> showAddActivity(
      BuildContext context,
      ) async {
    final TextEditingController nameController =
    TextEditingController();

    int selectedMinutes = 25;

    await showDialog<void>(
      context: context,

      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
              context,
              setDialogState,
              ) {
            return AlertDialog(
              title: const Text(
                'Add Activity',
              ),

              content: Column(
                mainAxisSize: MainAxisSize.min,

                children: [
                  TextField(
                    controller: nameController,

                    decoration: const InputDecoration(
                      labelText: 'Activity name',
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Align(
                    alignment: Alignment.centerLeft,

                    child: Text(
                      'Select study time',

                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,

                    children: [
                      ChoiceChip(
                        label: const Text(
                          '25 min',
                        ),

                        selected:
                        selectedMinutes == 25,

                        onSelected: (value) {
                          setDialogState(() {
                            selectedMinutes = 25;
                          });
                        },
                      ),

                      ChoiceChip(
                        label: const Text(
                          '45 min',
                        ),

                        selected:
                        selectedMinutes == 45,

                        onSelected: (value) {
                          setDialogState(() {
                            selectedMinutes = 45;
                          });
                        },
                      ),

                      ChoiceChip(
                        label: const Text(
                          '60 min',
                        ),

                        selected:
                        selectedMinutes == 60,

                        onSelected: (value) {
                          setDialogState(() {
                            selectedMinutes = 60;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },

                  child: const Text(
                    'Cancel',
                  ),
                ),

                ElevatedButton(
                  onPressed: () {
                    String name =
                    nameController.text.trim();

                    if (name.isEmpty) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter an activity name',
                          ),
                        ),
                      );

                      return;
                    }

                    data.addActivity(
                      name,
                      selectedMinutes,
                    );

                    Navigator.pop(
                      dialogContext,
                    );
                  },

                  child: const Text(
                    'Add',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
  }

  // TASK PAGE

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: data,

      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'My Activities',
            ),

            actions: [
              IconButton(
                icon: const Icon(
                  Icons.add,
                ),

                onPressed: () {
                  showAddActivity(context);
                },
              ),
            ],
          ),

          body: Column(
            children: [
              Expanded(
                child: data.activities.isEmpty
                    ? _emptyActivities(context)
                    : ListView.builder(
                  padding: const EdgeInsets.only(
                    top: 8,
                  ),

                  itemCount:
                  data.activities.length,

                  itemBuilder: (
                      context,
                      index,
                      ) {
                    StudyActivity activity =
                    data.activities[index];

                    return CheckboxListTile(
                      title: Text(
                        activity.name,
                      ),

                      subtitle: Text(
                        '${activity.minutes} minutes'
                            '${activity.confirmed ? ' • Confirmed' : ''}',
                      ),

                      value:
                      activity.completed,

                      onChanged:
                      activity.confirmed
                          ? null
                          : (value) {
                        data.changeActivity(
                          activity,
                          value ?? false,
                        );
                      },
                    );
                  },
                ),
              ),

              if (data.activities.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    children: [
                      if (data.selectedCount > 0)
                        Padding(
                          padding:
                          const EdgeInsets.only(
                            bottom: 8,
                          ),

                          child: Text(
                            '${data.selectedCount} activity selected',

                            style:
                            const TextStyle(
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),

                      SizedBox(
                        width: double.infinity,

                        child: ElevatedButton.icon(
                          onPressed:
                          data.selectedCount == 0
                              ? null
                              : () {
                            data.confirmActivities();

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Activities confirmed. Progress updated!',
                                ),
                              ),
                            );
                          },

                          icon: const Icon(
                            Icons.check,
                          ),

                          label: const Text(
                            'Confirm Completed Activities',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // EMPTY ACTIVITIES


  Widget _emptyActivities(
      BuildContext context,
      ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.edit_note,
              size: 75,
              color: Colors.green,
            ),

            const SizedBox(height: 15),

            const Text(
              'No activities yet',

              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Add your own study activity to get started.',

              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                showAddActivity(context);
              },

              icon: const Icon(
                Icons.add,
              ),

              label: const Text(
                'Add Activity',
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// PROGRESS


class ProgressPage extends StatelessWidget {
  final StudyData data;

  const ProgressPage({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: data,

      builder: (context, child) {
        data._checkDate();

        int maxMinutes = 1;

        int totalMinutes = 0;

        for (int value in data.weeklyMinutes) {
          totalMinutes += value;

          if (value > maxMinutes) {
            maxMinutes = value;
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'My Progress',
            ),
          ),

          body: ListView(
            padding: const EdgeInsets.all(18),

            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [
                      const Text(
                        'This Week',

                        style: TextStyle(
                          fontSize: 21,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        '${(totalMinutes / 60).toStringAsFixed(1)} Hours',

                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const Text(
                        'Total study time',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Study Hours',

                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Card(
                child: Padding(
                  padding:
                  const EdgeInsets.fromLTRB(
                    8,
                    20,
                    8,
                    12,
                  ),

                  child: Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.end,

                    children:
                    List.generate(
                      7,
                          (index) {
                        double barHeight =
                            30 +
                                (data.weeklyMinutes[
                                index] /
                                    maxMinutes) *
                                    120;

                        const List<String> days = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun',
                        ];

                        return Expanded(
                          child: Column(
                            children: [
                              Text(
                                '${(data.weeklyMinutes[index] / 60).toStringAsFixed(1)}h',

                                style:
                                const TextStyle(
                                  fontSize: 10,
                                ),
                              ),

                              const SizedBox(
                                height: 5,
                              ),

                              Container(
                                height: barHeight,

                                width: 24,

                                decoration:
                                BoxDecoration(
                                  color: Colors
                                      .green
                                      .shade400,

                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                    6,
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: 6,
                              ),

                              Text(
                                days[index],

                                style:
                                const TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              Row(
                children: [
                  _metric(
                    '${data.confirmedActivities}',
                    'Activities',
                    Icons.check_circle,
                  ),

                  _metric(
                    '${data.totalSessions}',
                    'Sessions',
                    Icons.timer,
                  ),
                ],
              ),

              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.today,
                    color: Colors.green,
                  ),

                  title: const Text(
                    "Today's Activity",
                  ),

                  subtitle: Text(
                    '${data.todayMinutes} minutes • ${data.todaySessions} sessions',
                  ),
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.eco,
                    color: Colors.green,
                  ),

                  title: const Text(
                    'Garden Level',
                  ),

                  subtitle: Text(
                    'Level ${data.level} based on completed activities',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _metric(
      String value,
      String label,
      IconData icon,
      ) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(15),

          child: Column(
            children: [
              Icon(
                icon,
                color: Colors.green,
              ),

              const SizedBox(height: 5),

              Text(
                value,

                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                label,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ACHIEVEMENTS


class AchievementsPage extends StatelessWidget {
  final StudyData data;

  const AchievementsPage({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: data,

      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Achievements',
            ),
          ),

          body: ListView(
            padding: const EdgeInsets.all(18),

            children: [
              _achievement(
                '🌰',
                'First Seed',
                'Complete 1 activity',
                data.confirmedActivities >= 1,
              ),

              _achievement(
                '🌱',
                'Growing Habit',
                'Complete 5 activities',
                data.confirmedActivities >= 5,
              ),

              _achievement(
                '🌳',
                'Focus Master',
                'Complete 10 activities',
                data.confirmedActivities >= 10,
              ),

              _achievement(
                '📋',
                'Activity Finisher',
                'Complete 10 activities',
                data.confirmedActivities >= 10,
              ),

              _achievement(
                '⭐',
                'Study Star',
                'Study 5 hours',
                data.totalMinutes >= 300,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _achievement(
      String emoji,
      String title,
      String description,
      bool unlocked,
      ) {
    return Card(
      child: ListTile(
        leading: Text(
          emoji,

          style: const TextStyle(
            fontSize: 32,
          ),
        ),

        title: Text(
          title,
        ),

        subtitle: Text(
          description,
        ),

        trailing: Icon(
          unlocked
              ? Icons.check_circle
              : Icons.lock,

          color: unlocked
              ? Colors.green
              : Colors.grey,
        ),
      ),
    );
  }
}


// PROFILE

class ProfilePage extends StatefulWidget {
  final StudyData data;

  const ProfilePage({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool notifications = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.data,

      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Profile',
            ),
          ),

          body: ListView(
            padding: const EdgeInsets.all(18),

            children: [

              // PROFILE

              const SizedBox(height: 10),

              const CircleAvatar(
                radius: 45,

                child: Icon(
                  Icons.person,
                  size: 50,
                ),
              ),

              const SizedBox(height: 12),

              const Center(
                child: Text(
                  'Student',

                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 5),

              Center(
                child: Text(
                  'Level ${widget.data.level} 🌱',

                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  '${widget.data.confirmedActivities} activities completed',

                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // DAILY GOAL


              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.flag,
                  ),

                  title: const Text(
                    'Daily Goal',
                  ),

                  trailing: const Text(
                    '5 Hours',
                  ),
                ),
              ),



              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.timer,
                  ),

                  title: const Text(
                    'Default Focus',
                  ),

                  trailing: const Text(
                    '25 min',
                  ),
                ),
              ),



              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.coffee,
                  ),

                  title: const Text(
                    'Long Break',
                  ),

                  trailing: const Text(
                    '15 min',
                  ),
                ),
              ),



              Card(
                child: SwitchListTile(
                  secondary: const Icon(
                    Icons.notifications,
                  ),

                  title: const Text(
                    'Notifications',
                  ),

                  value: notifications,

                  onChanged: (value) {
                    setState(() {
                      notifications = value;
                    });
                  },
                ),
              ),

              const SizedBox(height: 20),


              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),

                  child: Column(
                    children: [

                      const Text(
                        '🌱 Your Garden Progress',

                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        '${widget.data.confirmedActivities} / 20 activities completed',

                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 10),

                      LinearProgressIndicator(
                        value:
                        widget.data.confirmedActivities >= 20
                            ? 1.0
                            : widget.data.confirmedActivities / 20.0,

                        minHeight: 9,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'Level ${widget.data.level}',

                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
