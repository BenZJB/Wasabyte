//
//  DashView.swift
//  Thrive
//
//  Created by Sean Lin on 09/11/2024
//  Copyright © 2024 Haol. All rights reserved.
//

import SwiftUI
import Vision
import UIKit
import Foundation
import UniformTypeIdentifiers
import QuartzCore

struct DashView: View {
    @State private var isFileImporterPresented = false
    @State private var selectedFileURL: URL?
    @State private var name: String = UserDefaults.standard.string(forKey: "userName") ?? ""
    @State private var progressValue: Double = 0.0
    @State var medicines: [String: Int]
    @State private var totalChecked: Int = 0
    @State private var selectedDate: Date = Date()
    
    private var totalCheckboxes: Int {
        medicines.values.reduce(0, +)
    }
    
    init(medicines: [String: Int] = [:]) {
        _medicines = State(initialValue: medicines)
    }
    
    func updateProgress() {
        if totalCheckboxes > 0 {
            progressValue = Double(totalChecked) / Double(totalCheckboxes)
        } else {
            progressValue = 0.0
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            VStack {
                HStack {
                    Image(systemName: "pawprint.circle")
                        .resizable()
                        .foregroundColor(.purple)
                        .frame(width: 40, height: 40)
                    Spacer()
                    TextField("Enter your name", text: $name, onCommit: {
                        saveName()
                    })
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 2)
                    Spacer()
                    Button(action: {
                        isFileImporterPresented = true
                    }) {
                        Image(systemName: "document.badge.plus")
                            .font(.system(size: 35))
                            .foregroundColor(.blue)
                    }
                    .fileImporter(
                        isPresented: $isFileImporterPresented,
                        allowedContentTypes: [.image],
                        allowsMultipleSelection: false
                    ) { result in
                        do {
                            selectedFileURL = try result.get().first
                            if let fileURL = selectedFileURL,
                               let image = UIImage(contentsOfFile: fileURL.path) {
                                extractTextFromImage(image) { recognizedText in
                                    if let text = recognizedText {
                                        extractMedicines(from: text)
                                    }
                                }
                            }
                        } catch {
                            print("Error selecting file: \(error.localizedDescription)")
                        }
                    }
                }
                .padding(5)
                Divider()
            }
            .background(Color(hex: "C6E2E9").opacity(0.8))
            
            // Calendar and Scrollable Content
            VStack {
                DatePickerWithMarksView(selectedDate: $selectedDate).frame(height: 300)
                Spacer().frame(height: 20)
                
                ScrollView {
                    Text("\(selectedDate, formatter: DateFormatter.shortDate)")
                        .font(.headline)
                        .padding()
                    
                    // Display each medicine with checkboxes and CircularProgressView
                    ForEach(medicines.keys.sorted(), id: \.self) { medicine in
                        HStack {
                            MedicineDosageView(
                                medicine: medicine,
                                dosageCount: medicines[medicine] ?? 1,
                                checkedCount: $totalChecked,
                                updateProgress: updateProgress
                            )
                            .padding(1)
                            
                            Spacer()
                            CircularProgressView(progress: $progressValue)
                                .frame(width: 100, height: 100)
                        }
                    }
                }
            }
            Spacer()
        }
        .padding()
        .onAppear {
            loadName()
        }
    }
    
    private func saveName() {
        UserDefaults.standard.set(name, forKey: "userName")
    }
    
    private func loadName() {
        name = UserDefaults.standard.string(forKey: "userName") ?? ""
    }
    
    // Function to extract text from image
    func extractTextFromImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage else {
            print("Failed to convert UIImage to CGImage.")
            completion(nil)
            return
        }
        
        let request = VNRecognizeTextRequest { (request, error) in
            if let error = error {
                print("Text recognition error: \(error)")
                completion(nil)
                return
            }
            
            let recognizedText = request.results?.compactMap { result -> String? in
                guard let observation = result as? VNRecognizedTextObservation else { return nil }
                return observation.topCandidates(1).first?.string
            }.joined(separator: "\n")
            
            completion(recognizedText)
        }
        
        request.recognitionLevel = .accurate
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                print("Failed to perform text recognition: \(error)")
                completion(nil)
            }
        }
    }
    
    func extractMedicines(from text: String) {
        let lines = text.split(separator: "\n")
        var extractedMedicines: [String: Int] = [:]
        
        for line in lines {
            if line.contains("Medicine") {
                let parts = line.split(separator: "-")
                let medicine = parts.first?.replacingOccurrences(of: "Medicine Prescribed for Last", with: "").trimmingCharacters(in: .whitespaces)
                
                if let dosageInfo = parts.last {
                    let maxDosage = extractMaxDigit(from: String(dosageInfo))
                    if let medicine = medicine {
                        extractedMedicines[medicine] = maxDosage
                    }
                }
            }
        }
        
        medicines = extractedMedicines
    }

    func extractMaxDigit(from dose: String) -> Int {
        let pattern = #"(\d+)"#
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(dose.startIndex..., in: dose)
        
        var maxDigit = 0
        if let matches = regex?.matches(in: dose, range: range) {
            for match in matches {
                if let matchRange = Range(match.range(at: 1), in: dose),
                   let digit = Int(String(dose[matchRange])) {
                    maxDigit = max(maxDigit, digit)
                }
            }
        }
        return maxDigit
    }
}

struct MedicineDosageView: View {
    let medicine: String
    let dosageCount: Int
    @Binding var checkedCount: Int
    var updateProgress: () -> Void

    @State private var checkedDosages: [Bool]
    
    init(medicine: String, dosageCount: Int, checkedCount: Binding<Int>, updateProgress: @escaping () -> Void) {
        self.medicine = medicine
        self.dosageCount = dosageCount
        _checkedCount = checkedCount
        self.updateProgress = updateProgress
        _checkedDosages = State(initialValue: Array(repeating: false, count: dosageCount))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\(medicine) - \(dosageCount) dosages")
                .font(.headline)
                .padding(.bottom, 5)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                ForEach(0..<dosageCount, id: \.self) { index in
                    Toggle(isOn: Binding(
                        get: { checkedDosages[index] },
                        set: { newValue in
                            checkedDosages[index] = newValue
                            checkedCount += newValue ? 1 : -1
                            updateProgress()
                        }
                    )) {
                        EmptyView()
                    }
                    .toggleStyle(CheckToggleStyle())
                    .frame(width: 30, height: 30)
                }
            }
        }
        .padding()
        .frame(width: 200, height: 100)
        .background(Color(hex: "C6E2E9").opacity(0.8))
        .cornerRadius(10)
    }
}

struct DatePickerWithMarksView: View {
    @Binding var selectedDate: Date
    @State private var markedDates: Set<Date> = []

    var body: some View {
        VStack(spacing: 0) {
            DatePicker("Select a Date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .scaleEffect(0.8)
                .frame(height: 250)
                .clipped()
                .padding(.horizontal)

            Button(action: {
                toggleMark(for: selectedDate)
            }) {
                Text(markedDates.contains(selectedDate) ? "Unmark Date" : "Mark Date")
                    .font(.footnote)
                    .padding(6)
                    .background(markedDates.contains(selectedDate) ? Color.green : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.bottom, 5)
        }
        .padding()
        .onAppear {
            loadMarkedDates()
        }
    }
    
    private func toggleMark(for date: Date) {
        if markedDates.contains(date) {
            markedDates.remove(date)
        } else {
            markedDates.insert(date)
        }
        saveMarkedDates()
    }
    
    private func saveMarkedDates() {
        let markedDatesArray = Array(markedDates)
        UserDefaults.standard.set(markedDatesArray, forKey: "markedDates")
    }
    
    private func loadMarkedDates() {
        if let savedDates = UserDefaults.standard.object(forKey: "markedDates") as? [Date] {
            markedDates = Set(savedDates)
        }
    }
}

struct CheckToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Image(systemName: configuration.isOn ? "checkmark.square" : "square")
            .resizable()
            .frame(width: 20, height: 20)
            .onTapGesture {
                configuration.isOn.toggle()
            }
    }
}

struct CircularProgressView: View {
    @Binding var progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color(hex: "C6E2E9").opacity(0.8),
                    lineWidth: 10
                )
                .scaleEffect(0.4)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color(hex: "#F9A120"),
                    style: StrokeStyle(
                        lineWidth: 10,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: progress)
                .scaleEffect(0.4)
        }
    }
}

extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        DashView(medicines: [
            "Amoxil Capsule": 3,
            "Decetine Pills": 2,
            "Magistral Amoxil Tablet": 1
        ])
    }
}
