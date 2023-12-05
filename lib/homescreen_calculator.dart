import 'package:flutter/material.dart';
import 'package:labtest3/sqlite_db.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(username: ''),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final String username;

  HomeScreen({required this.username});

  @override
  Widget build(BuildContext context) {
    return Calculator();
  }
}

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  var totalBmi = 0.0;
  final TextEditingController totalBmiController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  String selectedGender = ' ';
  String status = '';

  @override
  void initState(){
    super.initState();
    retrievePreviousData();
  }

  Future<void> retrievePreviousData() async {
    List<Map<String, dynamic>> previousData = await SQLiteDB().queryAll('bitp3453_bmi');
    if (previousData.isNotEmpty) {
      Map<String, dynamic> latestData = previousData.last; //  take the last data in the list
      setState(() {
        nameController.text = latestData['username'];
        heightController.text = latestData['height'].toString();
        weightController.text = latestData['weight'].toString();
        statusController.text = latestData['bmi_status'];
        selectedGender = latestData['gender'];
      });
    }
  }

  Future<void> calculateTotalBMI() async {

    if (heightController.text.isNotEmpty && weightController.text.isNotEmpty) {
      double height = double.parse(heightController.text);
      double weight = double.parse(weightController.text);

      setState(() {
        totalBmi = (weight / ((height/100) * (height/100)));
        totalBmiController.text = totalBmi.toStringAsFixed(2);

      });


      if (selectedGender == 'Male') {
        if (totalBmi < 18) {
          statusController.text = 'Underweight. Careful during strong wind!';
        } else if (totalBmi >= 18.5 && totalBmi < 24.9) {
          statusController.text = 'That’s ideal! Please maintain';
        } else if (totalBmi >= 25 && totalBmi < 30) {
          statusController.text = 'Overweight! Work out please';
        } else {
          statusController.text = 'Whoa Obese! Dangerous mate!';
        }
      }else{
        if (totalBmi < 16) {
          statusController.text = 'Underweight. Careful during strong wind!';
        } else if (totalBmi >= 16 && totalBmi < 22) {
          statusController.text = 'That’s ideal! Please maintain';
        } else if (totalBmi >= 22 && totalBmi < 27) {
          statusController.text = 'Overweight! Work out please';
        } else {
          statusController.text = 'Whoa Obese! Dangerous mate!';
        }
      }

      Map<String, dynamic> bmiData = {
        'username': nameController.text,
        'height': height,
        'weight': weight,
        'gender': selectedGender,
        'bmi_status': statusController.text,
      };

      //await SQLiteDB().insertBMI(bmiData);
      await SQLiteDB().insertBMI('bitp3453_bmi', bmiData) != 0;

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BMI Calculator'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Your Fullname',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: heightController,
              decoration: InputDecoration(
                labelText: 'height in cm: 170',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: weightController,
              decoration: const InputDecoration(
                  labelText: 'weight in KG'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
            controller: totalBmiController,
              decoration: const InputDecoration(
                  labelText: 'BMI Value'),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Radio<String>(
                  value: 'Male',
                  groupValue: selectedGender,
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value!;
                    });
                  },
                ),
                Text('Male'),
                Radio<String>(
                  value: 'Female',
                  groupValue: selectedGender,
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value!;
                    });
                  },
                ),
                Text('Female'),
              ],
            ),
          ),

          ElevatedButton(
            onPressed: calculateTotalBMI,
            child: Text('Calculate BMI and Save'),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                statusController.text,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
