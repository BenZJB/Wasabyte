import SwiftUI
import Vision
import UIKit
import UniformTypeIdentifiers

struct HomeView: View {
    @State private var isFileImporterPresented = false
    @State private var selectedFileURL: URL?

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
                                        // sendTextToOpenAI(prompt: text)
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
