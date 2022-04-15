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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    var list  = [Item]()//陣列清單
    //  初始化執行
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionview.dataSource = self
        collectionview.delegate = self
        
        let searchresponse : SearchRespone = load("roomData")//呼叫解析
        list = searchresponse.result.stream_list//拿到了～～
        //print(list[0].head_photo)
        
        configureCellSize()//呼叫Cell的Size方法
        
        DispatchQueue.main.async {
            self.collectionview.reloadData()//啟動collectionview
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
    //CollectView的排版設定
    func configureCellSize(){
        let layout = collectionview.collectionViewLayout as? UICollectionViewFlowLayout
        
        layout?.estimatedItemSize = .zero
        layout?.minimumLineSpacing = 0
        
        let width = collectionview.bounds.width/2-30
        layout?.itemSize = CGSize(width: width, height: width)
    }
    //collectionview事件點擊
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print("item at \(indexPath.section)/\(indexPath.item) tapped")
        self.performSegue(withIdentifier: "ChatRoom", sender: self)
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
