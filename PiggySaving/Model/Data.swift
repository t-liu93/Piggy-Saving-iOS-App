//
//  Data.swift
//  PiggySaving
//
//  Created by Tianyu Liu on 28/01/2022.
//

import Foundation
import SwiftUI
import CoreData

struct LastSavingAmount: Codable {
    var amount: Double
    var saved: Int
    
    init() {
        self.amount = 0
        self.saved = 0
    }
}

struct Sum: Codable {
    var sum: Double
    
    init() {
        self.sum = 0
    }
}


struct Saving: Codable, Identifiable {
    let id = UUID().uuidString
    var date: String
    var amount: Double
    var saved: Int
    
    var isSaved: Bool {
        return saved == 1 ? true : false
    }
    
    enum CodingKeys: CodingKey {
        case date
        case amount
        case saved
    }
    
    var dateFormatted: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: self.date) ?? Date()
    }
    
    init() {
        self.date = "2000-01-01"
        self.amount = 1
        self.saved = 0
    }
    
    init(savingData: SavingData) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-DD"
        self.date = dateFormatter.string(from: savingData.date!)
        self.amount = savingData.amount
        self.saved = savingData.saved ? 1 : 0
    }
}

extension Saving {
    init(date: String, amount: Double, saved: Int) {
        self.date = date
        self.amount = amount
        self.saved = saved
    }
    
    static let sampleData: [Saving] =
    [
        Saving(date: "2000-01-01", amount: 10.0, saved: 1),
        Saving(date: "2000-01-02", amount: 10.1, saved: 1),
        Saving(date: "2000-01-03", amount: 10.2, saved: 0)
    ]
}

class SavingDataStore: ObservableObject {
    @Published var savings: [Saving]
    let container = NSPersistentContainer(name: "PiggySavingData")
    
    init() {
        self.savings = []
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core data failed to load: \(error.localizedDescription)")
            }
        }
        
        let context = self.container.viewContext
        let fetchRequest = SavingData.fetchRequest()
 
        // TODO: think about error handling later.
        let savings = try? context.fetch(fetchRequest)
        
        if let savings = savings {
            savings.forEach { saving in
                let newSaving = Saving(savingData: saving)
                self.savings.append(newSaving)
            }
        }
    }
    
    init(saving: [Saving]) {
        self.savings = saving
    }
    
    public func updateFromSelfSavingArray() -> Void {
        
    }
}
