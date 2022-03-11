//
//  WeatherModel.swift
//  WeatherApp
//
//  Created by sumwb on 2022/02/18.
//

import Foundation

typealias ItemValue = [String:String] // key : category, value : fcstValue


struct WeatherModel {
    var table_time: [[String]]
    var table_value: [[ItemValue]]
    var table_date: [String]
    var weatherIconString: String
    
    init(items: [Item]) {
        let useCategory: [String] = ["POP","PTY","PCP","SKY","SNO","TMP"]
        
        var itemValue: ItemValue = [:]
        
        var timeArray: [String] = []
        var valueArray: [ItemValue] = []
        
        var dateArray: [String] = []
        var returnTime: [[String]] = []
        var returnValue: [[ItemValue]] = []
        
        var isTimeChange: Bool = false
        var isDateChange: Bool = false
        
        for i in 0..<items.count {
            // 날짜 배열
            if dateArray.last != items[i].fcstDate {
                isDateChange = true
                dateArray.append(items[i].fcstDate)
            } else {
                isDateChange = false
            }
            
            // 시간 배열
            if i == 0 {
                timeArray.append(items[i].fcstTime)
            }
            if items.count == i + 1 {
                returnTime.append(timeArray)
            }
            
            if timeArray.last != items[i].fcstTime {
                isTimeChange = true
                if isDateChange == true {
                    returnTime.append(timeArray)
                    timeArray = []
                } else {
                    timeArray.append(items[i].fcstTime)
                }
            } else {
                isTimeChange = false
            }
            
            // 값 배열
            if useCategory.contains(items[i].category) {
                let value = setFcstValue(category: items[i].category, fcstValue: items[i].fcstValue)
                
                if !isTimeChange {
                    itemValue[items[i].category] = value
                } else {
                    if isDateChange {
                        valueArray.append(itemValue)
                        returnValue.append(valueArray)
                        
                        itemValue = [:]
                        valueArray = []
                        
                        itemValue[items[i].category] = value
                    } else {
                        valueArray.append(itemValue)
                        itemValue = [:]
                        
                        itemValue[items[i].category] = value
                    }
                }
            }
        }
        
        valueArray.append(itemValue)
        returnValue.append(valueArray)
        
        self.table_date = dateArray
        self.table_time = returnTime
        self.table_value = returnValue
        self.weatherIconString = ""
        
    }
    
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
