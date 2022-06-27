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
    var image: UIImage?
    var captionText: String?
    
    public init(position: CLLocationCoordinate2D) {
        self.position = position
    }
    
    func makeMarker(_ mapView: NMFMapView) -> NMFMarker {
        let marker = NMFMarker()
        updateMarker(marker)
        marker.mapView = mapView
        return marker
    }
    
    func updateMarker(_ marker: NMFMarker) {
        marker.position = position.nmLatLng
        if let image = image {
            marker.iconImage = NMFOverlayImage(image: image)
        }
        marker.captionText = captionText ?? ""
    }
}

public extension NaverMapMarker {
    func image(_ image: UIImage) -> NaverMapMarker {
        var new = self
        new.image = image
        return new
    }
    
    func captionText(_ captionText: String) -> NaverMapMarker {
        var new = self
        new.captionText = captionText
        return new
    }
}
