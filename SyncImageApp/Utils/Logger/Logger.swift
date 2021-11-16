//
//  Logger.swift
//  SyncImageApp
//
//  Created by Wisanu Paunglumjeak on 15/11/2564 BE.
//

import Foundation
import SwiftyBeaver

public var Log: SwiftyBeaver.Type = {
    var logger = SwiftyBeaver.self
    let console = ConsoleDestination()
    console.format = "$DHH:mm:ss.SSS$d $C$L$c $N.$F:$l - $M"
    logger.addDestination(console)
    return logger
}()
