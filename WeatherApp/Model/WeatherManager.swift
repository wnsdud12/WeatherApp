//
//  WeatherManager.swift
//  WeatherApp
//
//  Created by 박준영 on 2022/03/17.
//

import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeatherTable(_ weatherManager: WeatherManager, weather: WeatherModel)
}
struct WeatherManager {
    let weatherURL = "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst?"
    private let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String

    var delegate: WeatherManagerDelegate?

    func fetchWeather(nx: Int, ny: Int) {
        let baseDateTime: (date: String, time: String) = setBaseDateTime()

        guard let apiKey = apiKey else { return print("URL이 이상해요") }
        let weatherURLString = "\(weatherURL)serviceKey=\(apiKey)&base_date=\(baseDateTime.date)&base_time=\(baseDateTime.time)&nx=\(nx)&ny=\(ny)&numOfRows=1000&pageNo=1&dataType=JSON"
        print(weatherURLString)
        preformRequest(with: weatherURLString)
    }
    func preformRequest(with urlString: String) {

        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) {
                data, response, error in
                if error != nil {
                    print("preformRequestError - \(error!.localizedDescription)")
                    return
                }
                if let safeData = data {
                    if let weather = parseJSON(weatherData: safeData) {
                        delegate?.didUpdateWeatherTable(self, weather: weather)
                    }
                }
            }
            task.resume()
        } else {
            print("url error")
        }
    }
    func parseJSON(weatherData: Data) -> WeatherModel? {
        let UseCategory = ["TMX", "TMN", "TMP", "SKY", "PTY", "PCP", "SNO", "POP"]
        var dateArray: [String] = []
        var timeArray: [String] = []
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let weatherData = decodedData.response.body.items.item
            let items = weatherData.filter{UseCategory.contains($0.category)}

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
                        dateArray.append(item.fcstDate)
                        timeArray.append(item.fcstTime)
                    }
                }
                return array
            }()
            guard dateArray.count == timeArray.count, timeArray.count == valueArray.count else {
                print("error - 데이터가 빠진게 있습니다.")
                return nil
            }
            let weather = WeatherModel(date: dateArray, time: timeArray, value: valueArray)
            return weather
        }
        catch {
            print(error)
            return nil
        }
    }
}

// 혹시 저장할 때 "\(base_date)&base_time=\(base_time)" 으로 저장해도 되는지 확인
func setBaseDateTime() -> (String, String) {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH"
    var nowHour = formatter.string(from: Date()).toInt
    formatter.dateFormat = "mm"
    let nowMinute = formatter.string(from: Date()).toInt

    let base_date: String = {
        var base_date: String = ""
        switch (nowHour, nowMinute) {
            case (0...1, _):
                fallthrough
            case (2, 0..<10):
                let date = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
                // format 과정은 따로 함수로 하자
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyyMMdd"
                base_date = formatter.string(from: date)
            default:
                let date = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyyMMdd"
                base_date = formatter.string(from: date)
        }
        return base_date
    }()

    let base_time: String = {
        var base_time: String = ""

        let arrBaseDate: [Int] = [2,5,8,11,14,17,20,23] // base_time으로 사용 가능한 값의 배열

        switch (arrBaseDate.contains(nowHour), nowMinute >= 10) {
            case (true, true):
                base_time = String(format: "%02d00", nowHour)
            case (true, false):
                let newIndex = arrBaseDate.firstIndex(of: nowHour)! - 1
                if newIndex <= 0 {
                    base_time = "2300"
                } else {
                    base_time = String(format: "%02d00", arrBaseDate[newIndex])
                }
            case (false, _):
                while arrBaseDate.contains(nowHour) == false {
                    if nowHour > 0 {
                        nowHour -= 1
                    } else {
                        nowHour = 23
                    }
                }
                base_time = String(format: "%02d00", nowHour)
        }

        return base_time
    }()

    return (base_date, base_time)
}
// 테스트용 코드
func setBaseDateTime(testDate: String) -> (String, String) {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd HH:mm"
    let date = formatter.date(from: testDate)!
    formatter.dateFormat = "HH"
    var nowHour = formatter.string(from: date).toInt
    formatter.dateFormat = "mm"
    let nowMinute = formatter.string(from: date).toInt

    let base_date: String = {
        var base_date: String = ""
        print("base_date switch")
        switch (nowHour, nowMinute) {
            case (0...1, _):
                print("case (0...1, _)")
                fallthrough
            case (2, 0..<10):
                print("case (2, 0..<10)")
                let date = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyyMMdd"
                base_date = formatter.string(from: date)
            default:
                print("default case")
                let arr = testDate.components(separatedBy: " ")
                base_date = arr[0]
        }
        return base_date
    }()

    let base_time: String = {
        var base_time: String = ""

        let arrBaseDate: [Int] = [2,5,8,11,14,17,20,23] // base_time으로 사용 가능한 값의 배열
        print("base_time switch")
        switch (arrBaseDate.contains(nowHour), nowMinute >= 10) {
            case (true, true):
                print("case (true, true)")
                base_time = String(format: "%02d00", nowHour)
            case (true, false):
                print("case (true, false)")
                let newIndex = arrBaseDate.firstIndex(of: nowHour)! - 1
                if newIndex <= 0 {
                    print("case (true, false) - if(true)")
                    base_time = "2300"
                } else {
                    print("case (true, false) - if(false)")
                    base_time = String(format: "%02d00", arrBaseDate[newIndex])
                }
            case (false, _):
                print("case (false, _)")
                while arrBaseDate.contains(nowHour) == false {
                    if nowHour > 0 {
                        nowHour -= 1
                    } else {
                        nowHour = 23
                    }
                }
                base_time = String(format: "%02d00", nowHour)
        }

        return base_time
    }()
    print("base date\n\(base_date)\nbase time\n\(base_time)")

    return (base_date, base_time)
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

