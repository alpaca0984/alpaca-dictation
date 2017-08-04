//
//  PhraseTableViewController.swift
//  AlpacaDictation
//
//  Created by Masataka Hirano on 2017/08/01.
//  Copyright © 2017 Masataka Hirano. All rights reserved.
//

import UIKit
import Photos
import RealmSwift

class PhraseTableViewController: UITableViewController {
    
//    var assets = [PHAsset]()
    var assets: Results<Phrase>?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem

        // search Album and set to property
//        assets = fetchPHAssets()
        assets = fetchPhrases()
    }
    
    private func fetchPHAssets() -> [PHAsset] {
        let albumTitle: String = "AlpacaDictation"
        let fetchOptions: PHFetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumTitle)
        let fetchResult: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        guard let collection: PHAssetCollection = fetchResult.firstObject else {
            fatalError("piyo")
        }
        let resultAssets: PHFetchResult<PHAsset> = PHAsset.fetchAssets(in: collection, options: nil)

        return resultAssets.objects(at: IndexSet(integersIn: 0..<resultAssets.count))
    }
    private func fetchPhrases() -> Results<Phrase> {
        let realm = try! Realm()

        return realm.objects(Phrase.self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assets!.count
    }

//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cellIdentifier = "PhraseTableViewCell"
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PhraseTableViewCell else {
//            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
//        }
//
//        let asset: PHAsset = assets[indexPath.row]
//        cell.titleLabel.text = asset.localIdentifier
//
//        PHImageManager().requestImageData(for: asset, options: nil, resultHandler: { (data, string, orientation, hashable) in
//            cell.photoImageView.image = UIImage(data: data!)
//        })
//
//        return cell
//    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let _assets: [PHAsset] = fetchPHAssets()
        _assets.forEach { asset in
            print(asset.localIdentifier)
        }
        
        let cellIdentifier = "PhraseTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PhraseTableViewCell else {
            fatalError("piyo")
        }
        guard let phrase = assets?[indexPath.row] else {
            return cell
        }
        cell.titleLabel.text = phrase.phAssetidentifier

        let resultAssets: PHFetchResult<PHAsset> = PHAsset.fetchAssets(withLocalIdentifiers: [phrase.phAssetidentifier], options: nil)
        guard let asset = resultAssets.firstObject else {
            return cell
        }
        
        PHImageManager().requestImageData(for: asset, options: nil, resultHandler: { (data, string, orientation, hashable) in
            cell.photoImageView.image = UIImage(data: data!)
        })
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            // Delete the row from the data source
//            let asset: PHAsset = self.assets[indexPath.row]
//            if asset.canPerform(PHAssetEditOperation.delete) {
//                PHPhotoLibrary.shared().performChanges({
//                    let assetsWillDelete: NSArray = [asset]
//                    PHAssetChangeRequest.deleteAssets(assetsWillDelete)
//                }, completionHandler: { (isSuccess, error) in
//                    if isSuccess {
//                        self.assets.remove(at: indexPath.row)
//                        tableView.deleteRows(at: [indexPath], with: .fade)
//                    } else {
//                        // TODO: implement someday
//                    }
//                })
//            } else {
//                // TODO: implement someday
//            }
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }
//    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
