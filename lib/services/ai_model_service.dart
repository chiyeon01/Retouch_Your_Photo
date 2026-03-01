import 'dart:io';
import 'package:image/image.dart' as img;
import '../models/guidance_result.dart';
import 'dart:typed_data';
import 'package:flutter_pytorch_lite/flutter_pytorch_lite.dart';
import 'package:flutter/services.dart';

class AIModelService {
  String category;
  AIModelService(
      category,
      ) : this.category = category;

  dynamic _model;
  dynamic _detection_model;
  dynamic _depth_estimator;

  // 모델 입력 크기
  static const int inputWidth = 640;
  static const int inputHeight = 640;

  // ImageNet 정규화 값 (일반적으로 많이 사용됨)
  static const List<double> mean = [0.485, 0.456, 0.406];
  static const List<double> std = [0.229, 0.224, 0.225];

  // Model 초기화할 때 개별 모델과 depth_map, YOLO V8 model도 초기화
  Future<void> initializeModel() async {
    // TODO: PyTorch 모델 로드
    try {
      if (category == '음식') {
        final filePath = '${Directory.systemTemp.path}/food_model.ptl';
        File(filePath).writeAsBytesSync(await _getBuffer('assets/models/food_model.ptl'));
        _model = await FlutterPytorchLite.load(filePath);
        print("PyTorch 모델 로드 완료!(음식)");
      } else {
        final filePath = '${Directory.systemTemp.path}/person_model.ptl';
        File(filePath).writeAsBytesSync(await _getBuffer('assets/models/person_model.ptl'));
        _model = await FlutterPytorchLite.load(filePath);
        print("PyTorch 모델 로드 완료!(사람)");
      }

      final detection_filePath = '${Directory.systemTemp.path}/detection_model.ptl';
      File(detection_filePath).writeAsBytesSync(await _getBuffer('assets/models/detection_model.ptl'));
      _detection_model = await FlutterPytorchLite.load(detection_filePath);
      print("Detection Model 로드 완료!");

      final depth_filePath = '${Directory.systemTemp.path}/depth_estimator.ptl';
      File(depth_filePath).writeAsBytesSync(await _getBuffer('assets/models/depth_estimator.ptl'));
      _depth_estimator = await FlutterPytorchLite.load(depth_filePath);
      print("Depth Estimator 로드 완료!");

    } catch (e) {
      print("모델 로드 실패: $e");
      rethrow;
    }
  }

  Future<GuidanceResult> analyzeImage({
    required String imagePath,
    required String photographerId,
  }) async {
    try {
      var photographerIdMap;

      if (category == "음식") {
        // photographer_id를 정수로 매핑
        photographerIdMap = {
          'Raquel_Carmona_Romero': 0,
          'Vladislav_Nosick': 1,
          'Claudia_Totir': 2,
          'Thai_Thu': 3,
        };
      } else {
        photographerIdMap = {
          "Berty_Mandagie": 0,
        };
      }

      final image = File(imagePath);
      final bytes = await image.readAsBytes();
      img.Image? decodedImage = img.decodeImage(bytes);

      if (decodedImage == null) {
        throw Exception('이미지를 디코딩할 수 없습니다');
      }

      // 640x640으로 리사이징
      decodedImage = _resizeAndCenterCrop(decodedImage, inputWidth, inputHeight);

      // 1. Detection 모델용 입력: 0-255 범위 (정규화 안 함)
      final detectionInput = _imageToDetectionTensor(decodedImage);
      final detectionTensor = IValue.from(
        Tensor.fromBlobFloat32(
            detectionInput,
            Int64List.fromList([1, 3, inputWidth, inputHeight])
        ),
      );

      // 2. Depth 모델용 입력: 0-1 범위 (ImageNet 정규화 안 함)
      final depthInput = _imageToDepthTensor(decodedImage);
      final depthTensor = IValue.from(
        Tensor.fromBlobFloat32(
            depthInput,
            Int64List.fromList([1, 3, inputWidth, inputHeight])
        ),
      );

      // 3. Main 모델용 입력: ImageNet 정규화
      final mainInput = _imageToNormalizedTensor(decodedImage);
      final mainTensor = IValue.from(
        Tensor.fromBlobFloat32(
            mainInput,
            Int64List.fromList([1, 3, inputWidth, inputHeight])
        ),
      );

      final photographerIdInt = photographerIdMap[photographerId] ?? 0;

      // Detection 실행 (0-255 입력)
      IValue detection_results = await _detection_model.forward([detectionTensor]);

      // Depth 실행 (0-1 입력) -> 출력은 이미 ImageNet 정규화됨
      IValue depth_output = await _depth_estimator.forward([depthTensor]);

      print("================depth_output==================");
      print(depth_output.toTensor().shape);

      var depthValues = depth_output.toTensor().dataAsFloat32List;
      double minVal = depthValues.reduce((a, b) => a < b ? a : b);
      double maxVal = depthValues.reduce((a, b) => a > b ? a : b);

      print("Min: $minVal");
      print("Max: $maxVal");

      print("================main_input (ImageNet normalized)==================");
      print(mainTensor.toTensor().shape);
      print("Sample values: ${mainTensor.toTensor().dataAsFloat32List.take(10).toList()}");

      print("================detection_results==================");
      print(detection_results.toTensor().shape);
      var detValues = detection_results.toTensor().dataAsFloat32List;
      print("Unique values: ${detValues.toSet().take(5).toList()}");
      print("Sum: ${detValues.reduce((a, b) => a + b)}");

      final photographerIdTensor = IValue.from(
        Tensor.fromBlobInt32(
            Int32List.fromList([photographerIdInt]),
            Int64List.fromList([1])
        ),
      );

      // Main 모델 실행: ImageNet 정규화된 이미지 + depth + detection
      final inputs = [mainTensor, depth_output, detection_results, photographerIdTensor];
      IValue output = await _model.forward(inputs);

      Tensor outputTensor = output.toTensor();
      var values = outputTensor.dataAsFloat32List;

      // values = [좌우이동, 위아래이동, 전진/후진, 기울기, 수평, 미학점수]
      return GuidanceResult(
        horizontalMove: values[0],
        verticalMove: values[1],
        depthMove: values[2],
        tilt: values[3],
        horizontal: values[4],
        aestheticScore: values[5],
      );
    } catch (e) {
      print('Error analyzing image: $e');
      rethrow;
    }
  }

  /// Get byte buffer
  static Future<Uint8List> _getBuffer(String assetFileName) async {
    ByteData rawAssetFile = await rootBundle.load(assetFileName);
    final rawBytes = rawAssetFile.buffer.asUint8List();
    return rawBytes;
  }

  /// 이미지를 비율 유지하며 리사이징 후 센터 크롭
  img.Image _resizeAndCenterCrop(img.Image image, int targetWidth, int targetHeight) {
    // 원본 이미지의 종횡비
    final aspectRatio = image.width / image.height;
    final targetAspectRatio = targetWidth / targetHeight;

    int newWidth, newHeight;

    if (aspectRatio > targetAspectRatio) {
      // 이미지가 더 넓음 → 높이 기준으로 리사이징
      newHeight = targetHeight;
      newWidth = (targetHeight * aspectRatio).round();
    } else {
      // 이미지가 더 높음 → 너비 기준으로 리사이징
      newWidth = targetWidth;
      newHeight = (targetWidth / aspectRatio).round();
    }

    // 리사이징
    final resized = img.copyResize(
      image,
      width: newWidth,
      height: newHeight,
      interpolation: img.Interpolation.linear,
    );

    // 센터 크롭
    final x = (newWidth - targetWidth) ~/ 2;
    final y = (newHeight - targetHeight) ~/ 2;

    return img.copyCrop(
      resized,
      x: x,
      y: y,
      width: targetWidth,
      height: targetHeight,
    );
  }

  /// Detection 모델용: 0-255 범위 (정규화 안 함)
  Float32List _imageToDetectionTensor(img.Image image) {
    final int channels = 3;
    final int imageSize = inputWidth * inputHeight;
    final tensorSize = channels * imageSize;
    final tensor = Float32List(tensorSize);

    for (int y = 0; y < inputHeight; y++) {
      for (int x = 0; x < inputWidth; x++) {
        final pixel = image.getPixel(x, y);

        // 0-255 범위 그대로 (정규화 안 함)
        final r = pixel.r.toDouble();
        final g = pixel.g.toDouble();
        final b = pixel.b.toDouble();

        // NCHW 포맷
        final index = y * inputWidth + x;
        tensor[index] = r;
        tensor[imageSize + index] = g;
        tensor[2 * imageSize + index] = b;
      }
    }

    return tensor;
  }

  /// Depth 모델용: 0-1 범위 (ImageNet 정규화 안 함)
  Float32List _imageToDepthTensor(img.Image image) {
    final int channels = 3;
    final int imageSize = inputWidth * inputHeight;
    final tensorSize = channels * imageSize;
    final tensor = Float32List(tensorSize);

    for (int y = 0; y < inputHeight; y++) {
      for (int x = 0; x < inputWidth; x++) {
        final pixel = image.getPixel(x, y);

        // 0-1 범위로 정규화 (ImageNet mean/std 적용 안 함)
        final r = pixel.r / 255.0;
        final g = pixel.g / 255.0;
        final b = pixel.b / 255.0;

        // NCHW 포맷
        final index = y * inputWidth + x;
        tensor[index] = r;
        tensor[imageSize + index] = g;
        tensor[2 * imageSize + index] = b;
      }
    }

    return tensor;
  }

  /// Main 모델용: ImageNet 정규화 적용
  /// 형식: [1, 3, 640, 640] (NCHW 포맷)
  Float32List _imageToNormalizedTensor(img.Image image) {
    final int channels = 3; // RGB
    final int imageSize = inputWidth * inputHeight;

    // 텐서 크기: 1(batch) × 3(channels) × 640(height) × 640(width)
    final tensorSize = channels * imageSize;
    final tensor = Float32List(tensorSize);

    // 픽셀 순회하며 정규화
    for (int y = 0; y < inputHeight; y++) {
      for (int x = 0; x < inputWidth; x++) {
        final pixel = image.getPixel(x, y);

        // RGB 값 추출 (0-255 범위)
        final r = pixel.r / 255.0;
        final g = pixel.g / 255.0;
        final b = pixel.b / 255.0;

        // ImageNet 정규화: (pixel - mean) / std
        final rNorm = (r - mean[0]) / std[0];
        final gNorm = (g - mean[1]) / std[1];
        final bNorm = (b - mean[2]) / std[2];

        // NCHW 포맷으로 저장
        // R 채널: [0, imageSize)
        // G 채널: [imageSize, 2*imageSize)
        // B 채널: [2*imageSize, 3*imageSize)
        final index = y * inputWidth + x;
        tensor[index] = rNorm;
        tensor[imageSize + index] = gNorm;
        tensor[2 * imageSize + index] = bNorm;
      }
    }

    return tensor;
  }

  /// 모델 리소스 해제
  void dispose() {
    // TODO: 모델 리소스 해제
  }
}