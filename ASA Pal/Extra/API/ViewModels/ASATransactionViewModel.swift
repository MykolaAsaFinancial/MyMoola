//
//  ASATransactionViewModel.swift
//  ASA Pal
//
//  Created by Vakul Saini on 18/11/21.
//

import UIKit

class ASATransactionViewModel: NSObject {

    private var apiService: APIService!
    
    var data: Dynamic<ASAResponseRoot<ASATransactionData>> = Dynamic(ASAResponseRoot())
    var error: Dynamic<Error> = Dynamic(APICustomErrors.Empty.error)
    var isLoader: Dynamic<Bool> = Dynamic(false)
    
    override init() {
        super.init()
        apiService = APIService.shared
    }
    
    func getTransactions(consumerCode: String, fintechCode: String) {
        isLoader.value = true
        self.apiService.apiToGetConsumerData(consumerCode: consumerCode, fintechCode: fintechCode) { response, error in
            self.isLoader.value = false
            if let error = error {
                self.error.value = error
            }
            else if let data = response {
                if APIStaticData.SUCCESS_STATUS.contains(data.status) {
                    self.data.value = data
                }
                else {
                    self.error.value = ErrorWithMessage(data.message)
                }
            }
        }
    }
}
