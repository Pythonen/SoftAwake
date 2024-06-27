//
//  ClockInput.swift
//  SoftAwake
//
//  Created by Aleksi Puttonen on 24.6.2024.
//

import Foundation
import SwiftUI

struct CustomNumberPicker: View {
    @Binding var selectedNumber: Int
    var range: ClosedRange<Int>
    
    // Duplicate the range values for wrap-around effect
    private var duplicatedRange: [Int] {
        return Array(range) + Array(range) + Array(range) + Array(range)
    }
    
    private var midPoint: Int {
        return range.count
    }
    
    var body: some View {
        GeometryReader { geometry in
            Picker(selection: Binding(
                get: { self.selectedNumber + self.midPoint },
                set: { newValue in
                    self.selectedNumber = self.wrapIndex(newValue - self.midPoint)
                }
            ), label: Text("")) {
                ForEach(duplicatedRange.indices, id: \.self) { index in
                    Text(String(format: "%02d", self.duplicatedRange[index])).tag(index)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onAppear {
                // Set initial value to the middle section
                DispatchQueue.main.async {
                    self.selectedNumber = self.selectedNumber
                }
            }
        }
    }
    
    private func wrapIndex(_ index: Int) -> Int {
        if index < 0 {
            return index + range.count
        } else if index >= range.count {
            return index % range.count
        } else {
            return index
        }
    }
}

struct ClockInput: View {
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State private var wakeUpTime: String = UserDefaults.standard.string(forKey: "wakeuptime") ?? ""
    @State private var isListView = false
    @StateObject private var alarmManager = AlarmManager()

    
    var body: some View {
            VStack {
                HStack {
                    CustomNumberPicker(selectedNumber: $hours, range: 0...23)
                        .frame(width: 100, height: 200)
                    
                    Text(":")
                        .font(.largeTitle)
                    CustomNumberPicker(selectedNumber: $minutes, range: 0...59)
                        .frame(width: 100, height: 200)
                }
                NavigationLink(destination: AlarmListView()) {
                                HStack {
                                    Image(systemName: "bed.double.fill")
                                    Text("Set your wake up time")
                                }
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(10)
                            }
                            .simultaneousGesture(TapGesture().onEnded {
                                alarmManager.addAlarm(hours: hours, minutes: minutes)
                            })
                            .buttonStyle(.borderedProminent)
                            .padding()
               
                }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ClockInput()
    }
}
