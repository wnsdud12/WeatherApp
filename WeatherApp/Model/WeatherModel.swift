//
//  WeatherModel.swift
//  WeatherApp
//
//  Created by 박준영 on 2022/03/18.
//

import Foundation
import UIKit

typealias WeatherValue = [String: String]
typealias WeatherTableData = (date: String, time: String, value: WeatherValue)

struct WeatherModel {
    var sections: [String]
    var time: [[String]]
    var value: [[WeatherValue]]
    // tableView에 보여질 데이터
    var cellTime: [String]
    var cellTMP: [String]
    var cellImgSKY: [UIImage]
    var cellSKY: [String]
    var cellPOP: [String]
    var cellPCP: [String]

    // 최저/최고 온도
    var arrTMX: [String]
    var arrTMN: [String]

    init(date:[String], time: [String], value: [WeatherValue]) {
        print("weatherModel create")
        print("date\n\(date)\n\n")
        print("time\n\(time)\n\n")
        print("value\n\(value)\n\n")
        let tupleSKY = setSKY(value: value, time: time)

        self.cellTime = time.map {
            let intTime: Int = Int($0)! / 100
            let strTime = String(intTime) + "시"

            return strTime
        }
        self.cellTMP = value.map{ $0["TMP"]! }
        self.cellImgSKY = tupleSKY.image.map{ UIImage(named: $0)! }
        self.cellSKY = tupleSKY.label
        self.cellPOP = value.map{ $0["POP"]! }
        self.cellPCP = value.map{ $0["PCP"]! }

        self.arrTMN = value.filter{$0["TMN"] != nil}.map{ $0["TMN"]!}
        self.arrTMX = value.filter{$0["TMX"] != nil}.map{ $0["TMX"]!}

        // date array remove duplicate
        let set = Set(date)
        let sections = Array(set).sorted{ $0 < $1 }
        self.sections = sections

        let splitArrays: (time: [[String]], value: [[WeatherValue]]) = splitIndex(time: time, value: value)
        self.time = splitArrays.time
        self.value = splitArrays.value

    } // init()

} // WeatherModel

func splitIndex(time: [String], value: [WeatherValue]) -> ([[String]], [[WeatherValue]]) {
    var newTime: [String] = []
    var newValue: [WeatherValue] = []
    var splitTime: [[String]] = []
    var splitValue: [[WeatherValue]] = []

    for i in time.indices {
        if time[i] != "0000" {
            newTime.append(time[i])
            newValue.append(value[i])
        } else if time[i] == "0000" {
            splitTime.append(newTime)
            splitValue.append(newValue)
            newTime = []
            newValue = []
            newTime.append(time[i])
            newValue.append(value[i])
        }
    }
    splitTime.append(newTime)
    splitValue.append(newValue)

    return (splitTime, splitValue)
}

func setSKY(value: [WeatherValue], time: [String]) -> (image: [String], label: [String]) {
    var isDay: Bool
    var newImg: [String] = []
    var newLabel: [String] = []
    for i in value.indices {
        // 6시~20시의 데이터는 낮 / 나머지는 밤
        isDay = (6...20).contains(Int(time[i])!) ? true : false
        if value[i]["PTY"] == "없음" {
            newLabel.append(value[i]["SKY"]!)
            switch value[i]["SKY"] {
                case "맑음":
                    isDay ? newImg.append("sunny.png") : newImg.append("night.png")
                case "구름많음":
                    isDay ? newImg.append("cloud_sun.png") : newImg.append("cloud_night.png")
                case "흐림":
                    newImg.append("cloudy.png")
                default:
                    break
            }
        } else {
            switch value[i]["PTY"] {
                case "비":
                    newImg.append("rain.png")
                case "비/눈":
                    newImg.append("rainyORsnowy.png")
                case "눈":
                    newImg.append("snow.png")
                case "소나기":
                    newImg.append("rain_shower.png")
                default:
                    break
            }
        }
    }
    return (newImg, newLabel)
}
