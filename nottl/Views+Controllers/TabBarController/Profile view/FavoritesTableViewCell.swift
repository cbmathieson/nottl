//
//  FavoritesTableViewCell.swift
//  nottl
//
//  Created by Craig Mathieson on 2019-03-01.
//  Copyright © 2019 Craig Mathieson. All rights reserved.
//

import UIKit

class FavoritesTableViewCell: UITableViewCell {
    
    //Outlets
    @IBOutlet weak var noteImage: UIImageView!
    @IBOutlet weak var favoritesCount: UILabel!
    @IBOutlet weak var noteDescription: UILabel!
    @IBOutlet weak var profileName: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
