import SwiftUI
import Vision
import UIKit
import UniformTypeIdentifiers

struct HomeView: View {
    @State private var isFileImporterPresented = false
    @State private var selectedFileURL: URL?

    func sendTextToOpenAI(prompt: String) {
        let url = URL(string: "http://localhost:1234/v1/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "ministral",
            "prompt": prompt,
            "max_tokens": 1024
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending request: \(error)")
                return
            }
            
            if let data = data, let responseText = String(data: data, encoding: .utf8) {
                print("Response from API: \(responseText)")
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

    var body: some View {
        VStack(spacing: 20) {
            // Custom Top Section
            VStack {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                    Spacer()
                    Text("Wasabyte")
                        .font(.title)
                        .bold()
                    Spacer()
                    Button(action: {
                        isFileImporterPresented = true
                    }) {
                        Image(systemName: "document.badge.plus")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .fileImporter(
                        isPresented: $isFileImporterPresented,
                        allowedContentTypes: [.image],
                        allowsMultipleSelection: false
                    ) { result in
                        do {
                            selectedFileURL = try result.get().first
                            print("Selected file URL: \(String(describing: selectedFileURL))")
                            
                            // Ensure we have a valid URL and try to load it as a UIImage
                            if let fileURL = selectedFileURL,
                               let image = UIImage(contentsOfFile: fileURL.path) {
                                extractTextFromImage(image) { recognizedText in
                                    if let text = recognizedText {
                                        print("Extracted text: \(text)")
                                        sendTextToOpenAI(prompt: text)
                                    } else {
                                        print("No text recognized in the image.")
                                    }
                                }
                            }
                        } catch {
                            print("Error selecting file: \(error.localizedDescription)")
                        }
                    }
                }
                .padding()
                
                Divider()
            }
            .background(Color.blue.opacity(0.1))
            
            Spacer()
            
            // Main Content
            Text("Main content goes here")
            Spacer()
        }
        .padding()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
