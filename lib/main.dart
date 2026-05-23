import 'package:flutter/material.dart';
import 'models/question.dart';
import 'models/tiku_loader.dart';
import 'pages/home_page.dart';
import 'pages/exam_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BaoanApp());
}

class BaoanApp extends StatelessWidget {
  const BaoanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '保安员题库',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1565C0),
        useMaterial3: true,
        fontFamily: 'PingFang',
      ),
      home: const LoadingPage(),
    );
  }
}

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final tiku = await TikuLoader.load();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(tiku: tiku),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载题库失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield,
                  size: 56,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '保安员考试题库',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '加载题库中...',
                style: TextStyle(color: Colors.white.withAlpha(200)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
