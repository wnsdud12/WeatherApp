////
////  WeatherModel.swift
////  WeatherApp
////
////  Created by 박준영 on 2022/03/18.
////
//
//import Foundation
//import UIKit
//
//typealias WeatherValue = [String: String]
//typealias WeatherTableData = (date: String, time: String, value: WeatherValue)
//
//struct WeatherModel {
//    var sections: [String]
//    var cellTime: [[String]]
//    var cellTMP: [[String]]
//    var cellSKYPTY: [[WeatherValue]]
//    var cellPOP: [[String]]
//    var cellPCP: [[String]]
//    var headerTMXTMN: [WeatherValue]
//    var nowWeatherData: NowWeather
//    init(date:[String], time: [String], value: [WeatherValue]) {
//        nowWeatherData = NowWeather(date: date[0], time: time[0], value: value[0])
//
//        // date array remove duplicate
//        let set = Set(date)
//        let sections = Array(set).sorted{ $0 < $1 }
//        self.sections = sections
//
//        // time & value Array split
//        let splitArrays: (time: [[String]], value: [[WeatherValue]]) = splitIndex(time: time, value: value)
//        let cellTime: [[String]] = splitArrays.time.compactMap {
//            $0.compactMap{
//                convertTimeString(fcstTime:$0)
//            }
//        }
//        self.cellTime = cellTime
//
//        let splitedValue: [[WeatherValue]] = splitArrays.value
//
//        self.cellTMP = splitedValue.compactMap { $0.compactMap {$0["TMP"]} }
//        self.cellSKYPTY = splitedValue.compactMap{ $0.compactMap { $0.filter{ $0.key == "SKY" || $0.key == "PTY" }}}
//        self.cellPOP = splitedValue.compactMap { $0.compactMap {$0["POP"]} }
//        self.cellPCP = splitedValue.compactMap { $0.compactMap {$0["PCP"]} }
//
//        let headerTMXTMN: [WeatherValue] = {
//            var newDictArr: [WeatherValue] = []
//            var newDict: WeatherValue = [:]
//            for i in splitedValue {
//                for j in i {
//                    if j["TMX"] != nil {
//                        newDict["TMX"] = j["TMX"]
//                    }
//                    if j["TMN"] != nil {
//                        newDict["TMN"] = j["TMN"]
//                    }
//                }
//                newDictArr.append(newDict)
//                newDict = [:]
//            }
//            return newDictArr
//        }()
//        self.headerTMXTMN = headerTMXTMN
//    } // init()
//
//} // WeatherModel
//
//// 현재 시간의 날씨데이터
//struct NowWeather {
//    let date: String
//    let time: String
//    let value: WeatherValue
//}
//
//func splitIndex(time: [String], value: [WeatherValue]) -> ([[String]], [[WeatherValue]]) {
//    var newTime: [String] = []
//    var newValue: [WeatherValue] = []
//    var splitTime: [[String]] = []
//    var splitValue: [[WeatherValue]] = []
//
//    for i in time.indices {
//        if time[i] != "0000" {
//            newTime.append(time[i])
//            newValue.append(value[i])
//        } else if time[i] == "0000" {
//            splitTime.append(newTime)
//            splitValue.append(newValue)
//            newTime = []
//            newValue = []
//            newTime.append(time[i])
//            newValue.append(value[i])
//        }
//    }
//    splitTime.append(newTime)
//    splitValue.append(newValue)
//
//    return (splitTime, splitValue)
//}
//
