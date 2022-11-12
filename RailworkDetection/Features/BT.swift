//
//  BT.swift
//  RailworkDetection
//
//  Created by Niels Faurskov on 09/11/2022.
//

import Foundation
import CoreBluetooth
import os

class BT : NSObject, ObservableObject
{
    var centralManager : CBCentralManager!
    var device: CBPeripheral!
    public var started : Bool = false;
    func start() -> Void
    {
        centralManager = CBCentralManager(delegate: self, queue: nil);
        started = true;
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
    }
   
}

extension BT : CBPeripheralDelegate
{
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
       // peripheral.setNotifyValue(<#T##enabled: Bool##Bool#>, for: <#T##CBCharacteristic#>)
        for service in peripheral.services!
        {
            print(service)
        }
    }
}
