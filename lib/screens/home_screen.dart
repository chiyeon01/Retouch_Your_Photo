import 'package:flutter/material.dart';
import 'photographer_selection_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111318),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'RETOUCH',
          style: TextStyle(
            color: Color(0xFF8A9BB5),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 4.0,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              const Text(
                '어떤 사진을\n찍으시겠어요?',
                style: TextStyle(
                  color: Color(0xFFDDE3EE),
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  height: 1.35,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 2,
                color: const Color(0xFF3D6B9E),
              ),
              const SizedBox(height: 52),
              _CategoryCard(
                title: '음식',
                subtitle: 'Food Photography',
                icon: Icons.restaurant_rounded,
                accentColor: const Color(0xFF2E5F8A),
                highlightColor: const Color(0xFF4A8CC4),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PhotographerSelectionScreen(
                        category: '음식',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _CategoryCard(
                title: '사람',
                subtitle: 'Portrait Photography',
                icon: Icons.person_rounded,
                accentColor: const Color(0xFF1F3A52),
                highlightColor: const Color(0xFF3A6B8F),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PhotographerSelectionScreen(
                        category: '사람',
                      ),
                    ),
                  );
                },
              ),
              const Spacer(),
              Center(
                child: Text(
                  'Powered by AI Retouching',
                  style: TextStyle(
                    color: const Color(0xFF8A9BB5).withOpacity(0.4),
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color highlightColor;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.highlightColor,
    required this.onTap,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.975 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedSlide(
          offset: _isPressed ? const Offset(0, 0.008) : Offset.zero,
          duration: const Duration(milliseconds: 100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            decoration: BoxDecoration(
              color: _isPressed
                  ? const Color(0xFF141820)
                  : const Color(0xFF1E2535),
              border: Border.all(
                color: _isPressed
                    ? widget.highlightColor.withOpacity(0.4)
                    : const Color(0xFF2E3D55),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(16),
              gradient: _isPressed
                  ? null
                  : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF242C3E),
                  const Color(0xFF181D27),
                ],
              ),
              boxShadow: _isPressed
                  ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
                  : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: widget.accentColor.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: const Color(0xFF2A3547).withOpacity(0.6),
                  blurRadius: 1,
                  offset: const Offset(0, -1),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: widget.accentColor.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.highlightColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Color(0xFFDDE3EE),
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          color: Color(0xFF5A6B82),
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: const Color(0xFF3A5070),
                  size: 16,
                ),
              ],
            ),
          ),
        ), // AnimatedContainer
      ), // AnimatedSlide
    );
  }
}