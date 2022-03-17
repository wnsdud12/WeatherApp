//
//  WeatherManager.swift
//  WeatherApp
//
//  Created by 박준영 on 2022/03/17.
//

import Foundation
import Alamofire

protocol WeatherManagerDelegate {}
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
    }
    mutating func preformRequest(url: String) {
        self.params["base_date"] = "20220317"
        self.params["base_time"] = "1400"
        AF.request(url, parameters: self.params, encoder: URLEncodedFormParameterEncoder.default).responseDecodable(of: WeatherData.self) {
            response in
            if let weatherData = response.value?.response.body.items.item {
                print(weatherData)
                // 데이터 가공하는 코드
            }
            
        }
        
    }
}
