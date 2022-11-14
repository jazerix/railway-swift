//
//  MapLogic.swift
//  RailworkDetection
//
//  Created by Niels Faurskov on 12/11/2022.
//

import Foundation
import CoreLocation
import MapKit

@MainActor class MapLogic : ObservableObject
{
    @Published public var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude:50.5, longitude: 14.254053016537693),
                    span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
    );
    
    @Published public var joints : [Joint] = []
    
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
        closestMarkers()
    }
    
    struct Joint : Decodable, Identifiable
    {
        let id: Int
        let location: String
        let technical_location: String
        let equipment : Int
        let description: String
        let track_number : String
        let from_kilometers : String
        let coordinates : ApiCoordinates
        let position_location: String
        let distance : Double
    }
    
    struct ApiCoordinates : Decodable
    {
        let type : String
        let coordinates : [Double]
    }
    
    func closestMarkers()
    {
        guard let url = URL(string: "https://railway.faurskov.dev/api/joints?lat=56.546048939208234&long=9.724198113707246") else {
            fatalError("no bueno")
        }
        
        
        Task {
            let urlRequest = URLRequest(url: url);
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                fatalError("Unable to fetch markers");
            }
            let joints = try JSONDecoder().decode([Joint].self, from: data)
           
            
            self.joints = joints;
        }
    }
}
