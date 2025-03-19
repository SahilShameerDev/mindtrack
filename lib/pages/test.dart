import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(ScreenTimeTrackerApp());
}

class ScreenTimeTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Screen Time Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: ScreenTimeTrackerHomePage(),
    );
  }
}

class ScreenTimeTrackerHomePage extends StatefulWidget {
  @override
  _ScreenTimeTrackerHomePageState createState() => _ScreenTimeTrackerHomePageState();
}

class _ScreenTimeTrackerHomePageState extends State<ScreenTimeTrackerHomePage> with SingleTickerProviderStateMixin {
  static const platform = MethodChannel('com.example.screen_time_tracker/screen_time');
  
  Map<String, dynamic> _screenTimeData = {};
  Map<String, dynamic> _unlockData = {};
  bool _isLoading = false;
  bool _hasPermission = false;
  String _errorMessage = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkPermission();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final bool hasPermission = await platform.invokeMethod('checkUsageStatsPermission');
      
      setState(() {
        _hasPermission = hasPermission;
        _isLoading = false;
      });
      
      if (hasPermission) {
        _fetchScreenTimeData();
        _fetchUnlockData();
      }
    } on PlatformException catch (e) {
      setState(() {
        _errorMessage = 'Error checking permission: ${e.message}';
        _isLoading = false;
      });
    }
  }

  Future<void> _requestPermission() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await platform.invokeMethod('requestUsageStatsPermission');
      // We don't get a result right away as the user needs to interact with the system UI
      // Wait a bit then check permission again
      await Future.delayed(Duration(seconds: 1));
      _checkPermission();
    } on PlatformException catch (e) {
      setState(() {
        _errorMessage = 'Error requesting permission: ${e.message}';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchScreenTimeData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Fixed: Properly cast the result
      final result = await platform.invokeMethod('getScreenTimeData');
      
      final Map<String, dynamic> screenTimeData = {};
      
      // Manually convert and cast each value
      screenTimeData['totalUsageTime'] = result['totalUsageTime'] as int;
      
      final List<Map<String, dynamic>> appUsageList = [];
      final List<dynamic> rawAppUsage = result['appUsage'] as List<dynamic>;
      
      for (final app in rawAppUsage) {
        appUsageList.add({
          'packageName': app['packageName'] as String,
          'appName': app['appName'].toString(),
          'usageTime': app['usageTime'] as int,
        });
      }
      
      screenTimeData['appUsage'] = appUsageList;
      
      setState(() {
        _screenTimeData = screenTimeData;
        _isLoading = false;
      });
    } on PlatformException catch (e) {
      setState(() {
        _errorMessage = 'Error fetching data: ${e.message}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUnlockData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final result = await platform.invokeMethod('getPhoneUnlockCount');
      
      final Map<String, dynamic> unlockData = {};
      
      // Manually convert and cast each value
      unlockData['totalUnlocks'] = result['totalUnlocks'] as int;
      
      final List<Map<String, dynamic>> hourlyUnlocksList = [];
      final List<dynamic> rawHourlyUnlocks = result['hourlyUnlocks'] as List<dynamic>;
      
      for (final hourData in rawHourlyUnlocks) {
        hourlyUnlocksList.add({
          'hour': hourData['hour'] as int,
          'count': hourData['count'] as int,
        });
      }
      
      unlockData['hourlyUnlocks'] = hourlyUnlocksList;
      
      setState(() {
        _unlockData = unlockData;
        _isLoading = false;
      });
    } on PlatformException catch (e) {
      setState(() {
        _errorMessage = 'Error fetching unlock data: ${e.message}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _fetchScreenTimeData();
    await _fetchUnlockData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Screen Time Tracker'),
        bottom: _hasPermission && _errorMessage.isEmpty
          ? TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'Screen Time', icon: Icon(Icons.access_time)),
                Tab(text: 'Phone Unlocks', icon: Icon(Icons.lock_open)),
              ],
            )
          : null,
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : !_hasPermission
          ? _buildPermissionRequest()
          : _errorMessage.isNotEmpty
            ? Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red)))
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildScreenTimeList(),
                  _buildUnlockStats(),
                ],
              ),
      floatingActionButton: _hasPermission ? FloatingActionButton(
        onPressed: _refreshData,
        tooltip: 'Refresh',
        child: Icon(Icons.refresh),
      ) : null,
    );
  }

  Widget _buildPermissionRequest() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'Permission Required',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'This app needs access to usage stats to track screen time. On the next screen:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('1. Find this app in the list'),
                Text('2. Toggle the permission to "Allow"'),
                Text('3. For Xiaomi/MI phones, you may need to enable "Show more" to see all apps'),
                Text('4. Return to this app after granting permission'),
              ],
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _requestPermission,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text('Grant Permission', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenTimeList() {
    if (_screenTimeData.isEmpty) {
      return Center(child: Text('No screen time data available'));
    }

    final totalUsageTime = _screenTimeData['totalUsageTime'] ?? 0;
    final appUsageList = _screenTimeData['appUsage'] as List<dynamic>? ?? [];
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Total Screen Time Today',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _formatDuration(totalUsageTime),
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (appUsageList.isEmpty)
          Expanded(
            child: Center(
              child: Text('No app usage data available. Please try refreshing.'),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: appUsageList.length,
              itemBuilder: (context, index) {
                final app = appUsageList[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(app['appName'].toString()[0], style: TextStyle(color: Colors.white)),
                  ),
                  title: Text(app['appName'].toString()),
                  subtitle: Text(app['packageName'].toString()),
                  trailing: Text(_formatDuration(app['usageTime'] as int)),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildUnlockStats() {
    if (_unlockData.isEmpty) {
      return Center(child: Text('No unlock data available'));
    }

    final totalUnlocks = _unlockData['totalUnlocks'] ?? 0;
    final hourlyUnlocks = _unlockData['hourlyUnlocks'] as List<dynamic>? ?? [];
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Total Phone Unlocks Today',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '$totalUnlocks times',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (hourlyUnlocks.isEmpty)
          Expanded(
            child: Center(
              child: Text('No hourly unlock data available. Please try refreshing.'),
            ),
          )
        else
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hourly Unlock Pattern',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: _buildUnlockChart(hourlyUnlocks),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUnlockChart(List<dynamic> hourlyUnlocks) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _calculateMaxUnlocks(hourlyUnlocks),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final hour = hourlyUnlocks[groupIndex]['hour'] as int;
              final count = hourlyUnlocks[groupIndex]['count'] as int;
              String timeLabel = _formatHourLabel(hour);
              return BarTooltipItem(
                '$timeLabel\n$count unlocks',
                TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: SideTitles(
            showTitles: true,
            getTextStyles: (context, value) => TextStyle(
              color: Colors.black,
              fontSize: 10,
            ),
            margin: 10,
            getTitles: (double value) {
              final hour = hourlyUnlocks[value.toInt()]['hour'] as int;
              // Show only every 3 hours to avoid overcrowding
              if (hour % 3 == 0) {
                return _formatHourLabel(hour);
              }
              return ''; 
            },
          ),
          leftTitles: SideTitles(
            showTitles: true,
            getTextStyles: (context, value) => TextStyle(
              color: Colors.black,
              fontSize: 10,
            ),
            margin: 10,
            reservedSize: 30,
            getTitles: (value) {
              if (value == 0) return '0';
              if (value % 1 == 0) return value.toInt().toString();
              return '';
            },
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.black12, width: 1),
        ),
        barGroups: hourlyUnlocks.asMap().entries.map((entry) {
          final index = entry.key;
          final hourData = entry.value;
          final hour = hourData['hour'] as int;
          final count = hourData['count'] as int;
          
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                y: count.toDouble(),
                colors: [
                  // Color gradient based on time of day
                  _getColorForHour(hour),
                ],
                width: 12,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  double _calculateMaxUnlocks(List<dynamic> hourlyUnlocks) {
    double maxCount = 0.0;
    for (final hourData in hourlyUnlocks) {
      final count = hourData['count'] as int;
      if (count > maxCount) {
        maxCount = count.toDouble();
      }
    }
    // Add 20% padding to the max value
    return maxCount * 1.2;
  }

  Color _getColorForHour(int hour) {
    // Morning (6-11): Blue
    if (hour >= 6 && hour < 12) {
      return Colors.blue;
    }
    // Afternoon (12-17): Green
    else if (hour >= 12 && hour < 18) {
      return Colors.green;
    }
    // Evening (18-23): Orange
    else if (hour >= 18 && hour < 24) {
      return Colors.orange;
    }
    // Night (0-5): Purple
    else {
      return Colors.purple;
    }
  }

  String _formatHourLabel(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour $period';
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${remainingMinutes}m';
    } else {
      return '${remainingMinutes}m';
    }
  }
}