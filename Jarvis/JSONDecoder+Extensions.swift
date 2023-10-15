//
//  JSONDecoder+Extensions.swift
//  Jarvis
//
//  Created by Jason Anderson on 10/15/23.
//  Copyright © 2023 Kosoku Interactive, LLC. All rights reserved.
//

import Foundation
import CoreData

public extension JSONDecoder {
    static func managedObjectDecoder(context: NSManagedObjectContext) -> JSONDecoder {
        let retval = JSONDecoder()
        retval.userInfo[.managedObjectContext] = context
        return retval
    }
}
