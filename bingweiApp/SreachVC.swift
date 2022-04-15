//
//  ViewController.swift
//  bingweiApp
//
//  Created by Class on 2022/3/30.
//

import UIKit
//import AVFoundation實作影片關鍵字
//text Dechange實作searchbar

//  首頁VC
class SreachVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    @IBOutlet weak var collectionview: UICollectionView!
    
        override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    var list  = [Item]()//陣列清單
    var searchlist = [Item]()
    
    //  初始化執行
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionview.dataSource = self
        collectionview.delegate = self
        
        let searchresponse : SearchRespone = load("roomData")//呼叫解析
        self.list = searchresponse.result.stream_list//拿到了～～
        //        print(list[0].head_photo)
        searchlist = self.list
        configureCellSize()//呼叫Cell的Size方法
        
        
        
        DispatchQueue.main.async {
            self.collectionview.reloadData()//啟動collectionview
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Searchcell", for: indexPath) as! SearchCell
        
        cell.Sreachstream.text = String(row.streamer_id)
        cell.Sreachname.text = row.nickname
        cell.Sreachtask.text = row.tags
        cell.Sreachphoto.image = UIImage(named: "paopao")
        //要把url轉成images的處理
        DispatchQueue.global().async {
            do{
                //利用Data來產生下載內容
                let imageData = try Data(contentsOf: row.head_photo)
                let downLoadImage = UIImage(data: imageData)
                DispatchQueue.main.async {
                    cell.Sreachphoto.image = downLoadImage
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
        
        let width = collectionview.bounds.width/2-20
        layout?.itemSize = CGSize(width: width, height: width)
    }
    //collectionview 點擊事件響應
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("item at \(indexPath.section)/\(indexPath.item) tapped")
        self.performSegue(withIdentifier: "SreachToRoom", sender: self)
      }
    //------------------------------------------------------------------------------------
    //搜尋功能實作
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let searhview : UICollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "cellsearch", for: indexPath)
        return searhview
    }
    //動態搜尋
    func searchBar(_ searchBar: UISearchBar, textDidChange searchBarText: String) {
        list.removeAll()//用於展示的空陣列
        //陽春版(searchBarSearchButtonClicked)
//        for item in searchlist{
//            if  item.nickname.lowercased().contains(searchBar.text!.lowercased()){
//                list.append(item)
//            }else if item.tags.lowercased().contains(searchBar.text!.lowercased()){
//                list.append(item)
//            }
//        }
        if searchBarText.isEmpty{
            list = searchlist
//            print("偵測不到打字")
        }else{
            list = searchlist.filter({obj in obj.nickname.lowercased().contains(searchBarText.lowercased())})
            list = searchlist.filter({obj in obj.tags.lowercased().contains(searchBarText.lowercased())})
//            print("我在裡面打字")
        }
        collectionview.reloadData()
//        print("我已經reload")
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
    //當點擊view任何一處鍵盤收起
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
//    //按下鍵盤return鍵收起鍵盤
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//    self.view.endEditing(true)
//    textField.resignFirstResponder（）//要求離開我們的Responder
//    return true
//    }
}
