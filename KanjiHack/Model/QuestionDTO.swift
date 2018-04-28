//
//  Questions.swift
//  KanjiHack
//
//  Created by Anthony Marchenko on 4/28/18.
//  Copyright © 2018 Anthony Marchenko. All rights reserved.
//

import Foundation

struct QuestionDTO: Codable {
    var hint1: String
    var hint2: String
    var value: String
    
    init(hint1: String, hint2: String, value: String) {
        self.hint1 = hint1
        self.hint2 = hint2
        self.value = value
    }
}
