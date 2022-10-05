//
//  NaverMapMarker.swift
//  
//
//  Created by Sunghyun Kim on 2022/06/26.
//

import Foundation
import NMapsMap

public struct NaverMapMarker {
    
    var position: CLLocationCoordinate2D
    var image: (() -> UIImage)?
    var captionText: String?
    var anchor: CGPoint = .init(x: 0.5, y: 1)
    var onTap: ((CLLocationCoordinate2D) -> Void)?
    
    public init(position: CLLocationCoordinate2D) {
        self.position = position
    }
    
    func makeMarker(_ mapView: NMFMapView) -> NMFMarker {
        let marker = NMFMarker()
        updateMarker(marker, mapView)
        return marker
    }
    
    func updateMarker(_ marker: NMFMarker, _ mapView: NMFMapView) {
        DispatchQueue.main.async {
            marker.position = position.nmLatLng
            if let image = image {
                marker.iconImage = NMFOverlayImage(image: image())
            }
            marker.captionText = captionText ?? ""
            marker.touchHandler = {
                if let marker = $0 as? NMFMarker {
                    onTap?(marker.position.clCoordinate)
                }
                return true
            }
            marker.anchor = anchor
            marker.mapView = mapView
        }
    }
}

public extension NaverMapMarker {
    func image(_ image: @escaping () -> UIImage) -> NaverMapMarker {
        var new = self
        new.image = image
        return new
    }
    
    func captionText(_ captionText: String) -> NaverMapMarker {
        var new = self
        new.captionText = captionText
        return new
    }
    
    func onTap(perform action: @escaping (CLLocationCoordinate2D) -> Void) -> NaverMapMarker {
        var new = self
        new.onTap = action
        return new
    }
    
    func anchor(_ point: CGPoint) -> NaverMapMarker {
        var new = self
        new.anchor = point
        return new
    }
}
