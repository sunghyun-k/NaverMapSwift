//
//  ContentView.swift
//  NaverMapSwiftDemo
//
//  Created by Sunghyun Kim on 2022/06/28.
//

import SwiftUI
import NaverMapSwift
import NMapsMap

struct ContentView: View {
    @State var lineCoordinates = [CLLocationCoordinate2D]()
    @State var locations = [
        AnnotatedItem(name: "보라매공원", coordinate: .init(latitude: 37.4924020, longitude: 126.9212310)),
        AnnotatedItem(name: "레이드", coordinate: .init(latitude: 37.5058957, longitude: 127.0908851)),
        AnnotatedItem(name: "롯데월드 타워", coordinate: .init(latitude: 37.5125446, longitude: 127.1019602))
    ]
    @State var cameraPosition = NMFCameraPosition(
        NMGLatLng(lat: 37.5058957, lng: 127.0908851),
        zoom: 16.5
    )
    
    private func index(for location: AnnotatedItem) -> Int {
        guard let index = locations.firstIndex(where: { location.id == $0.id }) else {
            fatalError()
        }
        return index
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                Text("지도위치: \(cameraPosition.target)")
                NaverMap(
                    cameraPosition: $cameraPosition,
                    lineCoordinates: lineCoordinates,
                    markerItems: locations,
                    markerContent: { location in
                        NaverMapMarker(position: location.coordinate)
                            .image(.init(systemName: "phone.bubble.left.fill")!)
                            .captionText(location.name)
                    }
                )
                .tiltGestureEnabled(false)
                .rotateGestureEnabled(false)
                .onMapTap { coordinate in
                    lineCoordinates.append(coordinate)
                    locations.append(.init(name: "추가항목", coordinate: coordinate))
                }
                .pathStyle {
                    NaverMapPath()
                        .color(.init(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: 1))
                }
                .frame(height: proxy.size.height * 0.7)
                ScrollView {
                    ForEach($locations) { location in
                        HStack {
                            VStack {
                                TextField("이름", text: location.name)
                                Text("좌표: \(location.coordinate.latitude.wrappedValue), \(location.coordinate.longitude.wrappedValue)")
                            }
                            Button("이동") {
                                cameraPosition = .init(location.coordinate.wrappedValue)
                            }
                            Button("삭제") {
                                locations.remove(at: index(for: location.wrappedValue))
                            }
                        }
                    }
                }
                
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct AnnotatedItem: Identifiable {
    let id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
}
