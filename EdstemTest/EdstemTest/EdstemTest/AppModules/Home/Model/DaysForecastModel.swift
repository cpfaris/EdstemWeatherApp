//
//  DaysForecastModel.swift
//  EdstemTest
//
//  Created by FARIS CP on 09/12/24.
//

import Foundation
// MARK: - DaysForecast
struct DaysForecast: Codable {
    let cod: String?
    let message, cnt: Int?
    let list: [ForcastList]?
    let city: City?
}

// MARK: - City
struct City: Codable {
    let id: Int?
    let name: String?
    let coord: Coord?
    let country: String?
    let population, timezone, sunrise, sunset: Int?
}
// MARK: - List
struct ForcastList: Codable {
    let dt: Int?
    let main: Main?
    let weather: [Weather]?
    let clouds: Clouds?
    let wind: Wind?
    let visibility: Int?
    let pop: Double?
    let sys: Sys?
    let dtTxt: String?

    enum CodingKeys: String, CodingKey {
        case dt, main, weather, clouds, wind, visibility, pop, sys
        case dtTxt = "dt_txt"
    }
}

