
import Foundation

@MainActor class Device : ObservableObject
{
    @Published var calibrationStatus : CalibrationTypes = .NotCalibrated
    var calibration : Calibration? = nil
}
