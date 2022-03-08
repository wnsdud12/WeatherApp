//
//  WeatherModel.swift
//  WeatherApp
//
//  Created by sumwb on 2022/02/18.
//

import Foundation

typealias ItemValue = [String:String] // key : category, value : fcstValue
typealias ItemTable = (date:String,time:String,value:ItemValue)
typealias LowHighTMP = (String, ItemValue)

struct WeatherModel {
    
    enum WeatherIcon: String {
        case sunny
        case night
        case cloud_sun
        case cloud_night
        case cloudy
        case rain
        case snow
        case rainyORsnowy
        case rain_shower
    }
    
    var timeArray: [[String]]
    var valueArray: [[ItemValue]]
    var sections: [String]
    var weatherIconString: String
    init(items: [Item]) {
        // 시간 별 날씨 데이터 받아오기
        var timeArray: [String] = []
        var valueArray: [ItemValue] = []
        var itemValue: ItemValue = [:]
        //let useCategory: [String] = ["POP","PTY","PCP","SKY","SNO","TMP"]
        let useCategory: [String] = ["TMP"]
        // ViewController에 보내 tableView에 표시해줄 데이터
        var returnTime: [[String]] = []
        var returnValue: [[ItemValue]] = []
        
        // 날짜와 시간이 달라졌는지 확인할 변수
        var isSameDate: Bool = true
        var isSameTime: Bool = true
        
        var sections: [String] = [items[0].fcstDate]
        
        for i in items.indices where useCategory.contains(items[i].category) {
            isSameDate = sections.last == items[i].fcstDate ? true : false
            isSameTime = timeArray.last == items[i].fcstTime ? true : false
            
            let value = setFcstValue(category: items[i].category, fcstValue: items[i].fcstValue)
            
            if !isSameTime {
                if !isSameDate {
                    sections.append(items[i].fcstDate)
                    returnTime.append(timeArray)
                    timeArray = []
                }
                timeArray.append(items[i].fcstTime)
            } else {
                itemValue[items[i].category] = value
            }
        }
        
        returnTime.append(timeArray)
        returnValue.append(valueArray)
        
        self.timeArray = returnTime
        self.valueArray = returnValue
        self.sections = sections
        self.weatherIconString = ""
    }
    //    원본
    //    init(items: [Item]) {
    //        // 시간 별 날씨 데이터 받아오기
    //        var timeArray: [String] = [items[0].fcstTime]
    //        var valueArray: [ItemValue] = []
    //        var itemValue: ItemValue = [:]
    //        let useCategory: [String] = ["POP","PTY","PCP","SKY","SNO","TMP"]
    //
    //        for item in items where useCategory.contains(item.category) {
    //            let value = setFcstValue(category: item.category, fcstValue: item.fcstValue)
    //
    //            if timeArray.last == item.fcstTime {
    //                itemValue[item.category] = value
    //            } else {
    //                timeArray.append(item.fcstTime)
    //                valueArray.append(itemValue)
    //
    //                itemValue = [:]
    //                itemValue[item.category] = value
    //            }
    //        }
    //        valueArray.append(itemValue)
    //
    //        self.timeArray = timeArray.map {
    //            convertTimeString(fcstTime: $0)
    //        }
    //        self.valueArray = valueArray
    //        self.weatherIconString = "" + ".png"
    //    }
}

// fcstTime로 받아온 시간 문자열의 형식인 HHmm을 HH시로 바꿔서 반환
// ex) 1600 -> 16시
func convertTimeString(fcstTime: String) -> String {
    var timeString: String = ""
    if var intTime = Int(fcstTime) {
        intTime = intTime / 100
        timeString = String(intTime)
    }
    return timeString + "시"
}
// 자료구분문자(category)의 코드값을 확인하고 구분에 맞는 예보 값(fcstValue)을 반환해주는 함수
func setFcstValue(category: String, fcstValue: String) -> String {
    var valueString: String = ""
    switch category {
    case "POP": //강수확률
        valueString = fcstValue + "%"
    case "PTY": // 강수형태
        valueString = fcstValueOfPTY(fcstValue: fcstValue)
    case "PCP": // 강수량
        //valueString = fcstValueOfPCP(fcstValue: fcstValue)
        valueString = fcstValue
    case "SNO": // 신적설
        //valueString = fcstValueOfSNO(fcstValue: fcstValue)
        valueString = fcstValue
    case "SKY": // 하늘상태
        valueString = fcstValueOfSKY(fcstValue: fcstValue)
    case "TMP": // 기온
        valueString = fcstValue + "º"
    case "TMN": // 최저기온
        valueString = fcstValue + "º"
    case "TMX": // 최고기온
        valueString = fcstValue + "º"
    default:
        break
    }
    return valueString
}
// 강수 형태의 값을 불러오는 함수
func fcstValueOfPTY(fcstValue: String) -> String {
    var value_PTY: String
    switch fcstValue {
    case "0":
        value_PTY = "없음"
    case "1":
        value_PTY = "비"
    case "2":
        value_PTY = "비/눈"
    case "3":
        value_PTY = "눈"
    case "4":
        value_PTY = "소나기"
    default:
        value_PTY = "error"
    }
    return value_PTY
}
// 강수량의 값을 불러오는 함수
func fcstValueOfPCP(fcstValue: String) -> String {
    var value_PCP: String = ""
    switch fcstValue {
    case "강수없음":
        value_PCP = "강수없음"
    default:
        let float_PCP: Float = Float(fcstValue)!
        switch float_PCP {
        case 0:
            value_PCP = "강수없음"
        case 0.1..<1.0:
            value_PCP = "1.0mm 미만"
        case 1.0..<30.0:
            value_PCP = String(float_PCP) + "mm"
        case 30.0..<50.0:
            value_PCP = "30.0~50.0mm"
        default:
            value_PCP = "50.0mm 이상"
        }
    }
    return value_PCP
}

// 신적설 값을 불러오는 함수
func fcstValueOfSNO(fcstValue: String) -> String {
    var value_SNO: String = ""
    switch fcstValue {
    case "적설없음":
        value_SNO = "적설없음"
    default:
        let float_SNO: Float = Float(fcstValue)!
        switch float_SNO {
        case 0:
            value_SNO = "적설없음"
        case 0.1..<1.0:
            value_SNO = "1.0cm 미만"
        case 1.0..<5.0:
            value_SNO = String(float_SNO) + "cm"
        default:
            value_SNO = "5.0cm 이상"
        }
    }
    return value_SNO
}

// 하늘상태의 값을 불러오는 함수
func fcstValueOfSKY(fcstValue: String) -> String {
    var value_SKY: String
    switch fcstValue {
    case "1":
        value_SKY = "맑음"
    case "3":
        value_SKY = "구름많음"
    case "4":
        value_SKY = "흐림"
    default:
        value_SKY = "error"
    }
    return value_SKY
}
