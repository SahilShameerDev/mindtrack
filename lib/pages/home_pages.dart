import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const platform = MethodChannel('com.example.screen_time_tracker/screen_time');

  String _screenTime = 'Loading...';
  String _unlockCount = 'Loading...';
  String _mostUsedApp = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchData();
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
                          Container(
                            width: 60,
                            height: 60,
                            child: Image.asset('lib/icons/1.png'), // Happy emoji
                          ),
                          SizedBox(width: 20),
                          Container(
                            width: 60,
                            height: 60,
                            child: Image.asset('lib/icons/2.png'), // Sad emoji
                          ),
                          SizedBox(width: 20),
                          Container(
                            width: 60,
                            height: 60,
                            child: Image.asset('lib/icons/3.png'), // Angry emoji
                          ),
                          SizedBox(width: 20),
                          Container(
                            width: 60,
                            height: 60,
                            child: Image.asset('lib/icons/4.png'), // Anxious emoji
                          ),
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
                                        Container(
                                          width: 60,
                                          height: 60,
                                          child: Image.asset('lib/icons/5.png'), // Sleepy emoji
                                        ),
                                        SizedBox(width: 20),
                                        Container(
                                          width: 60,
                                          height: 60,
                                          child: Image.asset('lib/icons/6.png'), // Awkward emoji
                                        ),
                                        SizedBox(width: 20),
                                        Container(
                                          width: 60,
                                          height: 60,
                                          child: Image.asset('lib/icons/7.png'), // Disappointed emoji
                                        ),
                                        SizedBox(width: 20),
                                        Container(
                                          width: 60,
                                          height: 60,
                                          child: Image.asset('lib/icons/8.png'), // Happy emoji
                                        ),
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
          ],
        ),
        ),
      );
    }
  }