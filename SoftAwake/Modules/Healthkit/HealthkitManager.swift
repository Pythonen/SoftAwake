//
//  HealthkitManager.swift
//  SoftAwake
//
//  Created by Aleksi Puttonen on 28.6.2024.
//

import Foundation

import HealthKit
import SwiftUI
import UserNotifications


class HealthKitManager: ObservableObject {
    let healthStore = HKHealthStore()
    private let alarmManager: AlarmManager
    
    init(alarmManager: AlarmManager) {
        self.alarmManager = alarmManager
    }
    // Function to request authorization
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }
        
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        
        healthStore.requestAuthorization(toShare: nil, read: [sleepType]) { success, error in
            if let error = error {
                print("Error requesting authorization: \(error.localizedDescription)")
            }
            completion(success)
        }
    }
    
    // Function to query sleep data
    func fetchSleepData(completion: @escaping ([HKCategorySample]?) -> Void) {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())
        let endDate = Date()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
            if let error = error {
                print("Error fetching sleep data: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            completion(results as? [HKCategorySample])
        }
        
        healthStore.execute(query)
    }
    
    func scheduleFetchSleepData(alarm: Alarm) {
        guard alarm.isOn else { return }
        
        if alarmManager.timers[alarm.id] != nil {
            print("Timer already scheduled for this alarm.")
            return
        }
        
        var calendar = Calendar(identifier: .gregorian)
        var secondsFromGMT: Int { return TimeZone.current.secondsFromGMT() }
        func getCurrentTimeZone() -> TimeZone {
            TimeZone.current
        }
        calendar.timeZone = getCurrentTimeZone()

        let now = Date()
        print(now)
        print(calendar.timeZone)
        let (hours, minutes) = AlarmManager.parseTimeString(alarm.value)!
        let alarmDateComponents = DateComponents(hour: hours, minute: minutes)
        
        guard let alarmDate = calendar.nextDate(after: now, matching: alarmDateComponents, matchingPolicy: .nextTime) else {
            return
        }
        
        guard let fetchDate = calendar.date(byAdding: .minute, value: -30, to: alarmDate) else {
            print("Error calculating fetchDate.")
            return
        }
        print("Scheduled fetching sleep data on: ", fetchDate)
        let timeInterval = fetchDate.timeIntervalSince(now)
        if timeInterval > 0 {
            let timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { _ in
                self.checkSleepStateAndSchedule(alarm: alarm)
            }
            alarmManager.timers[alarm.id] = timer
        }
    }
    private func checkSleepStateAndSchedule(alarm: Alarm) {
        fetchSleepData { samples in
            print("---------SAMPLES: ", samples)
            guard let samples = samples else { return }
            
            if samples.last(where: { $0.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue || $0.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue }) != nil {
                // Light sleep found, play alarm
                print("Light sleep sample found: ", samples)
                self.alarmManager.triggerAlarm(alarm: alarm)
            } else {
                // No light sleep found, reschedule after a short interval
                print("No light sleep sample found: ", samples)
                Timer.scheduledTimer(withTimeInterval: 5 * 60, repeats: false) { _ in
                    self.checkSleepStateAndSchedule(alarm: alarm)
                }
            }
        }
    }
    func checkIfPermissionGranted() -> Bool {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let status = healthStore.authorizationStatus(for: sleepType)
        print(status.rawValue)
        if status == .sharingAuthorized { return true }
        return false
    }
    
}


