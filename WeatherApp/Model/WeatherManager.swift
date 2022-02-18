//
//  WeatherManager.swift
//  WeatherApp
//
//  Created by sumwb on 2022/02/17.
//

import Foundation

typealias ItemTable = (date:String,time:String,[String:String])

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURL = "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst?"
    private let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather() {
        print("start - fetchWeather()")
        let baseDateTime: (String, String) = setBaseDateTime()
        guard let apiKey = apiKey else {
            return print("URL이 이상해요")
        }
        let urlString = "\(weatherURL)serviceKey=\(apiKey)&base_date=\(baseDateTime.0)&base_time=\(baseDateTime.1)&nx=55&ny=127&numOfRows=100&pageNo=1&dataType=JSON"
        preformRequest(with: urlString)
        print(urlString)
    }
    func fetchWeather(testDate: String) {
        print("start - fetchWeather(testDate:)")
        let baseDateTime: (String, String) = setBaseDateTime(testDate: testDate)
        guard let apiKey = apiKey else { return }
        let urlString = "\(weatherURL)&serviceKey=\(apiKey)&base_date=\(baseDateTime.0)&base_time=\(baseDateTime.1)"
        preformRequest(with: urlString)
    }
}

func preformRequest(with urlString: String) {
    print("start - preformRequest(with:)")
    if let url = URL(string: urlString) {
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) {
            (data, response, error) in
            if error != nil {
                print("error - don't start preformRequest(with:)")
                return
            }
            if let safeData = data {
                parseJSON(weatherData: safeData)
            } else {
                print("error - don't start parsJSON(weatherData:)")
            }
        }
        task.resume()
    } else {
        print("error - url is wrong")
    }
}

func parseJSON(weatherData: Data) {
    print("start : parseJSON(weatherData:)")
    let decoder = JSONDecoder()
    do {
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
        let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
        print(decodedData)
        var itemTable: [ItemTable] = []
        for items in decodedData.response.body.items.item.indices {
            let fcstDate = decodedData.response.body.items.item[items].fcstDate
            let fcstTime = decodedData.response.body.items.item[items].fcstTime
            let category = decodedData.response.body.items.item[items].category
            let value = decodedData.response.body.items.item[items].fcstValue
        }
        print("우선 성공")
        //print("날짜 : \(fcstDate)\n시간 : \(fcstTime)\n데이터 : \(category) - \(value)")
    } catch {
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            print("error - \(decodedData.response.header.resultMsg)")
        }
        catch {
            print("error - can't get API data")
        }
    }
}

/// 현재 시간 정보를 받아와 날짜와 시간값을 요청값에 맞게 변환
/// - returns: ( base_date, base_time)
func setBaseDateTime() -> (String, String) {
    let date: Date = Date() // 현재시간
    var base_date: String = ""
    var base_time: String = ""
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko-KR")
    let baseTimeIntArray: [Int] = [2,5,8,11,14,17,20,23] // base_time으로 사용 가능한 값의 배열
    formatter.dateFormat = "HH"
    var hour = Int(formatter.string(from: date))! // 현재 시각 저장
    
    formatter.dateFormat = "mm"
    let minute = Int(formatter.string(from: date))! // 현재 분 저장
    
    formatter.dateFormat = "yyyyMMdd" // base_date에 들어갈 문자열 포맷
    
    if baseTimeIntArray.contains(hour), minute >= 10 { // 현재 시간이 base_time으로 사용 가능한 값이고 10분 이후일 때
        base_date = formatter.string(from: date)
        base_time = String(format: "%02d00", hour)
        
    } else if baseTimeIntArray.contains(hour), minute < 10 { // 현재 시간이 base_time으로 사용 가능한 값이고 10분 이전일 때 검색하면 그 시간의 데이터는 아직 제공되지 않기 때문에 이전의 base_time으로 검색해야 함
        let newIndex = baseTimeIntArray.firstIndex(of: hour)! - 1 // 현재보다 한번 전의 base_time의 값을 가져오기 위해 현재 인덱스 - 1
        if newIndex <= 0 { // 인덱스가 0보다 작아지면 하루 전의 마지막 base_time을 가져옴
            hour = baseTimeIntArray.last!
            base_date = setDateString(date: formatter.string(from: date), ago: -1)
            print(base_date)
        } else {
            hour = baseTimeIntArray[newIndex]
            base_date = formatter.string(from: date)
        }
        base_time = String(format: "%02d00", hour)
        
    } else if baseTimeIntArray.contains(hour) == false { // 현재 시간이 base_time으로 사용할 수 없는 값일 때
        base_date = formatter.string(from: date)
        while baseTimeIntArray.contains(hour) == false { // 한 시간 씩 뺄셈하며 base_time에 해당하는 값인 지 확인하고 0보다 작아졌을 때 하루전의 23시(base_time)으로 변경
            if hour > 0 {
                hour -= 1
            } else {
                hour = 23
                base_date = setDateString(date: formatter.string(from: date), ago: -1)
            }
        }
        base_time = String(format: "%02d00", hour)
    }
    return (base_date, base_time)
}

/// 직접 날짜와 시간을 입력받아 요청값에 맞게 변환
/// - parameters:
///     - testDate: yyyyMMdd HH:mm 형식.
/// - returns: ( base_date, base_time)
func setBaseDateTime(testDate: String) -> (String, String) {
    print(testDate) //20220216 01:16
    var base_date: String = ""
    var base_time: String = ""
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko-KR")
    formatter.dateFormat = "yyyyMMdd HH:mm"
    let date: Date = formatter.date(from: testDate)!
    
    let baseTimeIntArray: [Int] = [2,5,8,11,14,17,20,23]
    
    // error am 01:07
    formatter.dateFormat = "HH"
    var hour = Int(formatter.string(from: date))!
    
    formatter.dateFormat = "mm"
    let minute = Int(formatter.string(from: date))!
    print(String(format: "%02d:%02d", hour, minute))
    
    formatter.dateFormat = "yyyyMMdd" // base_date Format
    
    if baseTimeIntArray.contains(hour), minute >= 10 { // success
        base_date = formatter.string(from: date)
        base_time = String(format: "%02d00", hour)
        
    } else if baseTimeIntArray.contains(hour), minute < 10 {// success
        let newIndex = baseTimeIntArray.firstIndex(of: hour)! - 1
        if newIndex <= -1 {
            hour = baseTimeIntArray.last!
            base_date = setDateString(date: formatter.string(from: date), ago: -1)
            print(base_date)
        } else {
            hour = baseTimeIntArray[newIndex]
            base_date = formatter.string(from: date)
        }
        base_time = String(format: "%02d00", hour)
        
    } else if baseTimeIntArray.contains(hour) == false {
        base_date = formatter.string(from: date)
        while baseTimeIntArray.contains(hour) == false {
            if hour > 0 {
                hour -= 1
            } else {
                hour = 23
                base_date = setDateString(date: formatter.string(from: date), ago: -1)
            }
        }
        base_time = String(format: "%02d00", hour)
    }
    
    return (base_date, base_time)
}

/// 날짜 형식의 문자열을 입력받아 ago만큼의 날짜를 이동
/// - parameters:
///     - date: yyyyMMdd 형식
///     - ago: Int값 만큼 날짜 이동
/// - returns: ago만큼 이동시킨 날짜 문자열 반환
///````
/// ex) parameters: "20220217", -1
/// return "20220216"
func setDateString(date: String, ago: Int) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd"
    formatter.locale = Locale(identifier: "ko_KR")
    
    let date = formatter.date(from: date)!
    
    let calender = Calendar(identifier: .gregorian)
    let dateComponents = DateComponents(day: ago)
    let newDate: Date = calender.date(byAdding: dateComponents, to: date)!
    
    let dateString = formatter.string(from: newDate)
    
    return dateString
}
