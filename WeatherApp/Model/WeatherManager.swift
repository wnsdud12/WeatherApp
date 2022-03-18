//
//  WeatherManager.swift
//  WeatherApp
//
//  Created by 박준영 on 2022/03/17.
//

import Foundation
import Alamofire

//let UseCategory = ["TMX", "TMN", "TMP", "SKY", "PTY", "PCP", "SNO", "POP"]
let UseCategory = ["TMP"]
protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
}

struct WeatherManager {
    var delegate: WeatherManagerDelegate?
    
    let url = "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst"
    let API_KEY = Bundle.main.infoDictionary?["API_KEY"] as! String
    var params: [String: String] = [
        "pageNo": "1",
        "numOfRows": "1000",
        "dataType": "JSON"
    ]
    
    
    // URL을 만들 때 필요한 parameter 생성
    // base_date와 base_time은 매번 달라지기 때문에 나중에 초기화
    mutating func createParameter(nx: Int, ny: Int) {
        let nx: String = String(nx)
        let ny: String = String(ny)
        self.params["serviceKey"] = API_KEY.removingPercentEncoding
        self.params["nx"] = nx
        self.params["ny"] = ny
        preformRequest(url: url)
        print(nx,ny)
    }
    mutating func preformRequest(url: String) {
        self.params["base_date"] = setBaseDate()
        self.params["base_time"] = "2300"
        
        // test
        //        print("test")
        //        AF.request(url, parameters: self.params).responseString {res in print(res)}
        //        print("\n\n\n\n")
        
        
        AF.request(url, parameters: self.params, encoder: URLEncodedFormParameterEncoder.default).responseDecodable(of: WeatherData.self) {
            response in
            if let data = response.value?.response.body.items.item {
                // 데이터 가공하는 코드
                let items = data.filter { UseCategory.contains($0.category) }
                print(items)

                let dateArray = items.map{ $0.fcstDate }
                let timeArray = items.map{ $0.fcstTime }
                let valueArray: [WeatherValue] = {
                    var fcstTime = items[0].fcstTime
                    var value: WeatherValue = [:]
                    var array: [WeatherValue] = []
                    for item in items {
                        if fcstTime == item.fcstTime {
                            value[item.category] = setFcstValue(category: item.category, fcstValue: item.fcstValue)
                            fcstTime = item.fcstTime
                        } else {
                            fcstTime = item.fcstTime
                            array.append(value)
                            value = [:]
                            value[item.category] = setFcstValue(category: item.category, fcstValue: item.fcstValue)
                        }
                    }
                    array.append(value)
                    return array
                }()
                if dateArray.count == timeArray.count, timeArray.count == valueArray.count {
                    let weather = WeatherModel(date: dateArray, time: timeArray, value: valueArray)

                } else {
                    print("error - 데이터가 빠진게 있습니다.")
                }

            }
        }

    }
    func setBaseDate() -> String {
        let date = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        
        let base_date = formatter.string(from: date)
        
        return base_date
    }
}


// 자료구분문자(category)의 코드값을 확인하고 구분에 맞는 예보 값(fcstValue)을 반환해주는 함수
func setFcstValue(category: String, fcstValue: String) -> String {
    var valueString: String = ""
    switch category {
        case "POP": //강수확률
            valueString = fcstValue + "%"
        case "PTY": // 강수형태
            valueString = {
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
            }()
        case "PCP": // 강수량
            fallthrough
        case "SNO": // 신적설
            valueString = fcstValue
        case "SKY": // 하늘상태
            valueString = {
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
            }()
        case "TMP": // 기온
            fallthrough
        case "TMN": // 최저기온
            fallthrough
        case "TMX": // 최고기온
            valueString = fcstValue + "º"
        default:
            break
    }
    return valueString
}

