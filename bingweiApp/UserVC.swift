//
//  UserVC.swift
//  bingweiApp
//
//  Created by Class on 2022/4/8.
//

import UIKit
import Firebase
import FirebaseAuth

class UserVC : UIViewController {
    
    //Logout按鈕
    @IBOutlet weak var logoutAction: UIButton!
    //初始化載入
    override func viewDidLoad() {
        super.viewDidLoad()
        LoadPersonData()
    }
    //載入使用者的檔案
    func LoadPersonData(){
        //先檢查當前是否有使用者登入
        if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser
            if let user = user {
                //現在只要取得email
                let email = user.email
                //let uid = user.uid
                //let photoURL = user.photoURL
                let emailStr = String(email!)
                accountLabel.text = "帳號 ：\(emailStr)"
                
                let reference = Firestore.firestore().collection("User")
                reference.document(emailStr).getDocument { (snapshot ,error) in if let error = error{
                    print(error.localizedDescription)
                }else{
                    if let snapshot = snapshot{
                        //取值
                    let snapshotdata = snapshot.data()?["name"]
//                    self.nameLabel.text = "\(snapshotdata)"
                        if let nameStr = snapshotdata as? String{
//                            print("\(nameStr)")
                        self.nameLabel.text = "暱稱：\(nameStr)"
                        }
                    }
                }
                }
            }
        } else {
            // No user is signed in.
            // ...
        }
    }
    //標籤啦～～
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    //Logout按鈕動作
    @IBAction func logoutAction(_ sender: Any) {
        //登出功能
        if Auth.auth().currentUser != nil {
            do {
                //登出動作及跳轉
                try Auth.auth().signOut()
                if let controller = self.storyboard?.instantiateViewController(withIdentifier: "LoginView") as? LoginVC{
                    controller.modalPresentationStyle = .currentContext
                    self.navigationController?.viewControllers = [controller]
                }
                
            }catch let error as NSError{
                print(error.localizedDescription)
            }
        }
    }
}
