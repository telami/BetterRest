//
//  ContentView.swift
//  BetterRest
//
//  Created by telami on 2022/7/26.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var sleepAmount = 100.0
    @State private var wakeUp = defaultWakeTime
    @State private var coffeeAmount = 1

    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var alertMessage2 = ""
    @State private var showingAlert = false
    
    static let GMT8DateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "GMT+8")
        return formatter
        
    }()
    
    // 格式化日期
    func extractDate(date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }

    var body: some View {
        NavigationView {
            Form {
                
                Text(self.extractDate(date: Date(), format: "EEE"))
                    .font(.system(size: 14))
                    .fontWeight(.bold)


                Text(self.extractDate(date: Date(), format: "d"))
                    .font(.system(size: 15))
                    .fontWeight(.bold)

                Section {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .date)
                            .labelsHidden()
                            .environment(\.locale, Locale(identifier: "zh"))
                } header: {
                    Text("How do you want to wake up?")
                }
                Section {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                } header: {
                    Text("Desired amount of sleep")
                }
                Section {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                } header: {
                    Text("Desired amount of sleep")
                }
                Section {
                    Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20, step: 1)
                } header: {
                    Text("Daily coffee intake")
                }

            }
                    .navigationTitle("BetterRest")
                    .toolbar {
                        Button("Calculate", action: calculateBedtime)
                    }
                    .alert(alertTitle, isPresented: $showingAlert) {
                        Button("OK") {
                        }
                    } message: {
                        VStack {
                            Text(alertMessage + "  " + alertMessage2)
                        }
                    }
        }
    }

    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }

    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)

            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60

            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))

            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bedtime is…"
            alertMessage = showZhDate(sleepTime)
            alertMessage2 = sleepTime.formatted(date: .omitted, time: .shortened)

        } catch {

            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        showingAlert = true
    }

    func showZhDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "zh")
        dateFormatter.setLocalizedDateFormatFromTemplate("HHmm")
        return dateFormatter.string(from: date)
    }
}

class ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }

    #if DEBUG
    @objc class func injected() {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        windowScene?.windows.first?.rootViewController =
                UIHostingController(rootView: ContentView())
    }
    #endif
}


