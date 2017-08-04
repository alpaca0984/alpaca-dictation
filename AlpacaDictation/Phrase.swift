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
    dynamic var title = ""
    dynamic var phAssetidentifier = ""
    dynamic var videoUrl = ""
    dynamic var createdAt = Date()
    dynamic var updatedAt = Date()

    func getPHAsset() -> PHAsset {
        let resultAssets: PHFetchResult<PHAsset> = PHAsset.fetchAssets(withLocalIdentifiers: [phAssetidentifier], options: nil)
        guard let asset = resultAssets.firstObject else {
            fatalError("piyo")
        }

        return asset
    }

    func setThumbnail(imageView: UIImageView) {
        PHImageManager().requestImageData(for: getPHAsset(), options: nil, resultHandler: { (data, string, orientation, hashable) in
            imageView.image = UIImage(data: data!)
        })
    }
}
