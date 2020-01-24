//
//  OSLog+Location.swift
//  location
//
//  Created by Andrew Finke on 1/24/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import Foundation
import os.log

extension OSLog {

    // MARK: - Types -

    private static let subsystem: String = {
        guard let identifier = Bundle.main.bundleIdentifier else { fatalError() }
        return identifier
    }()

    static let updates = OSLog(subsystem: subsystem, category: "updates")
    static let filtering = OSLog(subsystem: subsystem, category: "filtering")
}
