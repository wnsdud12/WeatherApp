//
//  WeatherModel.swift
//  WeatherApp
//
//  Created by 박준영 on 2022/03/18.
//

import Foundation

typealias WeatherValue = [String: Any]
typealias WeatherTableData = (date: String, time: String, value: WeatherValue)

struct WeatherModel: Codable {
    init(date:[String], time: [String], value: [WeatherValue]) {
        
    }
}
