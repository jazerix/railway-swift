//
//  LocationManager.swift
//  RailworkDetection
//
//  Created by Niels Faurskov on 10/11/2022.
//

import Foundation
import CoreLocation

class LocationManager : NSObject, ObservableObject
{
    private let locationManager = CLLocationManager();
    @Published var currentLocation : CLLocation? = nil
    @Published var locationEstablished : Bool = false
    
    private var listeners : [(String) -> (Void)] = []
    
    public var exposedLocation: CLLocation? {
        return self.locationManager.location
    }
    
    override init() {
        super.init()
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func getPlace(for location: CLLocation, compilation: @escaping (CLPlacemark?) -> Void) {
        print(location.coordinate.latitude, location.coordinate.longitude)
    }
    
    public func addListener(listener : @escaping (String) -> (Void))
    {
        listeners.append(listener);
    }
}

extension LocationManager: CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("Not determined");
        case .restricted:
            print("restricted");
        case .denied:
            print("denied")
        case .authorizedAlways:
            print("authorization always")
        case .authorizedWhenInUse:
            print("authorization when in use")
        @unknown default:
            print("unknown")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (locations.count == 0) {
            return
        }
        print(locations)
        if (locationEstablished == false) {
            locationEstablished = true
        }
        currentLocation = locations.last!
        for listener in listeners {
            listener("hello");
        }
    }
    
}
