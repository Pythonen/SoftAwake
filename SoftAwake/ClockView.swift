//
//  ContentView.swift
//  SoftAwake
//
//  Created by Aleksi Puttonen on 24.6.2024.
//

import SwiftUI
import HealthKit
import HealthKitUI

struct ClockView: View {
    @EnvironmentObject var alarmManager: AlarmManager
    @State private var successAuth = false
    @State var authenticated = false
    @State var trigger = false
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Image(systemName: "alarm")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                    Text("Set a time for soft awakening")
                }
                .padding()
                
                ClockInput().environmentObject(alarmManager)
                
                NavigationLink(destination: AlarmListView().environmentObject(alarmManager)) {
                    HStack {
                        Image(systemName: "arrow.right.circle.fill")
                        Text("Or go to your alarms")
                    }
                    .padding(5)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .tint(Color.blue.opacity(0.7))
                .buttonStyle(.borderedProminent)
                .padding()
            }
            
            // Button for requesting HealthKit authorization
            Button("Grant access to your sleep data") {
                alarmManager.healthKitManager.requestAuthorization { success in
                    DispatchQueue.main.async {
                        successAuth = success
                    }
                    if success {
                        print("Authorization successful")
                    } else {
                        print("Authorization failed")
                    }
                }
            }
            .disabled(!authenticated)
            .opacity(authenticated ? 0 : 1)
            .onAppear() {
                
                // Check that Health data is available on the device.
                if HKHealthStore.isHealthDataAvailable() {
                    // Modifying the trigger initiates the health data
                    // access request.
                    trigger.toggle()
                }
            }
            .healthDataAccessRequest(store: alarmManager.healthKitManager.healthStore,
                                     shareTypes: [HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!],
                                     readTypes: [HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!],
                                     trigger: trigger) { result in
                switch result {
                    
                case .success(_):
                    authenticated = true
                case .failure(let error):
                    fatalError("*** An error occurred while requesting authentication: \(error) ***")
                }
                
            }
        }
    }
}
