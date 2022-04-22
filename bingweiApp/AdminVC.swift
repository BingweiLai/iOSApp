//
//  AdminVC.swift
//  bingweiApp
//
//  Created by Class on 2022/3/30.
//
import FirebaseAuth
import Firebase
import FirebaseStorage
import UIKit
class AdminVC: UIViewController{
    
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var adminTxt: UITextField!
    @IBOutlet weak var pwdTxt: UITextField!
    @IBOutlet weak var btnAdmin: UIButton!
    @IBOutlet weak var headimage: UIImageView!
    var imgnumber : String?
    let storage = Storage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headimage.image = UIImage(named: "picPersonal")
        headimage.layer.cornerRadius = headimage.frame.width/2
    }
    //當點擊view任何喔一處鍵盤收起
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPhotoVC"{
            let vc = segue.destination as? PhotoVC
            vc?.delegate = self
        }
    }
    
    //註冊動作鈕
    @IBAction func btnSend(_ sender: Any) {
        //註冊
        if (adminTxt.text == "" || pwdTxt.text == "" || nameTxt.text == ""){
            //通知視窗
            let alert = UIAlertController(title: "註冊失敗", message:"請檢查輸入格式", preferredStyle: .alert)
            let ok = UIAlertAction(title: "ok", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            //密碼小於6位元不給過
        }else if pwdTxt.text!.count<6{
            //通知視窗
            let alert = UIAlertController(title: "註冊失敗", message:"請檢查密碼輸入格式", preferredStyle: .alert)
            let ok = UIAlertAction(title: "ok", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
        else{
            //帳號創建
            Auth.auth().createUser(withEmail:adminTxt.text!, password:pwdTxt.text! ){ [self]user, error in
                if error != nil{
                    //通知視窗
                    let alert = UIAlertController(title: "註冊失敗", message:"請檢查帳號輸入格式", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "ok", style: .default, handler: nil)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }else{
                    //-----暱稱處理-----
                    let reference = Firestore.firestore()
                    //取得對話的匿名名稱,帳號
                    if  let nickname = self.nameTxt.text,let account = self.adminTxt.text{
                        //PersonData字典建構
                        let PersonData = ["name" : nickname,"account" : account] as [String : Any]
                        reference.collection("User").document(account).setData(PersonData) { [self](error) in
                            if error != nil{
                                print(error!.localizedDescription)
                            }else{
                                
                                self.uploadPhoto(image: self.headimage.image!)
                                
                                print ("成功存取資訊!")
                                
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    }
                }
            }
            
        }
    }
    func uploadPhoto(image: UIImage) {
        let  fileReference = storage.child("userphoto").child("\(self.adminTxt.text!).jpg")
        if let data = image.jpegData(compressionQuality: 1) {
            
            fileReference.putData(data, metadata: nil){ matadata, error in guard error == nil else {
                print("上傳圖片發生錯誤")
                return
            }
            }
        }
    }
}

extension AdminVC: photoVCDelegate{
    func photoselected(photo: UIImage, imageindex: String) {
        headimage.image = photo
        imgnumber = imageindex
    }
}


