//
//  MapConvert.swift
//  WeatherApp
//
//  Created by sumwb on 2022/02/22.
//

import Foundation
import Numerics

//
// API 신청할 때 받은 문서 파일에서 c 언어 예제 코드를 swift 언어로 변환
// tan, cos, pow 등의 수학함수들을 사용하기 위해 swift-numerics 패키지 사용
// https://github.com/apple/swift-numerics
//

typealias Point<T> = (x: T, y: T)

let NX: Int = 149 // X축 격자점 수
let NY: Int = 253 // Y축 격자점 수

struct MapConvert {
    let map: Map = Map()
    let x: Int
    let y: Int
//    let lon: Double
//    let lat: Double
    
    init(lon: Double, lat: Double) {
        let point = map_conv(lon: lon, lat: lat, map: map)
        self.x = point.x
        self.y = point.y
    }
}

struct Map {
    var Re: Double = 6371.00877 // 지구 반경 [km]
    var grid: Double = 5.0 // 격자간격 [km]
    var slat1: Double = 30.0 // 표준위도 [degree]
    var slat2: Double = 60.0 // 표준위도 [degree]
    var olon: Double = 126.0 // 기준점의 경도 [degree]
    var olat: Double = 38.0 // 기준점의 위도 [degree]
    var xo: Double // 기준점의 X좌표 [격자거리]
    var yo: Double // 기준점의 Y좌표 [격자거리]
    
    init() {
        let xo: Double = 210 / self.grid
        let yo: Double = 675 / self.grid
        
        self.xo = xo
        self.yo = yo
    }
}

func map_conv(lon: Double, lat: Double, map: Map) -> Point<Int> {
    let pointDouble = lamcproj(lon: lon, lat: lat, map: map)
    var pointInt: Point<Int>
    pointInt.x = Int(pointDouble.x + 1.5)
    pointInt.y = Int(pointDouble.y + 1.5)
    return pointInt
}
func lamcproj(lon: Double, lat: Double, map: Map) -> Point<Double> {
    let pointDouble: Point<Double>
    
    let PI: Double = asin(1.0) * 2.0
    let DEGRAD = PI / 180.0
    //let RADDEG = 180.0 / PI
    
    let re = map.Re / map.grid
    let slat1 = map.slat1 * DEGRAD
    let slat2 = map.slat2 * DEGRAD
    let olon = map.olon * DEGRAD
    let olat = map.olat * DEGRAD
    
    var sn = tan(PI * 0.25 + slat2 * 0.5) / tan(PI * 0.25 + slat1 * 0.5)
    sn = log(cos(slat1) / cos(slat2)) / log(sn)
    
    var sf = tan(PI * 0.25 + slat1 * 0.5)
    sf = pow(sf, sn) * cos(slat1) / sn
    
    var ro = tan(PI * 0.25 + olat * 0.5)
    ro = re * sf / pow(ro, sn)
    
    var ra = tan(PI * 0.25 + lat * DEGRAD * 0.5)
    ra = re * sf / pow(ra, sn)
    
    var theta = lon * DEGRAD - olon
    
    if theta > PI {
        theta -= 2.0 * PI
    }
    if theta < -PI {
        theta += 2.0 * PI
    }
    
    theta *= sn
    
    pointDouble.x = Double(ra * sin(theta)) + map.xo
    pointDouble.y = Double(ro - ra * cos(theta)) + map.yo
    
    return pointDouble
}
