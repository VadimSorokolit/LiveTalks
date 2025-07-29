//
//  Location.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 23.07.2025.
//

struct Location: Codable {
    let status: String
    let country: String
    let countryCode: String
    let region: String
    let regionName: String
    let city: String
    let zip: String
    let lat: Double
    let lon: Double
    let timezone: String
    let isp: String
    let org: String
    let asInfo: String
    let query: String

    private enum CodingKeys: String, CodingKey {
        case status
        case country
        case countryCode
        case region
        case regionName
        case city
        case zip
        case lat
        case lon
        case timezone
        case isp
        case org
        case asInfo = "as"
        case query
    }
}
