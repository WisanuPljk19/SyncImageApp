//
//  String+Utils.swift
//  SyncImageApp
//
//  Created by Wisanu Paunglumjeak on 15/11/2564 BE.
//

import Foundation

extension String {
    var toUrl: URL? {
        return URL(string: self)
    }
}
