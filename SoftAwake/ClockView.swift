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
        }
        }
    }
}

#Preview {
    ClockView()
}
