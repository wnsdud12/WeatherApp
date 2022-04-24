//
//  WeatherData.swift
//  WeatherApp
//
//  Created by sumwb on 2022/02/17.
//

import Foundation
// 단기예보조회 데이터
struct WeatherData: Codable {
    let response: Response
}

struct Response: Codable {
    let header: Header
    let body: Body
}

struct Header: Codable {
    let resultCode: String
    let resultMsg: String
}

struct Body: Codable {
    let items: Items
}

struct Items: Codable {
    let item: [Item]
}

struct Item: Codable {
    let fcstDate, fcstTime, fcstValue: String
    let nx, ny: Int
    let category: String
}


