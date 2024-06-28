//
//  AlarmManageer.swift
//  SoftAwake
//
//  Created by Aleksi Puttonen on 27.6.2024.
//

import Foundation
import UserNotifications

class AlarmManager: ObservableObject {
    
    var timers: [UUID: Timer] = [:]
    @Published var alarms: [Alarm] {
        didSet {
            saveAlarms()
        }
    }
    
    private let userDefaults = UserDefaults.standard
    let notificationCenter = UNUserNotificationCenter.current()
    lazy var healthKitManager: HealthKitManager = {
        return HealthKitManager(alarmManager: self)
    }()
    init() {
        self.alarms = AlarmManager.loadAlarms()
        scheduleAllAlarms()
    }
    
    func addAlarm(hours: Int, minutes: Int) {
        let timeString = String(format: "%02d:%02d", hours, minutes)
        let newAlarm = Alarm(id: UUID(), key: timeString, value: timeString, isOn: true)
        alarms.append(newAlarm)
        scheduleAlarm(newAlarm)
    }
    
    func deleteAlarm(at offsets: IndexSet) {
        offsets.forEach { index in
            let alarm = alarms[index]
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [alarm.id.uuidString])
            alarms.remove(at: index)
            cancelSleepDataFetch(for: alarm)
        }
    }
    
    func toggleAlarm(_ alarm: Alarm) {
        if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
            alarms[index].isOn.toggle()
            if alarms[index].isOn {
                scheduleAlarm(alarms[index])
            } else {
                notificationCenter.removePendingNotificationRequests(withIdentifiers: [alarms[index].id.uuidString])
                cancelSleepDataFetch(for: alarms[index])
            }
        }
    }
    
    private func scheduleAllAlarms() {
        for alarm in alarms {
            if alarm.isOn {
                scheduleAlarm(alarm)
            }
        }
    }
    
    private func scheduleAlarm(_ alarm: Alarm) {
        healthKitManager.scheduleFetchSleepData(alarm: alarm)
        let content = UNMutableNotificationContent()
        content.title = "Alarm"
        content.body = "Time to wake up!"
        content.sound = .defaultRingtone
        content.categoryIdentifier = "Alarm"
        if let (hours, minutes) = AlarmManager.parseTimeString(alarm.value) {
            var dateComponents = DateComponents()
            dateComponents.hour = hours
            dateComponents.minute = minutes
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: alarm.id.uuidString, content: content, trigger: trigger)
            
            notificationCenter.add(request) { error in
                if let error = error {
                    print("Error scheduling alarm: \(error.localizedDescription)")
                }
            }
        }
    }
    private static func loadAlarms() -> [Alarm] {
        guard let data = UserDefaults.standard.data(forKey: "alarms"),
              let alarms = try? JSONDecoder().decode([Alarm].self, from: data) else {
            return []
        }
        return alarms
    }
    
    private func saveAlarms() {
        if let data = try? JSONEncoder().encode(alarms) {
            userDefaults.set(data, forKey: "alarms")
        }
    }
    static func parseTimeString(_ timeString: String) -> (hours: Int, minutes: Int)? {
        let components = timeString.split(separator: ":")
        if components.count == 2,
           let hours = Int(components[0]),
           let minutes = Int(components[1]) {
            return (hours, minutes)
        } else {
            return nil
        }
    }
    func triggerAlarm(alarm: Alarm) {
        let content = UNMutableNotificationContent()
        content.title = "Wake Up"
        content.body = "Time to wake up!"
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        cancelSleepDataFetch(for: alarm)
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error triggering alarm: \(error.localizedDescription)")
            }
        }
    }
    func cancelSleepDataFetch(for alarm: Alarm) {
        if let timer = timers[alarm.id] {
            timer.invalidate()
            print("Invalidated timer: ", timer)
            timers.removeValue(forKey: alarm.id)
        }
    }
}
