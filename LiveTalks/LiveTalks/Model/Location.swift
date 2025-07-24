//
//  Location.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 23.07.2025.
//

import Foundation

struct Location: Decodable {
    let country: String
    let city: String
    let zip: String
    let timezone: String
    let org: String
    let query: String
    let lat: Double
    let lon: Double
}
