//
//  roomCollectionViewCell.swift
//  bingweiApp
//
//  Created by Class on 2022/4/1.
//

import UIKit

class ColletionCell: UICollectionViewCell {
    //圖片
    @IBOutlet weak var image: UIImageView!
    //房間ID(int)
    @IBOutlet weak var Stream_id: UILabel!
    //匿名
    @IBOutlet weak var Name_id: UILabel!
    //標籤
    @IBOutlet weak var Personlbl: UILabel!
    
    override func awakeFromNib() {        super.awakeFromNib()
    }
}


