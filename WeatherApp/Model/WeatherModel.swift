//
//  WeatherModel.swift
//  WeatherApp
//
//  Created by sumwb on 2022/02/18.
//

/*
 date,time,[category:value]
 테이블 뷰에 보여질 것
 날짜
 시간 온도 하늘상태 강수량(신적설) 강수확률
 시간 온도 하늘상태 강수량(신적설) 강수확률
 시간 온도 하늘상태 강수량(신적설) 강수확률
 .
 .
 .
 날짜
 시간 온도 하늘상태 강수량(신적설) 강수확률
 시간 온도 하늘상태 강수량(신적설) 강수확률
 시간 온도 하늘상태 강수량(신적설) 강수확률
 .
 .
 .
 */
import Foundation

typealias ItemValue = [String:String] // key : category, value : fcstValue
typealias ItemTable = (String,String,ItemValue)
typealias LowHighTMP = (String, ItemValue)

struct WeatherModel {
    
    let tableViewData: [ItemTable]
    //let viewLowHighTMPData: [LowHighTMP]
    
    init(items: [Item]) {
        let useCategory: [String] = ["POP","PTY","PCP","SKY","SNO","TMP"]
        //let otherUseCategory: [String] = ["TMN","TMN"]
        
        var itemValue: ItemValue = [:]
        var timeData: [ItemTable] = []
        
        var time = items[0].fcstTime
        var date = items[0].fcstDate
        
        for i in items where useCategory.contains(i.category) {
            let value = setFcstValue(category: i.category, fcstValue: i.fcstValue)
            if time == i.fcstTime {
                itemValue[i.category] = value
            } else {
                timeData.append((date, time, itemValue))
                date = i.fcstDate
                time = i.fcstTime
                itemValue = [:]
                continue
            }
           
        }
        self.tableViewData = timeData
        print(timeData)
    }
}

// 자료구분문자(category)의 코드값을 확인하고 구분에 맞는 예보 값(fcstValue)을 표시해주는 함수
func setFcstValue(category: String, fcstValue: String) -> String {
    var valueString: String = ""
    switch category {
    case "POP": //강수확률
        valueString = fcstValue + "%"
    case "PTY": // 강수형태
        valueString = fcstValueOfPTY(fcstValue: fcstValue)
    case "PCP": // 강수량
        valueString = fcstValueOfPCP(fcstValue: fcstValue)
    case "SNO": // 신적설
        valueString = fcstValueOfSNO(fcstValue: fcstValue)
    case "SKY": // 하늘상태
        valueString = fcstValueOfSKY(fcstValue: fcstValue)
    case "TMP": // 기온
        valueString = fcstValue + "℃"
    case "TMN": // 최저기온
        valueString = fcstValue + "℃"
    case "TMX": // 최고기온
        valueString = fcstValue + "℃"
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
        value_PTY = "몰?루"
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
        value_SKY = "몰?루"
    }
    return value_SKY
}
