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

    // MARK: Properties

    var phrases: Array<Phrase>!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem

        // search Album and set to property
        phrases = fetchPhrases()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return phrases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "PhraseTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PhraseTableViewCell else {
            fatalError("piyo")
        }
        let phrase = phrases[indexPath.row]

        // set properties to TableCell
        cell.titleLabel.text = phrase.title
        phrase.setThumbnail(toImageView: cell.photoImageView)

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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source

            let phrase = phrases[indexPath.row]

            // delete PHAsset
            if let asset = phrase.getPHAsset(), asset.canPerform(PHAssetEditOperation.delete) {
                PHPhotoLibrary.shared().performChanges({
                    let assetsWillDelete: NSArray = [asset]
                    PHAssetChangeRequest.deleteAssets(assetsWillDelete)
                }, completionHandler: { (isSuccess, error) in
                    if (!isSuccess) {
                        print(error!)
                    }
                })
            }

            // delete Phrase object
            let realm = phrase.realm!
            try! realm.write {
                realm.delete(phrase)
            }

            // delete from view
            phrases.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)

        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

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

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch segue.identifier ?? "" {
        case "ShowDetail":
            guard let viewController = segue.destination as? ViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let selectedPhraseCell = sender as? PhraseTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            guard let indexPath = tableView.indexPath(for: selectedPhraseCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            // Pass the selected object to the new view controller.
            viewController.phrase = phrases[indexPath.row]
        case "StartVideoRecording":
            break
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }

    // MARK: Private Methods

    private func fetchPhrases() -> Array<Phrase> {
        let realm = try! Realm()
        let phrases = Array(realm.objects(Phrase.self))

        return phrases
    }

    // MARK: Actions

    @IBAction func unwindToPhraseList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? ViewController, let phrase = sourceViewController.phrase {
            if let selectdIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing phrase.
                phrases[selectdIndexPath.row] = phrase
                tableView.reloadRows(at: [selectdIndexPath], with: .none)
            } else {
                // Add a new phrase.
                let newIndexPath = IndexPath(row: phrases.count, section: 0)
                phrases.append(phrase)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
    }

}
