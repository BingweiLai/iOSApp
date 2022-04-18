//
//  SearchCell.swift
//  bingweiApp
//
//  Created by Class on 2022/4/15.
//

import UIKit

class SearchCell: UICollectionViewCell {
    @IBOutlet weak var Sreachphoto: UIImageView!
    @IBOutlet weak var Sreachstream: UILabel!
    @IBOutlet weak var Sreachname: UILabel!
    @IBOutlet weak var Sreachtask: UILabel!
    @IBOutlet weak var Title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        Sreachphoto.layer.cornerRadius = 8
        Sreachphoto.layer.masksToBounds = true
        Sreachstream.layer.cornerRadius = 8
        Sreachstream.layer.masksToBounds = true
        Sreachname.layer.cornerRadius = 8
        Sreachname.layer.masksToBounds = true
        Sreachtask.layer.cornerRadius = 10
        Sreachtask.layer.masksToBounds = true
        Title.layer.cornerRadius = 8
        Title.layer.masksToBounds = true
    }
}

