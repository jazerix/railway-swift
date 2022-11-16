//
//  Main.swift
//  RailworkDetection
//
//  Created by Niels Faurskov on 10/11/2022.
//

import SwiftUI
import MapKit
import CoreLocation;

struct Main: View {
    
    @StateObject private var ble : BT = BT()
    @StateObject private var location : LocationManager = LocationManager()
    
    @State private var region = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(
                        latitude: 40.83834587046632,
                        longitude: 14.254053016537693),
                    span: MKCoordinateSpan(
                        latitudeDelta: 0.03,
                        longitudeDelta: 0.03)
                    )
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Device connection").foregroundColor(.blue)
                        .font(.subheadline)
                    Spacer()
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(x: 0.8, y: 0.8)
                    
                }
                HStack {
                    Text("Position established")
                    Spacer()
                    if (location.locationEstablished)
                    {
                        Image(systemName: "checkmark").scaleEffect(x: 0.8, y: 0.8)
                    }
                    else
                    {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .scaleEffect(x: 0.8, y: 0.8)
                    }
                    
                }.foregroundColor(location.locationEstablished ? .green : .blue)
                    .font(.subheadline)
                MapView(mapLogic: MapLogic(locationManager: location))
                    .disabled(true)
                    .cornerRadius(20)
                    .shadow(radius: 5)
                    .frame(height: 400)
                Text("00:00").padding(20).fontWeight(.bold).font(.largeTitle)
                Spacer()
                Button(action: start) {
                    Text("Start recording").foregroundColor(.white)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, maxHeight: 40)
                .background(.blue)
                .cornerRadius(5)
            }.padding()
            .navigationBarTitle("Railwork Diagnostics")
            .navigationBarTitleDisplayMode(.inline)
           
        }.onAppear(perform: btStuff)
    }
    
    private func start()
    {
        
    }
    
    private func btStuff()
    {
        if (!ble.started)
        {
            ble.start()
        }
    }
}

struct Main_Previews: PreviewProvider {
    static var previews: some View {
        Main()
    }
}
