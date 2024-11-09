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

func sendTextToOpenAI(prompt: String, completion: @escaping (String?) -> Void) {
    let url = URL(string: "http://localhost:1234/v1/chat/completions")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let newPrompt = """
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
    """ + prompt
    
    let requestBody: [String: Any] = [
        "model": "mistral-nemo",
        "prompt": newPrompt,
        "max_tokens": 4096
    ]
    
    request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error sending request: \(error)")
            completion(nil) // Returning nil in case of error
            return
        }
        
        if let data = data, let responseText = String(data: data, encoding: .utf8) {
            completion(responseText) // Return the response text to the completion handler
        } else {
            completion(nil) // Return nil if there's no data or can't convert to string
        }
    }
    
    task.resume()
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
