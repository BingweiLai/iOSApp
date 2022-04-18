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
    var textArray = [String]()//顯示訊息陣列
    var UsernameToChat = [String]()//使用者名稱陣列
    var webSocketTask : URLSessionWebSocketTask?
    var keyname = "訪客"
    var path : String?
    var play : AVPlayer?
    //在進入直播間之前先確定是否有帳號登入
    override func viewWillAppear(_ animated: Bool) {
        if Auth.auth() != nil{
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
                        //self.nameLabel.text = "\(snapshotdata)"
                        if let nameStr = snapshotdata as? String{
                            //print("\(nameStr)")
                            self.keyname = nameStr
                        }
                    }
                }
                }
            }
        }
    }
    //初始化處理
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableview.delegate = self不實做這一項的話,要用拉的！！！！！
        tableview.backgroundColor = UIColor.clear
        //WS連線
        guard let url = URL(string: "wss://lott-dev.lottcube.asia/ws/chat/chat:app_test?nickname=\(keyname)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else {
            print("can not create url!")
            return
        }
        let seesion = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocketTask = seesion.webSocketTask(with: url)
        webSocketTask!.resume()
    }
    //影片播放----------------------------------------------------------------
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playVideo()
    }
    //取得本機影片
    func playVideo() {
        
        path = Bundle.main.path(forResource: "hime3", ofType:"mp4")
        guard path != nil
        else {
            debugPrint("hime3.mp4 not found")
            return
        }
        //player是影片本身
        play = AVPlayer(url: URL(fileURLWithPath: path!))
        //影片處理階段
        let playerLayer = AVPlayerLayer(player: play)//用AVplayerLayer實現
        playerLayer.frame = self.view.bounds
        playerLayer.videoGravity = .resizeAspectFill//全螢幕顯示
        self.view.layer.insertSublayer(playerLayer, at: 0)
        play!.play()

    }
    //webcsocket-----------------------------------------------------------
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
        if textInput.text == " "{
            textInput.text = nil
            return
        }else{
            WsSend()
        }
        textInput.text = nil
    }
    //Alert按鈕-------------------------------------------------------------------------------------
    @IBAction func BackHomeBtn(_ sender: Any) {
        let controller = UIAlertController(title: "BreakHeart", message: "確定離開此聊天室？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "立馬走", style: .default) { _ in
            self.webSocketTask?.cancel(with: .goingAway, reason: nil)
            self.play?.pause()
            self.dismiss(animated: true)
            self.performSegue(withIdentifier: "BackHome", sender: self)
        }
        controller.addAction(okAction)
        let cancelAction = UIAlertAction(title: "先不要", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)}
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
    //當點擊view任何一處鍵盤收起
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
