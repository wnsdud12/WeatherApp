//
//  Extenstions.swift
//  WeatherApp
//
//  Created by 박준영 on 2022/04/08.
//

import Foundation
let group = DispatchGroup()
let queue = DispatchQueue.main
extension String {
    // String 변수를 Int로 변경
    var toInt: Int {
        return Int(self)!
    }
    var toDouble: Double {
        return Double(self)!
    }
}

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultsValue: T
    var container: UserDefaults = .standard

    var wrappedValue: T {
        get {
            return container.object(forKey: key) as? T ?? defaultsValue
        }
        set {
            container.set(newValue, forKey: key)
        }
    }
}
extension UserDefaults {
    @UserDefault(key: keyEnum.grid_x.rawValue, defaultsValue: 0)
    static var grid_x: Int
    @UserDefault(key: keyEnum.grid_y.rawValue, defaultsValue: 0)
    static var grid_y: Int
    @UserDefault(key: keyEnum.address.rawValue, defaultsValue: "없음")
    static var address: String
    @UserDefault(key: keyEnum.degree_lat.rawValue, defaultsValue: 0.0)
    static var degree_lat: Double
    @UserDefault(key: keyEnum.degree_lon.rawValue, defaultsValue: 0.0)
    static var degree_lon: Double
    @UserDefault(key: keyEnum.isFirst.rawValue, defaultsValue: nil)
    static var isFirst: Bool? // 앱 첫 실행 여부
    enum keyEnum: String {
        case grid_x
        case grid_y
        case degree_lat
        case degree_lon
        case address
        case isFirst
    }
    class func delete() {
        print("UserDefaults의 지역 관련 데이터 삭제")
        self.address = ""
        self.degree_lat = 0
        self.degree_lon = 0
        self.grid_x = 0
        self.grid_y = 0
    }
    class func printAll() {
        print("")
        print("==============")
        print("UserDefaults All value print")
        print("grid_x - \(self.grid_x)")
        print("grid_y - \(self.grid_y)")
        print("degree_lat - \(self.degree_lat)")
        print("degree_lon - \(self.degree_lon)")
        print("address - \(self.address)")
        print("isFirst - \(self.isFirst)")
        print("==============")
        print("")
    }
}
extension Notification.Name {
    static let end_didUpdateLocations = Notification.Name("end_didUpdateLocations")
}
func removeDuplicate<T: Hashable>(_ array: [T]) -> [T] {
    let set: Set<T> = Set(array)
    let array = Array(set)
    return array
}
