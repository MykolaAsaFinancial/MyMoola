//
//  ASATransaction.swift
//  ASA Pal
//
//  Created by Vakul Saini on 18/11/21.
//

import UIKit

struct ASATransactionData: Codable {
    var transactions: [ASATransaction]?
}

struct ASATransaction: Codable {
    /*var consumerFiTransactionDetailId: Int?
    var activityDate: String?
    var effectiveDate: String?
    var lastTranDate: String?
    var interest: Double?
    var balanceChange: Double?
    var newBalance: Double?
    var prevAvailBalance: Double?
    var salesTaxAmount: Double?
    var batchSequence: String?
    var voidCode: String?
    var transactionPostDate: String?
    var transactionPostTime: String?
    var recurringTran: Bool?
    var transactionAmount: Double?
    var transactionDescription: String?
    var transactionReference: String?
    var transactionMemo: String?
    var transactionTypeCode: String?
    var transactionType: Int?*/
    
    var transactionPostDate: String?
    var transactionMemo: String?
    var balanceChange: Double?
}

struct ASAPersonalData: Codable {
    var personal: [ASAPersonal]?
}

struct ASAPersonal: Codable {
    
    var firstName: String?
    var lastName: String?
    var email: String?
}
