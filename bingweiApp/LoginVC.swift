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
    //監聽
    var handle : AuthStateDidChangeListenerHandle?
    //登入按鈕事件
    @IBAction func btnLogin(_ sender: Any) {
        Auth.auth().signIn(withEmail: adminTxt.text!, password: pwdTxt.text!){(user, error)in if error != nil{
            print(error!)
            //如果登入畫面失敗跳出Alert視窗
            let alert = UIAlertController(title: "登入失敗", message:"帳號或密碼錯誤", preferredStyle: .alert)
            let ok = UIAlertAction(title: "ok", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            
        }else{
            
            //登入成功後跳轉首頁並將登入頁面改成個人頁面
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
    //初始化
    override func viewDidLoad() {
        super.viewDidLoad()
        //將按鈕做圓角化處理
        btnLogin.layer.cornerRadius = 15
    }
    //畫面即將呈現時
    override func viewWillAppear(_ animated: Bool) {
        //監聽是否有使用者帳號登入
        handle = Auth.auth().addStateDidChangeListener{ auth, user in
            //如果使用者不為nil則跳轉頁面
            if user != nil {
                if let controller = self.storyboard?.instantiateViewController(withIdentifier: "UserView") as? UserVC{
                    controller.modalPresentationStyle = .currentContext
                    self.navigationController?.viewControllers = [controller]
                }
            }else{
                //沒有使用者登入
                print("not find any user")
            }
            
        }
    }
    //畫面關閉的時候
    override func viewDidDisappear(_ animated: Bool) {
        //移除監聽
        Auth.auth().removeStateDidChangeListener(handle!)
    }
}
