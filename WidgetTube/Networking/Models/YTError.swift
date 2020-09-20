//
//  YTError.swift
//  YouTube
//
//  Created by Josh Kowarsky on 9/21/20.
//

import Foundation

struct YTErrorWrapper: Codable {
    let error: YTError
}

struct YTError: Error, Codable {
    let code: Int
    let message: String
}
