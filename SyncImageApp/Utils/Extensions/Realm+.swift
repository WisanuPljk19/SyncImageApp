//
//  RealmResult.swift
//  SyncImageApp
//
//  Created by Wisanu Paunglumjeak on 16/11/2564 BE.
//

import Foundation
import RealmSwift

extension Results {
    func toList<T>(of: T.Type) -> [T] {
        var list = [T]()
        self.forEach { realmCollectionValue in
            if let result = realmCollectionValue as? T {
                list.append(result)
            }
        }
        return list
    }
}
