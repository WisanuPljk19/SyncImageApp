//
//  LimitsViewModel.swift
//  SyncImageApp
//
//  Created by Wisanu Paunglumjeak on 17/11/2564 BE.
//

import Foundation

class LimitsViewModel {
    
    let repository: Repository
    
    var limitData: LimitData
    
    init() {
        self.repository = Repository.shared
        self.limitData = repository.getLimitData()
    }
    
}
