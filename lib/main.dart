import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Конвертер единиц измерения',
            style: TextStyle(fontSize: screenWidth > 600 ? 24.0 : 18.0),
          ),
        ),
      ),
      body: UnitSelectionScreen(),
    );
  }
}

class UnitSelectionScreen extends StatelessWidget {
  final List<String> categories = const ['Масса', 'Валюта', 'Температура', 'Длина', 'Площадь'];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(categories[index]),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConversionScreen(category: categories[index]),
              ),
            );
          },
        );
      },
    );
  }
}

class ConversionScreen extends StatefulWidget {
  final String category;

  ConversionScreen({required this.category});

  @override
  _ConversionScreenState createState() => _ConversionScreenState();
}

class _ConversionScreenState extends State<ConversionScreen> {
  double inputValue = 0.0;
  String fromUnit = '';
  String toUnit = '';
  String result = '';

  Map<String, Map<String, double>> conversionRates = {
    'Масса': {'Грамм': 1, 'Килограмм': 0.001, 'Тонна': 1e-6},
    'Валюта': {'USD': 1, 'EUR': 0.9, 'RUB': 88.0},
    'Температура': {'Цельсий': 1, 'Фаренгейт': 33.8, 'Кельвин': 274.15},
    'Длина': {'Сантиметр': 1, 'Метр': 0.01, 'Километр': 1e-5},
    'Площадь': {'Квадратный сантиметр': 1, 'Квадратный метр': 1e-4, 'Квадратный километр': 1e-10},
  };

  @override
  void initState() {
    super.initState();
    fromUnit = conversionRates[widget.category]!.keys.first;
    toUnit = conversionRates[widget.category]!.keys.elementAt(1);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            widget.category,
            style: TextStyle(fontSize: screenWidth > 600 ? 24.0 : 18.0),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Измеряемая единица:'),
            DropdownButton<String>(
              value: fromUnit,
              onChanged: (value) {
                setState(() {
                  fromUnit = value!;
                });
              },
              items: conversionRates[widget.category]!.keys.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            Text('Единица, в которую переводим:'),
            DropdownButton<String>(
              value: toUnit,
              onChanged: (value) {
                setState(() {
                  toUnit = value!;
                });
              },
              items: conversionRates[widget.category]!.keys.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  inputValue = double.tryParse(value) ?? 0.0;
                });
              },
              decoration: InputDecoration(labelText: 'Введите значение'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (inputValue >= 0) {
                  setState(() {
                    double rawResult = inputValue * conversionRates[widget.category]![toUnit]! /
                        conversionRates[widget.category]![fromUnit]!;
                    result = formatResult(rawResult);
                  });
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Ошибка'),
                        content: Text('Введите неотрицательное значение'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('ОК'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Конвертировать'),
            ),
            SizedBox(height: 16.0),
            Text('Результат: $result'),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  String temp = fromUnit;
                  fromUnit = toUnit;
                  toUnit = temp;
                });
              },
              child: Text('Поменять местами'),
            ),
          ],
        ),
      ),
    );
  }

  String formatResult(double rawResult) {
    String formattedResult = rawResult.toStringAsFixed(10).replaceAll(RegExp(r'(?:(\.0+)|0+)$'), '');
    return formattedResult.endsWith('.') ? formattedResult.substring(0, formattedResult.length - 1) : formattedResult;
  }
}
