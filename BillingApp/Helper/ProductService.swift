//
//  ProductService.swift
//  BillingApp
//
//  Created by Tirth Shah on 18/07/25.
//


import Foundation
import FirebaseFirestore

class ProductService {
    
    static let shared = ProductService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func fetchAllProducts(completion: @escaping ([[String: Any]]) -> Void) {
        db.collection("products").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching products: \(error.localizedDescription)")
                completion([])
                return
            }
            
            var allProducts: [[String: Any]] = []
            
            snapshot?.documents.forEach { doc in
                var product = doc.data()
                product["id"] = doc.documentID
                allProducts.append(product)
            }
            
            completion(allProducts)
        }
    }
    
    func fetchProductsGroupedByCategory(completion: @escaping ([String: [[String: Any]]]) -> Void) {
        db.collection("products").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching products: \(error.localizedDescription)")
                completion([:])
                return
            }
            
            var grouped: [String: [[String: Any]]] = [:]
            
            snapshot?.documents.forEach { doc in
                var product = doc.data()
                product["id"] = doc.documentID
                
                if let barcode = product["barcode"] as? String,
                   let prefix = barcode.split(separator: "-").first {
                    let key = String(prefix)
                    grouped[key, default: []].append(product)
                }
            }
            
            completion(grouped)
        }
    }
}
