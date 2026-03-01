import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/ai_model_service.dart';
import '../models/guidance_result.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraScreen extends StatefulWidget {
  final String photographerId;
  final String photographerName;
  final String category;

  const CameraScreen({
    super.key,
    required this.photographerId,
    required this.photographerName,
    required this.category,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isProcessing = false;
  GuidanceResult? _currentGuidance;
  String? category;

  //late final AIModelService _aiService = AIModelService(category);
  bool _isModelReady = false; // 모델 준비 상태
  AIModelService? _aiService; //
  bool _isLoading = true;
  String _loadingMessage = 'AI 모델 로딩 중...';

  @override
  void initState() {
    super.initState();
    category = widget.category;
    _aiService = AIModelService(category); // category 할당 후에 생성!
    _initializeAll();
  }

  Future<void> _initializeAll() async {
    try {
      await _requestCameraPermission();

      setState(() => _loadingMessage = 'AI 모델 로딩 중...');
      await _prepareService();   // 모델 로드 완전히 끝날 때까지 여기서 멈춤

      setState(() => _loadingMessage = '카메라 초기화 중...');
      await _initializeCamera(); // 카메라 초기화
    } catch (e) {
      debugPrint('초기화 실패: $e');
      if (mounted) Navigator.pop(context); // 실패하면 뒤로가기(튕김 방지) -> 이거 지우면 fuck된다 치연아
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 권한 요청 함수 추가
  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('카메라 권한이 필요합니다')),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _prepareService() async {
    // 모델 초기화
    await _aiService?.initializeModel();

    if (mounted) {
      setState(() {
        _isModelReady = true;
      });
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _cameraController!.initialize();

        await _cameraController!.setFlashMode(FlashMode.off);

        setState(() {
          _isInitialized = true;
        });

        // 실시간 프레임 분석 시작
        _startRealtimeAnalysis();
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  void _startRealtimeAnalysis() {
    // 실시간으로 프레임을 분석 -> 빠르게 하면 좀.. 겹치는듯..?
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && _isInitialized) {
        _analyzeFrame();
        _startRealtimeAnalysis();
      }
    });
  }

  Future<void> _analyzeFrame() async {
    if (_isProcessing || !_isInitialized || !_isModelReady) return;

    _isProcessing = true;

    try {
      // 현재 프레임 캡처
      final XFile image = await _cameraController!.takePicture();

      // 분석
      // with PyTorch 모델
      final guidance = await _aiService?.analyzeImage(
        imagePath: image.path,
        photographerId: widget.photographerId,
      );

      if (mounted) {
        setState(() {
          _currentGuidance = guidance;
        });
      }
    } catch (e) {
      debugPrint('Frame analysis error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 로딩 중일 때
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 20),
              Text(
                _loadingMessage,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: CameraPreview(
                _cameraController!
            ),
          ),

          // 상단 정보 바
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.photographerName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.category,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 가이드라인
          if (_currentGuidance != null)
            Positioned.fill(
              child: _GuidanceOverlay(guidance: _currentGuidance!),
            ),

          // 하단 가이드 정보
          if (_currentGuidance != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: _GuidanceInfoPanel(guidance: _currentGuidance!),
              ),
            ),
        ],
      ),
    );
  }
}

// 가이드라인 위젯
class _GuidanceOverlay extends StatelessWidget {
  final GuidanceResult guidance;

  const _GuidanceOverlay({required this.guidance});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GuidancePainter(guidance: guidance),
    );
  }
}

class GuidancePainter extends CustomPainter {
  final GuidanceResult guidance;

  GuidancePainter({required this.guidance});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // 그리드
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1;

    // 수평선
    canvas.drawLine(
      Offset(0, size.height / 3),
      Offset(size.width, size.height / 3),
      gridPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 2 / 3),
      Offset(size.width, size.height * 2 / 3),
      gridPaint,
    );

    // 수직선
    canvas.drawLine(
      Offset(size.width / 3, 0),
      Offset(size.width / 3, size.height),
      gridPaint,
    );
    canvas.drawLine(
      Offset(size.width * 2 / 3, 0),
      Offset(size.width * 2 / 3, size.height),
      gridPaint,
    );

    // 중심 가이드
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    canvas.drawCircle(
      Offset(centerX, centerY),
      10,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 하단 가이드 정보
class _GuidanceInfoPanel extends StatelessWidget {
  final GuidanceResult guidance;

  const _GuidanceInfoPanel({required this.guidance});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 미학 점수
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 24),
              const SizedBox(width: 8),
              Text(
                '미학 점수: ${guidance.aestheticScore.toStringAsFixed(1)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 가이드 정보
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _GuidanceIndicator(
                icon: Icons.swap_horiz,
                label: '좌우',
                value: guidance.horizontalMove,
              ),
              _GuidanceIndicator(
                icon: Icons.swap_vert,
                label: '상하',
                value: guidance.verticalMove,
              ),
              _GuidanceIndicator(
                icon: Icons.zoom_in,
                label: '거리',
                value: guidance.depthMove,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _GuidanceIndicator(
                icon: Icons.rotate_right,
                label: '기울기',
                value: guidance.tilt,
              ),
              _GuidanceIndicator(
                icon: Icons.horizontal_rule,
                label: '수평',
                value: guidance.horizontal,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GuidanceIndicator extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;

  const _GuidanceIndicator({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final color = value.abs() < 0.1 ? Colors.green : Colors.orange;
    final arrow;

    if (label == '좌우') {
      arrow = value > 0.1 ? '→' : value < -0.1 ? '←' : '✓';
    } else if (label == '상하') {
      arrow = value > 0.1 ? '↑' : value < -0.1 ? '↓' : '✓';
    } else if (label == '거리') {
      arrow = value > 0.1 ? '↑' : value < -0.1 ? '↓' : '✓';
    } else if (label == '기울기') {
      arrow = value > 0.1 ? '↺' : value < -0.1 ? '↻' : '✓';
    } else {
      arrow = value > 0.1 ? '↺' : value < -0.1 ? '↻' : '✓';
    }


    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        Text(
          arrow,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}