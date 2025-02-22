///
///  AlarmManageer.swift
///  SoftAwake
///
///  Created by Aleksi Puttonen on 27.6.2024.
///
import Foundation
import UserNotifications
import AVFoundation
import UIKit

class AlarmManager: ObservableObject {
    var timers: [UUID: Timer] = [:]
    @Published var alarms: [Alarm] {
        didSet {
            saveAlarms()
        }
    }
    
    private let userDefaults = UserDefaults.standard
    let notificationCenter = UNUserNotificationCenter.current()
    private var audioPlayer: AVAudioPlayer?
    
    lazy var healthKitManager: HealthKitManager = {
        return HealthKitManager(alarmManager: self)
    }()
    
    init() {
        self.alarms = AlarmManager.loadAlarms()
        scheduleAllAlarms()
    }
    
    func scheduleAlarm(_ alarm: Alarm) {
        guard alarm.isOn else { return }
        healthKitManager.scheduleFetchSleepData(alarm: alarm)
        // Calculate the next alarm time
        if let (hours, minutes) = AlarmManager.parseTimeString(alarm.value) {
            let calendar = Calendar.current
            var components = DateComponents()
            components.hour = hours
            components.minute = minutes
            
            guard let nextAlarmDate = calendar.nextDate(after: Date(), matching: components, matchingPolicy: .nextTime) else {
                return
            }
            
            // Schedule the timer for this alarm
            let timeInterval = nextAlarmDate.timeIntervalSinceNow
            if timeInterval > 0 {
                let timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
                    self?.triggerAlarm(alarm: alarm)
                }
                timers[alarm.id] = timer
            }
        }
    }
    
    func triggerAlarm(alarm: Alarm) {
        playAlarm()
        // Post notification for UI update
        let content = UNMutableNotificationContent()
                content.title = "Wake Up"
                content.body = "Time to wake up!"
        content.userInfo = ["alarmId": alarm.id.uuidString]
                
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
                notificationCenter.add(request) { error in
                    if let error = error {
                        print("Error triggering alarm: \(error.localizedDescription)")
                    } else {
                        print("Triggered alarm")
                    }
                }
    }
    
    func playAlarm() {
            guard let url = Bundle.main.url(forResource: "alarm", withExtension: "mp3") else {
                print("Alarm sound file not found")
                return
            }
            
            do {
                // Create a new player for the alarm sound
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.numberOfLoops = -1 // Loop indefinitely
                audioPlayer?.setVolume(1.0, fadeDuration: 0.0)
                audioPlayer?.prepareToPlay()
                
                DispatchQueue.global().async { [weak self] in
                    let played = self?.audioPlayer?.play() ?? false
                    print("Alarm sound playback started: \(played)")
                }
            } catch {
                print("Failed to play alarm: \(error)")
            }
    }
    
    func stopAlarm(alarm: Alarm) {
        print("stopAlarm called")
        audioPlayer?.stop()
        print("Alarm sound playback stopped")
        audioPlayer = nil
        if let current = alarms.firstIndex(where: { $0.id == alarm.id }){
            cancelSleepDataFetch(for: alarms[current])
            toggleAlarm(alarms[current])
        }
            
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
                cancelSleepDataFetch(for: alarms[index])
            }
        }
    }
    
    private func scheduleAllAlarms() {
        for alarm in alarms where alarm.isOn {
            scheduleAlarm(alarm)
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
        guard components.count == 2,
              let hours = Int(components[0]),
              let minutes = Int(components[1]) else {
            return nil
        }
        return (hours, minutes)
    }
    
    func cancelSleepDataFetch(for alarm: Alarm) {
        timers[alarm.id]?.invalidate()
        timers[alarm.id] = nil
    }
}

