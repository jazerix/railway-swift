import Foundation
import CoreLocation
import MapKit

@MainActor class MapLogic : ObservableObject, RecordingSubscriber
{
    func start() {
        showTrace = true;
    }
    
    func stop() {
        showTrace = false;
        history.removeAll()
    }
    
    @Published public var showTrace : Bool = false
    
    @Published public var joints : [Joint] = []
    
    public var history : [CLLocation] = [];
    private var measuringFrom : CLLocation? = nil
    
    
    
    private var locationManager : LocationManager
    
    
    init(locationManager : LocationManager, recordingTimer : RecordingTimer)
    {
        self.locationManager = locationManager;
        locationManager.addListener(listener: {(location : CLLocation) in
            if (self.showTrace == false) {
                return;
            }
            if (self.measuringFrom == nil) {
                self.history.append(location)
                self.measuringFrom = location;
            }
            else {
                let distanceBetween = location.distance(from: self.measuringFrom!);
                print(distanceBetween);
                if (distanceBetween > 100) { // if we've moved less than 100 meters we do not care
                    print("Updating points")
                    self.history.append(location);
                    self.measuringFrom = location;
                }
            }
            //self.closestMarkers()
        })
        recordingTimer.addSubscriber(subscriber: self)
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
        let currentCoordinate : CLLocationCoordinate2D! = locationManager.currentLocation?.coordinate;
        if (currentCoordinate == nil) {
            return;
        }
        
        guard let url = URL(string: "https://railway.faurskov.dev/api/joints?lat=\(currentCoordinate.latitude)&long=\(currentCoordinate.longitude)") else {
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
