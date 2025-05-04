import 'package:flutter/material.dart';

void main() => runApp(MoodTunesApp());

class MoodTunesApp extends StatefulWidget {
  const MoodTunesApp({super.key});

  @override
  State<MoodTunesApp> createState() => _MoodTunesAppState();
}

class _MoodTunesAppState extends State<MoodTunesApp> {
  bool isDark = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoodTunes',
      debugShowCheckedModeBanner: false,
      theme: isDark ? ThemeData.dark() : ThemeData.light(),
      home: SplashScreen(onThemeToggle: () {
        setState(() {
          isDark = !isDark;
        });
      }),
    );
  }
}

Route fadeTransition(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
  );
}

class SplashScreen extends StatelessWidget {
  final VoidCallback onThemeToggle;
  const SplashScreen({super.key, required this.onThemeToggle});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(fadeTransition(HomeScreen(onThemeToggle: onThemeToggle)));
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.graphic_eq, size: 80, color: Colors.white),
              SizedBox(height: 20),
              Text('MoodTunes', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              Text('Feel the music. Match your mood.', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}

class MoodRecord {
  final String mood;
  final DateTime time;
  MoodRecord(this.mood, this.time);
}

List<MoodRecord> moodHistory = [];

class HomeScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  const HomeScreen({super.key, required this.onThemeToggle});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController moodController = TextEditingController();
  bool musicOn = true;

  String getPlaylist(String mood) {
    final lower = mood.toLowerCase();
    if (lower.contains("happy")) return "Happy Vibes Playlist";
    if (lower.contains("sad")) return "Chill & Cry Playlist";
    if (lower.contains("relaxed")) return "Lo-Fi Chill Beats";
    if (lower.contains("angry")) return "Rock Rage Mix";
    return "Daily Mood Mix";
  }

  void showVisualizer() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Visualizer"),
        content: SizedBox(
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              10,
              (i) => AnimatedBar(),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Close"))
        ],
      ),
    );
  }

  void submitMood(String mood) {
    moodHistory.add(MoodRecord(mood, DateTime.now()));
    final playlist = getPlaylist(mood);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Your Mood: $mood"),
        content: Text("Suggested Playlist: $playlist"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          )
        ],
      ),
    );

    showVisualizer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MoodTunes"),
        actions: [
          IconButton(
            icon: Icon(musicOn ? Icons.music_note : Icons.music_off),
            onPressed: () {
              setState(() {
                musicOn = !musicOn;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Background music ${musicOn ? 'enabled' : 'disabled'}"),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, fadeTransition(SettingsScreen(onThemeToggle: widget.onThemeToggle)));
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.purple.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What’s your mood today?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
            SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: [
                EmojiButton(label: "Happy", emoji: "😊", onTap: () => submitMood("Happy")),
                EmojiButton(label: "Sad", emoji: "😢", onTap: () => submitMood("Sad")),
                EmojiButton(label: "Angry", emoji: "😠", onTap: () => submitMood("Angry")),
                EmojiButton(label: "Relaxed", emoji: "😌", onTap: () => submitMood("Relaxed")),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: moodController,
              decoration: InputDecoration(
                hintText: "e.g. happy, sad, relaxed",
                prefixIcon: Icon(Icons.emoji_emotions),
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.music_note),
              label: Text("Get Playlist"),
              onPressed: () {
                final mood = moodController.text.trim();
                if (mood.isNotEmpty) {
                  submitMood(mood);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            Spacer(),
            Center(
              child: TextButton.icon(
                icon: Icon(Icons.history, color: Colors.white70),
                label: Text("View Mood History", style: TextStyle(color: Colors.white70)),
                onPressed: () => Navigator.push(context, fadeTransition(MoodHistoryScreen())),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class EmojiButton extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const EmojiButton({super.key, required this.emoji, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple,
        shape: StadiumBorder(),
      ),
      child: Text('$emoji $label'),
    );
  }
}

class AnimatedBar extends StatefulWidget {
  const AnimatedBar({super.key});

  @override
  _AnimatedBarState createState() => _AnimatedBarState();
}

class _AnimatedBarState extends State<AnimatedBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _height;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 500))..repeat(reverse: true);
    _height = Tween<double>(begin: 10, end: 50).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _height,
      builder: (_, __) => Container(
        margin: EdgeInsets.symmetric(horizontal: 2),
        width: 6,
        height: _height.value,
        color: Colors.white,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class MoodHistoryScreen extends StatelessWidget {
  const MoodHistoryScreen({super.key});

  String formatTime(DateTime dt) {
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} on ${dt.day}/${dt.month}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mood History"), backgroundColor: Colors.deepPurple),
      body: ListView.builder(
        itemCount: moodHistory.length,
        itemBuilder: (_, i) {
          final mood = moodHistory[i];
          return ListTile(
            leading: Icon(Icons.emoji_emotions_outlined, color: Colors.purple),
            title: Text("Mood: ${mood.mood}"),
            subtitle: Text("Time: ${formatTime(mood.time)}"),
          );
        },
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  const SettingsScreen({super.key, required this.onThemeToggle});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings & Profile"), backgroundColor: Colors.purple),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(radius: 40, child: Icon(Icons.person, size: 50)),
            SizedBox(height: 10),
            Text("Janani", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("janani@example.com", style: TextStyle(color: Colors.white60)),
            Divider(height: 40),
            SwitchListTile(
              title: Text("Dark Mode"),
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (_) => widget.onThemeToggle(),
              secondary: Icon(Icons.palette),
            ),
            SwitchListTile(
              title: Text("Notifications"),
              value: notificationsOn,
              onChanged: (val) => setState(() => notificationsOn = val),
              secondary: Icon(Icons.notifications),
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text("Edit Profile"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}