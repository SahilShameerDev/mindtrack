import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(ScreenTimeTrackerApp());
}

class ScreenTimeTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Screen Time Tracker',
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

class _ScreenTimeTrackerHomePageState extends State<ScreenTimeTrackerHomePage> {
  static const platform = MethodChannel('com.example.screen_time_tracker/screen_time');
  
  Map<String, dynamic> _screenTimeData = {};
  bool _isLoading = false;
  bool _hasPermission = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkPermission();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Screen Time Tracker'),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : !_hasPermission
          ? _buildPermissionRequest()
          : _errorMessage.isNotEmpty
            ? Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red)))
            : _buildScreenTimeList(),
      floatingActionButton: _hasPermission ? FloatingActionButton(
        onPressed: _fetchScreenTimeData,
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