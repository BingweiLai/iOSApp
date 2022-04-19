//
//  RoomVC.swift
//  bingweiApp
//
//  Created by Class on 2022/4/12.
//

import UIKit
import AVKit
import AVFoundation
import Firebase
import FirebaseAuth

class RoomVC : UIViewController, URLSessionWebSocketDelegate {
    @IBOutlet weak var textInput: UITextField!//輸入文字的方塊
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var leaveBtn: UIButton!
    @IBOutlet weak var chatView: UIView!
    
    @IBOutlet weak var viewButton: NSLayoutConstraint!
    
    var textArray = [String]()//顯示訊息陣列
    var UsernameToChat = [String]()//使用者名稱陣列
    var webSocketTask : URLSessionWebSocketTask?
    var keyname = "訪客"
    var MyVideo : AVPlayer?
    var looper: AVPlayerLooper?

    //在進入直播間之前先確定是否有帳號登入
    override func viewWillAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil{
            let user = Auth.auth().currentUser
            if let user = user{
                let email = user.email
                let reference = Firestore.firestore().collection("User")
                reference.document(email!).getDocument { (snapshot ,error) in if let error = error{
                    print(error.localizedDescription)
                }else{
                    if let snapshot = snapshot{
                        //取值
                        let snapshotdata = snapshot.data()?["name"]
                        if let nameStr = snapshotdata as? String{
                            self.keyname = nameStr
                            self.Wscontent()
                        }
                    }
                }
                }
            }
        }else{
            Wscontent()
        }
    }
    //初始化處理
    override func viewDidLoad() {
        super.viewDidLoad()
        //影片重複播放func
        repeatVideo()
        //將UI元件向上移動
        view.bringSubviewToFront(textInput)
        view.bringSubviewToFront(tableview)
        view.bringSubviewToFront(sendBtn)
        view.bringSubviewToFront(leaveBtn)
        view.bringSubviewToFront(chatView)
        //按鈕外觀設計
        sendBtn.layer.cornerRadius = 10
        sendBtn.layer.masksToBounds = true
        leaveBtn.layer.cornerRadius = 10
        leaveBtn.layer.masksToBounds = true
        //keyboard事件監聽與上抬
        addKeyboardObserver()
        //背景透明
        chatView.backgroundColor = UIColor.clear
        tableview.backgroundColor = UIColor.clear
            }
    //影片播放----------------------------------------------------------------
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    //影片循環
    func repeatVideo(){
        let url = Bundle.main.url(forResource: "hime3", withExtension: ".mp4")
        let play = AVQueuePlayer()
        MyVideo = play
        let item = AVPlayerItem(url: url!)
        let playlayer = AVPlayerLayer(player: play)
        playlayer.frame = view.bounds
        playlayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(playlayer)
        looper = AVPlayerLooper(player: play, templateItem: item)
        self.MyVideo?.play()
        
    }
    //webcsocket-----------------------------------------------------------
    func Wscontent(){
        //WS連線
        guard let url = URL(string: "wss://lott-dev.lottcube.asia/ws/chat/chat:app_test?nickname=\(keyname)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else {
            print("can not create url!")
            return
        }
        let seesion = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocketTask = seesion.webSocketTask(with: url)
        webSocketTask!.resume()
    }
    func WsSend(){//發送func
        let WSsendText = textInput.text!
        //按照傳輸的格式才能傳出去
        let message = URLSessionWebSocketTask.Message.string("{\"action\": \"N\",\"content\": \"\(WSsendText)\"}")
        //發送
        webSocketTask?.send(message){ error in if let error = error {
            print(error)
        }
        }
    }
    func WsReceive(){//接收func
        webSocketTask?.receive{ result in
            switch result{
            case .failure(let error):
                print("Error in receiving message: \(error)")
            case .success(let message):
                switch message{
                case .string(let text):
                    //print("Received string: \(text)")
                    let data = text.data(using: .utf8)
                    do {
                        let test = try JSONDecoder().decode(WsRespone.self, from: data!)
                        //print(test.sender_role!)
                        switch test.sender_role!{
                        case -1:
                            //發話內容
                            self.textArray.append(test.body!.text!)
                            self.UsernameToChat.append(test.body!.nickname!)
                        case 5:
                            //系統訊息
                            self.textArray.append(test.body!.content!.tw!)
                            self.UsernameToChat.append("System")
                        case 0:
                            //訪客登入
                            self.UsernameToChat.append(test.body!.entry_notice!.username!)
                            switch test.body!.entry_notice!.action!{
                            case "enter":
                                self.textArray.append("進入")
                            case "leave":
                                self.textArray.append("離開")
                            default:
                                print("錯誤")
                            }
                        default:
                            print("無法辨識的用戶,錯誤處理")
                        }
                    } catch {
                        print("json error")
                    }
                    
                default:
                    print("錯誤1")
                }
            }
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
            self.WsReceive()
        }
    }
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        WsReceive()
    }
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("close!!")
    }
    //聊天室實作-------------------------------------------------------------------------------
    //發送訊息Button
    @IBAction func updateText(_ sender: Any) {
        guard let myOldText = textInput.text else {
            return
        }
        
        let myMewText = myOldText.trimmingCharacters(in: CharacterSet.whitespaces)
        
        if myMewText.count == 0{
            let alert = UIAlertController(title: "請輸入文字", message:"不能是空白或者無文字", preferredStyle: .alert)
            let ok = UIAlertAction(title: "ok", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            textInput.text = nil
        }else{
            WsSend()
            textInput.text = nil
        }
        
    }
    //Alert按鈕-------------------------------------------------------------------------------------
    @IBAction func BackHomeBtn(_ sender: Any) {
        let controller = UIAlertController(title: "", message: "確定離開此聊天室？", preferredStyle: .alert)
        //將照片加入Alert視窗裡面
        let imageView =  UIImageView(frame: CGRect(x: 60, y: 50, width: 150, height: 130))
        imageView.image = UIImage(named: "brokenHeart")
        controller.view.addSubview(imageView)
        let height = NSLayoutConstraint(item: controller.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 240)
        let width = NSLayoutConstraint(item: controller.view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200)
        controller.view.addConstraint(height)
        controller.view.addConstraint(width)
        
        
        let okAction = UIAlertAction(title: "立馬走", style: .default) { _ in
            self.webSocketTask?.cancel(with: .goingAway, reason: nil)
            self.MyVideo?.pause()
            self.dismiss(animated: true)
            self.performSegue(withIdentifier: "BackHome", sender: self)
        }
        controller.addAction(okAction)
        let cancelAction = UIAlertAction(title: "先不要", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)}
}
//鍵盤聊天室向上彈跳
extension RoomVC {
    func addKeyboardObserver() {
        //因為selector寫法只要指定方法名稱即可，參數則是已經定義好的NSNotification物件，所以不指定參數的寫法「#selector(keyboardWillShow)」也可以
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func keyboardWillShow(notification: Notification) {
        // 能取得鍵盤高度就讓view上移鍵盤高度，否則上移view的1/3高度
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRect = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRect.height
            //view.frame.origin.y = -keyboardHeight
            viewButton.constant = -315
        }
        /*else {
            view.frame.origin.y = -view.frame.height / 3
        }*/
    }
    @objc func keyboardWillHide(notification: Notification) {
        // 讓view回復原位
        viewButton.constant = 15
    }
    // 當畫面消失時取消監控鍵盤開闔狀態
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

extension RoomVC : UITableViewDelegate, UITableViewDataSource {
    //顯示cell有幾列
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return textArray.count
    }
    //tableviewcell的位置排序
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath) as! TableViewCell
        
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)//對整個tableview翻轉
        cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)//對cell進行翻轉處理
        cell.backgroundColor = UIColor.clear//Cell背景透明
        //對調index上下順序由下至上
        let index = textArray.count - 1 - indexPath.row
        cell.MessageText.text = "\(UsernameToChat[index]) : \(textArray[index])"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
    }
    //當點擊view任何一處鍵盤收起
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
