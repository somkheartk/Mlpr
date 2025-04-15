import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        textTheme:
            GoogleFonts.kanitTextTheme(), // Set Kanit as the default font
      ),
      home: SettingsScreen(),
    ),
  );
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ตั้งค่า', style: GoogleFonts.kanit()),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Text(
                'เมนู',
                style: GoogleFonts.kanit(fontSize: 24.0, color: Colors.white),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('หน้าหลัก', style: GoogleFonts.kanit()),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/home');
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('ตั้งค่า', style: GoogleFonts.kanit()),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.language),
            title: Text('เปลี่ยนภาษา', style: GoogleFonts.kanit()),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LanguageSettingsScreen(),
                ),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('การแจ้งเตือน', style: GoogleFonts.kanit()),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationSettingsScreen(),
                ),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('ความเป็นส่วนตัว', style: GoogleFonts.kanit()),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrivacySettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class LanguageSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เปลี่ยนภาษา', style: GoogleFonts.kanit()),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Text(
          'หน้าการตั้งค่าภาษา',
          style: GoogleFonts.kanit(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class PrivacySettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ความเป็นส่วนตัว', style: GoogleFonts.kanit()),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Text(
          'หน้าการตั้งค่าความเป็นส่วนตัว',
          style: GoogleFonts.kanit(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class NotificationSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('การแจ้งเตือน', style: GoogleFonts.kanit()),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Text(
          'หน้าการตั้งค่าการแจ้งเตือน',
          style: GoogleFonts.kanit(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
