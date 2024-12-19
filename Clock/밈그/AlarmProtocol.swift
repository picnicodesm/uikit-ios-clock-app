//
//  AlarmProtocol.swift
//  Clock
//
//  Created by 김상민 on 2023/08/18.
//

import Foundation

protocol AlarmDelegate {
    func setAlarm(dayLabel text: String)
    
    func setAlarm(sound soundText: String)
    
    func setAlarm(alarm alarmModel: AlarmModel)
    
    func updateDataSource()
    
    func updateSwitchData(isOn: Bool, id itemId: UUID)
}

extension AlarmDelegate {
    func setAlarm(dayLabel text: String) {}
    
    func setAlarm(sound soundText: String) {}
    
    func setAlarm(alarm alarmModel: AlarmModel) {}
    
    func updateDataSource() {}
    
    func updateSwitchData(isOn: Bool, id itemId: UUID) {}
}
