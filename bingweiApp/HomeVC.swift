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
    
    var keyname : String?
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    var list  = [Item]()//陣列清單
    //  初始化執行
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionview.dataSource = self
        collectionview.delegate = self
        //Json
        let searchresponse : SearchRespone = load("roomData")//呼叫解析
        list = searchresponse.result.stream_list//取得解析
        DispatchQueue.main.async {
            self.collectionview.reloadData()//啟動collectionview
        }
    }
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
                            print(nameStr)
                            print(self.keyname)
                            self.collectionview.reloadData()
                        }
                    }
                }
                }
            }
        }else{
            keyname = "訪客"
            self.collectionview.reloadData()
        }
    }
    //監聽使用者
    func checkuser(){
        if Auth.auth().currentUser != nil {
            print("使用者登入")
        } else {
            print("使用者登出")
        }
    }
    //-----------------------------------------------------------------------
    //CollectView實作
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.list.count
    }
    //在這裡顯示cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let row = list[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
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
                print(error.localizedDescription)
            }
        }
        return cell;
    }    
    //CollectView設定
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
//        print("item at \(indexPath.section)/\(indexPath.item) tapped")
        self.performSegue(withIdentifier: "ChatRoom", sender: self)
      }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
         let headView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerCollection", for: indexPath) as? HomeheaderCollectionReusableView
        headView?.userName.text = keyname
        print(headView?.userName.text)
        print("進入header")
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
