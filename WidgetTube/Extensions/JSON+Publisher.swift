//
//  JSON+Publisher.swift
//  YouTube
//
//  Created by Josh Kowarsky on 9/20/20.
//

import Alamofire
import Combine

extension Publisher {
    public func decodeJSON<Item>(type: Item.Type) -> Publishers.Decode<Self, Item, JSONDecoder> where Item : Decodable, Self.Output == JSONDecoder.Input {
        return decode(type: type, decoder: JSONDecoder())
    }
}
