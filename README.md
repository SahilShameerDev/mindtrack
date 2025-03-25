# MindTrack

MindTrack is a Flutter-based mobile application designed to help users monitor their mental health and daily habits. It provides features such as mood tracking, screen time monitoring, phone unlock count analysis, and personalized mental health tips.

---

## Project Summary

MindTrack aims to promote mindfulness and mental well-being by enabling users to:
- Track their daily mood and emotions.
- Monitor their screen time and app usage.
- Analyze phone unlock patterns.
- Receive mental health tips and suggestions.

---

## Implementation Details

### Software Requirements
- **Flutter SDK**: Version 3.0 or higher
- **Dart**: Version 2.17 or higher
- **Hive**: For local data storage
- **Android Studio**: For Android development and testing
- **Xcode**: For iOS development and testing (optional)

### Hardware Requirements
- **Device**: Android device with API level 21 (Lollipop) or higher
- **Memory**: Minimum 2GB RAM
- **Storage**: Minimum 50MB free space

### Algorithms Used
1. **Mood Analysis**: Maps user-selected mood indices to visual charts for weekly trends.
2. **Screen Time Calculation**: Aggregates app usage data using Android's `UsageStatsManager`.
3. **Unlock Count Analysis**: Tracks phone unlock events and calculates hourly patterns.

---

## Results and Testing

### Code Snippets
#### Example: Saving Mood Data
```dart
Future<void> _saveMood(int moodIndex) async {
  final today = _getCurrentDayName();
  setState(() {
    _selectedMoodIndex = moodIndex;
    weeklyMoods[today] = moodIndex;
  });
  await moodBox.put('weekly_moods', weeklyMoods);
}
```

#### Example: Fetching Screen Time Data
```kotlin
private fun getScreenTimeData(): HashMap<String, Any> {
    val result = HashMap<String, Any>()
    val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
    val stats = usageStatsManager.queryUsageStats(
        UsageStatsManager.INTERVAL_DAILY, startTime, endTime
    )
    // Process stats and calculate total usage time
    result["totalUsageTime"] = totalMinutes
    return result
}
```

---

### Test Cases

| Test Case ID | Test Scenario                  | Test Steps                                                                 | Expected Result                                                                 | Actual Result                                                                   | Status  |
|--------------|--------------------------------|---------------------------------------------------------------------------|--------------------------------------------------------------------------------|--------------------------------------------------------------------------------|---------|
| TC001        | Mood Selection Functionality   | 1. Open the app. <br> 2. Select a mood emoji. <br> 3. Save the mood.      | Mood is saved and displayed in the weekly mood chart.                          | Mood is saved and displayed correctly.                                          | Passed  |
| TC002        | Screen Time Data Fetch         | 1. Open the app. <br> 2. Navigate to the "Screen Time" page.              | Total screen time and app usage data are displayed.                            | Screen time and app usage data are displayed correctly.                         | Passed  |
| TC003        | Unlock Count Analysis          | 1. Open the app. <br> 2. Navigate to the "Unlock Count" page.             | Total unlock count and hourly breakdown are displayed.                         | Unlock count and hourly breakdown are displayed correctly.                      | Passed  |
| TC004        | Profile Update Functionality   | 1. Open the app. <br> 2. Navigate to the "Profile" page. <br> 3. Update profile details. | Profile details are updated and saved successfully.                            | Profile details are updated and saved correctly.                                | Passed  |
| TC005        | Error Handling for Permissions | 1. Deny usage stats permission. <br> 2. Try fetching screen time data.    | An error message is displayed, prompting the user to enable permissions.       | Error message is displayed, and user is prompted to enable permissions.         | Passed  |

---

## Conclusion

MindTrack has been thoroughly tested and performs as expected. It provides an intuitive interface for users to track their mental health and habits. Future enhancements may include:

- Advanced analytics and insights based on user data.
