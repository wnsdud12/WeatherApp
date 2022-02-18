//
//  ViewController.swift
//  WeatherApp 주륵주륵
//
//  Created by sumwb on 2022/02/17.
//

import UIKit
/// - 해야 할 것
///     - 지역 변경 기능 추가
///     - 받아온 데이터 화면에 출력
class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("start APP")
        let weatherManager = WeatherManager()
        weatherManager.fetchWeather()
    }
    
    
}

