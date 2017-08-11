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

    // MARK: Properties

    @IBOutlet var captureButtons: [SwiftyCamButton]!

    override func viewDidLoad() {
        super.viewDidLoad()

        maximumVideoDuration = 10.0

        cameraDelegate = self

        captureButtons.forEach { (captureButton) in
            captureButton.delegate = self
            view.addSubview(captureButton)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Delegate for SwiftyCamViewController

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        print("took a photo")
    }

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
        print("rocorded a video")

        // next destination
        guard let nextViewController = storyboard?.instantiateViewController(withIdentifier: "PhraseViewController") as? PhraseViewController else {
            fatalError("foo")
        }
        nextViewController.tmpVideoAsset = AVURLAsset(url: url)

        // move to next destination
        navigationController?.pushViewController(nextViewController, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
