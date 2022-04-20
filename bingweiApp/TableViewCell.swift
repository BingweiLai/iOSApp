//
//  TableViewCell.swift
//  bingweiApp
//
//  Created by Class on 2022/4/12.
//

import UIKit

class TableViewCell: UITableViewCell {
    //訊息列
    @IBOutlet weak var MessageText: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        MessageText.layer.cornerRadius = 15
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
