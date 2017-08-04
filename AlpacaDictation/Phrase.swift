//
//  Phrase.swift
//  AlpacaDictation
//
//  Created by Masataka Hirano on 2017/08/03.
//  Copyright © 2017 Masataka Hirano. All rights reserved.
//

import Foundation
import RealmSwift

class Phrase: Object {
    dynamic var title = ""
    dynamic var phAssetidentifier = ""
    dynamic var videoUrl = ""
    dynamic var createdAt = Date()
    dynamic var updatedAt = Date()
}
