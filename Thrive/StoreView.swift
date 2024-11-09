//
//  storeview.swift
//  HealthThrive
//
//  Created by 保会 on 08/11/2024.
//

import SwiftUI
import Combine

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
    
    @ObservedObject var viewModel: StoreViewModel
    
    @State private var showingPurchaseAlert = false
    @State private var alertMessage = ""
    
    private let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                HStack {
                    Image(systemName: "pawprint.circle.fill")
                        .resizable()
                        .foregroundColor(.orange)
                        .frame(width: 24, height: 24)
                    Text("\(viewModel.catCoins) Cat Coins")
                        .font(.title2)
                        .bold()
                }
                
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.storeItems) { item in
                        StoreItemCard(item: item) {
                            purchaseItem(item)
                        }
                    }
                }
                .padding()
                .background(Color.bg.ignoresSafeArea())
            }
        }
        .background(Color.bg.ignoresSafeArea(.all))
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
                
                Image(systemName: "pawprint.circle.fill")
                    .resizable()
                    .foregroundColor(.orange)
                    .frame(width: 20, height: 20)
                
                Text("\(item.price)")
                    .foregroundColor(.orange)
                    .bold()
                
                Spacer()
                
                Button(action: onPurchase) {
                    Text("Buy")
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.bg)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 4)
    }
}

//struct StoreView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            StoreView()
//        }
//    }
//}
