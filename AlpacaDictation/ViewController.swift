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

class ViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate {

    // MARK: Properties

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!

    var phrase: Phrase!            // for persisted item
    var tmpVideoAsset: AVURLAsset! // for new item not saved yet

    override func viewDidLoad() {
        super.viewDidLoad()

        titleTextField.delegate = self

        if phrase != nil {
            titleTextField.text = phrase.title
            phrase.setThumbnail(toImageView: videoImageView)
        } else {
            let imageGenerator = AVAssetImageGenerator(asset: tmpVideoAsset)
            imageGenerator.appliesPreferredTrackTransform = true
            let cgImage = try! imageGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            videoImageView.image = UIImage(cgImage: cgImage)
        }

        // Assign tap gesture to UIImageView.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(sender:)))
        videoImageView.addGestureRecognizer(tapGestureRecognizer)

        // Enable the Save button only if the text field has a valid Phrase name.
        updateSaveButtonState()
    }

    func imageTapped(sender: UITapGestureRecognizer) {
        // Activate background sound.
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)

        // Play video.
        if phrase != nil, let asset = phrase.getPHAsset() {
            PHImageManager.default().requestPlayerItem(forVideo: asset, options: nil, resultHandler: { (result, info) in
                self.playVideo(playerItem: result!)
            })
        } else {
            let playerItem = AVPlayerItem(asset: tmpVideoAsset)
            playVideo(playerItem: playerItem)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UITextFieldDelegate

    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
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

        // Get input values.
        let title = titleTextField.text ?? ""

        if phrase != nil {
            // Update Phrase properties.
            let realm = phrase.realm!
            try! realm.write {
                phrase.title = title
            }
        } else {
            // Fetch Album.
            guard let collection = AlbumFinder.fetchDefault() else {
                fatalError("Album not found.")
            }

            // Instantiate new Phrase that will be saved.
            phrase = Phrase(value: ["title" : title])

            // Save PHAsset and Phrase model.
            // TODO: Use `performChanges` instead. `~AndWait` should not be used in main thread.
            try! PHPhotoLibrary.shared().performChangesAndWait({
                // Save video.
                let createAssetRequest: PHAssetChangeRequest? = .creationRequestForAssetFromVideo(atFileURL: self.tmpVideoAsset.url)
                let assetPlaceholder: PHObjectPlaceholder? = createAssetRequest?.placeholderForCreatedAsset!
                let albumChangeRequest: PHAssetCollectionChangeRequest? = PHAssetCollectionChangeRequest(for: collection)
                let enumeration: NSArray = [assetPlaceholder!]
                albumChangeRequest!.addAssets(enumeration)
            })

            // Fetch latest video.
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            guard let latestVideoAsset = PHAsset.fetchAssets(with: .video, options: fetchOptions).firstObject else {
                fatalError("piyo")
            }
            self.phrase.phAssetidentifier = latestVideoAsset.localIdentifier

            // Save Phrase.
            let realm = try! Realm()
            try! realm.write {
                realm.add(self.phrase)
            }
        }
    }

    // MARK: Private Methods

    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = titleTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }

    private func playVideo(playerItem: AVPlayerItem) {
        let player = AVPlayer(playerItem: playerItem)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }

}
