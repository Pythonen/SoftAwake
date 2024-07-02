//
//  ContentView.swift
//  SoftAwake
//
//  Created by Aleksi Puttonen on 24.6.2024.
//

import SwiftUI

struct ClockView: View {
    @EnvironmentObject var alarmManager: AlarmManager
    @State private var successAuth = false
    
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
            Button("Request HealthKit Authorization") {
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
            .opacity(successAuth ? 0 : 1)
            .disabled(successAuth)
        }
        .onAppear {
            successAuth = alarmManager.healthKitManager.checkIfPermissionGranted()
        }
    }
}

#Preview {
    ClockView()
}
