//
//  RealmChangesetEnums.swift
//  SyncImageApp
//
//  Created by Wisanu Paunglumjeak on 17/11/2564 BE.
//

import Foundation
import RxRealm

enum RealmChangesetEnums {
    case initial
    case insert
    case delete
    case update
    
    static func getEnumsFrom(_ changeset: RealmChangeset?) -> RealmChangesetEnums{
        guard let changeset = changeset else {
            return .initial
        }
        if changeset.inserted.count > 0 {
            return .insert
        }else if changeset.updated.count > 0 {
            return .update
        }else if changeset.deleted.count > 0 {
            return .delete
        }
        fatalError("invalid changeset")
    }
}
