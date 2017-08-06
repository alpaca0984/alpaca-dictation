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
            // Set parameters and options for requesting thumbnail.
            let frameSize = imageView.frame.size
            let options = PHImageRequestOptions()
            options.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
            options.isSynchronous = true

            PHImageManager().requestImage(for: asset, targetSize: frameSize, contentMode: PHImageContentMode.aspectFit, options: options, resultHandler: { (result, info) in
                imageView.image = result
            })
        }
    }

}
