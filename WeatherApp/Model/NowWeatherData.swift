//
//  NowWeatherData.swift
//  WeatherApp
//
//  Created by 박준영 on 2022/04/18.
//

import Foundation
// 초단기실황조회 데이터
struct NowWeatherData: Codable {
    let response: NowResponse
}
struct NowResponse: Codable {
    let header: NowHeader
    let body: NowBody
}
struct NowHeader: Codable {
    let resultCode: String
    let resultMsg: String
}
struct NowBody: Codable {
    let items: NowItems
}
struct NowItems: Codable {
    let item: [NowItem]
}
struct NowItem: Codable {
    let category: String
    let obsrValue: String
    let nx, ny: Int
    let baseDate, baseTime: String
}
