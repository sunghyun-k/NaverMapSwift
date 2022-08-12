//
//  NaverMap.swift
//  
//
//  Created by Sunghyun Kim on 2022/06/25.
//

import SwiftUI
import NMapsMap

public struct NaverMap<MarkerItems>: UIViewRepresentable where MarkerItems: RandomAccessCollection, MarkerItems.Element: Identifiable {
    
    /// 상위 뷰에서 카메라 포지션을 사용하기 위한 바인딩 프로퍼티.
    @Binding var cameraPosition: NMFCameraPosition
    
    var lineCoordinates = [CLLocationCoordinate2D]()
    
    var onMapTap: ((CLLocationCoordinate2D) -> Void)?
    
    var isRotateGestureEnabled = true
    var isTiltGestureEnabled = true
    
    var markerItems: MarkerItems
    var markerContent: ((MarkerItems.Element) -> NaverMapMarker)?
    var pathContent: () -> NaverMapPath = { NaverMapPath() }
    
    public init(
        cameraPosition: Binding<NMFCameraPosition>,
        lineCoordinates: [CLLocationCoordinate2D] = [CLLocationCoordinate2D](),
        markerItems: MarkerItems,
        markerContent: @escaping (MarkerItems.Element) -> NaverMapMarker
    ) {
        self._cameraPosition = cameraPosition
        self.lineCoordinates = lineCoordinates
        
        self.markerItems = markerItems
        self.markerContent = markerContent
    }
    
    public func makeUIView(context: Context) -> NMFMapView {
        let mapView = NMFMapView()
        mapView.touchDelegate = context.coordinator
        mapView.addCameraDelegate(delegate: context.coordinator)
        mapView.moveCamera(NMFCameraUpdate(position: cameraPosition))
        return mapView
    }
    
    public func updateUIView(_ mapView: NMFMapView, context: Context) {
        updateOptions(mapView)
        updateCamera(
            mapView,
            isCameraMoving: context.coordinator.isCameraMoving,
            animated: context.transaction.animation != nil
        )
        updateMarker(mapView, coordinator: context.coordinator)
        updatePath(mapView, coordinator: context.coordinator)
    }
    
    private func updateOptions(_ mapView: NMFMapView) {
        mapView.isRotateGestureEnabled = isRotateGestureEnabled
        mapView.isTiltGestureEnabled = isTiltGestureEnabled
    }
    
    private func updateCamera(_ mapView: NMFMapView, isCameraMoving: Bool, animated: Bool) {
        guard mapView.cameraPosition != cameraPosition,
              !isCameraMoving
        else { return }
        let cameraUpdate = NMFCameraUpdate(position: cameraPosition)
        if animated {
            cameraUpdate.animation = .easeIn
        }
        mapView.moveCamera(cameraUpdate)
    }
    
    private func updateMarker(_ mapView: NMFMapView, coordinator: Coordinator) {
        guard let markerContent = markerContent else {
            return
        }
        var ids: [AnyHashable] = Array(coordinator.markers.keys)
        for item in markerItems {
            let content = markerContent(item)
            // 기존 마커 업데이트
            if let index = ids.firstIndex(of: item.id) {
                guard let marker = coordinator.markers[item.id] else {
                    fatalError()
                }
                content.updateMarker(marker)
                ids.remove(at: index)
            }
            // 없을 경우 신규 생성 후 삽입
            else {
                let marker = content.makeMarker(mapView)
                content.updateMarker(marker)
                coordinator.markers[item.id] = marker
            }
        }
        // 제거된 마커 맵에서 삭제
        for id in ids {
            coordinator.markers[id]?.mapView = nil
            coordinator.markers[id] = nil
        }
    }
    
    private func updatePath(_ mapView: NMFMapView, coordinator: Coordinator) {
        guard lineCoordinates.count > 1 else {
            return
        }
        let content = pathContent()
        if let path = coordinator.path {
            content.updatePath(path, coordinates: lineCoordinates, mapView: mapView)
        } else {
            let path = content.makePath()
            content.updatePath(path, coordinates: lineCoordinates, mapView: mapView)
            coordinator.path = path
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    public class Coordinator: NSObject, NMFMapViewTouchDelegate, NMFMapViewCameraDelegate {
        var parent: NaverMap
        init(_ parent: NaverMap) {
            self.parent = parent
        }
        
        var markers = [AnyHashable: NMFMarker]()
        var path: NMFPath?
        var isCameraMoving = false
        
        // MARK: - NMFMapViewTouchDelegate
        
        public func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
            parent.onMapTap?(latlng.clCoordinate)
        }
        
        // MARK: - NMFMapViewCameraDelegate
        
        public func mapViewCameraIdle(_ mapView: NMFMapView) {
            parent.cameraPosition = mapView.cameraPosition
            isCameraMoving = false
        }
        public func mapView(_ mapView: NMFMapView, cameraWillChangeByReason reason: Int, animated: Bool) {
            isCameraMoving = true
        }
    }
}

// MARK: - Modifier

public extension NaverMap {
    /// 지도가 탭되면 호출된다.
    /// `NMFMapViewTouchDelegate > mapViewCameraIdle(:)`
    func onMapTap(perform action: @escaping (CLLocationCoordinate2D) -> Void) -> NaverMap {
        var new = self
        new.onMapTap = action
        return new
    }
    
    /// NMFPath (패스 오버레이)의 속성을 변경한다.
    func pathStyle(_ content: @escaping () -> NaverMapPath) -> NaverMap {
        var new = self
        new.pathContent = content
        return new
    }
    
    func rotateGestureEnabled(_ value: Bool) -> NaverMap {
        var new = self
        new.isRotateGestureEnabled = value
        return new
    }
    
    func tiltGestureEnabled(_ value: Bool) -> NaverMap {
        var new = self
        new.isTiltGestureEnabled = value
        return new
    }
}

public typealias _DefaultMarkerItems = [_DefaultMarkerItem]
public struct _DefaultMarkerItem: Identifiable {
    public var id = false
}

public extension NaverMap where MarkerItems == _DefaultMarkerItems {
    init(
        cameraPosition: Binding<NMFCameraPosition>,
        lineCoordinates: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
    ) {
        self._cameraPosition = cameraPosition
        self.lineCoordinates = lineCoordinates
        markerItems = []
    }
}

struct NaverMap_Previews: PreviewProvider {
    init() {
        NMFAuthManager.shared().clientId = "mt3k8l7gvz"
    }
    static var previews: some View {
        NaverMap(cameraPosition: .constant(NMFCameraPosition(CLLocationCoordinate2D(latitude: 37.4924020, longitude: 126.9212310))))
    }
}
