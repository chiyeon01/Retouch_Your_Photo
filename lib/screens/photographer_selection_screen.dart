import 'package:flutter/material.dart';
import 'camera_screen.dart';

class PhotographerSelectionScreen extends StatelessWidget {
  final String category;

  const PhotographerSelectionScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final photographers = _getPhotographers(category);
    final isFood = category == '음식';

    return Scaffold(
      backgroundColor: const Color(0xFF111318),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF8A9BB5), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'SELECT',
          style: const TextStyle(
            color: Color(0xFF8A9BB5),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 4.0,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 배너
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1A3A5C),
                    const Color(0xFF0F2540),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF4A8CC4).withOpacity(0.4),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E4A7A).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A5F96).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF4A8CC4).withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      category == '음식' ? Icons.restaurant_rounded : Icons.person_rounded,
                      color: const Color(0xFF7AB8E8),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(
                          color: Color(0xFFDDE3EE),
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '포토그래퍼를 선택해주세요',
                        style: TextStyle(
                          color: Color(0xFF5A7A9A),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.82,
                ),
                itemCount: photographers.length,
                itemBuilder: (context, index) {
                  final photographer = photographers[index];
                  return _PhotographerCard(
                    photographer: photographer,
                    index: index,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CameraScreen(
                            photographerId: photographer.id,
                            photographerName: photographer.name,
                            category: category,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Photographer> _getPhotographers(String category) {
    if (category == '음식') {
      return [
        Photographer(id: 'Raquel_Carmona_Romero', name: 'Raquel_Carmona_Romero', imageUrl: ''),
        Photographer(id: 'Vladislav_Nosick', name: 'Vladislav_Nosick', imageUrl: ''),
        Photographer(id: 'Claudia_Totir', name: 'Claudia_Totir', imageUrl: ''),
        Photographer(id: 'Thai_Thu', name: 'Thai_Thu', imageUrl: ''),
      ];
    } else {
      return [
        Photographer(id: 'Berty_Mandagie', name: 'Berty_Mandagie', imageUrl: ''),
        Photographer(id: 'person_2', name: '정포트레이트', imageUrl: ''),
        Photographer(id: 'person_3', name: '윤프로필', imageUrl: ''),
        Photographer(id: 'person_4', name: '한스냅', imageUrl: ''),
      ];
    }
  }
}

class Photographer {
  final String id;
  final String name;
  final String imageUrl;

  Photographer({
    required this.id,
    required this.name,
    required this.imageUrl,
  });
}

class _PhotographerCard extends StatefulWidget {
  final Photographer photographer;
  final VoidCallback onTap;
  final int index;

  const _PhotographerCard({
    required this.photographer,
    required this.onTap,
    required this.index,
  });

  @override
  State<_PhotographerCard> createState() => _PhotographerCardState();
}

class _PhotographerCardState extends State<_PhotographerCard> {
  bool _isPressed = false;

  String _getInitials(String name) {
    final parts = name.split('_').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '?';
  }

  Color get _accentColor {
    final colors = [
      const Color(0xFF2E5F8A),
      const Color(0xFF1F4A6E),
      const Color(0xFF2A5578),
      const Color(0xFF243F5C),
    ];
    return colors[widget.index % colors.length];
  }

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
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: _isPressed
                ? null
                : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF232B3A),
                const Color(0xFF181D27),
              ],
            ),
            color: _isPressed ? const Color(0xFF141820) : null,
            border: Border.all(
              color: _isPressed
                  ? const Color(0xFF4A8CC4).withOpacity(0.4)
                  : const Color(0xFF2E3D55),
              width: 1,
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
                color: _accentColor.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 아바타
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _accentColor.withOpacity(0.5),
                    border: Border.all(
                      color: const Color(0xFF3A6B8F).withOpacity(0.6),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(widget.photographer.name),
                      style: const TextStyle(
                        color: Color(0xFF7AB8E8),
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // 이름
                Text(
                  widget.photographer.name.replaceAll('_', '\n'),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFCDD5E0),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 10),
                // 하단 구분선 + 선택 힌트
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 16,
                      height: 1,
                      color: const Color(0xFF3A5070),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'SELECT',
                      style: TextStyle(
                        color: Color(0xFF4A6A8A),
                        fontSize: 9,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 16,
                      height: 1,
                      color: const Color(0xFF3A5070),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}