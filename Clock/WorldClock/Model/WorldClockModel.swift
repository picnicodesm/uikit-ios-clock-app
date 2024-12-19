//
//  File.swift
//  Clock
//
//  Created by 김상민 on 2023/08/14.
//

import Foundation

struct WorldClock: Hashable {
    var dateDiff: String
    var timeDiff: String
    var cityName: String
    var time: String    
}

extension WorldClock {    
    static var list: [WorldClock] = []
}
