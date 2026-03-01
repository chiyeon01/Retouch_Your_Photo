// AI 모델이 반환하는 가이드라인 결과
// 모델 출력: [좌우이동, 위아래이동, 전진/후진, 기울기, 수평, 미학점수]
class GuidanceResult {
  // 좌우 이동 (-: 왼쪽, +: 오른쪽)
  final double horizontalMove;

  // 위아래 이동 (-: 위, +: 아래)
  final double verticalMove;

  // 전진/후진 (-: 후진, +: 전진)
  final double depthMove;

  // 기울기 (-: 왼쪽 기울임, +: 오른쪽 기울임)
  final double tilt;

  // 수평 (-: 시계방향, +: 반시계방향)
  final double horizontal;

  // 미학 점수 (0-100)
  final double aestheticScore;

  GuidanceResult({
    required this.horizontalMove,
    required this.verticalMove,
    required this.depthMove,
    required this.tilt,
    required this.horizontal,
    required this.aestheticScore,
  });

  // 모델 출력 배열로부터 생성
  // [values] = [좌우이동, 위아래이동, 전진/후진, 기울기, 수평, 미학점수]
  factory GuidanceResult.fromModelOutput(List<double> values) {
    if (values.length != 6) {
      throw ArgumentError('Model output must contain exactly 6 values');
    }

    return GuidanceResult(
      horizontalMove: values[0],
      verticalMove: values[1],
      depthMove: values[2],
      tilt: values[3],
      horizontal: values[4],
      aestheticScore: values[5],
    );
  }

  // 모델 출력 배열로 변환
  List<double> toModelOutput() {
    return [
      horizontalMove,
      verticalMove,
      depthMove,
      tilt,
      horizontal,
      aestheticScore,
    ];
  }

  // 완벽한 구도인지 확인 (모든 값이 임계값 이내)
  bool isPerfectComposition({double threshold = 0.1}) {
    return horizontalMove.abs() < threshold &&
        verticalMove.abs() < threshold &&
        depthMove.abs() < threshold &&
        tilt.abs() < threshold &&
        horizontal.abs() < threshold;
  }

  @override
  String toString() {
    return 'GuidanceResult(horizontal: $horizontalMove, vertical: $verticalMove, '
        'depth: $depthMove, tilt: $tilt, horizontal: $horizontal, '
        'aesthetic: $aestheticScore)';
  }
}