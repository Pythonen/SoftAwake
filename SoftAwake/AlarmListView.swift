//
//  AlarmListView.swift
//  SoftAwake
//
//  Created by Aleksi Puttonen on 25.6.2024.
//

import Foundation
import SwiftUI

struct AlarmListView: View {
    @EnvironmentObject var alarmManager: AlarmManager

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
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack {
            Text(alarm.value)
                .font(.subheadline)
                .foregroundColor(alarm.isOn ? (colorScheme == .dark ? .white : .black) : .gray)
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
