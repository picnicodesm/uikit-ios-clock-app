//
//  RingModel.swift
//  Clock
//
//  Created by 김상민 on 2023/08/28.
//

import Foundation

struct RingModel: Hashable {
    var ring: String = "Radar"
}

extension RingModel {
    static var shared = RingModel()
    
    static let rings: [String] = ["Radar (Default)", "Apex", "Beacon", "Bulletin", "By The Seaside", "Chimes", "Circuit", "Constellation", "Cosmic", "Crystals", "Hillside", "Illuminate", "Night Owl", "Opening", "Playtime", "Presto", "Radiate", "Reflection", "Ripples", "Sencha", "Signal", "Silk", "Slow Rise", "Stargaze", "Summit", "Twinkle", "Uplift", "Waves", "Classic"]

    static let noRing: [String] = ["Stop Playing"]
}
