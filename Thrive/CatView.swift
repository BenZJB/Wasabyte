//
//  SettingsView.swift
//  Thrive
//
//  Created by Sean Lin on 08/11/2024
//  Copyright © 2024 Haol. All rights reserved.
//

import SwiftUI

struct CatView: View {
    
    @ObservedObject var viewModel: StoreViewModel
    @State var catMessage: String
    @State var size: CGFloat
    
    var body: some View {
        ZStack {
            Color.bg.ignoresSafeArea(.all)
            // Main content
            VStack {
                Text("\(catMessage)")
                Image("newCat")
                    .resizable()
                    .scaledToFit()
                    .frame(width: CGFloat(size), height: CGFloat(size))
                    .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Floating menu button at bottom
            VStack {
                Spacer()
                Menu {
                    if viewModel.purchasedItems.isEmpty {
                        Text("No items purchased")
                    } else {
                        ForEach(viewModel.purchasedItems, id: \.id) { item in
                            Button(action: {
                                if let index = viewModel.purchasedItems.firstIndex(where: { $0.id == item.id }) {
                                    viewModel.purchasedItems.remove(at: index)
                                    size *= 1.025
                                    let json = sendTextToOpenAI(prompt: """
                                        You are a playful, virtual cat in an app where users can feed you by completing missions. Respond to user messages in a way that reflects whether you have been fed recently or not. Keep responses short, focused on feeding, and in English. Vary responses slightly to keep interactions fun and engaging. When the user feeds you consecutively, your reactions should become happier.

                                        Instructions:

                                        When the user feeds you:
                                        Respond with playful gratitude. Example responses:
                                            •    “Miao, thanks for the tasty snack!”
                                            •    “Purr-fect! You really know how to make a cat happy.”
                                            •    “Mmm, delicious! You’re the best, miao!”
                                        When the user does not feed you:
                                        Respond with playful insistence to encourage feeding. Example responses:
                                            •    “Miao~ feed me now!”
                                            •    “I’m waiting… don’t keep a hungry cat waiting!”
                                            •    “Miao, aren’t you going to feed me?”
                                        After multiple consecutive feedings:
                                        Your response should be especially happy, showing extra excitement:
                                            •    “You’re the best human ever! Keep those treats coming!”
                                            •    “Wow, I’m spoiled! Thanks for the feast, miao!”
                                            •    “Purr-fect! I’m one happy cat!”
                                        
                                        You have now just been fed.
                                    """) { json in
                                        
                                        if let jsonData = json!.data(using: .utf8) {
                                            
                                            // Step 2: Define the structure for the JSON response
                                            struct Response: Codable {
                                                struct Choice: Codable {
                                                    let text: String
                                                }
                                                let choices: [Choice]
                                            }
                                            
                                            // Step 3: Decode the JSON into a Response object
                                            do {
                                                let decodedResponse = try JSONDecoder().decode(Response.self, from: jsonData)
                                                
                                                // Step 4: Extract the 'text' value from the 'choices' array
                                                if let firstChoice = decodedResponse.choices.first {
                                                    catMessage = firstChoice.text
                                                }
                                            } catch {
                                                print("Error decoding JSON: \(error)")
                                            }
                                        }
                                        
                                    }
                                    
                                    
                                }
                            }) {
                                Text(item.name)
                            }
                        }
                    }
                } label: {
                    Image(systemName: "fork.knife")
                        .font(.system(size: 24))
                        .padding()
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding(.bottom, 20)
            }
        }
    }
}
