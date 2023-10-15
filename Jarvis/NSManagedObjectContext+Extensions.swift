//
//  NSManagedObjectContext+Extensions.swift
//  Jarvis
//
//  Created by Jason Anderson on 10/15/23.
//  Copyright © 2023 Kosoku Interactive, LLC. All rights reserved.
//

import CoreData

public extension NSManagedObjectContext {
    typealias JARCoreDataCompletionBlock = ([NSManagedObject], Error?) -> Void
    
    func saveRecursively() throws {
        var blockError: Error? = nil
        
        if (self.hasChanges) {
            self.performAndWait { [weak self] in
                guard let self = self else {
                    return
                }
                do {
                    try self.save()
                    
                    var parentContext = self.parent
                    while (parentContext != nil) {
                        parentContext?.performAndWait({
                            do {
                                try parentContext?.save()
                                
                                parentContext = parentContext?.parent
                            } catch {
                                blockError = error
                            }
                        })
                    }
                } catch {
                    blockError = error
                }
            }
        }
        
        if blockError != nil {
            throw blockError!
        }
    }
    
    func fetchEntityNamed(_ entityName: String, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) throws -> [NSManagedObject] {
        try self.fetchEntityNamed(entityName, predicate: predicate, sortDescriptors: sortDescriptors, limit: 0, offset: 0)
    }
    
    func fetchEntityNamed(_ entityName: String, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, limit: Int) throws -> [NSManagedObject] {
        try self.fetchEntityNamed(entityName, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit, offset: 0)
    }
    
    func fetchEntityNamed(_ entityName: String, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, limit: Int, offset: Int) throws -> [NSManagedObject] {
        let request = FetchRequest.fetchRequestForEntityName(entityName, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit, offset: offset)
        return try self.fetch(request)
    }
    
    func fetchEntityNamed(_ entityName: String, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, completion: @escaping JARCoreDataCompletionBlock) -> Void {
        self.fetchEntityNamed(entityName, predicate: predicate, sortDescriptors: sortDescriptors, limit: 0, offset: 0, completion: completion)
    }
    
    func fetchEntityNamed(_ entityName: String, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, limit: Int, completion: @escaping JARCoreDataCompletionBlock) -> Void {
        self.fetchEntityNamed(entityName, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit, offset: 0, completion: completion)
    }
    
    func fetchEntityNamed(_ entityName: String, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, limit: Int, offset: Int, completion: @escaping JARCoreDataCompletionBlock) -> Void {
        let request = FetchRequest.fetchRequestForEntityName(entityName, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit, offset: offset)
        let asyncRequest = NSAsynchronousFetchRequest(fetchRequest: request) { [weak self] result in
            self?.perform {
                completion(result.finalResult ?? [], nil)
            }
        }
        self.perform {
            do {
                try self.execute(asyncRequest)
            } catch {
                completion([], error)
            }
        }
    }
    
    func countForEntityNamed(_ entityName: String, predicate: NSPredicate?) throws -> Int {
        let request = FetchRequest.fetchRequestForEntityName(entityName, predicate: predicate, sortDescriptors: nil, limit: 0, offset: 0)
        request.resultType = .countResultType
        return try self.count(for: request)
    }
    
    func propertiesForEntityNamed(_ entityName: String, properties: [Any], predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) throws -> [NSManagedObject] {
        let request = FetchRequest.fetchRequestForEntityName(entityName, predicate: predicate, sortDescriptors: nil, limit: 0, offset: 0)
        request.also {
            $0.resultType = .dictionaryResultType
            $0.propertiesToFetch = properties
        }
        return try self.fetch(request)
    }
    
    func fetchWithOptions(_ options: [JARNSFetchRequestOptionsKey: Any]) throws -> [NSManagedObject] {
        let request = FetchRequest.fetchRequestWithOptions(options)
        return try self.fetch(request)
    }
}
