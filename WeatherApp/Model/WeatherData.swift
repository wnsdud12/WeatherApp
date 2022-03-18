//
//  WeatherData.swift
//  WeatherApp
//
//  Created by sumwb on 2022/02/17.
//

import Foundation
/// Weather API를 디코딩할 때 생성되는 JSON data
struct WeatherData: Codable {
    let response: Response
}

struct Response: Codable {
    let header: Header
    let body: Body
}

/// 에러가 생겼을 시 Header 객체 내의 인스턴스로 에러 확인 가능
/// - resultCode : 응답 메시지코드
/// - resultMsg : 응답 메시지 설명
struct Header: Codable {
    let resultCode: String
    let resultMsg: String
}

struct Body: Codable {
    let items: Items
}

/// item 객체 별로 하나의 category와 fcstValue의 값만 저장되어 있으며, 각각의 item 객체들은 하나의 배열로 묶여 있음
struct Items: Codable {
    let item: [Item]
}

/// api로 받아온 JSON 객체 내에 실질적인 데이터가 저장되는 객체
///  - fcstDate : 예보일자
///  - fcstTime : 예보시각
///  - category : 자로구분코드
///  - fcstValue : 예보 값
///  - nx, ny : 예보지점 X, Y 좌표
struct Item: Codable {
    let fcstDate, fcstTime, fcstValue: String
    let nx, ny: Int
    let category: String
}


