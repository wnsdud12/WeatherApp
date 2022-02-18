//
//  WeatherModel.swift
//  WeatherApp
//
//  Created by sumwb on 2022/02/18.
//

import Foundation

typealias ItemTable = (date:String,time:String,[String:String])
typealias aaa = (String,String,String,String)

struct WeatherModel {
    var itemForView: [aaa]
    
    init(fcstDate: [String], fcstTime: [String], category: [String], fcstValue:[String]) {
        var itemTableArray: [aaa] = []
        for i in fcstDate.indices {
            let newData:aaa = (fcstDate[i],fcstTime[i],category[i],fcstValue[i])
            itemTableArray.append(newData)
        }
        self.itemForView = itemTableArray
    }
}






//struct WeatherModel {
//    let category: String
//    var fcstValue: String {
//        switch category {
//        case "POP": //강수확률
//            return self.fcstValue + "%"
//        case "PTY": // 강수형태
//            return fcstValueOfPTY(fcstValue: self.fcstValue)
//        case "PCP": // 강수량
//            return fcstValueOfPCP(fcstValue: self.fcstValue)
//        case "SNO": // 신적설
//            return fcstValueOfSNO(fcstValue: self.fcstValue)
//        case "SKY": // 하늘상태
//            return fcstValueOfSKY(fcstValue: self.fcstValue)
//        case "TMP": // 기온
//            return self.fcstValue + "℃"
//        case "TMN": // 최저기온
//            return self.fcstValue + "℃"
//        case "TMX": // 최고기온
//            return self.fcstValue + "℃"
//        default:
//            return ""
//        }
//    }
//}
//func fcstValueOfPTY(fcstValue: String) -> String {
//    var value_PTY: String
//    switch fcstValue {
//    case "0":
//        value_PTY = "없음"
//    case "1":
//        value_PTY = "비"
//    case "2":
//        value_PTY = "비/눈"
//    case "3":
//        value_PTY = "눈"
//    case "4":
//        value_PTY = "소나기"
//    default:
//        value_PTY = "몰?루"
//    }
//    return value_PTY
//}
//// 강수량의 값을 불러오는 함수
//func fcstValueOfPCP(fcstValue: String) -> String {
//    var value_PCP: String = ""
//    switch fcstValue {
//    case "강수없음":
//        value_PCP = "강수없음"
//    default:
//        let float_PCP: Float = Float(fcstValue)!
//        switch float_PCP {
//        case 0:
//            value_PCP = "강수없음"
//        case 0.1..<1.0:
//            value_PCP = "1.0mm 미만"
//        case 1.0..<30.0:
//            value_PCP = String(float_PCP) + "mm"
//        case 30.0..<50.0:
//            value_PCP = "30.0~50.0mm"
//        default:
//            value_PCP = "50.0mm 이상"
//        }
//    }
//    return value_PCP
//}
//
//// 신적설 값을 불러오는 함수
//func fcstValueOfSNO(fcstValue: String) -> String {
//    var value_SNO: String = ""
//    switch fcstValue {
//    case "적설없음":
//        value_SNO = "적설없음"
//    default:
//        let float_SNO: Float = Float(fcstValue)!
//        switch float_SNO {
//        case 0:
//            value_SNO = "적설없음"
//        case 0.1..<1.0:
//            value_SNO = "1.0cm 미만"
//        case 1.0..<5.0:
//            value_SNO = String(float_SNO) + "cm"
//        default:
//            value_SNO = "5.0cm 이상"
//        }
//    }
//    return value_SNO
//}
//
//// 하늘상태의 값을 불러오는 함수
//func fcstValueOfSKY(fcstValue: String) -> String {
//    var value_SKY: String
//    switch fcstValue {
//    case "1":
//        value_SKY = "맑음"
//    case "3":
//        value_SKY = "구름많음"
//    case "4":
//        value_SKY = "흐림"
//    default:
//        value_SKY = "몰?루"
//    }
//    return value_SKY
//}
