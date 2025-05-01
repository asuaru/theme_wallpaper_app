import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(ThemeWallpaperApp());
}

class ThemeWallpaperApp extends StatefulWidget {
  @override
  _ThemeWallpaperAppState createState() => _ThemeWallpaperAppState();
}

class _ThemeWallpaperAppState extends State<ThemeWallpaperApp> {
  String? lightWallpaperPath;
  String? darkWallpaperPath;

  @override
  void initState() {
    super.initState();
    _loadPaths();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.storage.request();
    await Permission.accessMediaLocation.request();
  }

  Future<void> _loadPaths() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      lightWallpaperPath = prefs.getString('light_wallpaper');
      darkWallpaperPath = prefs.getString('dark_wallpaper');
    });
  }

  Future<void> _pickWallpaper(bool isDark) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      String path = result.files.single.path!;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (isDark) {
        await prefs.setString('dark_wallpaper', path);
        darkWallpaperPath = path;
      } else {
        await prefs.setString('light_wallpaper', path);
        lightWallpaperPath = path;
      }
      setState(() {});
    }
  }

  Future<void> _applyWallpaper() async {
    final brightness = MediaQuery.of(context).platformBrightness;
    String? path = brightness == Brightness.dark ? darkWallpaperPath : lightWallpaperPath;

    if (path != null && File(path).existsSync()) {
      try {
        await WallpaperManagerFlutter().setwallpaperfromFile(File(path), WallpaperManagerFlutter.HOME_SCREEN);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Wallpaper applied")));
      } catch (e) {
        print("Error setting wallpaper: \$e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Theme Wallpaper App',
      themeMode: ThemeMode.system,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(title: Text("Theme Wallpaper App")),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () => _pickWallpaper(false),
                child: Text("Select Light Theme Wallpaper"),
              ),
              if (lightWallpaperPath != null) Text("Selected: \${lightWallpaperPath!.split('/').last}"),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _pickWallpaper(true),
                child: Text("Select Dark Theme Wallpaper"),
              ),
              if (darkWallpaperPath != null) Text("Selected: \${darkWallpaperPath!.split('/').last}"),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: _applyWallpaper,
                child: Text("Apply Based on Theme"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}