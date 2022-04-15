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
    
    @IBAction func PhotoBtn(_ sender: Any) {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "AdminView") as? AdminVC
        {
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true, completion: nil)
        }
    }
}
