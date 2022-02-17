//
//  WeatherData.swift
//  WeatherApp
//
//  Created by sumwb on 2022/02/17.
//

import Foundation

/*// API로 받아온 JSON 데이터 구조
{
    "response": {
        "header": {
            "resultCode": "00",
            "resultMsg": "NORMAL_SERVICE"
        },
        "body": {
            "dataType": "JSON",
            "items": {
                "item": [
                    {
                    "baseDate": "20220217",
                    "baseTime": "1400",
                    "category": "TMP",
                    "fcstDate": "20220217",
                    "fcstTime": "1500",
                    "fcstValue": "-2",
                    "nx": 55,
                    "ny": 127
                    },
                    {
                        ...
                    },
                ]
            },
            "pageNo": 1,
            "numOfRows": 1000,
            "totalCount": 700
        }
    }
}*/

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
    let category: Category
    let nx, ny: Int
}

/// - POP : 강수확률(%)
/// - PTY : 강수형태(없음 = 0, 비 = 1, 비/눈 = 2, 눈 = 3, 소나기 = 4)
/// - PCP : 1시간 강수량(mm)
/// - SNO : 1시간 신적설(cm)
/// - SKY : 하늘상태(맑음 =1, 구름많음(3), 흐림(4)
/// - TMP : 현재 기온(℃)
/// - TMN : 최저기온(℃)
/// - TMX : 최고기온(℃)
enum Category: String, Codable {
    case POP, PTY, PCP, SNO, SKY, TMP, TMN, TMX
}
