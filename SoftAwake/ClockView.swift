//
//  ContentView.swift
//  SoftAwake
//
//  Created by Aleksi Puttonen on 24.6.2024.
//

import SwiftUI

struct ClockView: View {
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
                ClockInput()
                NavigationLink(destination: AlarmListView()) {
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
        }
    }
}

#Preview {
    ClockView()
}
