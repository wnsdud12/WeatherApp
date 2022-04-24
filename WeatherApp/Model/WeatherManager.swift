//
//  WeatherManager.swift
//  WeatherApp
//
//  Created by 박준영 on 2022/04/15.
//

import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeatherTable(_ weatherManager: WeatherManager, weather: [WeatherModel])
    func didUpdateNowWeatherData(_ weatherManager: WeatherManager, nowWeatherData: WeatherModel?)
}
// fcst : 단기예보조회
// ncst : 초단기실황조회
struct WeatherManager {
    let weatherURL = "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/"
    private let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String

    var delegate: WeatherManagerDelegate?

    func fetchWeather(nx: Int, ny: Int) async {
        let fcstBaseDateTime: (date: String, time: String) = setBaseDateTime()
        let ncstBaseDateTime: (date: String, time: String) = setNcstBaseDateTime()

        guard let apiKey = apiKey else { return print("URL이 이상해요") }
        let fcstURL = "\(weatherURL)getVilageFcst?serviceKey=\(apiKey)&base_date=\(fcstBaseDateTime.date)&base_time=\(fcstBaseDateTime.time)&nx=\(nx)&ny=\(ny)&numOfRows=1000&pageNo=1&dataType=JSON"
        let ncstURL = "\(weatherURL)getUltraSrtNcst?serviceKey=\(apiKey)&base_date=\(ncstBaseDateTime.date)&base_time=\(ncstBaseDateTime.time)&nx=\(nx)&ny=\(ny)&numOfRows=100&pageNo=1&dataType=JSON"

        print("")
        print("==============")
        print("fcstURL\n\(fcstURL)")
        print("==============")
        print("")
        print("")
        print("==============")
        print("ncstURL\n\(ncstURL)")
        print("==============")
        print("")
        await preformRequest(fcstURL: fcstURL, ncstURL: ncstURL)
    }
    func preformRequest(fcstURL: String, ncstURL: String) async {
        do {
            // 단기예보조회
            guard let url = URL(string: fcstURL) else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            let weather = parseJSON(fcstData: data)
            delegate?.didUpdateWeatherTable(self, weather: weather)
            // 초단기실황조회
            guard let url = URL(string: ncstURL) else { return }
            let (data2, _) = try await URLSession.shared.data(from: url)
            let nowWeather = parseJSON(ncstData: data2)
            delegate?.didUpdateNowWeatherData(self, nowWeatherData: nowWeather)
        } catch {
            print(error)
        }
    }
    // 단기예보조회
    func parseJSON(fcstData: Data) -> [WeatherModel] {
        let nowTime: Int = { // baseTime은 14시일 때 1400, 15시일 때 1500의 형식으로 나오기 때문에 비교할 때 편하게 하기 위해 100을 곱해줌
            let date = Date.now
            let formatter = DateFormatter()
            formatter.dateFormat = "HH"
            let nowTime = formatter.string(from: date).toInt * 100
            return nowTime
        }()
        // 받아온 데이터를 전부 for문으로 돌리면 시간이 오래 걸리기 때문에 사용할 카테고리만 모아서 필터링했음
        // TMX : 일 최고기온, TMN : 일 최저기온, TMP : 1시간 기온, SKY : 하늘상태, PTY : 강수형태, PCP : 1시간 강수량, SNO : 1시간 신적설, POP : 강수확률
        let useCategory = ["TMX", "TMN", "TMP", "SKY", "PTY", "PCP", "SNO", "POP"]
        let decoder = JSONDecoder()
        var weatherArray: [WeatherModel] = []
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: fcstData)
            let weatherData = decodedData.response.body.items.item
            let items = weatherData.filter{useCategory.contains($0.category)}
            var date: String = items[0].fcstDate
            var time: String = items[0].fcstTime
            var weatherValue: WeatherValue = [:]

            for i in items.indices {
                let category = items[i].category
                let value = setFcstValue(category: category, fcstValue: items[i].fcstValue)
                if time == items[i].fcstTime {
                    weatherValue[category] = value
                } else {
                    weatherArray.append(WeatherModel.init(date: date, time: time, value: weatherValue))
                    weatherValue = [:]
                    weatherValue[category] = value
                    time = items[i].fcstTime
                    date = items[i].fcstDate
                }
            }
        }
        catch {
            print(error)
        }
        let weather = weatherArray.filter{ // 과거 데이터는 보이지 않게
            if $0.date <= weatherArray[0].date {
                if $0.time.toInt <= nowTime {
                    return false
                } else {
                    return true
                }
            } else {
                return true
            }
        }
        return weather
    }
    // 초단기실황조회
    func parseJSON(ncstData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(NowWeatherData.self, from: ncstData)
            let nowWeatherData = decodedData.response.body.items.item
            let date = nowWeatherData[0].baseDate
            let time = nowWeatherData[0].baseTime
            var value: WeatherValue = [:]
            for item in nowWeatherData {
                switch item.category {
                    case "T1H": // 기온
                        value["T1H"] = item.obsrValue
                    case "RN1": // 1시간 강수량
                        value["RN1"] = item.obsrValue
                    case "PTY": // 강수형태
                        value["PTY"] = item.obsrValue
                    default:
                        break
                }
            }
            let nowWeather = WeatherModel(date: date, time: time, value: value)
            return nowWeather
        } catch {
            print(error)
            return nil
        }
    }
}

// 자료구분문자(category)의 코드값을 확인하고 구분에 맞는 예보 값(fcstValue)을 반환해주는 함수(단기예보 전용)
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

// 단기예보조회 API에 요청할 날짜 / 시간
// 날짜는 yyyyMMdd 포맷으로 요청
// 시간은 HH00 포맷으로 요청, ex) 2시 59분에 요청 -> url에는 0200으로 입력
// *오전 2시부터 3시간 간격마다(useCategory 배열) 예보 데이터를 받아오는데 해당 시각 10분 후부터 제공
// ex) 2시(14시) 10분부터 2시(14시) 데이터를 받아올 수 있으며, 2시(14시) 9분에 조회할 시 23시(11시) 데이터를 받아옴
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
        let arrBaseDate: [Int] = [2,5,8,11,14,17,20,23]

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
// 단기예보조회 API에 오류가 있을 시 테스트를 위해 문자열로 날짜 및 시간을 직접 입력
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

        let arrBaseDate: [Int] = [2,5,8,11,14,17,20,23]
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

// 초단기실황조회 API에 요청할 날짜 / 시간
// 날짜는 yyyyMMdd 포맷으로 요청
// 시간은 HH00 포맷으로 요청, ex) 2시 59분에 요청 -> url에는 0200으로 입력
// *매시각 예보 데이터를 받아오는데 해당 시각 30분에 생성되며 10분마다 최신 정보로 업데이트
// (30분에 생성은 되지만 40분 전까지는 해당 시각의 데이터를 받을 수 없음..)
// ex) 2시 40분부터 2시 데이터를 받아올 수 있으며, 2시 39분에 데이터 조회시 url에 입력할 때는 0100으로 입력해야 함
func setNcstBaseDateTime() -> (String, String) {
    let now = Date.now
    let formatter = DateFormatter()
    formatter.dateFormat = "HH"
    var hour = formatter.string(from: now).toInt
    formatter.dateFormat = "mm"
    let minute = formatter.string(from: now).toInt

    let base_date: String = {
        var base_date = ""
        formatter.dateFormat = "yyyyMMdd"
        switch (hour, minute) {
            case (0, 0 ..< 40):
                let date = Calendar.current.date(byAdding: .day, value: -1, to: now)!
                base_date = formatter.string(from: date)
            case (_, 40 ..< 59):
                base_date = formatter.string(from: now)
            case (_, 0 ..< 40):
                let date = Calendar.current.date(byAdding: .hour, value: -1, to: now)!
                base_date = formatter.string(from: date)
            default:
                break
        }
        return base_date
    }()
    let base_time: String = {
        var base_time = ""
        if minute > 40 {
            if hour == 0 {
                base_time = "0000"
            } else {
                base_time = String(format: "%02d00", hour)
            }
        } else {
            if hour == 0 {
                base_time = "2300"
            } else {
                hour -= 1
                base_time = String(format: "%02d00", hour)
            }
        }
        return base_time
    }()
    return (base_date, base_time)
}
// 초단기실황조회 API에 오류가 있을 시 테스트를 위해 문자열로 날짜 및 시간을 직접 입력
func setNcstBaseDateTime(testDate: String) -> (String, String) {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd HH:mm"
    let date = formatter.date(from: testDate)!
    formatter.dateFormat = "HH"
    var hour = formatter.string(from: date).toInt
    formatter.dateFormat = "mm"
    let minute = formatter.string(from: date).toInt

    let base_date: String = {
        var base_date = ""
        formatter.dateFormat = "yyyyMMdd"
        switch (hour, minute) {
            case (0, 0 ..< 40):
                let date = Calendar.current.date(byAdding: .day, value: -1, to: date)!
                base_date = formatter.string(from: date)
            case (_, 40 ..< 59):
                base_date = formatter.string(from: date)
            case (_, 0 ..< 40):
                let date = Calendar.current.date(byAdding: .hour, value: -1, to: date)!
                base_date = formatter.string(from: date)
            default:
                break
        }
        return base_date
    }()
    let base_time: String = {
        var base_time = ""
        if minute > 40 {
            if hour == 0 {
                base_time = "0000"
            } else {
                base_time = String(format: "%02d00", hour)
            }
        } else {
            if hour == 0 {
                base_time = "2300"
            } else {
                hour -= 1
                base_time = String(format: "%02d00", hour)
            }
        }
        return base_time
    }()
    return (base_date, base_time)
}
