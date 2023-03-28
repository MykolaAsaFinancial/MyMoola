//
//  ASATransaction.swift
//  ASA Pal
//
//  Created by Vakul Saini on 18/11/21.
//

import UIKit

struct ASAAccountBalance: Codable {
    var balance: Double?
    var description: String?
}

struct ASATransactionData: Codable {
    var transactions: [ASATransaction]?
}

struct ASATransaction: Codable {    
    var merchant_name: String?
    var date: String?
    var amount: Double?
}

struct ASAPersonalData: Codable {
    var personal: [ASAPersonal]?
}

struct ASAPersonal: Codable {
    
    var firstName: String?
    var lastName: String?
    var email: String?
}
