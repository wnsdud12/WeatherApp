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
// fcstDate로 받아온 날짜 문자열의 형식인 yyyyMMdd를 M월 d일 (E)로 변환
// ex) 20220309 -> 3월 9일 (수)
private func convertDateString(fcstDate: String) -> String {
    var dateString: String = ""
    var date: Date = Date()
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.dateFormat = "yyyyMMdd"
    date = formatter.date(from: fcstDate)!

    formatter.dateFormat = "M월 d일 (E)"
    dateString = formatter.string(from: date)
    return dateString
}
// fcstTime로 받아온 시간 문자열의 형식인 HHmm을 HH시로 반환
// ex) 1600 -> 16시
func convertTimeString(fcstTime: String) -> String {
    var timeString: String = ""
    var intTime: Int = fcstTime.toInt
    intTime = intTime / 100
    timeString = String(intTime)

    return timeString + "시"
}
