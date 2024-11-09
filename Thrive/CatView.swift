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
                                
                                let result = sendTextToOpenAI(sysPrompt: """
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
                                    
                                Change your response every time.
                                """, usrPrompt: """
                                    You have been just fed.
                                """)
                                
                                if let response = result {
                                    print(response)
                                    if let jsonData = response.data(using: .utf8) {
                                        do {
                                            // Parse the JSON into a dictionary
                                            if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                                                // Access the choices array
                                                if let choices = jsonObject["choices"] as? [[String: Any]],
                                                   let firstChoice = choices.first,
                                                   let message = firstChoice["message"] as? [String: Any],
                                                   let content = message["content"] as? String {
                                                        catMessage = content
                                                } else {
                                                    print("Error: Could not find 'content' key")
                                                }
                                            }
                                        } catch {
                                            print("Error parsing JSON: \(error)")
                                        }
                                    }
                                } else {
                                    print("Failed to get a response.")
                                }
                                
                                if let index = viewModel.purchasedItems.firstIndex(where: { $0.id == item.id }) {
                                    viewModel.purchasedItems.remove(at: index)
                                    size *= 1.025
                                    }
                                }
                            ) {
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
