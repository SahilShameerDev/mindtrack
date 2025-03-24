import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const platform = MethodChannel('com.example.screen_time_tracker/screen_time');
  
  // Hive box for storing mood data
  late Box moodBox;
  
  // Map to store day-mood pairs
  Map<String, int> weeklyMoods = {
    'Monday': 0,
    'Tuesday': 0,
    'Wednesday': 0,
    'Thursday': 0, 
    'Friday': 0,
    'Saturday': 0,
    'Sunday': 0
  };

  String _screenTime = 'Loading...';
  String _unlockCount = 'Loading...';
  String _mostUsedApp = 'Loading...';
  int _selectedMoodIndex = 0;

  @override
  void initState() {
    super.initState();
    _initHive();
    _fetchData();
  }
  
  // Initialize Hive and load saved mood data
  Future<void> _initHive() async {
    moodBox = await Hive.openBox('mood_data');
    _loadMoodData();
  }
  
  // Load saved mood data from Hive
  void _loadMoodData() {
    final savedMoods = moodBox.get('weekly_moods');
    if (savedMoods != null) {
      setState(() {
        weeklyMoods = Map<String, int>.from(savedMoods);
      });
    }
    
    // Get today's selected mood if available
    final today = _getCurrentDayName();
    setState(() {
      _selectedMoodIndex = weeklyMoods[today] ?? 0;
    });
  }
  
  // Get current day of week as string
  String _getCurrentDayName() {
    final now = DateTime.now();
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    // DateTime weekday is 1-7 where 1 is Monday, so subtract 1 for zero-indexed array
    return days[now.weekday - 1];
  }
  
  // Save mood for today
  Future<void> _saveMood(int moodIndex) async {
    final today = _getCurrentDayName();
    setState(() {
      _selectedMoodIndex = moodIndex;
      weeklyMoods[today] = moodIndex;
    });
    
    // Save to Hive
    await moodBox.put('weekly_moods', weeklyMoods);
  }

  Future<void> _fetchData() async {
    try {
      // Fetch screen time
      final screenTimeData = await platform.invokeMethod<Map>('getScreenTimeData');
      final totalUsageTime = screenTimeData?['totalUsageTime'] ?? 0;
      setState(() {
        _screenTime = '${totalUsageTime}m';
      });

      // Fetch unlock count
      final unlockCountData = await platform.invokeMethod<Map>('getPhoneUnlockCount');
      final totalUnlocks = unlockCountData?['totalUnlocks'] ?? 0;
      setState(() {
        _unlockCount = '$totalUnlocks';
      });

      // Fetch most used app
      final appUsage = screenTimeData?['appUsage'] as List<dynamic>? ?? [];
      if (appUsage.isNotEmpty) {
        final mostUsedApp = appUsage.first['appName'] ?? 'Unknown';
        setState(() {
          _mostUsedApp = mostUsedApp;
        });
      } else {
        setState(() {
          _mostUsedApp = 'No data';
        });
      }
    } catch (e) {
      setState(() {
        _screenTime = 'Error';
        _unlockCount = 'Error';
        _mostUsedApp = 'Error';
      });
    }
  }

  bool _isExpanded = false;
  final double _collapsedHeight = 300;
  final double _expandedHeight = 400;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  // Widget for emoji button with selection indicator and feedback
  Widget _moodEmojiButton(int index, String imagePath) {
    final isSelected = _selectedMoodIndex == index;
    
    return GestureDetector(
      onTap: () {
        // Add haptic feedback
        HapticFeedback.mediumImpact();
        
        // Save mood
        _saveMood(index);
        
        // Show feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mood updated!'),
            duration: Duration(seconds: 1),
            backgroundColor: Color.fromARGB(255, 255, 100, 0),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      child: TweenAnimationBuilder(
        duration: Duration(milliseconds: isSelected ? 300 : 0),
        tween: Tween<double>(begin: 1.0, end: isSelected ? 1.2 : 1.0),
        builder: (context, double scale, child) {
          return Transform.scale(
            scale: scale,
            child: Container(
              width: 60,
              height: 60,
              decoration: isSelected 
                ? BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(30),
                  )
                : null,
              child: Padding(
                padding: isSelected ? const EdgeInsets.all(3.0) : EdgeInsets.zero,
                child: Image.asset(imagePath),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: Color.fromARGB(192, 255, 64, 0),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(45),
                  bottomRight: Radius.circular(45),
                ),
              ),
              height: _isExpanded ? _expandedHeight : _collapsedHeight,
              width: double.infinity,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Section
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Text(
                            'Welcome,',
                            style: TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
                            ),
                          ),
                          Spacer(),
                          IconButton(
                            icon: Icon(Icons.menu, color: Color(0xFFFFFFFF)),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      Text(
                        'Select Today\'s Mood',
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Inter',
                        ),
                      ),
                      // First row of Emojis
                      SizedBox(height: 25),
                      Row(
                        children: [
                          SizedBox(width: 10),
                          _moodEmojiButton(1, 'lib/icons/1.png'), // Happy emoji
                          SizedBox(width: 20),
                          _moodEmojiButton(2, 'lib/icons/2.png'), // Sad emoji
                          SizedBox(width: 20),
                          _moodEmojiButton(3, 'lib/icons/3.png'), // Angry emoji
                          SizedBox(width: 20),
                          _moodEmojiButton(4, 'lib/icons/4.png'), // Anxious emoji
                        ],
                      ),
                      // Second row of Emojis - Only visible when expanded
                      AnimatedOpacity(
                        opacity: _isExpanded ? 1.0 : 0.0,
                        duration: Duration(milliseconds: 300),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          height: _isExpanded ? 80 : 0,
                          child:
                              _isExpanded
                                  ? Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: Row(
                                      children: [
                                        SizedBox(width: 10),
                                        _moodEmojiButton(5, 'lib/icons/5.png'), // Sleepy emoji
                                        SizedBox(width: 20),
                                        _moodEmojiButton(6, 'lib/icons/6.png'), // Awkward emoji
                                        SizedBox(width: 20),
                                        _moodEmojiButton(7, 'lib/icons/7.png'), // Disappointed emoji
                                        SizedBox(width: 20),
                                        _moodEmojiButton(8, 'lib/icons/8.png'), // Another emoji
                                      ],
                                    ),
                                  )
                                  : SizedBox(),
                        ),
                      ),
                      Spacer(),
                      // Expand/collapse button
                      GestureDetector(
                        onTap: _toggleExpanded,
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: 120,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'How Was Your Day?',
                      style: TextStyle(
                        color: Color(0xFF000000),
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    width: 720,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(168, 254, 140, 0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.add, color: Colors.white),
                          // You can add more widgets here if needed in the future.
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(118, 255, 140, 0),
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        child: Center(
                          child: Text(
                            'Feeling Good',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        width: 90,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(118, 255, 140, 0),
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        child: Center(
                          child: Text(
                            'Not Bad',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        width: 90,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(118, 255, 140, 0),
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        child: Center(
                          child: Text(
                            'It\'s Okay',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    //Screen Time Card
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/screen-time');
                      },
                      child: Container(
                        width: 135,
                        height: 111,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(168, 254, 140, 0),
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  'Screen Time',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  _screenTime,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 29,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 40),
                    // Unlock Count Card
                      GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/unlock-count');
                      },
                      child: Container(
                        width: 135,
                        height: 111,
                        decoration: BoxDecoration(
                        color: Color.fromARGB(168, 254, 140, 0),
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                            'Unlock Count',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Inter',
                            ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                            _unlockCount,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 29,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
                            ),
                            ),
                          ),
                          ],
                        ),
                        
                        ),
                      ),
                      )
                    ],
                  )
                  
                ],
              ),
              
            ),

            //MOST USED APPS
            SizedBox(height: 5),
                  Container(
                    height: 120,
                    width: 340,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(168, 254, 140, 0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  'Most used apps',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Align(alignment: Alignment.center,
                                child: Text(
                                  _mostUsedApp,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                ),
                              ),
                            ],
                          ),
                    ),
                  ),
            SizedBox(height: 20),
            // Weekly Mood Board
                  Container(
                    height: 200,
                    width: 340,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(168, 254, 140, 0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  'Weekly Mood Board',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                            ],
                          ),
                    ),
                  ),
            SizedBox(height: 20),
                  Container(
                    height: 220,
                    width: 340,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(168, 254, 140, 0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  'Mental Health Suggestions and Tips',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                              Container(
                              decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              child: Column(
                              children:[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                child: Align(alignment: Alignment.center,
                                child: Text(
                                  'Identify stress triggers and address them one at a time.',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                child: Align(alignment: Alignment.center,
                                child: Text(
                                  'Practice mindfulness or meditation for 10 minutes daily',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                child: Align(alignment: Alignment.center,
                                child: Text(
                                  'Talk to someone you trust about how you feel.',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                ),
                              ),
                              ],
                              ),
                              ),                           
                            ],
                          ),
                    ),
                  ),      
                SizedBox(height: 20),
                // Weekly Mood Board
                SizedBox(height: 20),
                Container(
                  height: 270,
                  width: 340,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(168, 254, 140, 0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weekly Mood Board',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Inter',
                          ),
                        ),
                        SizedBox(height: 20),
                        Expanded(
                          child: _buildMoodChart(),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildDayMoodColumn('Mon', weeklyMoods['Monday'] ?? 0),
                            _buildDayMoodColumn('Tue', weeklyMoods['Tuesday'] ?? 0),
                            _buildDayMoodColumn('Wed', weeklyMoods['Wednesday'] ?? 0),
                            _buildDayMoodColumn('Thu', weeklyMoods['Thursday'] ?? 0),
                            _buildDayMoodColumn('Fri', weeklyMoods['Friday'] ?? 0),
                            _buildDayMoodColumn('Sat', weeklyMoods['Saturday'] ?? 0),
                            _buildDayMoodColumn('Sun', weeklyMoods['Sunday'] ?? 0),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
        ),
      );
    }
  
  // Helper method to build a day column with mood indicator
  Widget _buildDayMoodColumn(String day, int moodIndex) {
    String imagePath = moodIndex > 0 && moodIndex <= 8 
        ? 'lib/icons/$moodIndex.png' 
        : 'lib/icons/empty.png';
    
    return Column(
      children: [
        Text(
          day,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: 40,
          height: 40,
          child: moodIndex > 0 
              ? Image.asset(imagePath)
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.white54,
                    shape: BoxShape.circle,
                  ),
                ),
        ),
      ],
    );
  }

  // Add this method to your class
  Widget _buildMoodChart() {
    // List of weekdays in order
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    // Generate data points for the chart
    List<FlSpot> spots = [];
    for (int i = 0; i < days.length; i++) {
      final moodValue = weeklyMoods[days[i]] ?? 0;
      if (moodValue > 0) {
        // Only add spots for days that have mood data
        spots.add(FlSpot(i.toDouble(), moodValue.toDouble()));
      }
    }
    
    return LineChart(
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
                if (value < 0 || value >= days.length) {
                  return const Text('');
                }
                
                // Use abbreviated day names
                final abbreviations = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    abbreviations[value.toInt()],
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 8,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.white,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 6,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: Color.fromARGB(255, 255, 64, 0),
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Color.fromARGB(100, 255, 255, 255),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
 
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final dayName = days[spot.x.toInt()];
                final moodIndex = spot.y.toInt();
                
                // Map mood index to descriptive text
                String moodText = 'Unknown';
                switch(moodIndex) {
                  case 1: moodText = 'Happy'; break;
                  case 2: moodText = 'Sad'; break;
                  case 3: moodText = 'Angry'; break;
                  case 4: moodText = 'Anxious'; break;
                  case 5: moodText = 'Sleepy'; break;
                  case 6: moodText = 'Awkward'; break;
                  case 7: moodText = 'Disappointed'; break;
                  case 8: moodText = 'Content'; break;
                }
                
                return LineTooltipItem(
                  '$dayName: $moodText',
                  TextStyle(color: Colors.black),
                );
              }).toList();
            }
          ),
        ),
      ),
    );
  }
}