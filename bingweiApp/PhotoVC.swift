//
//  PhotoVC.swift
//  bingweiApp
//
//  Created by Class on 2022/4/15.
//

import UIKit
class PhotoVC : UIViewController{
    
    @IBOutlet weak var PhotoDB: UIButton!
    @IBOutlet weak var Camera: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PhotoDB.layer.cornerRadius = 15
        Camera.layer.cornerRadius = 15
        
    }
    
    @IBAction func Camera(_ sender: Any) {
        let alert = UIAlertController(title: "功能尚未完成", message:"敬請期待", preferredStyle: .alert)
        let ok = UIAlertAction(title: "ok", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
        
    }
    @IBAction func PhotoBtn(_ sender: Any) {
        let alert = UIAlertController(title: "功能尚未完成", message:"敬請期待", preferredStyle: .alert)
        let ok = UIAlertAction(title: "ok", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
}
