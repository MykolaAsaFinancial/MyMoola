//
//  ErrorClass.swift
//  ASA Vault
//
//  Created by Vakul Saini on 29/07/21.
//

import UIKit

struct ErrorClass: Equatable {
    var string: String
}

extension ErrorClass: ExpressibleByStringLiteral {
    init(stringLiteral: String) {
        string = stringLiteral
    }
}

enum APICustomErrors: ErrorClass {
    case NoInternet = "It seems you are not connected to the internet. Please try again."
    case InvalidJson = "We are facing some technical difficulties. Please try again."
    case Empty = ""
}

extension APICustomErrors {
    var error: Error {
        return ErrorWithMessage(self.rawValue.string)
    }
}

func ErrorWithMessage(_ message: String) -> Error {
   return NSError(domain: "com.asa.pal", code: 9999, userInfo: [NSLocalizedDescriptionKey: message]) as Error
}
