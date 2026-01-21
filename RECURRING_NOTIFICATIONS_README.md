# Recurring Task Notifications - Configuration Guide

To ensure recurring task notifications work properly, please configure the following settings in Xcode:

## 1. Enable Background Processing

1. Select the Cloudo target in Xcode
2. Go to the "Signing & Capabilities" tab
3. Click "+ Capability" and add "Background Modes"
4. Check the box for "Background Processing"
5. Check the box for "Background Fetch"

## 2. Update Info.plist (if needed manually)

If the background modes are not appearing in your built app, you may need to manually add the following to Info.plist:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>processing</string>
</array>
```

## 3. Testing Recurring Notifications

To test recurring notifications:
1. Create a task with a reminder set a few minutes in the future
2. Enable one of the recurrence options
3. Wait for the notification to fire or complete the task manually
4. The app should automatically schedule the next occurrence

## 4. Troubleshooting

If recurring notifications are not working:
1. Check that you have granted notification permissions to the app
2. Ensure the app has background processing capabilities enabled
3. Try restarting the app after enabling these capabilities
4. Check the device's notification settings for the app

The recurring notification system now:
- Uses direct date triggers instead of repeating calendar triggers
- Properly reschedules notifications when tasks are completed
- Catches up on missed notifications when the app launches or comes to the foreground
- Uses background processing to update recurring tasks even when the app is not active 