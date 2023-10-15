//
//  FetchRequest.swift
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

import CoreData
import Feige

public enum JARNSFetchRequestOptionsKey: String {
    case entityName = "JARNSFetchRequestOptionsKeyEntityName"
    case includesSubentities = "JARNSFetchRequestOptionsKeyIncludesSubentities"
    case predicate = "JARNSFetchRequestOptionsKeyPredicate"
    case fetchLimit = "JARNSFetchRequestOptionsKeyFetchLimit"
    case fetchOffset = "JARNSFetchRequestOptionsKeyFetchOffset";
    case fetchBatchSize = "JARNSFetchRequestOptionsKeyFetchBatchSize";
    case sortDescriptors = "JARNSFetchRequestOptionsKeySortDescriptors";
    case relationshipKeyPathsForPrefetching = "JARNSFetchRequestOptionsKeyRelationshipKeyPathsForPrefetching";
    case resultType = "JARNSFetchRequestOptionsKeyResultType";
    case includesPendingChanges = "JARNSFetchRequestOptionsKeyIncludesPendingChanges";
    case propertiesToFetch = "JARNSFetchRequestOptionsKeyPropertiesToFetch";
    case returnsDistinctResults = "JARNSFetchRequestOptionsKeyReturnsDistinctResults";
    case includesPropertyValues = "JARNSFetchRequestOptionsKeyIncludesPropertyValues";
    case shouldRefreshRefetchedObjects = "JARNSFetchRequestOptionsKeyShouldRefreshRefetchedObjects";
    case returnsObjectsAsFaults = "JARNSFetchRequestOptionsKeyReturnsObjectsAsFaults";
    case propertiesToGroupBy = "JARNSFetchRequestOptionsKeyPropertiesToGroupBy";
    case havingPredicate = "JARNSFetchRequestOptionsKeyHavingPredicate";
}

open class FetchRequest {
    static func fetchRequestForEntityName<ResultType: NSManagedObject>(_ entityName: String, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, limit: Int?, offset: Int?) -> NSFetchRequest<ResultType> {
        var options: [JARNSFetchRequestOptionsKey: Any] = [.entityName: entityName]
        
        predicate?.let({
            options[.predicate] = $0
        })
        sortDescriptors?.let({
            options[.sortDescriptors] = $0
        })
        limit?.let({
            options[.fetchLimit] = $0
        })
        offset?.let({
            options[.fetchOffset] = $0
        })
        
        return fetchRequestWithOptions(options)
    }
    
    static func fetchRequestWithOptions<ResultType: NSManagedObject>(_ options: Dictionary<JARNSFetchRequestOptionsKey, Any>) -> NSFetchRequest<ResultType> {
        guard let entityName = options[.entityName] as? String else {
            fatalError("must pass Entity Name with fetch request options")
        }
        
        let retval = NSFetchRequest<ResultType>(entityName: entityName)
        
        (options[.includesSubentities] as? Bool)?.let {
            retval.includesSubentities = $0
        }
        (options[.predicate] as? NSPredicate)?.let {
            retval.predicate = $0
        }
        (options[.fetchLimit] as? Int)?.let {
            retval.fetchLimit = $0
        }
        (options[.fetchOffset] as? Int)?.let {
            retval.fetchOffset = $0
        }
        (options[.fetchBatchSize] as? Int)?.let {
            retval.fetchBatchSize = $0
        }
        (options[.sortDescriptors] as? [NSSortDescriptor])?.let {
            retval.sortDescriptors = $0
        }
        (options[.relationshipKeyPathsForPrefetching] as? [String])?.let {
            retval.relationshipKeyPathsForPrefetching = $0
        }
        (options[.resultType] as? NSFetchRequestResultType)?.let {
            retval.resultType = $0
        }
        (options[.includesPendingChanges] as? Bool)?.let {
            retval.includesPendingChanges = $0
        }
        (options[.propertiesToFetch] as? [Any])?.let {
            retval.propertiesToFetch = $0
        }
        (options[.returnsDistinctResults] as? Bool)?.let {
            retval.returnsDistinctResults = $0
        }
        (options[.includesPropertyValues] as? Bool)?.let {
            retval.includesPropertyValues = $0
        }
        (options[.shouldRefreshRefetchedObjects] as? Bool)?.let {
            retval.shouldRefreshRefetchedObjects = $0
        }
        (options[.returnsObjectsAsFaults] as? Bool)?.let {
            retval.returnsObjectsAsFaults = $0
        }
        (options[.propertiesToGroupBy] as? [Any])?.let {
            retval.propertiesToGroupBy = $0
        }
        (options[.havingPredicate] as? NSPredicate)?.let {
            retval.havingPredicate = $0
        }
        
        return retval
    }
}

extension NSFetchRequestResultType: ScopeFunctions {}
