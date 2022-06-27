//
//  NaverMapPath.swift
//  
//
//  Created by Sunghyun Kim on 2022/06/26.
//

import Foundation
import NMapsMap

public struct NaverMapPath {
    
    var width: CGFloat = 5
    var outlineWidth: CGFloat = 1
    
    var color: UIColor = .white
    var outlineColor: UIColor = .black
    
    public init() {}
    
    func makePath() -> NMFPath {
        return NMFPath()
    }
    
    func updatePath(_ path: NMFPath, coordinates: [CLLocationCoordinate2D], mapView: NMFMapView) {
        path.width = width
        path.outlineWidth = outlineWidth
        
        path.color = color
        path.outlineColor = outlineColor
        
        let points = coordinates.map { $0.nmLatLng }
        path.path = NMGLineString(points: points)
        
        path.mapView = mapView
    }
}

public extension NaverMapPath {
    func width(_ width: CGFloat) -> NaverMapPath {
        var new = self
        new.width = width
        return new
    }
    func outlineWidth(_ outlineWidth: CGFloat) -> NaverMapPath {
        var new = self
        new.outlineWidth = outlineWidth
        return new
    }
    
    func color(_ color: UIColor) -> NaverMapPath {
        var new = self
        new.color = color
        return new
    }
    func outlineColor(_ outlineColor: UIColor) -> NaverMapPath {
        var new = self
        new.outlineColor = outlineColor
        return new
    }
}
