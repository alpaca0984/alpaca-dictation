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

    @IBOutlet weak var captureButton: SwiftyCamButton!

    var captureButtonDefault: SwiftyCamButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        maximumVideoDuration = 10.0

        cameraDelegate = self

        captureButton.delegate = self
        captureButtonDefault = captureButton.copy() as! SwiftyCamButton
        view.addSubview(captureButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Notifies the container that the size of its view is about to change.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            let point = captureButton.frame.origin
            captureButton.frame.origin = CGPoint(x: point.y, y: point.x)
        } else {
            captureButton.frame.origin = captureButtonDefault.frame.origin
        }
    }

    // MARK: Delegate for SwiftyCamViewController

    /**
     Called when SwiftyCamViewController begins recording video.

     - Parameter swiftyCam: Current SwiftyCamViewController session
     - Parameter camera: Current camera orientation
     */
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        captureButton.backgroundColor = UIColor.red
    }

    /**
     Called when SwiftyCamViewController finishes recording video.

     - Parameter swiftyCam: Current SwiftyCamViewController session
     - Parameter camera: Current camera orientation
     */
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
        captureButton.backgroundColor = captureButtonDefault.backgroundColor

        // Next destination
        guard let nextViewController = storyboard?.instantiateViewController(withIdentifier: "PhraseViewController") as? PhraseViewController else {
            fatalError("foo")
        }
        nextViewController.tmpVideoAsset = AVURLAsset(url: url)

        // Move to next destination
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

extension SwiftyCamButton: NSCopying {

    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = SwiftyCamButton(frame: self.frame)
        copy.backgroundColor = self.backgroundColor

        return copy
    }

}
