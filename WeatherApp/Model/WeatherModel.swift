//
//  WeatherModel.swift
//  WeatherApp
//
//  Created by 박준영 on 2022/04/15.
//

import Foundation
typealias WeatherValue = [String: String]
typealias WeatherTableData = (date: String, time: String, value: WeatherValue)

struct WeatherModel {
    let date: String
    let time: String
    var value: WeatherValue
}
