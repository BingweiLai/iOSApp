//
//  ViewController.swift
//  bingweiApp
//
//  Created by Class on 2022/3/30.
//

import UIKit
import FirebaseAuth
import Firebase

//  首頁VC
class HomeVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    //collectionview
    @IBOutlet weak var collectionview: UICollectionView!
    //連接WebSocket時的暱稱預設是訪客
    var keyname : String?
    //陣列清單
    var list  = [Item]()
    //初始化
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionview.dataSource = self
        collectionview.delegate = self
        //Json
        let searchresponse : SearchRespone = load("roomData")
        //取得Json解析
        list = searchresponse.result.stream_list
        DispatchQueue.main.async {
            //啟動collectionview
            self.collectionview.reloadData()
        }
    }
    //當畫面即將顯示
    override func viewWillAppear(_ animated: Bool) {
        //監聽使用者不為nil時
        if Auth.auth().currentUser != nil{
            let user = Auth.auth().currentUser
            if let user = user{
                //取得使用者信箱
                let email = user.email
                let reference = Firestore.firestore().collection("User")
                reference.document(email!).getDocument { (snapshot ,error) in if let error = error{
                    print("錯誤訊息:\(error.localizedDescription)")
                }else{
                    if let snapshot = snapshot{
                        //取值
                        let snapshotdata = snapshot.data()?["name"]
                        if let nameStr = snapshotdata as? String{
                            //取得暱稱之後給keyname
                            self.keyname = nameStr
                            print(nameStr)
                            print(self.keyname)
                            //重整collectionview
                            self.collectionview.reloadData()
                        }
                    }
                }
                }
            }
        }else{
            //沒有人登入時
            keyname = "訪客"
            self.collectionview.reloadData()
        }
    }
    //-----------------------------------------------------------------------
    //CollectView實作
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //顯示有幾格
        return self.list.count
    }
    //在這裡顯示cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let row = list[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        //顯示每個cell裡面物件的資訊
        cell.stream.text = String(row.streamer_id)
        cell.name.text = row.nickname
        cell.task.text = row.tags
        cell.headphoto.image = UIImage(named: "paopao")
        cell.Title.text = row.stream_title
        //要把url轉成images的處理
        DispatchQueue.global().async {
            do{
                //利用Data來產生下載內容
                let imageData = try Data(contentsOf: row.head_photo)
                let downLoadImage = UIImage(data: imageData)
                DispatchQueue.main.async {
                    cell.headphoto.image = downLoadImage
                }
            }catch{
                print("錯誤訊息：\(error.localizedDescription)")
            }
        }
        return cell;
    }    
    //CollectView排版設定設定
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let bounds = collectionView.bounds
        let hightVel = self.view.frame.height
        let widthVel = self.view.frame.width
        let cellsize = (hightVel < widthVel) ? bounds.height/2 : bounds.width/2
        return CGSize(width: cellsize - 10 , height: cellsize - 10 )
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    //collectionview事件點擊
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ChatRoom", sender: self)
      }
    //collectionview_header的設定
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
         let headView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerCollection", for: indexPath) as? HomeheaderCollectionReusableView
        headView?.userName.text = keyname
        print(headView?.userName.text)
        return headView!
        
    }
    //------------------------------------------------------------------------------------
    //以下為json
    //json解析函式
    func load <T: Decodable>(_ filename: String) -> T{
        let data: Data
        //            取得檔案的方式NSData或Bundle
        guard let file = Bundle.main.url(forResource: filename, withExtension: "json") else{
            fatalError("Couldnt load \(filename) in main bundle.")
        }
        do{
            //                取得檔案
            data = try Data(contentsOf: file)
        }catch{
            fatalError("Coundn't load \(file) from main bundle:\n\(error)")
        }
        do{
            //                執行解碼的部分
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from:data)
        }catch{
            fatalError("Couldn't parse \(filename) as \(T.self)\n\(error)")
        }
    }
}
