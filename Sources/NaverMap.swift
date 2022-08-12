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
    @Binding var positionMode: NMFMyPositionMode
    
    var lineCoordinates = [CLLocationCoordinate2D]()
    var onMapTap: ((CLLocationCoordinate2D) -> Void)?
    var isRotateGestureEnabled = true
    var isTiltGestureEnabled = true
    
    var markerItems: MarkerItems
    var markerContent: ((MarkerItems.Element) -> NaverMapMarker)?
    var pathContent: () -> NaverMapPath = { NaverMapPath() }
    
    public init(
        cameraPosition: Binding<NMFCameraPosition>,
        positionMode: Binding<NMFMyPositionMode> = .constant(.disabled),
        lineCoordinates: [CLLocationCoordinate2D] = [CLLocationCoordinate2D](),
        markerItems: MarkerItems,
        markerContent: @escaping (MarkerItems.Element) -> NaverMapMarker
    ) {
        self._cameraPosition = cameraPosition
        self._positionMode = positionMode
        self.lineCoordinates = lineCoordinates
        
        self.markerItems = markerItems
        self.markerContent = markerContent
    }
    
    public func makeUIView(context: Context) -> NMFMapView {
        let mapView = NMFMapView()
        mapView.touchDelegate = context.coordinator
        mapView.addCameraDelegate(delegate: context.coordinator)
        mapView.addOptionDelegate(delegate: context.coordinator)
        mapView.moveCamera(NMFCameraUpdate(position: cameraPosition))
        return mapView
    }
    
    public func updateUIView(_ mapView: NMFMapView, context: Context) {
        updateOptions(mapView, coordinator: context.coordinator)
        updateCamera(mapView, coordinator: context.coordinator,
                     animated: context.transaction.animation != nil)
        updateMarker(mapView, coordinator: context.coordinator)
        updatePath(mapView, coordinator: context.coordinator)
    }
    
    private func updateOptions(_ mapView: NMFMapView, coordinator: Coordinator) {
        guard !coordinator.updatingParentOptions else {
            coordinator.updatingParentOptions = false
            return
        }
        mapView.isRotateGestureEnabled = isRotateGestureEnabled
        mapView.isTiltGestureEnabled = isTiltGestureEnabled
        if mapView.positionMode != positionMode {
            mapView.positionMode = positionMode
        }
    }
    
    private func updateCamera(_ mapView: NMFMapView, coordinator: Coordinator, animated: Bool) {
        guard !coordinator.updatingCamera else { return }
        guard !coordinator.updatingParentCamera else {
            coordinator.updatingParentCamera = false
            return
        }
        guard mapView.cameraPosition != cameraPosition else { return }
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
                guard let marker = coordinator.markers[item.id] else { fatalError() }
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
        guard lineCoordinates.count > 1 else { return }
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
    
    // MARK: - Coordinator
    public class Coordinator: NSObject, NMFMapViewTouchDelegate, NMFMapViewCameraDelegate, NMFMapViewOptionDelegate {
        var parent: NaverMap
        init(_ parent: NaverMap) {
            self.parent = parent
        }
        
        var markers = [AnyHashable: NMFMarker]()
        var path: NMFPath?
        
        var updatingParentOptions = false
        var updatingParentCamera = false
        var updatingCamera = false
        
        // MARK: - NMFMapViewTouchDelegate
        
        public func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
            parent.onMapTap?(latlng.clCoordinate)
        }
        
        // MARK: - NMFMapViewCameraDelegate
        
        public func mapViewCameraIdle(_ mapView: NMFMapView) {
            updatingCamera = false
            updatingParentCamera = true
            parent.cameraPosition = mapView.cameraPosition
        }
        public func mapView(_ mapView: NMFMapView, cameraWillChangeByReason reason: Int, animated: Bool) {
            updatingCamera = true
            parent.cameraPosition = mapView.cameraPosition
        }
        
        // MARK: - NMFMapViewOptionDelegate
        public func mapViewOptionChanged(_ mapView: NMFMapView) {
            updatingParentOptions = true
            parent.positionMode = mapView.positionMode
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
        positionMode: Binding<NMFMyPositionMode> = .constant(.disabled),
        lineCoordinates: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
    ) {
        self._cameraPosition = cameraPosition
        self._positionMode = positionMode
        self.lineCoordinates = lineCoordinates
        markerItems = []
    }
}
