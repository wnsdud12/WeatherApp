//
//  MapConvert.swift
//  WeatherApp
//
//  Created by sumwb on 2022/02/22.
//

import Foundation
import CoreLocation
import Numerics

//
// API 신청할 때 받은 문서 파일에서 c 언어 예제 코드를 swift 언어로 변환
// tan, cos, pow 등의 수학함수들을 사용하기 위해 swift-numerics 패키지 사용
// https://github.com/apple/swift-numerics
//

typealias Grid = (x: Int, y: Int)
typealias Degree = (lat: Double, lon: Double)

protocol MapConvertType {}
extension Int: MapConvertType {}
extension Double: MapConvertType {}

struct Map {
    static var shared = Map()
    let NX: Int = 149 // X축 격자점 수
    let NY: Int = 253 // Y축 격자점 수
    let Re: Double = 6371.00877 // 지구 반경 [km]
    let grid: Double = 5.0 // 격자간격 [km]
    let slat1: Double = 30.0 // 표준위도 [degree]
    let slat2: Double = 60.0 // 표준위도 [degree]
    let olon: Double = 126.0 // 기준점의 경도 [degree]
    let olat: Double = 38.0 // 기준점의 위도 [degree]
    let xo: Double // 기준점의 X좌표 [격자거리]
    let yo: Double // 기준점의 Y좌표 [격자거리]

    private init() {
        let xo: Double = 210 / self.grid
        let yo: Double = 675 / self.grid

        self.xo = xo
        self.yo = yo
    }
}
func lamcproj<T>(lon_x: T, lat_y: T, isWantGrid: Bool) {

    let map = Map.shared
    let PI = asin(1.0) * 2.0
    let DEGRAD = PI / 180.0
    let RADDEG = 180.0 / PI

    let re = map.Re / map.grid
    let slat1 = map.slat1 * DEGRAD
    let slat2 = map.slat2 * DEGRAD
    let olon = map.olon * DEGRAD
    let olat = map.olat * DEGRAD

    var sn = tan(PI * 0.25 + slat2 * 0.5)/tan(PI * 0.25 + slat1 * 0.5)
    sn = log(cos(slat1) / cos(slat2)) / log(sn)
    var sf = tan(PI * 0.25 + slat1 * 0.5)
    sf = pow(sf, sn) * cos(slat1) / sn
    var ro = tan(PI * 0.25 + olat * 0.5)
    ro = re * sf/pow(ro,sn)

    var grid: Grid = (0,0)
    var degree: Degree = (0,0)

    switch isWantGrid {
        case true: // (lon, lat) -> (x, y)
            convertToGrid(longitude: lon_x as! Double, latitude: lat_y as! Double)
        case false:// (x, y) -> (lon, lat)
            // 4/7 18:10 저장 - 다시 키면 여기부터 구현 및 true일 때 결괏값 테스트
            convertToDegree(x: lon_x as! Int, y: lat_y as! Int)
    }
    func convertToGrid(longitude: Double, latitude: Double) {
        var ra = tan(PI * 0.25 + latitude * DEGRAD * 0.5)
        ra = re*sf/pow(ra,sn)
        var theta = (longitude) * DEGRAD - olon
        if (theta > PI) { theta -= 2.0*PI }
        if (theta < -PI) { theta += 2.0*PI }
        theta *= sn
        let x = Double((ra * sin(theta)) + map.xo)
        let y = Double((ro - ra * cos(theta)) + map.yo)

        grid.x = Int(x + 1.5)
        grid.y = Int(y + 1.5)

        let testString = "lon.= \(longitude), lat.= \(latitude) ---> X = \(grid.x), Y = \(grid.y)"
        UserDefaults.degree_lat = latitude
        UserDefaults.degree_lon = longitude
        UserDefaults.grid_x = grid.x
        UserDefaults.grid_y = grid.y
    }
    func convertToDegree(x: Int, y: Int) {
        let x1 = Double(x - 1)
        let y1 = Double(y - 1)
        var theta: Double

        let xn = x1 - map.xo
        let yn = ro - y1 + map.yo
        var ra = sqrt(xn * xn + yn * yn)
        if (sn < 0.0)  { ra = -ra }
        var alat = pow((re * sf / ra), (1.0 / sn))
        alat = 2.0 * atan(alat) - PI * 0.5
        if (fabs(xn) <= 0.0) {
            theta = 0.0
        } else {
            if (fabs(yn) <= 0.0) {
                theta = PI * 0.5
                if(xn < 0.0 ) {
                   theta = -theta

                }
            } else {
                theta = atan2(xn,yn)
            }
        }
        let alon = theta/sn + olon
        degree.lat = Double(alat * RADDEG)
        degree.lon = Double(alon * RADDEG)

        let testString = "X = \(x), Y = \(y) ---> lon.= \(degree.lon), lat.= \(degree.lat)"
        UserDefaults.grid_x = x
        UserDefaults.grid_y = y
        UserDefaults.degree_lat = degree.lat
        UserDefaults.degree_lon = degree.lon
    }
}
/// UserDefaults에 저장된 lat, lon 데이터로 지명 정보를 저장
func searchAddress() {
    UserDefaults.printAll()
    var address: String = ""
    let lat = UserDefaults.degree_lat
    let lon = UserDefaults.degree_lon
    let location = CLLocation(latitude: lat, longitude: lon)

    CLGeocoder().reverseGeocodeLocation(location, preferredLocale: Locale(identifier: "Ko-kr")) {
        (placemarks, error) -> Void in

        // searchbar로 지역 선택했을 때의 주소와 재시작 해서 fetchWeather로 주소 받아올 때 내용이 다름
        if let pm = placemarks?.last {
            if error != nil {
                print("현재 위치를 받아올 수 없음 \(error.debugDescription)")
            }
            if pm.administrativeArea != nil {
                address += pm.administrativeArea!
            }
            if pm.locality != nil {
                address += " " + pm.locality!
            }
            if pm.thoroughfare != nil {
                address += " " + pm.thoroughfare!
            }
        }
        UserDefaults.address = address
    }
}
