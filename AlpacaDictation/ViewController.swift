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
    
    var phrase: Phrase?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        titleTextField.text = phrase!.title
        phrase!.setThumbnail(imageView: videoImageView)

        // assign tap gesture to UIImageView
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(sender:)))
        videoImageView.isUserInteractionEnabled = true
        videoImageView.addGestureRecognizer(tapGestureRecognizer)
    }

    func imageTapped(sender: UITapGestureRecognizer) {
        // activate play sound
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)

        // play video
        let imageManager: PHImageManager = .default()
        imageManager.requestPlayerItem(forVideo: phrase!.getPHAsset(), options: nil, resultHandler: { (playerItem, hashable) in
            let player = AVPlayer(playerItem: playerItem)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        })
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
