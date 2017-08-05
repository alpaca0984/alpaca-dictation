//
//  ViewController.swift
//  AlpacaDictation
//
//  Created by Masataka Hirano on 2017/07/31.
//  Copyright © 2017 Masataka Hirano. All rights reserved.
//

import UIKit
import Photos
import AVKit
import AVFoundation
import RealmSwift
import os.log

class ViewController: UIViewController, UINavigationControllerDelegate {
    // MARK: Properties
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!

    var phrase: Phrase?            // for persisted item
    var tmpVideoAsset: AVURLAsset? // for new item not saved yet

    override func viewDidLoad() {
        super.viewDidLoad()

        if let phrase = phrase {
            titleTextField.text = phrase.title
            phrase.setThumbnail(toImageView: videoImageView)
        } else {
            let imgGenerator = AVAssetImageGenerator(asset: tmpVideoAsset!)
            let cgImage = try! imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            videoImageView.image = UIImage(cgImage: cgImage)
        }

        // assign tap gesture to UIImageView
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(sender:)))
        videoImageView.isUserInteractionEnabled = true
        videoImageView.addGestureRecognizer(tapGestureRecognizer)

        // Enable the Save button only if the text field has a valid Phrase name.
        updateSaveButtonState()
    }

    func imageTapped(sender: UITapGestureRecognizer) {
        // activate play sound
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)

        // process for playing video
        let playVideo = { (_ playerItem: AVPlayerItem) in
            let player = AVPlayer(playerItem: playerItem)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }

        // play video
        if let phrase = phrase {
            if let asset = phrase.getPHAsset() {
                PHImageManager.default().requestPlayerItem(forVideo: asset, options: nil, resultHandler: { (playerItem, hashable) in
                    playVideo(playerItem!)
                })
            }
        } else {
            let playerItem = AVPlayerItem(asset: tmpVideoAsset!)
            playVideo(playerItem)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITextFieldDelegate

    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
//        saveButton.isEnabled = false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }

    // MARK: Navigation

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        if presentingViewController is UINavigationController {
            dismiss(animated: true, completion: nil)
        } else if let owingNavigationController = navigationController {
            owingNavigationController.popViewController(animated: true)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }

        // input values
        let title = titleTextField.text ?? ""

        if let phrase = phrase {
            // update Phrase properties
            let realm = phrase.realm!
            try! realm.write {
                phrase.title = title
            }
        } else {
            // fetch Album
            let albumTitle: String = "AlpacaDictation"
            let fetchOptions: PHFetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", albumTitle)
            let fetchResult: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            guard let collection = fetchResult.firstObject else {
                fatalError("MyAlbum was not found.")
            }

            // instantiate new Phrase that will be saved
            phrase = Phrase(value: ["title" : title])

            // save PHAsset and Phrase model
            PHPhotoLibrary.shared().performChanges({
                // save video
                let createAssetRequest: PHAssetChangeRequest? = .creationRequestForAssetFromVideo(atFileURL: self.tmpVideoAsset!.url)
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

                DispatchQueue.main.async {
                    self.phrase!.phAssetidentifier = latestVideoAsset.localIdentifier
                    // save Phrase
                    let realm = try! Realm()
                    try! realm.write {
                        realm.add(self.phrase!)
                    }
                }
            }))
        }
    }

    // MARK: Private Methods

    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
//        let text = titleTextField.text ?? ""
//        saveButton.isEnabled = !text.isEmpty
    }
}
