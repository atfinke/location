//
//  Config.swift
//  location
//
//  Created by Andrew Finke on 1/24/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import Foundation

struct Config {
    static let url: URL = {
        let string = "https://magic-box-support.herokuapp.com/background/locations"
        guard let url = URL(string: string) else {
            fatalError()
        }
        return url
    }()
}
