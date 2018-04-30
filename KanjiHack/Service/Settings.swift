//
//  Settings.swift
//  KanjiHack
//
//  Created by Anthony Marchenko on 4/30/18.
//  Copyright © 2018 Anthony Marchenko. All rights reserved.
//

import Foundation

let kUpdatedTimeKey = "updatedTimeKey"

class Settings {
    
    static let sharedManager = Settings()
    
    private init() {} // Prevent clients from creating another instance.
    
    func setUpdatedTime() {
        let defaults = UserDefaults.standard
        defaults.set(Date(), forKey: kUpdatedTimeKey)
    }
    
    func getUpdatedTime() -> Date? {
        let defaults = UserDefaults.standard
        return defaults.object(forKey: kUpdatedTimeKey) as! Date?
    }
    
    func resetUpdatedTime() {
        let defaults = UserDefaults.standard
        defaults.set(nil, forKey: kUpdatedTimeKey)
    }
}
