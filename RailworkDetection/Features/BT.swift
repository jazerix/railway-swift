//
//  BT.swift
//  RailworkDetection
//
//  Created by Niels Faurskov on 09/11/2022.
//

import Foundation
import CoreBluetooth
import os

@MainActor
class BT : NSObject, ObservableObject
{
    let stateCHUUID : CBUUID = CBUUID(string: "D7714266-1EC0-7B8A-C64E-51AFCDFADDEE");
    let recordingIDCHUUID : CBUUID = CBUUID(string: "D7714266-1EC0-7B8A-C64E-51AFCFFADDEE");
    let timeCHUUID : CBUUID = CBUUID(string: "D7714266-1EC0-7B8A-C64E-51AFCCFADDEE");
    let calibrationCHUUID : CBUUID = CBUUID(string: "D7714266-1EC0-7B8A-C64E-51AFCEFADDEE");
    let batteryCHUUID : CBUUID = CBUUID(string: "D7714266-1EC0-7B8A-C64E-51AFD0FADDEE");
    let samplesCHUUID : CBUUID = CBUUID(string: "D7714266-1EC0-7B8A-C64E-51AFD1FADDEE")
    
    var calibrationCharacterisic : CBCharacteristic? = nil
    var batteryCharacteristic : CBCharacteristic? = nil
    var timeCharacteristic : CBCharacteristic? = nil
    var stateCharacteristic : CBCharacteristic? = nil;
    var recordingIDCharacteristic : CBCharacteristic? = nil;
    var samplesCharacteristic : CBCharacteristic? = nil;
    
    
    @Published public var connected : Bool = false;
    @Published var calibrationStatus : CalibrationTypes = .Calibrated
    @Published var calibrationValues : [Int8] = [0, 0, 0]
    @Published var batteryState : BatteryInfo = BatteryInfo(charging: false, level: 0)
    @Published public var recording : Bool = false;
    var calibrationFailed = false;
    
    var recordingStarting : Bool = false
    var recordingTimer  : RecordingTimer? = nil
    var recordingId : Int? = nil
    var samples : UInt32 = 0
    var averageSamples : Double = 0;
    
    var refreshTimer = Timer()
    var centralManager : CBCentralManager!
    var device: CBPeripheral!
    var calibrationStart : Date? = nil;
    public var started : Bool = false;
    
    func start(recordingTimer : RecordingTimer) -> Void
    {
        centralManager = CBCentralManager(delegate: self, queue: nil);
        started = true;
        self.recordingTimer = recordingTimer
        refreshTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(refreshFromDevice), userInfo: nil, repeats: true)
    }
    
    var countDownToRefresh = 5;
    @objc func refreshFromDevice()
    {
        if (connected == false) {
            return
        }
        if (recording && countDownToRefresh > 0)
        {
            countDownToRefresh -= 1; // when recording we only want to retrieve new data every 30 seconds to minimize processing
            return;
        }
        countDownToRefresh = 5;
        if (calibrationCharacterisic != nil && !recording) {
            readStuff(peripheral: device, characteristic: calibrationCharacterisic!)
        }
        if (batteryCharacteristic != nil)
        {
            readStuff(peripheral: device, characteristic: batteryCharacteristic!)
        }
        if (stateCharacteristic != nil)
        {
            readStuff(peripheral: device, characteristic: stateCharacteristic!)
        }
        if (timeCharacteristic != nil)
        {
            readStuff(peripheral: device, characteristic: timeCharacteristic!)
        }
        if (samplesCharacteristic != nil && recording) {
            readStuff(peripheral: device, characteristic: samplesCharacteristic!)
        }
    }
}

extension BT : CBCentralManagerDelegate
{
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch(central.state) {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            centralManager.scanForPeripherals(withServices: nil)
        @unknown default:
            print("central.state is @unknown")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connected = false;
        centralManager.scanForPeripherals(withServices: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if (peripheral.name == nil) {
            return;
        }
        if (!peripheral.name!.lowercased().contains("railway diagnostics")) {
            return;
        }
        
        print("Found device - stopping scanning");
        centralManager.stopScan();
        device = peripheral;
        print("Connecting to device!");
        centralManager.connect(device);
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("We're in!")
        peripheral.delegate = self;
        peripheral.discoverServices(nil);
        connected = true;
        
        calibrationStatus = .Calibrated;
        calibrationValues = [0, 0, 0]
    }
    
}

extension BT : CBPeripheralDelegate
{
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services!
        {
            print("Peripheral: \(service)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            switch(characteristic.uuid)
            {
            case stateCHUUID:
                stateCharacteristic = characteristic
                break
            case batteryCHUUID:
                batteryCharacteristic = characteristic
                break;
            case calibrationCHUUID:
                calibrationCharacterisic = characteristic
                break
            case timeCHUUID:
                timeCharacteristic = characteristic
                break
            case recordingIDCHUUID:
                recordingIDCharacteristic = characteristic;
                break
            case samplesCHUUID:
                samplesCharacteristic = characteristic;
                break;
            default:
                break
            }
        }
        refreshFromDevice()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print(error ?? "Characterisic written");
    }
    
    func writeStuff(peripheral: CBPeripheral, characteristic: CBCharacteristic)
    {
        var hello = "hello";
        let data = NSData(bytes: &hello, length: hello.lengthOfBytes(using: String.Encoding.ascii))
        peripheral.writeValue(data as Data, for: characteristic, type: .withResponse);
    }
    
    func readStuff(peripheral: CBPeripheral, characteristic: CBCharacteristic)
    {
        print("Reading characteristic");
        peripheral.readValue(for: characteristic);
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch(characteristic.uuid)
        {
        case calibrationCHUUID:
            calibrationData(characteristic: characteristic)
            break;
        case batteryCHUUID:
            batteryData(characteristic: characteristic)
            break;
        case timeCHUUID:
            timeData(characteristic: characteristic)
            break;
        case stateCHUUID:
            stateData(characteristic: characteristic)
            break;
        case recordingIDCHUUID:
            recordingIdData(characteristic: characteristic)
            break;
        case samplesCHUUID:
            sampleData(characteristic: characteristic)
            break;
        default:
            return;
        }
    }
    
    func calibrationData(characteristic:CBCharacteristic)
    {
        if (characteristic.value == nil) {
            return;
        }
        let val = characteristic.value!
        let calibrationData : [Int8] = val.map(Int8.init);
        if (calibrationData[0] == 0 || calibrationData[1] == 0 || calibrationData[2] == 0) {
            calibrationStatus = .NotCalibrated;
            calibrationValues = [0, 0, 0];
            if (calibrationStart != nil && calibrationStart!.timeIntervalSinceNow < -1) {
                calibrationFailed = true;
                calibrationStart = nil;
            }
            return;
        }
        
        calibrationStart = nil;
        calibrationValues = calibrationData;
        calibrationStatus = .Calibrated;
    }
    
    func calibrate()
    {
        if (calibrationCharacterisic == nil) {
            return;
        }
        let data = NSData();
        calibrationValues = [0, 0, 0]
        calibrationStart = Date.now
        calibrationFailed = false;
        calibrationStatus = .Calibrating;
        device.writeValue(data as Data, for: calibrationCharacterisic!, type: .withResponse)
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(refreshFromDevice), userInfo: nil, repeats: false)
    }
    
    
    func batteryData(characteristic: CBCharacteristic)
    {
        if (characteristic.value == nil) {
            return;
        }
        
        let val = characteristic.value!
        let batteryData : BatteryInfo = val.withUnsafeBytes { buffer in
            buffer.load(as: BatteryInfo.self)
        }
        
        batteryState = batteryData;
    }
    
    func timeData(characteristic: CBCharacteristic)
    {
        let time : UInt32 = characteristic.value!.withUnsafeBytes { buffer in
            buffer.load(as: UInt32.self)
        }
        
        if (recording && recordingTimer!.getStartedAt() == nil)
        {
            let convertedToDouble : Double = Double(time) / 1000;
            let startTime : Date = Date(timeIntervalSinceNow: -convertedToDouble);
            recordingTimer?.setStartedAt(startedAt: startTime)
        }
        print("Current time \(time)")
    }
    
    func startRecording() -> Void
    {
        if (stateCharacteristic == nil) {
            return
        }
        device.writeValue(Data([1]), for: stateCharacteristic!, type: .withResponse)
        recordingTimer?.setStartedAt(startedAt: Date.now)
        recordingStarting = true
        samples = 0
        averageSamples = 0;
        refreshFromDevice()
    }
    
    func stopRecording() -> Void
    {
        if (stateCharacteristic == nil)
        {
            return
        }
        device.writeValue(Data([0]), for: stateCharacteristic!, type: .withResponse)
        recording = false;
        recordingTimer?.clear()
        recordingId = nil;
        recordingStarting = false
        refreshFromDevice()
    }
    
    func stateData(characteristic: CBCharacteristic)
    {
        let state : UInt8 = characteristic.value!.withUnsafeBytes { buffer in
            buffer.load(as: UInt8.self)
        }
        
        recordingStarting = false;
        if (state == 1) // calibrated
        {
            if (recording == true)
            {
                recording = false;
                recordingTimer?.clear()
                recordingId = nil;
            }
            return
        }
        if (state == 2)
        {
            if (recording == false)
            {
                recording = true;
                if (recordingIDCharacteristic != nil) {
                    readStuff(peripheral: device, characteristic: recordingIDCharacteristic!)
                }
                if (samplesCharacteristic != nil) {
                    readStuff(peripheral: device, characteristic: samplesCharacteristic!)
                }
            }
        }
        
    }
    
    func recordingIdData(characteristic: CBCharacteristic)
    {
        let recordingId : Int32 = characteristic.value!.withUnsafeBytes { buffer in
            buffer.load(as: Int32.self)
        }
        self.recordingId = Int(recordingId);
        recordingTimer?.recordingId = self.recordingId
    }
    
    func sampleData(characteristic: CBCharacteristic)
    {
        let samples : UInt32 = characteristic.value!.withUnsafeBytes { buffer in
            buffer.load(as: UInt32.self)
        }
        self.samples = samples;
        self.averageSamples = Double(samples) / Double(abs(recordingTimer?.secondsPassed ?? 1))
    }
    
}
