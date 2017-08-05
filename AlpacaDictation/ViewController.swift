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

class ViewController: UIViewController, UINavigationControllerDelegate {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var videoImageView: UIImageView!

    var phrase: Phrase?            // for persisted item
    var tmpVideoPHAsset: PHAsset?  // for new item not saved yet
    var tmpVideoAsset: AVURLAsset? // for new item not saved yet

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

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
            PHImageManager.default().requestPlayerItem(forVideo: phrase.getPHAsset(), options: nil, resultHandler: { (playerItem, hashable) in
                playVideo(playerItem!)
            })
        } else {
            let playerItem = AVPlayerItem(asset: tmpVideoAsset!)
            playVideo(playerItem)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        if presentingViewController is UINavigationController {
            dismiss(animated: true, completion: nil)
        } else if let owingNavigationController = navigationController {
            owingNavigationController.popViewController(animated: true)
        }
    }
}
