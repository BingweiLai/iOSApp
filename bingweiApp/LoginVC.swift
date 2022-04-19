//
//  LoginVC.swift
//  bingweiApp
//
//  Created by Class on 2022/3/30.
//

import UIKit
import Firebase
class LoginVC : UIViewController,UITextFieldDelegate{
    @IBOutlet weak var adminTxt: UITextField!
    @IBOutlet weak var pwdTxt: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    var handle : AuthStateDidChangeListenerHandle?
    //  btnLogin事件
    @IBAction func btnLogin(_ sender: Any) {
        
        Auth.auth().signIn(withEmail: adminTxt.text!, password: pwdTxt.text!){(user, error)in if error != nil{
            print(error!)
            //          如果登入畫面失敗跳出視窗
            let alert = UIAlertController(title: "登入失敗", message:"帳號或密碼錯誤", preferredStyle: .alert)
            let ok = UIAlertAction(title: "ok", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }else{
            //跳轉個人頁面
            self.tabBarController?.selectedIndex = 0
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "UserView") as? UserVC{
                controller.modalPresentationStyle = .currentContext
                self.navigationController?.viewControllers = [controller]
            }
        }
        }
    }
    //當點擊view任何喔一處鍵盤收起
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    //監聽
    func checkuser(){
        if Auth.auth().currentUser != nil {
            print("使用者登入")
        } else {
            print("使用者登出")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        checkuser()
        btnLogin.layer.cornerRadius = 15
    }
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener({ auth, user in
            guard user != nil else{
                print("沒登入")
                return
            }
            print("有登入")
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "UserView") as? UserVC{
                controller.modalPresentationStyle = .currentContext
                self.navigationController?.viewControllers = [controller]
            }
        })
    }
    override func viewDidDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
}
