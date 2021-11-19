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
    
    func updateLimits(){
        _ = repository.updateLimitData(limitData: self.limitData)
    }
    
    func validateLimitData() -> (Bool, String?) {
        if limitData.jpeg < 0 || limitData.png < 0 || limitData.heic < 0 {
            //error less than zero
            return (false, "Each type must have a quantity of 0 or more.")
        } else if summaryLimits() < 100 {
            //error sum less than zero
            return (false, "All types combined must be greater than 100.")
        }
        
        return (true, nil)
    }
    
    func summaryLimits() -> Int{
        return limitData.jpeg + limitData.png + limitData.heic
    }
}
