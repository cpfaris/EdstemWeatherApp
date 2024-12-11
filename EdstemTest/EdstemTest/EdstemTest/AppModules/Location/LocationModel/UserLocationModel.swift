//
//  UserLocationModel.swift
//  EdstemTest
//
//  Created by FARIS CP on 10/12/24.
//

import Foundation
import CoreLocation
import MapKit

// MARK: - AddressResult
struct AddressResult: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
}

// MARK: - AnnotationItem
struct AnnotationItem: Identifiable {
    let id = UUID()
    let latitude: Double
    let longitude: Double
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
