//
//  APIService.swift
//  ASA Vault
//
//  Created by Vakul Saini on 26/07/21.
//

import UIKit
import Alamofire

struct APIStaticData {

    static let API_KEY  = ""
    static let AUTHORIZATION_KEY  = ""
    static let APP_CODE  = ""
    
    static let BASE_URL = "https://openapi.asacore.com"
    static let SUCCESS_STATUS = [200, 201]
}


// MARK:- API Sinleton class
final class APIService: NSObject {
    private override init() { }
    static let shared = APIService()
}


// MARK:- Endpoints
enum APIEndPoints: String {
    case accounts = "Balance/Accounts"
    case transactions = "Transactions"
}

extension APIEndPoints {
    var url: String {
        return "\(APIStaticData.BASE_URL)/\(self.rawValue)"
    }
}


// MARK:- Headers Extenstions
extension HTTPHeaders {
    mutating func appendCommonHeaders() {
        self.add(name: "Ocp-Apim-Subscription-Key", value: APIStaticData.API_KEY)
        self.add(name: "AuthorizationKey", value: APIStaticData.AUTHORIZATION_KEY)
        self.add(name: "ApplicationCode", value: APIStaticData.APP_CODE)
        self.add(name: "X_ASA_version",             value: "1.01")
    }
}

// MARK:- API Common Methods
extension APIService {
    func performAPI<T: Decodable>(endPoint: APIEndPoints,
                    method: HTTPMethod,
                    params: [String: Any]?,
                    headers: HTTPHeaders?,
                    encoding: ParameterEncoding = JSONEncoding.default, completion: @escaping (T?, Error?) -> Void) {
        performAPI(url: endPoint.url, method: method, params: params, headers: headers, encoding: encoding, completion: completion)
    }
    
    
    func performAPI<T: Decodable>(url: String,
                    method: HTTPMethod,
                    params: [String: Any]?,
                    headers: HTTPHeaders?,
                    encoding: ParameterEncoding = JSONEncoding.default,
                    completion: @escaping (T?, Error?) -> Void) {
        
        // Checking for internet connectivity
        if !Internet.isAvailable() {
            completion(nil, APICustomErrors.NoInternet.error)
            return
        }
        
        debugPrint("URL: \(url)")
        debugPrint("Params: \n\(params ?? [:])")
        debugPrint("headers: \n\(headers ?? HTTPHeaders([]))")
        
        AF.request(url, method: method, parameters: params, encoding: encoding, headers: headers){ $0.timeoutInterval = 180 }.response { [unowned self] response in
            debugPrint("Response for URL: \(url)")
            parseData(response: response, completion: completion)
        }
    }
    
    
    func parseData<T: Decodable>(response: AFDataResponse<Data?>, completion: @escaping (T?, Error?) -> Void) {
        switch response.result {
            case .success(let value):
                // Check if we recieved the data properly
                guard let data = value else {
                    // No data found
                    debugPrint(APICustomErrors.InvalidJson.error.localizedDescription)
                    completion(nil, APICustomErrors.InvalidJson.error)
                    return
                }
                
                // We have data, Now try parsing
                do {
                    let obj = try data.decode() as T
                    debugPrint(obj)
                    completion(obj, nil)
                } catch _ {
                    debugPrint(APICustomErrors.InvalidJson.error.localizedDescription)
                    completion(nil, APICustomErrors.InvalidJson.error)
                }
            
            case .failure(let error):
                debugPrint(error.localizedDescription)
                completion(nil, error)
        }
    }
    
}


// MARK:- App APIs
extension APIService {

    func apiToGetTransactionsData(consumerCode: String, fintechCode: String, completion: @escaping (ASAResponseRoot<[ASATransactionData]>?, Error?) -> ()) {
        var headers = HTTPHeaders()
        headers.appendCommonHeaders()
        headers.add(name: "asaConsumerCode", value: consumerCode)
        headers.add(name: "asaFintechCode", value: fintechCode)
        performAPI(endPoint: .transactions, method: .post, params: [:], headers: headers, completion: completion)
    }
    
    func apiToGetAccountsData(consumerCode: String, fintechCode: String, completion: @escaping (ASAResponseRoot<[ASAAccountBalance]>?, Error?) -> ()) {
        var headers = HTTPHeaders()
        headers.appendCommonHeaders()
        headers.add(name: "asaConsumerCode", value: consumerCode)
        headers.add(name: "asaFintechCode", value: fintechCode)
        performAPI(endPoint: .accounts, method: .get, params: nil, headers: headers, completion: completion)
    }
}


extension Data {
    func decode<T: Decodable>() throws -> T {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: self)
    }
}


// MARK:- Internet Connection Checker
class Internet {
    class func isAvailable() -> Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
}
