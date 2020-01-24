//
//  Location.swift
//  location
//
//  Created by Andrew Finke on 1/24/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import CoreLocation
import os.log

struct Location: Codable {
    
    // MARK: - Properties -
    
    private static let minLocationDiff = 0.0005
    private static let minIntervalDiff = 10.0
    private static let forceSigDiffIntervalDiff = 60.0 * 60.0 * 6
    
    let timestamp: Double
    let speed: Double
    let latitude: Double
    let longitude: Double
    
    // MARK: - Initalization -
    
    init (_ location: CLLocation) {
        timestamp = location.timestamp.timeIntervalSince1970
        speed = location.speed
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
    }
    
    func isSigDifferent(from location: Location) -> Bool {
        let diff = sqrt(pow(latitude - location.latitude, 2) + pow(longitude - location.longitude, 2))
        let time = timestamp - location.timestamp
        
        os_log("location diff: %{public}f, %{public}f", log: .filtering, type: .debug, diff, time)
        if time > Location.forceSigDiffIntervalDiff {
            return true
        }
        
        return diff > Location.minLocationDiff &&
            time > Location.minIntervalDiff
    }
}
