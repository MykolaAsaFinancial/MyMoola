//
//  ASATransactionViewModel.swift
//  ASA Pal
//
//  Created by Vakul Saini on 18/11/21.
//

import UIKit

struct DataModel {
    let title: String
    let subTitle: String
    let desc: String
}

final class ASATransactionViewModel {

    private var apiService: APIService = APIService.shared
    
    var transactions: Dynamic<[DataModel]> = Dynamic([])
    var accounts: Dynamic<[DataModel]> = Dynamic([])
    var error: Dynamic<Error> = Dynamic(APICustomErrors.Empty.error)
    var isLoader: Dynamic<Bool> = Dynamic(false)
    
    func getTransactions() {
        let dict = AppDelegate.shared.getURLParams()
        guard let consumerCode = dict["AsaConsumerCode"], let fintechCode = dict["AsaFintechCode"] else { return }
        
        isLoader.value = true
        apiService.apiToGetTransactionsData(consumerCode: consumerCode, fintechCode: fintechCode) { response, error in
            self.isLoader.value = false
            if let error = error {
                self.error.value = error
            }
            else if let data = response {
                if APIStaticData.SUCCESS_STATUS.contains(data.status) {
                    if let transactionData = data.data {
                        let transactions = transactionData.flatMap({ $0.transactions ?? [] })
                        self.transactions.value = transactions.map({ DataModel(title: $0.date ?? "", subTitle: $0.merchant_name ?? "", desc: $0.amount?.toCurrency() ?? "") })
                    }
                }
                else {
                    self.error.value = ErrorWithMessage(data.message)
                }
            }
        }
    }
    
    func getAccounts() {
        let dict = AppDelegate.shared.getURLParams()
        guard let consumerCode = dict["AsaConsumerCode"], let fintechCode = dict["AsaFintechCode"] else { return }
        
        isLoader.value = true
        apiService.apiToGetAccountsData(consumerCode: consumerCode, fintechCode: fintechCode) { response, error in
            self.isLoader.value = false
            if let error = error {
                self.error.value = error
            }
            else if let data = response {
                if APIStaticData.SUCCESS_STATUS.contains(data.status) {
                    
                    var dataModels = [DataModel]()
                    
                    if let value = dict["AsaConsumerCode"] {
                        dataModels.append(DataModel(title: "ASA Consumer ID", subTitle: value, desc: ""))
                    }
                    if let value = dict["AsaFintechCode"] {
                        dataModels.append(DataModel(title: "ASA Fintech ID", subTitle: value, desc: ""))
                    }
                    if let value = dict["FintechName"] {
                        let decoded_value = value.replacingOccurrences(of: "+", with: " ")
                        dataModels.append(DataModel(title: "Fintech Name", subTitle: decoded_value, desc: ""))
                    }
                    
                    
                    let accountsModels = data.data?.compactMap({ DataModel(title: "Account/Balance", subTitle: $0.description ?? "", desc: $0.balance?.toCurrency() ?? "") }) ?? []
                    
                    dataModels.append(contentsOf: accountsModels)
                    
                    self.accounts.value = dataModels
                }
                else {
                    self.error.value = ErrorWithMessage(data.message)
                }
            }
        }
    }
    
}
