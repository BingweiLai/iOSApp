//
//  CollectionViewCell.swift
//  bingweiApp
//
//  Created by Class on 2022/4/7.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    //這裡是首頁(home)的物件
    @IBOutlet weak var headphoto: UIImageView!
    @IBOutlet weak var stream: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var task: UILabel!
    //這邊是收尋(sreach)頁面的物件
    
    override func awakeFromNib() {
        super.awakeFromNib()
        stream.layer.cornerRadius = 8
        stream.layer.masksToBounds = true
        task.layer.cornerRadius = 8
        task.layer.masksToBounds = true
        name.layer.cornerRadius = 8
        name.layer.masksToBounds = true
        headphoto.layer.cornerRadius = 10
        headphoto.layer.masksToBounds = true
    }
}
