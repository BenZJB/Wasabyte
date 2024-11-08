//
//  CommunityView.swift
//  Thrive
//
//  Created by Sean Lin on 08/11/2024
//  Copyright © 2024 Haol. All rights reserved.
//
//
//  storeview.swift
//  HealthThrive
//
//  Created by 保会 on 08/11/2024.
//
import SwiftUI

struct CatFood: Identifiable {
    let id = UUID()
    let name: String
    let price: Int
    let image: String
    let description: String
}

class StoreViewModel: ObservableObject {
    @Published var catCoins: Int = 100
    @Published var purchasedItems: [CatFood] = []
    @Published var storeItems: [CatFood] = [
        CatFood(name: "Tuna Treat", price: 50, image: "tuna", description: "Fresh tuna bits"),
        CatFood(name: "Chicken Delight", price: 30, image: "chicken", description: "Tender chicken pieces"),
        CatFood(name: "Salmon Feast", price: 70, image: "salmon", description: "Premium salmon"),
        CatFood(name: "Cat Kibble", price: 20, image: "kibble", description: "Crunchy kibble"),
        CatFood(name: "Fish Medley", price: 45, image: "fish", description: "Mixed seafood treat"),
        CatFood(name: "Milk Bottle", price: 25, image: "milk", description: "Cat-safe milk")
    ]
    
    func purchaseItem(_ item: CatFood) -> Bool {
        if catCoins >= item.price {
            catCoins -= item.price
            purchasedItems.append(item)
            return true
        }
        return false
    }
}

struct StoreView: View {
    @StateObject private var viewModel = StoreViewModel()
    @State private var showingPurchaseAlert = false
    @State private var alertMessage = ""
    
    private let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(.yellow)
                    Text("\(viewModel.catCoins) Cat Coins")
                        .font(.title2)
                        .bold()
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.storeItems) { item in
                        StoreItemCard(item: item) {
                            purchaseItem(item)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Cat Food Store")
        .alert(isPresented: $showingPurchaseAlert) {
            Alert(
                title: Text("Purchase Status"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func purchaseItem(_ item: CatFood) {
        if viewModel.purchaseItem(item) {
            alertMessage = "Successfully purchased \(item.name)!"
        } else {
            alertMessage = "Not enough Cat Coins to purchase \(item.name)"
        }
        showingPurchaseAlert = true
    }
}

struct StoreItemCard: View {
    let item: CatFood
    let onPurchase: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(item.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 120)
                .cornerRadius(8)
            
            Text(item.name)
                .font(.headline)
            
            Text(item.description)
                .font(.caption)
                .foregroundColor(.gray)
            
            HStack {
                Text("\(item.price) Coins")
                    .foregroundColor(.orange)
                    .bold()
                
                Spacer()
                
                Button(action: onPurchase) {
                    Text("Buy")
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}

struct StoreView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StoreView()
        }
    }
}
