//
//  WeatherTMPModel.swift
//  WeatherApp
//
//  Created by sumwb on 2022/02/25.
//

import Foundation

// 현재 시간으로 데이터를 받아오면 오늘의 최저/최고 기온을 받아오지 못 할 수도 있어 전날 23시 기준의 데이터를 받아와야 함
struct WeatherTMPModel {
    
    var todayTMPArray: [LowHighTMP]
    let nowTMP: String
    
    init() {
        self.todayTMPArray = []
        self.nowTMP = ""
    }
    init(items: [Item]) {
        let baseDateTime = setBaseDateTime()
        var itemValue: ItemValue = [:]
        var nowTMP: String = ""
        var todayTMPArray: [LowHighTMP] = []
        for item in items where item.fcstDate == baseDateTime.0 && item.fcstTime == baseDateTime.1 && item.category == "TMP" {
            print(item.fcstDate, item.fcstTime, item.fcstValue)
            nowTMP = setFcstValue(category: item.category, fcstValue: item.fcstValue)
            
        }
        self.nowTMP = nowTMP
        
        
        // 일일 최저/최고기온 데이터 받아오기
        itemValue = [:]
        var date = items[0].fcstDate
        for item in items where item.category == "TMN" || item.category == "TMX" {
            let value = setFcstValue(category: item.category, fcstValue: item.fcstValue)
            if item.fcstDate == date {
                itemValue[item.category] = value
            } else {
                todayTMPArray.append((date, itemValue))
                date = item.fcstDate
                itemValue = [:]
                itemValue[item.category] = value
            }
            
        }
        todayTMPArray.append((date, itemValue))
        self.todayTMPArray = todayTMPArray
    }
}
