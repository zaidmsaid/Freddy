//
//  JSON.swift
//  Freddy
//
//  Created by Matthew D. Mathias on 3/17/15.
//  Copyright © 2015 Big Nerd Ranch. Licensed under MIT.
//

import Foundation

/// An enum to describe the structure of JSON.
public enum JSON {
    /// A case for denoting an array with an associated value of `[JSON]`
    case array([JSON])
    /// A case for denoting a dictionary with an associated value of `[Swift.String: JSON]`
    case dictionary([String: JSON])
    /// A case for denoting a double with an associated value of `Swift.Double`.
    case double(Double)
    /// A case for denoting an integer with an associated value of `Swift.Int`.
    case int(Int)
    /// A case for denoting a string with an associated value of `Swift.String`.
    case string(String)
    /// A case for denoting a boolean with an associated value of `Swift.Bool`.
    case bool(Bool)
    /// A case for denoting null.
    case null
    
    func get(stringAt path: JSONPathType, _ defaultValue: String) -> String {
        get(stringAt: path) ?? defaultValue
    }
    
    func get(stringAt path: JSONPathType) -> String? {
        do {
            return try getString(at: path, alongPath: [.nullBecomesNil, .missingKeyBecomesNil])
        } catch {
            return nil
        }
    }
    
    func get(intAt path: JSONPathType, _ defaultValue: Int) -> Int {
        get(intAt: path) ?? defaultValue
    }
    
    func get(intAt path: JSONPathType) -> Int? {
        do {
            return try getInt(at: path, alongPath: [.nullBecomesNil, .missingKeyBecomesNil])
        } catch {
            return nil
        }
    }
    
    func get(arrayAt path: JSONPathType, _ defaultValue: [JSON]) -> [JSON] {
        get(arrayAt: path) ?? defaultValue
    }
    
    func get(arrayAt path: JSONPathType) -> [JSON]? {
        do {
            return try getArray(at: path, alongPath: [.nullBecomesNil, .missingKeyBecomesNil])
        } catch {
            return nil
        }
    }
    
    func get(jsonAt path: JSONPathType, _ defaultValue: JSON) -> JSON {
        get(jsonAt: path) ?? defaultValue
    }
    
    func get(jsonAt path: JSONPathType) -> JSON? {
        do {
            guard let dictionary = try getDictionary(at: path, alongPath: [.nullBecomesNil, .missingKeyBecomesNil]) else {
                return nil
            }
            return JSON(dictionary)
        } catch {
            return nil
        }
    }
    
    func get(boolAt path: JSONPathType, _ defaultValue: Bool) -> Bool {
        get(boolAt: path) ?? defaultValue
    }
    
    func get(boolAt path: JSONPathType) -> Bool? {
        do {
            return try getBool(at: path, alongPath: [.nullBecomesNil, .missingKeyBecomesNil])
        } catch {
            return get(stringAt: path)?.lowercased() == "true"
        }
    }
    
    func get(doubleAt path: JSONPathType, _ defaultValue: Double) -> Double {
        get(doubleAt: path) ?? defaultValue
    }
    
    func get(doubleAt path: JSONPathType) -> Double? {
        do {
            guard let value = try getDouble(at: path, alongPath: [.nullBecomesNil, .missingKeyBecomesNil]) else {
                return nil
            }
            guard value.isFinite, !value.isNaN else {
                return nil
            }
            return value
        } catch {
            return nil
        }
    }
    
    func get(cgFloatAt path: JSONPathType, _ defaultValue: CGFloat) -> CGFloat {
        get(cgFloatAt: path) ?? defaultValue
    }
    
    func get(cgFloatAt path: JSONPathType) -> CGFloat? {
        guard let value = get(floatAt: path) else {
            return nil
        }
        return CGFloat(value)
    }
    
    func get(floatAt path: JSONPathType, _ defaultValue: Float) -> Float {
        get(floatAt: path) ?? defaultValue
    }
    
    func get(floatAt path: JSONPathType) -> Float? {
        guard let value = get(doubleAt: path) else {
            return nil
        }
        
        let floatValue = Float(value)
        
        guard floatValue.isFinite, !floatValue.isNaN else {
            return nil
        }
        return floatValue
    }
    
    func get(dictionaryAt path: JSONPathType, _ defaultValue: [String: JSON]) -> [String: JSON] {
        get(dictionaryAt: path) ?? defaultValue
    }
    
    func get(dictionaryAt path: JSONPathType) -> [String: JSON]? {
        do {
            guard let value = try getDictionary(at: path, alongPath: [.nullBecomesNil, .missingKeyBecomesNil]) else {
                return nil
            }
            return value
        } catch {
            return nil
        }
    }
}

// MARK: - Errors

extension JSON {

    /// An enum to encapsulate errors that may arise in working with `JSON`.
    public enum Error: Swift.Error {
        /// The `index` is out of bounds for a JSON array
        case indexOutOfBounds(index: Int)
        
        /// The `key` was not found in the JSON dictionary
        case keyNotFound(key: String)
        
        /// The JSON is not subscriptable with `type`
        case unexpectedSubscript(type: JSONPathType.Type)
        
        /// Unexpected JSON `value` was found that is not convertible `to` type 
        case valueNotConvertible(value: JSON, to: Any.Type)
        
        /// The JSON is not serializable to a `String`.
        case stringSerializationError
    }

}

// MARK: - Test Equality

/// Return `true` if `lhs` is equal to `rhs`.
public func ==(lhs: JSON, rhs: JSON) -> Bool {
    switch (lhs, rhs) {
    case (.array(let arrL), .array(let arrR)):
        return arrL == arrR
    case (.dictionary(let dictL), .dictionary(let dictR)):
        return dictL == dictR
    case (.string(let strL), .string(let strR)):
        return strL == strR
    case (.double(let dubL), .double(let dubR)):
        return dubL == dubR
    case (.double(let dubL), .int(let intR)):
        return dubL == Double(intR)
    case (.int(let intL), .int(let intR)):
        return intL == intR
    case (.int(let intL), .double(let dubR)):
        return Double(intL) == dubR
    case (.bool(let bL), .bool(let bR)):
        return bL == bR
    case (.null, .null):
        return true
    default:
        return false
    }
}

extension JSON: Equatable {}

// MARK: - Printing

extension JSON: CustomStringConvertible {

    /// A textual representation of `self`.
    public var description: Swift.String {
        switch self {
        case .array(let arr):       return String(describing: arr)
        case .dictionary(let dict): return String(describing: dict)
        case .string(let string):   return string
        case .double(let double):   return String(describing: double)
        case .int(let int):         return String(describing: int)
        case .bool(let bool):       return String(describing: bool)
        case .null:                 return "null"
        }
    }

}
