import SwiftUI
import CoreLocation
import MapKit



struct MapView: View {
    
    @StateObject var mapLogic : MapLogic
    
   
    var body: some View {
        Map(coordinateRegion: $mapLogic.region, showsUserLocation: true)
            .cornerRadius(20)
            .shadow(radius: 5)
            .frame(height: 400)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(mapLogic: MapLogic(locationManager: LocationManager())).previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("Default")
    }
}
