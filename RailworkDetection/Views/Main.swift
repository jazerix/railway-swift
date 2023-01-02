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
    @StateObject private var recordingTimer : RecordingTimer = RecordingTimer()
    
    @State private var showSettigns = false;
    @State private var selectedTrainType : String? = nil
    @State private var selectedSurfaceType : String? = nil
    @State private var settingsInitializedError = false;
    @State private var showConfirmStopRecording = false;
   
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Device connection")
                    Spacer()
                    if (ble.connected)
                    {
                        if (ble.batteryState.charging)
                        {
                            if (ble.batteryState.charging && ble.batteryState.level > 100)
                            {
                                Text("Not charging").font(.footnote).foregroundColor(.red)
                            }
                            else
                            {
                                Text("\(ble.batteryState.level)%").font(.footnote)
                                Image(systemName: "battery.100.bolt")
                            }
                        }
                        else
                        {
                            HStack{
                                Text("\(ble.batteryState.level)%").font(.footnote)
                                switch (true)
                                {
                                case ble.batteryState.level > 75:
                                    Image(systemName: "battery.100")
                                case ble.batteryState.level > 60:
                                    Image(systemName: "battery.75")
                                case ble.batteryState.level > 30:
                                    Image(systemName: "battery.50")
                                case ble.batteryState.level > 15:
                                    Image(systemName: "battery.25")
                                default:
                                    Image(systemName: "battery.0")
                                }
                            }
                        }
                        
                    }
                    else
                    {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .scaleEffect(x: 0.8, y: 0.8)
                    }
                }.foregroundColor(ble.connected ? .green : .blue)
                    .font(.subheadline)
                    .frame(height: 20)
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
                    .frame(height: 20)
                if (ble.connected && ble.calibrationStatus != .Calibrating) {
                    HStack {
                        if (ble.calibrationStatus == .NotCalibrated) {
                            Label("Device not calibrated", systemImage: "info.circle")
                                .fontWeight(.light)
                                .font(.callout)
                                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                            Spacer();
                        } else {
                            Label("Device calibrated", systemImage: "info.circle")
                                .fontWeight(.light)
                                .font(.callout)
                                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                            Spacer();
                            Text("X\(ble.calibrationValues[0]) Y\(ble.calibrationValues[1]) Z\(ble.calibrationValues[2])")
                                .fontWeight(.light)
                                .font(.callout)
                                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                        }
                    }.padding(14)
                        .background(Color(red: 0.1, green: 0.1, blue: 0.1))
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .cornerRadius(14)
                }
                MapView(mapLogic: MapLogic(locationManager: location, recordingTimer: recordingTimer))
                    .disabled(true)
                    .cornerRadius(14)
                    .shadow(radius: 5)
                    .frame(height: 300)
                    .overlay(Button(action: settings) {
                        if (selectedTrainType == nil || selectedSurfaceType == nil)
                        {
                            Text("Train Settings").frame(minWidth: 0, maxWidth: .infinity, minHeight: 20)
                        }
                        else
                        {
                            Text("\(selectedTrainType!) - \(selectedSurfaceType!) Surface")
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 20)
                        }
                    }.buttonStyle(.borderedProminent)
                        .tint(.gray)
                        .cornerRadius(14)
                        .disabled(ble.recording),
                    alignment: .bottom)
                Spacer()
                VStack
                {
                    HStack {
                        Label("\(recordingTimer.dataPoints)", systemImage: "location.circle").font(.body)
                        Label("\(ble.samples)", systemImage: "waveform.circle").font(.body)
                        Text("(\(String(format: "%0.f", ble.averageSamples)) samples / sec)").font(.callout).foregroundColor(.white).opacity(0.4)
                    }.padding(.bottom, 10)
                    HStack
                    {
                        Text(formatTime(time:recordingTimer.secondsPassed)).fontWeight(.bold).font(.largeTitle)
                        Spacer()
                        Text("Recording \(ble.recordingId == nil ? "-" : String(ble.recordingId!))").fontWeight(.light)
                    }
                    HStack {
                        
                        Button(action: start) {
                            if (ble.recording)
                            {
                                Text("Recording...")
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 30)
                                    .foregroundColor(.white)
                            }
                            else
                            {
                                Label("Start recording", systemImage: "play.fill")
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 30)
                                    .foregroundColor(.white)
                            }
                                
                        }.buttonStyle(.borderedProminent).tint(.green)
                            .disabled(!ble.connected || ble.calibrationStatus != .Calibrated || ble.recording)
                            .alert(isPresented: $settingsInitializedError) {
                                Alert(title: Text("Settings Not Initialized"), message: Text("Please initialize settings"), dismissButton: .default(
                                    Text("OK")
                                ))
                            }
                        
                        if (ble.connected)
                        {
                            if (ble.recording)
                            {
                                Button(action: {
                                    showConfirmStopRecording = true;
                                }) {
                                    Image(systemName: "stop.fill")
                                        .frame(minWidth: 40, minHeight: 30)

                                }
                                .buttonStyle(.borderedProminent).tint(.red)
                                .alert(isPresented: $showConfirmStopRecording) {
                                    Alert(
                                        title: Text("Are you sure?"),
                                        message: Text("This action cannot be undone"),
                                        primaryButton: .destructive(Text("Stop Recording")) {
                                            stopRecording()
                                        },
                                        secondaryButton: .cancel()
                                    )
                                }
                            }
                            else
                            {
                                Button(action: calibrate)
                                {
                                    if(ble.calibrationStatus == .Calibrated)
                                    {
                                        Image(systemName: "target")
                                            .frame(minWidth: 40, minHeight: 30)
                                    }
                                    else
                                    {
                                        Label(ble.calibrationStatus == .Calibrating ? "Calibrating..." : "Calibrate", systemImage: "target")
                                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 30)
                                            .foregroundColor(.white)
                                    }
                                    
                                }
                                .buttonStyle(.borderedProminent).tint(.blue)
                                .alert(isPresented: $ble.calibrationFailed) {
                                    Alert(title: Text("Calibratin Failed").foregroundColor(.red), message: Text("Please re-orient device"), dismissButton: .default(
                                        Text("OK"),
                                        action: {
                                            ble.calibrationStart = nil;
                                        }
                                    ))
                                }
                                .disabled(ble.calibrationStatus == .Calibrating)
                            }
                        }
                            
                    }
                    .disabled(!ble.connected || ble.calibrationStatus == .Calibrating)
                }
               
            }
            .sheet(isPresented: $showSettigns) {
                SettingsView(selectedTrain: $selectedTrainType, selectedSurface: $selectedSurfaceType)
                    .presentationDetents([.medium])
            }
            .padding()
            .navigationBarTitle("Railwork Diagnostics")
            .navigationBarTitleDisplayMode(.inline)
           
        }.onAppear {
            btStuff()
            recordingTimer.subscribeToLocationEvents(locationManager : location)
        }
        
    }
    
    private func calibrate()
    {
        ble.calibrate();
    }
    
    private func settings()
    {
        showSettigns.toggle();
    }
    
    private func start()
    {
        if (selectedTrainType == nil || selectedSurfaceType == nil)
        {
            settingsInitializedError = true;
            return;
        }
        ble.startRecording()
    }
    
    private func stopRecording() -> Void
    {
        ble.stopRecording()
    }
    
    private func formatTime(time : Int) -> String
    {
        let absTime = abs(time)
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        
        return formatter.string(from: TimeInterval(absTime))!
    }
    
    private func btStuff()
    {
        if (!ble.started)
        {
            ble.start(recordingTimer: recordingTimer)
        }
    }
}

struct Main_Previews: PreviewProvider {
    static var previews: some View {
        Main().preferredColorScheme(.dark)
    }
}
