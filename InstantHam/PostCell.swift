//
//  PostCell.swift
//  InstantHam
//
//  Created by Emily Ou on 2/19/20.
//  Copyright © 2020 Emily Ou. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {

    @IBOutlet weak var topUsernameLabel: UILabel!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
