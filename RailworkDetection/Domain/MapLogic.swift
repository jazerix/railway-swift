//
//  MapLogic.swift
//  RailworkDetection
//
//  Created by Niels Faurskov on 12/11/2022.
//

import Foundation
import CoreLocation
import MapKit

class MapLogic : ObservableObject
{
    @Published public var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude:50.5, longitude: 14.254053016537693),
                    span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
    );
    
    private var locationManager : LocationManager
    
    init(locationManager : LocationManager)
    {
        self.locationManager = locationManager;
        locationManager.addListener(listener: {(a : String) in
            self.region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: locationManager.currentLocation?.coordinate.latitude ?? 50, longitude: locationManager.currentLocation?.coordinate.longitude ?? 10),
                span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
            );
        })
    }
    
    
    
    func closestMarkers()
    {
        
    }
}
