import Foundation

protocol RecordingSubscriber 
{
    func start() async -> Void
    func stop() async -> Void
}
