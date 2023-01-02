import Foundation
import CoreLocation
import Combine

class RecordingTimer : ObservableObject
{
    private var timer : AnyCancellable? = nil;
    private var subscribers : [RecordingSubscriber] = []
    private var fileHandle : FileHandle? = nil;
    public var recordingId : Int? = nil
    
    @Published public var dataPoints = 0
    
    private var subscribedToLocationUpdates = false
    private var startedAt : Date? = nil
    public var secondsPassed : Int = 0;
    
    public func start() -> Void {
        dataPoints = 0;
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.objectWillChange.send();
                self.secondsPassed = Int(self.startedAt?.timeIntervalSinceNow ?? 0);
                
            }
        
        let manager = FileManager.default
        
        guard let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let currentRecordingUrl = url.appendingPathComponent("current.txt")
        
        do {
            if !manager.fileExists(atPath: currentRecordingUrl.path()) {
                manager.createFile(atPath: currentRecordingUrl.path(), contents:  Data([4]), attributes: [FileAttributeKey.creationDate: Date()])
            }
            fileHandle = try FileHandle(forUpdating: currentRecordingUrl)
            try fileHandle?.seekToEnd()
        }
        catch {
            print(error)
        }
    }
    
    public func subscribeToLocationEvents(locationManager : LocationManager)
    {
        if subscribedToLocationUpdates {
            return
        }
        
        locationManager.addListener(listener: { (currentLocation : CLLocation) in
            if self.fileHandle == nil || self.startedAt == nil {
                return;
            }
            let timestampMs : String = String(floor(abs((self.startedAt?.timeIntervalSinceNow ?? 0) *  1000)));
            let lat : String = String(currentLocation.coordinate.latitude)
            let lon = String(format: "%f", currentLocation.coordinate.longitude)
            self.dataPoints += 1;
            self.fileHandle?.write("\(timestampMs),\(lat),\(lon)\n".data(using: .utf8)!)
        })
        subscribedToLocationUpdates = true;
    }
   
    public func addSubscriber(subscriber : RecordingSubscriber) {
        subscribers.append(subscriber);
    }
    
    
    public func setStartedAt(startedAt : Date) -> Void
    {
        self.startedAt = startedAt;
        if (timer == nil) {
            start();
        }
        for subscriber in self.subscribers {
            Task {
                await subscriber.start();
            }
        }
            
    }
    
    public func getStartedAt() -> Date?
    {
        return self.startedAt
    }
    
    private func renameFileWithState() throws
    {
        let manager = FileManager.default
        
        guard let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let currentRecordingUrl = url.appendingPathComponent("current.txt")
        let moveTo = url.appendingPathComponent("recording-\(recordingId ?? 0).csv")
        try manager.moveItem(atPath: currentRecordingUrl.path(), toPath: moveTo.path())
    }
    
    public func stop()
    {
        timer?.cancel()
        timer = nil;
        if fileHandle != nil {
            do
            {
                try fileHandle?.close()
                try renameFileWithState()
            } catch {
                print(error)
            }
        }
        for subscriber in subscribers {
            Task {
                await subscriber.stop()
            }
        }
    }
    
    public func clear()
    {
        stop();
        startedAt = nil;
    }
}
