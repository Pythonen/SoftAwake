//
//  AlarmListView.swift
//  SoftAwake
//
//  Created by Aleksi Puttonen on 25.6.2024.
//

import Foundation
import SwiftUI

struct AlarmListView: View {
    @State private var wakeUpTimes: [(key: String, value: String, isOn: Bool)] = []
    var body: some View {
        VStack {
            List {
                ForEach(wakeUpTimes.indices, id: \.self) { index in
                    Toggle(isOn: $wakeUpTimes[index].isOn) {
                        HStack {
                            Text(wakeUpTimes[index].value)
                                .font(.subheadline)
                                .foregroundColor(wakeUpTimes[index].isOn ? .black : .gray)
                        }
                    }
                    .onChange(of: wakeUpTimes[index].isOn) { oldValue,  newValue in
                        updateToggleState(at: index, to: newValue)
                    }
                }
                .onDelete(perform: delete)
            }
        }
        .onAppear(perform: loadWakeUpTimes)
        .navigationTitle("Alarm List")
    }
    func loadWakeUpTimes(){
        let userDefaults = UserDefaults.standard
        let dictionary = userDefaults.dictionaryRepresentation()
        let timeFormatRegex = try! NSRegularExpression(pattern: "^\\d{2}:\\d{2}$")
        
        wakeUpTimes = dictionary.compactMap { key, value in
            if let stringValue = value as? String,
               timeFormatRegex.firstMatch(in: stringValue, options: [], range: NSRange(location: 0, length: stringValue.utf16.count)) != nil {
                let isOn = userDefaults.bool(forKey: "\(key)_toggle")
                return (key, stringValue, isOn)
            }
            return nil
        }
    }
    func delete(at offsets: IndexSet) {
        offsets.forEach { index in
            let key = wakeUpTimes[index].key
            UserDefaults.standard.removeObject(forKey: key)
        }
        wakeUpTimes.remove(atOffsets: offsets)
    }
    func updateToggleState(at index: Int, to newValue: Bool) {
        let key = wakeUpTimes[index].key
        UserDefaults.standard.set(newValue, forKey: "\(key)_toggle")
    }
}
