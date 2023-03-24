//
//  ASAResponseRoot.swift
//  ASA Pal
//
//  Created by Vakul Saini on 18/11/21.
//

import UIKit

struct ASAResponseRoot<T: Codable>: Codable {
    var status = 200
    var message = "Success"
    var data: T?
    
    enum CodingKeys: String, CodingKey {
        case status, message, data
    }
}

extension ASAResponseRoot {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.contains(.status) {
            status = try container.decode(Int.self, forKey: .status)
        }
        if container.contains(.message) {
            message = try container.decode(String.self, forKey: .message)
        }
        if container.contains(.data) {
            do {
                let value = try container.decode(T.self, forKey: .data)
                data = value
            } catch _ {
                data = nil
            }
        }
    }
}
