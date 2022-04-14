//
//  WeatherLocale.swift
//  WeatherApp
//
//  Created by 박준영 on 2022/04/07.
//

import Foundation

struct WeatherLocales {
    static var locales: [WeatherLocale] = WeatherLocalesInit()!
    private init() {}
}
private func WeatherLocalesInit() -> [WeatherLocale]? {
    let localeList = parseCSV()
    var locales: [WeatherLocale] = []
    if let localeList = localeList {
        var sido: String
        var gugun: String
        var eupmyeondong: String
        var x: Int
        var y: Int
        var point: (Int, Int)
        for localeArr in localeList {
            sido = localeArr[0]
            gugun = localeArr[1]
            eupmyeondong = localeArr[2]
            x = localeArr[3].toInt
            y = {
                if localeArr[4].contains("\r") {
                    return localeArr[4].components(separatedBy: "\r")[0].toInt
                }
                return localeArr[4].toInt
            }()
            point = (x,y)
            locales.append(WeatherLocale(sido: sido, gugun: gugun, eupmyeondong: eupmyeondong, point: point))
        }
        return locales
    } else {
        print("error - LocaleData를 받아올 수 없음")
        return nil
    }
}
private func parseCSV() -> [[String]]? {
    do {
        let path = Bundle.main.path(forResource: "LocaleData", ofType: "csv")!
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        let dataEncoded = String(data: data, encoding: .utf8)
        if let localeList = dataEncoded?.components(separatedBy: "\n").map({$0.components(separatedBy: ",")}) {
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
    let point: (x: Int, y: Int)
    var address: String {
        get {
            return self.sido + " " + self.gugun + " " + self.eupmyeondong
        }
    }
}
