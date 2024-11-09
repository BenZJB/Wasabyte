//
//  Inference.swift
//  Thrive
//
//  Created by Sean Lin on 09/11/2024
//  Copyright © 2024 Haol. All rights reserved.
//

import SwiftUI
import Vision
import UIKit
import UniformTypeIdentifiers

func sendTextToOpenAI(sysPrompt: String = "", usrPrompt: String) -> String? {
    let url = URL(string: "http://localhost:1234/v1/chat/completions")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    if sysPrompt == "" {
        
        let sysPrompt = """
        Analyze the image of the patient’s health record provided below. Extract details about their treatment plan and present the data in the specified format.
        
            •    Details to extract:
            •    Medicine: Name of each prescribed medicine.
            •    Dose: Dosage of each medicine.
            •    Frequency: Frequency with which each medicine should be administered.
            •    Output Format: Provide your response in this exact structure for consistent string handling:
        
        [
            {"Medicine": "Medicine 1", "Dose": "Dose 1", "Frequency": "Frequency 1"},
            {"Medicine": "Medicine 2", "Dose": "Dose 2", "Frequency": "Frequency 2"},
            ...
        ]
        """
    }
    
    let requestBody: [String: Any] = [
        "model": "ministral",
        "messages": [
            ["role": "system", "content": sysPrompt],
            ["role": "user", "content": usrPrompt]
        ],
        "max_tokens": 4096
    ]
    
    // Create a DispatchGroup to manage the synchronous wait
    let dispatchGroup = DispatchGroup()
    var responseText: String?
    var requestError: Error?
    
    // Begin the network request
    dispatchGroup.enter()
    
    let requestData = try? JSONSerialization.data(withJSONObject: requestBody)
    request.httpBody = requestData
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        defer { dispatchGroup.leave() }
        
        if let error = error {
            requestError = error
            return
        }
        
        if let data = data, let text = String(data: data, encoding: .utf8) {
            responseText = text
        }
    }
    
    task.resume()
    
    // Wait for the network request to finish
    dispatchGroup.wait()
    
    // Handle the response or error
    if let error = requestError {
        print("Error: \(error)")
        return nil
    }
    
    return responseText
}


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
