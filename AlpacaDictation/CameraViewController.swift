//
//  CameraViewController.swift
//  AlpacaDictation
//
//  Created by Masataka Hirano on 2017/07/31.
//  Copyright © 2017 Masataka Hirano. All rights reserved.
//

import UIKit
import SwiftyCam
import Photos
import RealmSwift

class CameraViewController: SwiftyCamViewController, SwiftyCamViewControllerDelegate {

    @IBOutlet weak var captureButton: SwiftyCamButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        maximumVideoDuration = 10.0

        cameraDelegate = self

        captureButton.delegate = self
        view.addSubview(captureButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        print("写真が撮影されました")
    }

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
        print("ビデオが撮影されました")

        // search Album
        let albumTitle: String = "AlpacaDictation"
        let fetchOptions: PHFetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumTitle)
        let fetchResult: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        guard let collection = fetchResult.firstObject else {
            fatalError("MyAlbum was not found.")
        }

        PHPhotoLibrary.shared().performChanges({
            // save video
            let createAssetRequest: PHAssetChangeRequest? = .creationRequestForAssetFromVideo(atFileURL: url)
            let assetPlaceholder: PHObjectPlaceholder? = createAssetRequest?.placeholderForCreatedAsset!
            let albumChangeRequest: PHAssetCollectionChangeRequest? = PHAssetCollectionChangeRequest(for: collection)
            let enumeration: NSArray = [assetPlaceholder!]
            albumChangeRequest!.addAssets(enumeration)

        }, completionHandler: ({ (isSuccess, error) in
            // fetch latest video
            let fetchOptions: PHFetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            guard let latestVideoAsset = PHAsset.fetchAssets(with: .video, options: fetchOptions).firstObject else {
                fatalError("piyo")
            }

            // instantiate Phrase
            let phrase = Phrase()
            phrase.title = "piyopiyo"
            phrase.phAssetidentifier = latestVideoAsset.localIdentifier
            
            // save Phrase
            let realm = try! Realm()
            try! realm.write {
                realm.add(phrase)
            }
        }))

//        guard let nextViewController = storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController else {
//            fatalError("foo")
//        }
//        nextViewController.message = "bar"
//        navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }

}
