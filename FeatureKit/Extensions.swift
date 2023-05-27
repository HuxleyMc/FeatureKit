//
//  Extensions.swift
//  FeatureKit
//
//  Created by Huxley McGuffin on 27/5/2023.
//

import Foundation




protocol StringOrBool {
    func string() -> String?
    func bool() -> Bool?
}

extension Bool: StringOrBool {
    func string() -> String? {
        nil
    }
    func bool() -> Bool? {
        self as Bool
    }
}

extension String: StringOrBool {
    func string() -> String? {
        self as String
    }
    func bool() -> Bool? {
        nil
    }
}
