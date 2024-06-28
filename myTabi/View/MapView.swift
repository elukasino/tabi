//
//  MapView.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 26.06.2024.
//

import SwiftUI
import MapKit
import Foundation
import CoreLocation

struct MapView: View {
    let startLocation: Location
    let endLocation: Location
    
    var body: some View {
        Map(interactionModes: []) {
            if startLocation.coordinate != nil {
                Marker("Start", coordinate: startLocation.coordinate!).tint(.green) //TODO: in iOS 18, add .green.mix(with: black...)
            }
            if endLocation.coordinate != nil {
                Marker("Destination", coordinate: endLocation.coordinate!)
            }
        }
        .mapStyle(.standard(elevation: .realistic))
    }
}

#Preview {
    MapView(startLocation: Location(address: "Thákurova 9, Praha", coordinate: CLLocationCoordinate2D(latitude: 50.105050295798094, longitude: 14.389895002767982)), endLocation: Location(address: "Dlouhá, Veleň", coordinate: CLLocationCoordinate2D(latitude: 50.17556417431436, longitude: 14.553697441650922)))
}
