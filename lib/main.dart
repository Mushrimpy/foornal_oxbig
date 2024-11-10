import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'dart:io';

// ... (keeping previous MyApp and main() unchanged)
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foornal - Your Food Journal',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const ImagePickerScreen(),
    );
}
}

class NutrientData {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  NutrientData({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory NutrientData.fromJson(Map<String, dynamic> json) {
    return NutrientData(
      calories: json['calories'].toDouble(),
      protein: json['protein'].toDouble(),
      carbs: json['carbs'].toDouble(),
      fat: json['fat'].toDouble(),
    );
  }
}

class HistoricalData {
  final DateTime date;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  HistoricalData({
    required this.date,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory HistoricalData.fromJson(Map<String, dynamic> json) {
    return HistoricalData(
      date: DateTime.parse(json['date']),
      calories: json['calories'].toDouble(),
      protein: json['protein'].toDouble(),
      carbs: json['carbs'].toDouble(),
      fat: json['fat'].toDouble(),
    );
  }
}

class ImagePickerScreen extends StatefulWidget {
  const ImagePickerScreen({super.key});

  @override
  State<ImagePickerScreen> createState() => _ImagePickerScreenState();
}
class StreakData {
  final int currentStreak;
  final int longestStreak;
  final int totalUploads;
  final String lastUpload;
  final String healthyTip;

  StreakData({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalUploads,
    required this.lastUpload,
    required this.healthyTip,
  });

  factory StreakData.fromJson(Map<String, dynamic> json) {
    return StreakData(
      currentStreak: json['current_streak'],
      longestStreak: json['longest_streak'],
      totalUploads: json['total_uploads'],
      lastUpload: json['last_upload'],
      healthyTip: json['healthy_tip'],
    );
  }
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  StreakData? _streakData;
  NutrientData? _nutrientData;
  List<HistoricalData> _historicalData = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    await Future.wait([
      _fetchStreakData(),
      _fetchNutrientData(),
      _fetchHistoricalData(),
    ]);
  }

  Future<void> _fetchStreakData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://serverless.on-demand.io/apps/testing/info'),
        headers: {
          'Authorization': 'Bearer YOUR_AUTH_TOKEN_HERE',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _streakData = StreakData.fromJson(jsonDecode(response.body));
          _nutrientData = NutrientData.fromJson(jsonDecode(response.body));
        });
      } else {
        throw Exception('Failed to load streak data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        await _fetchStreakData(); // Fetch new streak data after image selection
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Widget _buildStreakCard() {
    if (_streakData == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStreakStat(
                '🔥 Current Streak',
                '${_streakData!.currentStreak} days',
              ),
              _buildStreakStat(
                '🏆 Best Streak',
                '${_streakData!.longestStreak} days',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStreakStat(
                '📸 Total Uploads',
                _streakData!.totalUploads.toString(),
              ),
              _buildStreakStat(
                '📅 Last Upload',
                _streakData!.lastUpload,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _streakData!.healthyTip,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

Widget _buildStreakStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  // ... (keeping previous _fetchStreakData and _pickImage methods)

  Future<void> _fetchNutrientData() async {
    // Simulated data - replace with actual API call
    _nutrientData = NutrientData(
      calories: 650,
      protein: 25,
      carbs: 85,
      fat: 22,
    );
  }

  Future<void> _fetchHistoricalData() async {
    // Simulated data - replace with actual API call
    _historicalData = [
      HistoricalData(date: DateTime.now().subtract(const Duration(days: 5)), calories: 2100, protein: 80, carbs: 250, fat: 70),
      HistoricalData(date: DateTime.now().subtract(const Duration(days: 4)), calories: 1950, protein: 85, carbs: 220, fat: 65),
      HistoricalData(date: DateTime.now().subtract(const Duration(days: 3)), calories: 2200, protein: 90, carbs: 260, fat: 75),
      HistoricalData(date: DateTime.now().subtract(const Duration(days: 2)), calories: 2000, protein: 88, carbs: 240, fat: 68),
      HistoricalData(date: DateTime.now().subtract(const Duration(days: 1)), calories: 1850, protein: 82, carbs: 215, fat: 60),
      HistoricalData(date: DateTime.now(), calories: 2050, protein: 87, carbs: 245, fat: 70),
    ];
  }

  Widget _buildNutrientCard() {
    if (_nutrientData == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nutrient Breakdown',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildNutrientCircle(
                      'Calories',
                      _nutrientData!.calories.toString(),
                      Colors.orange,
                    ),
                    const SizedBox(height: 8),
                    const Text('kcal'),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    _buildNutrientCircle(
                      'Protein',
                      '${_nutrientData!.protein}g',
                      Colors.red,
                    ),
                    const SizedBox(height: 8),
                    const Text('Protein'),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    _buildNutrientCircle(
                      'Carbs',
                      '${_nutrientData!.carbs}g',
                      Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    const Text('Carbs'),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    _buildNutrientCircle(
                      'Fat',
                      '${_nutrientData!.fat}g',
                      Colors.green,
                    ),
                    const SizedBox(height: 8),
                    const Text('Fat'),
                  ],
                ),
              ),
            ],
          ),
          // const SizedBox(height: 20),
          // const Text(
          //   'Vitamins & Minerals',
          //   style: TextStyle(
          //     fontSize: 16,
          //     fontWeight: FontWeight.bold,
          //   ),
          // ),
          // const SizedBox(height: 10),
          // Row(
          //   children: _nutrientData!.vitamins.entries.map((entry) {
          //     return Expanded(
          //       child: Column(
          //         children: [
          //           Text(
          //             'Vitamin ${entry.key}',
          //             style: const TextStyle(fontSize: 12),
          //           ),
          //           const SizedBox(height: 4),
          //           Text(
          //             '${entry.value.toInt()}%',
          //             style: const TextStyle(
          //               fontSize: 16,
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //         ],
          //       ),
          //     );
          //   }).toList(),
          // ),
        ],
      ),
    );
  }

  Widget _buildNutrientCircle(String label, String value, Color color) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.2),
      ),
      child: Center(
        child: Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoricalChart() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= _historicalData.length) {
                          return const Text('');
                        }
                        return Text(
                          _historicalData[value.toInt()].date.day.toString(),
                          style: const TextStyle(fontSize: 12),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  _createLineBarsData('calories', Colors.orange),
                  _createLineBarsData('protein', Colors.red),
                  _createLineBarsData('carbs', Colors.blue),
                  _createLineBarsData('fat', Colors.green),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Calories', Colors.orange),
              _buildLegendItem('Protein', Colors.red),
              _buildLegendItem('Carbs', Colors.blue),
              _buildLegendItem('Fat', Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  LineChartBarData _createLineBarsData(String dataType, Color color) {
    return LineChartBarData(
      spots: _historicalData.asMap().entries.map((entry) {
        double value = switch (dataType) {
          'calories' => entry.value.calories / 20,  // Scaled down for visibility
          'protein' => entry.value.protein,
          'carbs' => entry.value.carbs,
          'fat' => entry.value.fat,
          _ => 0,
        };
        return FlSpot(entry.key.toDouble(), value);
      }).toList(),
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foornal: Your Food Journal'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_isLoading)
              const LinearProgressIndicator()
            else
              const SizedBox(height: 2),
            _buildStreakCard(),
            if (_image != null) ...[
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    _image!,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              _buildNutrientCard(),
            ],
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Add Today\'s Meal'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildHistoricalChart(),
          ],
        ),
      ),
    );
  }
}
