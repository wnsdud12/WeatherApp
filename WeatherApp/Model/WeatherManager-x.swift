////
////  WeatherManager.swift
////  WeatherApp
////
////  Created by 박준영 on 2022/03/17.
////
//
//import Foundation
//
//protocol WeatherManagerDelegate2 {
//    func didUpdateWeatherTable(_ weatherManager: WeatherManager, weather: WeatherModel)
//}
//struct WeatherManager2 {
//    let weatherURL = "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst?"
//    private let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String
//
//    var delegate: WeatherManagerDelegate2?
//
//    func fetchWeather(nx: Int, ny: Int) {
//        let baseDateTime: (date: String, time: String) = setBaseDateTime()
//
//        guard let apiKey = apiKey else { return print("URL이 이상해요") }
//        let weatherURLString = "\(weatherURL)serviceKey=\(apiKey)&base_date=\(baseDateTime.date)&base_time=\(baseDateTime.time)&nx=\(nx)&ny=\(ny)&numOfRows=1000&pageNo=1&dataType=JSON"
//
//        print("")
//        print("==============")
//        print("url\n\(weatherURLString)")
//        print("==============")
//        print("")
//        preformRequest(with: weatherURLString)
//    }
//    func preformRequest(with urlString: String) {
//
//        if let url = URL(string: urlString) {
//            let session = URLSession(configuration: .default)
//            let task = session.dataTask(with: url) {
//                data, response, error in
//                if error != nil {
//                    print("preformRequestError - \(error!.localizedDescription)")
//                    return
//                }
//                if let safeData = data {
//                    if let weather = parseJSON(weatherData: safeData) {
//                        delegate?.didUpdateWeatherTable(self, weather: weather)
//                    }
//                }
//            }
//            task.resume()
//        } else {
//            print("url error")
//        }
//    }
//    func parseJSON(weatherData: Data) -> WeatherModel? {
//        let UseCategory = ["TMX", "TMN", "TMP", "SKY", "PTY", "PCP", "SNO", "POP"]
//        var dateArray: [String] = []
//        var timeArray: [String] = []
//        let decoder = JSONDecoder()
//        do {
//            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
//            let weatherData = decodedData.response.body.items.item
//            let items = weatherData.filter{UseCategory.contains($0.category)}
//
//            let valueArray: [WeatherValue] = {
//                var fcstTime = items[0].fcstTime
//                var value: WeatherValue = [:]
//                var array: [WeatherValue] = []
//                for item in items {
//                    if fcstTime == item.fcstTime {
//                        value[item.category] = setFcstValue(category: item.category, fcstValue: item.fcstValue)
//                        fcstTime = item.fcstTime
//                    } else {
//                        fcstTime = item.fcstTime
//                        array.append(value)
//                        value = [:]
//                        value[item.category] = setFcstValue(category: item.category, fcstValue: item.fcstValue)
//                        dateArray.append(item.fcstDate)
//                        timeArray.append(item.fcstTime)
//                    }
//                }
//                return array
//            }()
//            guard dateArray.count == timeArray.count, timeArray.count == valueArray.count else {
//                print("error - 데이터가 빠진게 있습니다.")
//                return nil
//            }
//            let weather = WeatherModel(date: dateArray, time: timeArray, value: valueArray)
//            return weather
//        }
//        catch {
//            print(error)
//            return nil
//        }
//    }
//}
