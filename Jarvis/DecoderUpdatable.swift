//
//  DecoderUpdatable.swift
//  Jarvis
//
//  Created by Jason Anderson on 10/14/23.
//  Copyright © 2023 Kosoku Interactive, LLC. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import Foundation

public protocol DecoderUpdatable {
    mutating func update(from decoder: Decoder) throws
}

public protocol DecodingFormat {
    func decoder(for data: Data) -> Decoder
}

public extension DecodingFormat {
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        try T.init(from: decoder(for: data))
    }
    
    func update<T: DecoderUpdatable>(_ value: inout T, from data: Data) throws {
        try value.update(from: decoder(for: data))
    }
}

public struct DecoderExtractor: Decodable {
    let decoder: Decoder
    
    public init(from decoder: Decoder) throws {
        self.decoder = decoder
    }
}

extension JSONDecoder: DecodingFormat {
    public func decoder(for data: Data) -> Decoder {
        try! decode(DecoderExtractor.self, from: data).decoder
    }
}

public extension KeyedDecodingContainer {
    func update<T: DecoderUpdatable>(_ value: inout T, forKey key: Key, userInfo: [CodingUserInfoKey: Any] = [:]) throws {
        let nestedDecoder = NestedDecoder(from: self, key: key, userInfo: userInfo)
        try value.update(from: nestedDecoder)
    }
    
    func decode(_ type: Dictionary<String, Any>.Type, forKey key: K) throws -> Dictionary<String, Any> {
        let container = try self.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
        return try container.decode(type)
    }
    
    func decodeIfPresent(_ type: Dictionary<String, Any>.Type, forKey key: K) throws -> Dictionary<String, Any>? {
        guard contains(key) else {
            return nil
        }
        guard try decodeNil(forKey: key) == false else {
            return nil
        }
        return try decode(type, forKey: key)
    }
    
    func decode(_ type: Array<Any>.Type, forKey key: K) throws -> Array<Any> {
        var container = try self.nestedUnkeyedContainer(forKey: key)
        return try container.decode(type)
    }
    
    func decodeIfPresent(_ type: Array<Any>.Type, forKey key: K) throws -> Array<Any>? {
        guard contains(key) else {
            return nil
        }
        guard try decodeNil(forKey: key) == false else {
            return nil
        }
        return try decode(type, forKey: key)
    }
    
    func decode(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {
        var dictionary = Dictionary<String, Any>()
        
        for key in allKeys {
            if let boolValue = try? decode(Bool.self, forKey: key) {
                dictionary[key.stringValue] = boolValue
            } else if let stringValue = try? decode(String.self, forKey: key) {
                dictionary[key.stringValue] = stringValue
            } else if let intValue = try? decode(Int.self, forKey: key) {
                dictionary[key.stringValue] = intValue
            } else if let doubleValue = try? decode(Double.self, forKey: key) {
                dictionary[key.stringValue] = doubleValue
            } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self, forKey: key) {
                dictionary[key.stringValue] = nestedDictionary
            } else if let nestedArray = try? decode(Array<Any>.self, forKey: key) {
                dictionary[key.stringValue] = nestedArray
            }
        }
        return dictionary
    }
}

public extension UnkeyedDecodingContainer {
    mutating func decode(_ type: Array<Any>.Type) throws -> Array<Any> {
        var array: [Any] = []
        while isAtEnd == false {
            // See if the current value in the JSON array is `null` first and prevent infite recursion with nested arrays.
            if try decodeNil() {
                continue
            } else if let value = try? decode(Bool.self) {
                array.append(value)
            } else if let value = try? decode(Double.self) {
                array.append(value)
            } else if let value = try? decode(String.self) {
                array.append(value)
            } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self) {
                array.append(nestedDictionary)
            } else if let nestedArray = try? decode(Array<Any>.self) {
                array.append(nestedArray)
            }
        }
        return array
    }
    
    mutating func decode(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {
        let nestedContainer = try self.nestedContainer(keyedBy: JSONCodingKeys.self)
        return try nestedContainer.decode(type)
    }
}

public final class NestedDecoder<Key: CodingKey>: Decoder {
    let container: KeyedDecodingContainer<Key>
    let key: Key
    
    public var userInfo: [CodingUserInfoKey : Any]
    public var codingPath: [CodingKey] {
        container.codingPath
    }
    
    init(from container: KeyedDecodingContainer<Key>, key: Key, userInfo: [CodingUserInfoKey: Any] = [:]) {
        self.container = container
        self.key = key
        self.userInfo = userInfo
    }
    
    public func container<K>(keyedBy type: K.Type) throws -> KeyedDecodingContainer<K> where K : CodingKey {
        try container.nestedContainer(keyedBy: type, forKey: key)
    }
    
    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        try container.nestedUnkeyedContainer(forKey: key)
    }
    
    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        NestedSingleValueDecodingContainer(container: container, key: key)
    }
}

public final class NestedSingleValueDecodingContainer<Key: CodingKey>: SingleValueDecodingContainer {
    let container: KeyedDecodingContainer<Key>
    let key: Key
    
    public var codingPath: [CodingKey] {
        container.codingPath
    }
    
    init(container: KeyedDecodingContainer<Key>, key: Key) {
        self.container = container
        self.key = key
    }
    
    public func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        return try container.decode(type, forKey: key)
    }
    
    public func decodeNil() -> Bool {
        return (try? container.decodeNil(forKey: key)) ?? false
    }
}

struct JSONCodingKeys: CodingKey {
    var stringValue: String
    
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    var intValue: Int?
    
    init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }
}
