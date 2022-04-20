//
//  AdminVC.swift
//  bingweiApp
//
//  Created by Class on 2022/3/30.
//
import FirebaseAuth
import Firebase
import UIKit
class AdminVC: UIViewController{
    
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var adminTxt: UITextField!
    @IBOutlet weak var pwdTxt: UITextField!
    @IBOutlet weak var btnAdmin: UIButton!
    
    //註冊動作鈕
    @IBAction func btnSend(_ sender: Any) {
        //註冊
        if (adminTxt.text == "" || pwdTxt.text == "" || nameTxt.text == ""){
            //通知視窗
            let alert = UIAlertController(title: "註冊失敗", message:"請檢查輸入格式", preferredStyle: .alert)
            let ok = UIAlertAction(title: "ok", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
                        
        }else if pwdTxt.text!.count<6{
            //通知視窗
            let alert = UIAlertController(title: "註冊失敗", message:"請檢查密碼輸入格式", preferredStyle: .alert)
            let ok = UIAlertAction(title: "ok", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
        else{
            //帳號創建
            Auth.auth().createUser(withEmail:adminTxt.text!, password:pwdTxt.text! ){user, error in
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
                        reference.collection("User").document(account).setData(PersonData) {(error) in
                            if error != nil{
                                print(error!.localizedDescription)
                            }else{
                                print ("成功存取資訊!")
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    //當點擊view任何喔一處鍵盤收起
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillDisappear(_ animated: Bool) {
        dismiss(animated: true)
    }
    
}

