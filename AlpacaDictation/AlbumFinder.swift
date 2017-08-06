//
//  AlbumFinder.swift
//  AlpacaDictation
//
//  Created by Masataka Hirano on 2017/08/06.
//  Copyright © 2017 Masataka Hirano. All rights reserved.
//

import Foundation
import Photos

class AlbumFinder {

    class func fetchDefault() -> PHAssetCollection? {
        return fetch(withTitle: "AlpacaDictation")
    }

    class func fetch(withTitle title: String) -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", title)
        let fetchResult: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        guard let collection = fetchResult.firstObject else {
            return nil
        }

        return collection
    }

}
