//
//  ViewController.swift
//  WeatherApp
//
//  Created by sumwb on 2022/02/17.
//

import UIKit
/// - 해야 할 것
///     - info-plist 권한 부여(아직 하나도 안했음)
///     - git ignore 다시 해보기
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

