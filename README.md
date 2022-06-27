# NaverMapSwift

네이버지도 iOS SDK를 SwiftUI로 래핑한 패키지.

## 지원하는 기능

- 카메라 이동 (이니셜라이저 -> `cameraPosition: Binding<CameraPosition>`)

- Path 표시 (이니셜라이저 -> `lineCoordinates: [CLLocationCoordinate2D]`)

- Path 스타일화 (모디파이어 -> `pathStyle`)

- Marker 표시 (이니셜라이저 -> `markerItems`, `markerContent`)

- Map 탭 (모디파이어 -> `onMapTap(perform:)`)

- 회전, 틸트 잠금 (모디파이어 -> `rotateGestureEnabled(:)`, `tiltGestureEnabled(:)`)
