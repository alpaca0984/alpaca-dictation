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
        let albumTitle = "AlpacaDictation"
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumTitle)
        let fetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let anAlbum = fetchResult.firstObject {
            PHPhotoLibrary.shared().performChanges({
                let createAssetRequest: PHAssetChangeRequest? = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                let albumChangeRequest: PHAssetCollectionChangeRequest? = PHAssetCollectionChangeRequest(for: anAlbum)

                let assetPlaceholder: PHObjectPlaceholder? = createAssetRequest?.placeholderForCreatedAsset!
                let enumeration: NSArray = [assetPlaceholder!]
                albumChangeRequest!.addAssets(enumeration)
            }, completionHandler: nil)
        } else {
            print("MyAlbum was not found.")
        }        

//        guard let nextViewController = storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController else {
//            fatalError("foo")
//        }
////        nextViewController.message = "bar"
//        navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }

}
