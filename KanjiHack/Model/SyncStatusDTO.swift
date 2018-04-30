//
//  SyncStatusDTO.swift
//  KanjiHack
//
//  Created by Anthony Marchenko on 4/30/18.
//  Copyright © 2018 Anthony Marchenko. All rights reserved.
//

import Foundation

struct SyncStatusDTO {
    var added: Int
    var updated: Int
    var deleted: Int
    var total: Int
    
    init(added: Int, updated: Int, deleted: Int, total: Int) {
        self.added = added
        self.updated = updated
        self.deleted = deleted
        self.total = total
    }
}
