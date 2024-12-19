//
//  CitiesModel.swift
//  Clock
//
//  Created by 김상민 on 2023/08/14.
//

import Foundation

struct Cities {
    static let citiesByType: [[String]] = [cityA, cityB, cityC, cityD, cityE, cityF, cityG, cityH, cityI, cityJ, cityK, cityL, cityM, cityN, cityO, cityP, cityQ, cityR, cityS, cityT, cityU, cityV, cityW, cityX, cityY, cityZ]
    static let cities: [String] = TimeZone.knownTimeZoneIdentifiers.map { $0.replacingOccurrences(of: "/", with: ", ") }
    static let cityA: [String] = cities.filter { $0.first! == "A" }
    static let cityB: [String] = cities.filter { $0.first! == "B" }
    static let cityC: [String] = cities.filter { $0.first! == "C" }
    static let cityD: [String] = cities.filter { $0.first! == "D" }
    static let cityE: [String] = cities.filter { $0.first! == "E" }
    static let cityF: [String] = cities.filter { $0.first! == "F" }
    static let cityG: [String] = cities.filter { $0.first! == "G" }
    static let cityH: [String] = cities.filter { $0.first! == "H" }
    static let cityI: [String] = cities.filter { $0.first! == "I" }
    static let cityJ: [String] = cities.filter { $0.first! == "J" }
    static let cityK: [String] = cities.filter { $0.first! == "K" }
    static let cityL: [String] = cities.filter { $0.first! == "L" }
    static let cityM: [String] = cities.filter { $0.first! == "M" }
    static let cityN: [String] = cities.filter { $0.first! == "N" }
    static let cityO: [String] = cities.filter { $0.first! == "O" }
    static let cityP: [String] = cities.filter { $0.first! == "P" }
    static let cityQ: [String] = cities.filter { $0.first! == "Q" }
    static let cityR: [String] = cities.filter { $0.first! == "R" }
    static let cityS: [String] = cities.filter { $0.first! == "S" }
    static let cityT: [String] = cities.filter { $0.first! == "T" }
    static let cityU: [String] = cities.filter { $0.first! == "U" }
    static let cityV: [String] = cities.filter { $0.first! == "V" }
    static let cityW: [String] = cities.filter { $0.first! == "W" }
    static let cityX: [String] = cities.filter { $0.first! == "X" }
    static let cityY: [String] = cities.filter { $0.first! == "Y" }
    static let cityZ: [String] = cities.filter { $0.first! == "Z" }
}
