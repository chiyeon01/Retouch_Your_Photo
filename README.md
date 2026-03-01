# Retouch Your Photo

<div align="center">
  <img width="650" alt="image" src="https://github.com/user-attachments/assets/3a571d68-dc94-4919-b9d8-1d1e53443e08" />
</div>

<br/><br/>

# 1. 서비스 개요

**Retouch Your Photo**는 사진을 더 잘 찍고 싶은 사람들을 위한 **Flutter 기반 실시간 촬영 가이드 앱**입니다.

단순히 "잘 찍힌 사진"을 기준으로 피드백을 주는 것이 아니라, **음식·인물 등 특정 카테고리**에서 **특정 작가의 고유한 스타일**로 학습된 커스텀 AI 모델을 기반으로 가이드라인을 제공합니다. 사용자는 원하는 작가의 감성과 구도를 실시간으로 따라가며 촬영할 수 있습니다.

### 주요 기능

| 기능 | 설명 |
|------|------|
| 📸 실시간 촬영 가이드 | 카메라 화면에서 실시간으로 구도 피드백 제공 |
| 🎨 작가 스타일 학습 모델 | 특정 작가의 사진 특징을 학습한 커스텀 AI 모델 적용 |
| 🍽️ 카테고리 지원 | 음식(Food), 인물(Portrait) 카테고리별 모델 제공 |
| 🧭 6축 가이드라인 | 좌우 / 위아래 / 앞뒤 / 기울기 / 회전 / 좋음 |

<br/>

### 촬영 가이드라인 상세

```
← →  좌우 이동    ↑ ↓  위아래 이동    ↕  앞뒤 이동
↺    기울기 조정   ↻    회전 조정      ✅  최적 구도 (좋음)
```

<br/><br/>

# 2. 모델 아키텍처

<div align="center">
  <img width="650" alt="image" src="https://github.com/user-attachments/assets/d1f15672-478c-446e-9797-1da83d3ff691" />
</div>

### 모델 개요

본 서비스의 AI 모델은 기존의 공개된 모델을 단순 활용하는 것이 아니라, **기존 모델들을 결합하고 일부 구조를 새롭게 설계하여 세상에 없는 커스텀 모델**을 직접 구축하였습니다.

- 특정 작가의 사진 데이터를 수집하여 카테고리별로 학습
- 작가의 구도·조명·색감 등 스타일 특성을 추출
- 실시간 추론에 최적화된 경량화 구조 적용

<br/>

### 모델 세부내용

모델의 세부 내용은 다음과 같습니다.

- **YOLO:** 객체 위치를 탐지한 후 자체적인 processing
- **Depth Estimator:** 프레임의 3D 원근감 추출 후 processing
- **MobileNet:** 프레임의 기본적인 feature map 추출
- **Embedding:** 특정 작가의 특징 추출
- **Regression Layer:** concate된 feature map을 토대로 (○, 6) 형태의 통계적 값을 반환하는 fully-connected-layer

<br/><br/>

# 3. 레퍼런스

[Retouch Your Photo VELOG](https://velog.io/@chiyeon01/Project-Retouching-Your-Photo)<br/>
[Retouch Your Photo PPT](https://www.canva.com/design/DAHAiN_OG68/3itKJNmlflSALfVwwKLIfw/edit?utm_content=DAHAiN_OG68&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton)
