import SwiftUI
import UniformTypeIdentifiers

struct HomeView: View {
    @State private var isFileImporterPresented = false
    @State private var selectedFileURL: URL?
    func sendTextFileToOpenAI(fileURL: URL) {
        // Step 1: Read the file content
        guard let fileContent = try? String(contentsOf: fileURL, encoding: .utf8) else {
            print("Failed to read file content.")
            return
        }
        
        // Step 2: Set up the OpenAI API request
        let apiKey = "YOUR_OPENAI_API_KEY"
        let url = URL(string: "https://api.openai.com/v1/completions")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Step 3: Prepare the request body
        let requestBody: [String: Any] = [
            "model": "gpt-4",
            "prompt": fileContent,
            "max_tokens": 100
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        // Step 4: Send the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending request: \(error)")
                return
            }
            
            if let data = data, let responseText = String(data: data, encoding: .utf8) {
                print("Response from OpenAI: \(responseText)")
            }
        }
        
        task.resume()
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
                        isFileImporterPresented = true  // Set to true to open file picker
                    }) {
                        Image(systemName: "document.badge.plus")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .fileImporter(
                        isPresented: $isFileImporterPresented,
                        allowedContentTypes: [.image, .pdf],
                        allowsMultipleSelection: false // Set to false to select only one file
                    ) { result in
                        do {
                            selectedFileURL = try result.get().first
                            print("Selected file URL: \(String(describing: selectedFileURL))")
                            sendTextFileToOpenAI(fileURL:selectedFileURL!)
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
