//
//  PhotoVC.swift
//  bingweiApp
//
//  Created by Class on 2022/4/15.
//

import UIKit
protocol photoVCDelegate : AnyObject{
    func photoselected(photo:UIImage, imageindex:String)
    
}

class PhotoVC : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var PhotoDB: UIButton!
    @IBOutlet weak var headimage: UIImageView!
    var delegate : photoVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headimage.layer.cornerRadius = headimage.frame.width/2
        PhotoDB.layer.cornerRadius = 15
        
    }
    

    @IBAction func PhotoBtn(_ sender: Any) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let imagePickerAlertController = UIAlertController(title: "上傳照片", message: "請選擇要上傳的照片", preferredStyle: .actionSheet)
        
        let imageFromLibAction = UIAlertAction(title: "照片圖庫", style: .default) { (Void) in

                  // 判斷是否可以從照片圖庫取得照片來源
                  if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {

                      // 如果可以，指定 UIImagePickerController 的照片來源為 照片圖庫 (.photoLibrary)，並 present UIImagePickerController
                      imagePickerController.sourceType = .photoLibrary
                      self.present(imagePickerController, animated: true, completion: nil)
                  }
              }
        let imageFromCameraAction = UIAlertAction(title: "相機", style: .default) { (Void) in
                 // 判斷是否可以從相機取得照片來源
                 if UIImagePickerController.isSourceTypeAvailable(.camera) {
                     // 如果可以，指定 UIImagePickerController 的照片來源為 照片圖庫 (.camera)，並 present UIImagePickerController
                     imagePickerController.sourceType = .camera
                     self.present(imagePickerController, animated: true, completion: nil)
                 }
             }

             // 新增一個取消動作，讓使用者可以跳出 UIAlertController
             let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (Void) in

                 imagePickerAlertController.dismiss(animated: true, completion: nil)
             }
             // 將上面三個 UIAlertAction 動作加入 UIAlertController
             imagePickerAlertController.addAction(imageFromLibAction)
             //imagePickerAlertController.addAction(imageFromCameraAction)
             imagePickerAlertController.addAction(cancelAction)
             //當使用者按下 uploadBtnAction 時會 present 剛剛建立好的三個 UIAlertAction 動作與
              present(imagePickerAlertController, animated: true, completion: nil)
    }
}

extension PhotoVC {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        // 取得從 UIImagePickerController 選擇的檔案
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            selectedImageFromPicker = pickedImage
        }
        
        // 可以自動產生一組獨一無二的 ID 號碼，方便等一下上傳圖片的命名
        let uniqueString = NSUUID().uuidString
        
        // 當判斷有 selectedImage 時，我們會在 if 判斷式裡將圖片上傳
        if let selectedImage = selectedImageFromPicker {
            headimage.image = selectedImage
            delegate?.photoselected(photo: selectedImage, imageindex: uniqueString)
        }
        //回去上頁
        dismiss(animated: true, completion: nil)
    }
}
        

 
