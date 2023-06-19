import 'package:flutter/material.dart';
import 'package:flutter_fitness_app/classes/Exercise.dart';
import 'package:flutter_fitness_app/classes/WorkoutTemplate.dart';
import 'package:flutter_fitness_app/classes/timerService.dart';
import 'package:flutter_fitness_app/pages/exerciseCard.dart';
import 'package:flutter_fitness_app/DB/DBHelper.dart';
import 'package:provider/provider.dart';

import '../DB/DBHelper.dart';
import '../classes/activeWorkoutState.dart';

class ActiveWorkout extends StatefulWidget {
  const ActiveWorkout({Key? key}) : super(key: key);

  @override
  State<ActiveWorkout> createState() => _ActiveWorkoutState();
}

class _ActiveWorkoutState extends State<ActiveWorkout> {
  List<Exercise> activeExercises = [];

  TimerService timerService = TimerService();


  @override
  Widget build(BuildContext context) {
    final activeWorkoutState = Provider.of<ActiveWorkoutState>(context);
    final timerService = activeWorkoutState.timerService;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            // Add this leading property
            icon: Icon(Icons.arrow_downward, color: Colors.white),
            onPressed: () {
              Navigator.pop(context); // Navigates to the previous page
            },
          ),
          title: StreamBuilder<int>(
            stream: timerService.timerStream,
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
              if (snapshot.hasData) {
                final int totalSeconds = snapshot.data!;
                final int hours = totalSeconds ~/ 3600;
                final int minutes = (totalSeconds % 3600) ~/ 60;
                final int seconds = totalSeconds % 60;
                return Text(
                    '${activeWorkoutState.workoutName}:\n${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}');
              } else {
                return Text('${activeWorkoutState.workoutName}');
              }
            },
          ),
          foregroundColor: Colors.white,
          backgroundColor: Colors.red[800],
          actions: [
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SimpleDialog(
                      title: Text('Choose an option'),
                      children: <Widget>[
                        SimpleDialogOption(
                          onPressed: () async {
                            saveExerciseData(activeWorkoutState.activeExercises);
                            var activeWorkoutState1 =
                                Provider.of<ActiveWorkoutState>(context,
                                    listen: false);
                            activeWorkoutState1.endWorkout();

                            setState(() {
                              activeWorkoutState.activeExercises.clear();
                              Navigator.pop(context);
                              Navigator.pop(context);
                            });
                            List<Exercise> savedExercises =
                                await fetchExercises();
                          },
                          child: Container(
                            padding: EdgeInsets.all(10.0),
                            color: Colors.red[800],
                            child: Text('Save Workout Data',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        SimpleDialogOption(
                          onPressed: () async {
                            String? workoutName = await showDialog<String>(
                              context: context,
                              builder: (BuildContext context) {
                                TextEditingController controller =
                                    TextEditingController();
                                return AlertDialog(
                                  title: Text('Enter Workout Template Name'),
                                  content: TextField(
                                    controller: controller,
                                    decoration: InputDecoration(
                                        hintText: 'Workout Template Name'),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(controller.text);
                                      },
                                      child: Text('OK'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Cancel'),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (workoutName != null && workoutName.isNotEmpty) {
                              saveExerciseData(activeWorkoutState.activeExercises);
                              Map<String, dynamic> workoutData = {
                                'workoutName': workoutName,
                                // Use user entered workoutName
                                'exercises': '',
                                'type': '',
                                'sets': '',
                                'date': DateTime.now().toString(),
                              };
                              for (int i = 0;
                                  i < activeWorkoutState.activeExercises.length;
                                  i++) {
                                workoutData['exercises'] +=
                                    '${activeWorkoutState.activeExercises[i].name},';
                                workoutData['sets'] +=
                                    '${activeWorkoutState.activeExercises[i].sets!.length},';
                                if (activeWorkoutState
                                        .activeExercises[i].weight !=
                                    null) {
                                  workoutData['type'] += '1,';
                                } else if (activeWorkoutState
                                        .activeExercises[i].distance !=
                                    null) {
                                  workoutData['type'] += '2,';
                                } else if (activeWorkoutState
                                        .activeExercises[i].time !=
                                    null) {
                                  workoutData['type'] += '3,';
                                } else {
                                  workoutData['type'] += '4,';
                                }
                              }
                              await DBHelper.insertWorkout(workoutData);

                              var activeWorkoutState1 =
                                  Provider.of<ActiveWorkoutState>(context,
                                      listen: false);
                              activeWorkoutState1.endWorkout();

                              setState(() {
                                activeExercises.clear();
                                Navigator.pushReplacementNamed(context, "/");
                              });
                              List<WorkoutTemplate> savedWorkouts =
                                  await convertToWorkoutTemplates();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            color: Colors.red[800],
                            child: const Text('Save Workout as Template',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        SimpleDialogOption(
                          onPressed: () {
                            var activeWorkoutState1 =
                                Provider.of<ActiveWorkoutState>(context,
                                    listen: false);
                            activeWorkoutState1.endWorkout();

                            setState(() {
                              activeExercises.clear();
                              Navigator.pop(context);
                              Navigator.pop(context);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            color: Colors.red[800],
                            child: const Text('Finish without saving',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text(
                "Finish Workout",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            // List of exercises

            ListView.builder(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 100.0),
              itemCount: activeWorkoutState.activeExercises.length,
              itemBuilder: (context, index) {
                return ExerciseCard(
                  exercise: activeWorkoutState.activeExercises[index],
                  exerciseIndex: index,
                );
              },
            ),
            // Buttons to cancel workout and add exercise
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Cancel Workout Button
                      ElevatedButton.icon(
                        onPressed: () {
                          var activeWorkoutState =
                              Provider.of<ActiveWorkoutState>(context,
                                  listen: false);
                          activeWorkoutState.endWorkout();

                          setState(() {
                            activeExercises.clear();
                            Navigator.pop(context);
                          });
                        },
                        icon: Icon(Icons.cancel_outlined),
                        label: Text("Cancel Workout"),
                      ),
                      // Add Exercise Button
                      ElevatedButton.icon(
                        onPressed: () async {
                          dynamic result = await Navigator.pushNamed(
                              context, '/addExercise');
                          if (result != null) {
                            setState(() {
                              activeWorkoutState.addExercise(result);
                            });
                          }
                        },
                        icon: Icon(Icons.add),
                        label: Text("Add Exercise"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    timerService.dispose();
    super.dispose();
  }

  void saveExerciseData(List<Exercise> exercises) async {
    Map<String, dynamic> exerciseData = {
      'name': '',
      'sets': '',
      'reps': '',
      'weight': '',
      'time': '',
      'distance': '',
      'date': DateTime.now().toString(),
    };
    for (int i = 0; i < exercises.length; i++) {
      exerciseData['name'] = exercises[i].name;
      exerciseData['sets'] = '';
      exerciseData['reps'] = '';
      exerciseData['weight'] = '';
      exerciseData['time'] = '';
      exerciseData['distance'] = '';
      for (int j = 0; j < exercises[i].sets!.length; j++) {
        exerciseData['sets'] += '${j + 1},';
        if (exercises[i].weight != null) {
          exerciseData['reps'] += '${exercises[i].reps?[j]},';
          exerciseData['weight'] += '${exercises[i].weight?[j]},';
        } else if (exercises[i].distance != null) {
          exerciseData['time'] += '${exercises[i].time?[j]},';
          exerciseData['distance'] += '${exercises[i].distance?[j]},';
        } else if (exercises[i].time != null) {
          exerciseData['time'] += '${exercises[i].time?[j]},';
        } else {
          exerciseData['reps'] += '${exercises[i].reps?[j]},';
        }
      }
    }
    print("Exercise Data: $exerciseData");
    await DBHelper.insertExercise(exerciseData);
  }
}
