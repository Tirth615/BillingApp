//
//  BarcodeGenerator.swift
//  BillingApp
//
//  Created by Tirth Shah on 17/07/25.
//


import FirebaseFirestore

class BarcodeGenerator {
    
    static func generateBarcode(for categoryPrefix: String, completion: @escaping (String?) -> Void) {
        let db = Firestore.firestore()
        let counterRef = db.collection("barcode_counters").document(categoryPrefix)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            var lastNumber = 0
            
            let counterDoc: DocumentSnapshot
            do {
                try counterDoc = transaction.getDocument(counterRef)
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }
            
            if let current = counterDoc.data()?["lastNumber"] as? Int {
                lastNumber = current
            }
            
            let newNumber = lastNumber + 1
            transaction.updateData(["lastNumber": newNumber], forDocument: counterRef)
            
            let barcode = "\(categoryPrefix)-" + String(format: "%03d", newNumber)
            return barcode
        }, completion: { (object, error) in
            if let error = error {
                print("Error generating barcode: \(error.localizedDescription)")
                completion(nil)
            } else if let barcode = object as? String {
                completion(barcode)
            } else {
                completion(nil)
            }
        })
    }
}
