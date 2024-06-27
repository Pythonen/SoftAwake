//
//  AlarmListView.swift
//  SoftAwake
//
//  Created by Aleksi Puttonen on 25.6.2024.
//

import Foundation
import SwiftUI

struct AlarmListView: View {
    @StateObject private var alarmManager = AlarmManager()
    var body: some View {
            NavigationView {
                List {
                    ForEach(alarmManager.alarms) { alarm in
                        AlarmRow(alarm: alarm, toggleAction: {
                            alarmManager.toggleAlarm(alarm)
                        })
                    }
                    .onDelete(perform: alarmManager.deleteAlarm)
                }
            }
            .navigationTitle("Alarms")
        }
}

struct AlarmRow: View {
    var alarm: Alarm
    var toggleAction: () -> Void
    
    var body: some View {
        HStack {
            Text(alarm.value)
                .font(.subheadline)
                .foregroundColor(alarm.isOn ? .black : .gray)
            Spacer()
            Toggle(isOn: Binding(
                get: { alarm.isOn },
                set: { _ in toggleAction() }
            )) {
                Text("Enabled")
            }
            .labelsHidden()
        }
    }
}
