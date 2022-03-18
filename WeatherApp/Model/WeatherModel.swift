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
    var cellTime: [String]
    var cellTMP: [String]
    var cellImgSKY: [UIImage]
    var cellSKY: [String]
    var cellPOP: [String]
    var cellPCP: [String]
    init(date:[String], time: [String], value: [WeatherValue]) {
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
    } // init()

} // WeatherModel
func setSKY(value: [WeatherValue], time: [String]) -> (image: [String], label: [String]) {
    var isDay: Bool
    var newImg: [String] = []
    var newLabel: [String] = []
    for i in value.indices {
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
