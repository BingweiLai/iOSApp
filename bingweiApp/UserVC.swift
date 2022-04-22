//
//  UserVC.swift
//  bingweiApp
//
//  Created by Class on 2022/4/8.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

class UserVC : UIViewController {
    @IBOutlet weak var userPhoto: UIImageView!
    //Logout按鈕
    @IBOutlet weak var logoutAction: UIButton!
    //標籤
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    var emailStr : String?
    let storage = Storage.storage().reference()
    //初始化載入
    override func viewDidLoad() {
        super.viewDidLoad()
        LoadPersonData()
        userPhoto.layer.cornerRadius = userPhoto.frame.width/2
    }
    override func viewWillAppear(_ animated: Bool) {
        downloadPhoto()
    }
    //載入使用者的檔案
    func LoadPersonData(){
        //先檢查當前是否有使用者登入
        if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser
            if let user = user {
                //取得email
                let email = user.email
                self.emailStr = String(email!)
                accountLabel.text = "帳號 ：\(self.emailStr!)"
                
                let reference = Firestore.firestore().collection("User")
                reference.document(emailStr!).getDocument { (snapshot ,error) in if let error = error{
                    print(error.localizedDescription)
                }else{
                    if let snapshot = snapshot{
                        //取值
                    let snapshotdata = snapshot.data()?["name"]
                        if let nameStr = snapshotdata as? String{
                        self.nameLabel.text = "暱稱：\(nameStr)"
                        }
                    }
                }
                }
            }
        } else {
            print("無使用者登入")
        }
        
    }
    func downloadPhoto(){
        let fileReference = storage.child("userphoto/").child("\(emailStr!).jpg")
        fileReference.getData(maxSize: .max){data, error in
            guard error == nil else{
                print("取得照片失敗")
                return
            }
            guard let data = data else {
                return
            }
            let getphoto = UIImage(data: data)
            self.userPhoto.image = getphoto
        }
    }
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
