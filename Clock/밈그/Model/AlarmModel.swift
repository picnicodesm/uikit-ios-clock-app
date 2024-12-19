//
//  AlarmModel.swift
//  Clock
//
//  Created by 김상민 on 2023/08/18.
//

import Foundation

struct AlarmModel: Hashable {
    var uuid: UUID = UUID()
    var time: String = "9:10"
    var repeatDay: String = "Never"
    var labelText: String = "Alarm"
    var sound: String = "Radar"
    var snooze: Bool = true
}

extension AlarmModel {
    static var alarms: [AlarmModel] = []
    
    static let sounds: [[String]] = [
        ["Vibrations"],
        ["BAD HOBBY", "SMILEY", "Pick a Song"],
        ["Radar (Default)", "Apex", "Beacon", "Bulletin", "By The Seaside", "Chimes", "Circuit", "Constellation", "Cosmic", "Crystals", "Hillside", "Illuminate", "Night Owl", "Opening", "Playtime", "Presto", "Radiate", "Reflection", "Ripples", "Sencha", "Signal", "Silk", "Slow Rise", "Stargaze", "Summit", "Twinkle", "Uplift", "Waves", "Classic"],
        ["None"]
    ]
}
