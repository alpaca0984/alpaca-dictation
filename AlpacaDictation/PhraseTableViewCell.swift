//
//  PhraseTableViewCell.swift
//  AlpacaDictation
//
//  Created by Masataka Hirano on 2017/08/01.
//  Copyright © 2017 Masataka Hirano. All rights reserved.
//

import UIKit

class PhraseTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
