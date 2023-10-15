//
//  CodingUserInfoKey+Extensions.swift
//  Jarvis
//
//  Created by Jason Anderson on 10/15/23.
//  Copyright © 2023 Kosoku Interactive, LLC. All rights reserved.
//

import Foundation
import CoreData

public extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
}
