//
//  AlarmModel.swift
//  SoftAwake
//
//  Created by Aleksi Puttonen on 27.6.2024.
//

import Foundation

struct Alarm: Identifiable, Codable {
    let id: UUID
    var key: String
    var value: String
    var isOn: Bool
}
