//
//  WeatherLocale.swift
//  WeatherApp
//
//  Created by 박준영 on 2022/04/07.
//

import Foundation

struct WeatherLocales {
    static var locales: [WeatherLocale] = [WeatherLocale]()
    static let test = WeatherLocalesInit()
    private init() {}
}
private func WeatherLocalesInit() {
    let localeList = parseCSV()
    if let localeList = localeList {
        var sidoName: String
        var gunguName: String
        var dongName: String
        var x: Int
        var y: Int
        var point: Point<Int>
        for localeArr in localeList {
            sidoName = localeArr[0]
            gunguName = localeArr[1]
            dongName = localeArr[2]
            x = localeArr[3].toInt
            y = {
                if localeArr[4].contains("\r") {
                    return localeArr[4].components(separatedBy: "\r")[0].toInt
                }
                return localeArr[4].toInt
            }()
            point = (x,y)
            print("localeArr\n시/도 : \(sidoName), 군/구 : \(gunguName), 동 : \(dongName), 좌표 : \(point)")
        }
    }
}
private func parseCSV() -> [[String]]? {
    do {
        let path = Bundle.main.path(forResource: "LocaleData", ofType: "csv")!
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        let dataEncoded = String(data: data, encoding: .utf8)
        if let localeList = dataEncoded?.components(separatedBy: "\n").map{$0.components(separatedBy: ",")} {
            return localeList
        } else {
            return nil
        }
    } catch {
        print(error)
        return nil
    }
}
struct WeatherLocale {
    let sido: String
    let gugun: String
    let eupmyeondong: String
    let point: Point<Int>
}
