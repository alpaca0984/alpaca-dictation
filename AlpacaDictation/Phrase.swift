//
//  Phrase.swift
//  AlpacaDictation
//
//  Created by Masataka Hirano on 2017/08/03.
//  Copyright © 2017 Masataka Hirano. All rights reserved.
//

import Foundation
import RealmSwift
import Photos

class Phrase: Object {
    
    // MARK: Properties

    dynamic var title = ""
    dynamic var phAssetidentifier = ""
    dynamic var createdAt = Date()
    dynamic var updatedAt = Date()

    func getPHAsset() -> PHAsset? {
        let resultAssets: PHFetchResult<PHAsset> = PHAsset.fetchAssets(withLocalIdentifiers: [phAssetidentifier], options: nil)
        guard let asset = resultAssets.firstObject else {
            return nil
        }

        return asset
    }

    func setThumbnail(toImageView imageView: UIImageView) {
        if let asset = getPHAsset() {
            PHImageManager().requestImageData(for: asset, options: nil, resultHandler: { (data, string, orientation, hashable) in
                imageView.image = UIImage(data: data!)
            })
        }
    }

}
