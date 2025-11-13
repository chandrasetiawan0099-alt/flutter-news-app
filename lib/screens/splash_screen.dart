import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'news_list_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    // Prefer status bar light content on splash for a modern look (optional)
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent));

    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));

    _scale = Tween<double>(begin: 0.75, end: 1.05).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.0, 0.85, curve: Curves.easeOutCubic)),
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.15, 1.0, curve: Curves.easeIn)),
    );

    _ctrl.forward();

    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // small pause for polish then navigate
        Future.delayed(const Duration(milliseconds: 250), () {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const NewsListScreen()),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Modern minimal background
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, child) {
            return Transform.scale(
              scale: _scale.value,
              child: Opacity(
                opacity: _opacity.value,
                child: child,
              ),
            );
          },
          child: Container(
            // container gives a subtle rounded card look to the logo
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Image.asset(
              'assets/image/logo.png',
              width: 140,
              height: 140,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
