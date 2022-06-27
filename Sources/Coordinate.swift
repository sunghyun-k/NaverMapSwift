//
//  Coordinate.swift
//  Doongster
//
//  Created by Sunghyun Kim on 2022/06/25.
//

import Foundation
import NMapsMap

public extension NMGLatLng {
    /// `NMGLatLng` -> `CLLocationCoordinate2D`
    var clCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
}

public extension CLLocationCoordinate2D {
    /// `CLLocationCoordinate2D` -> `NMGLatLng`
    var nmLatLng: NMGLatLng {
        return NMGLatLng(lat: latitude, lng: longitude)
    }
}

public extension NMFCameraPosition {
    /// 줌을 16.5로 맞추어 카메라를 생성한다.
    convenience init(_ target: CLLocationCoordinate2D) {
        self.init(target.nmLatLng, zoom: 16.5)
    }
}
