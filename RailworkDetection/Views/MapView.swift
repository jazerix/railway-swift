import SwiftUI
import CoreLocation
import MapKit



struct MapView: UIViewRepresentable {
    typealias UIViewType = MKMapView
    
    @StateObject var mapLogic : MapLogic
   // @Binding var recording : Bool
    

    
    class MapViewCoordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView : MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay);
            renderer.strokeColor = .systemRed
            renderer.lineWidth = 5
            
            return renderer;
        }
    }
    
    func makeCoordinator() -> MapViewCoordinator {
        return MapViewCoordinator()
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView();
        mapView.showsUserLocation = true;
        mapView.setUserTrackingMode(.follow, animated: true)
        
        mapView.delegate = context.coordinator;
        
        return mapView;
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.removeAnnotations(mapView.annotations);
        mapView.setUserTrackingMode(.follow, animated: true)
        mapView.removeOverlays(mapView.overlays);
        
        let coordinates = mapLogic.history.map { $0.coordinate }
        if (coordinates.count <= 1) {
            return;
        }
        
        let polyLine = MKPolyline(coordinates: coordinates, count: coordinates.count)
        //mapView.addOverlay(polyLine)
        mapView.addOverlay(polyLine);

    }

    
 
    
    
   
    /*var body: some View {
        Map(coordinateRegion: $mapLogic.region, showsUserLocation: true, annotationItems: mapLogic.joints) { joint in
            MapMarker(coordinate: CLLocationCoordinate2D(
                latitude: joint.coordinates.coordinates[1],
                longitude: joint.coordinates.coordinates[0]
            ))
        }
        .disabled(true)
        .cornerRadius(20)
        .shadow(radius: 5)
        .frame(height: 400)
    }*/
}

struct MapView_Previews: PreviewProvider {
    @State static var recording : Bool = false;
    static var recordingTimer = RecordingTimer()
    static var previews: some View {
        MapView(mapLogic: MapLogic(locationManager: LocationManager(), recordingTimer: recordingTimer)).previewLayout(.sizeThatFits)
            .previewDisplayName("Default")
    }
}
