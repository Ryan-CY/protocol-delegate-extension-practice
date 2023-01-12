//
//  ViewController.swift
//  protocol, delegate & extension practice
//
//  Created by Ryan Lin on 2023/1/10.
//

import UIKit
// for PHPicker
import PhotosUI
// for DocumentPicker
import UniformTypeIdentifiers

class ViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet var imageViews: [UIImageView]!
    
    var frameColor = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = CGFloat(80)
        imageView.layer.borderWidth = CGFloat(10)
        imageView.layer.borderColor = view.backgroundColor?.cgColor
        imageView.contentMode = .scaleAspectFill
        
        for imageView in imageViews {
            imageView.layer.cornerRadius = CGFloat(33)
            imageView.layer.borderWidth = CGFloat(7)
            imageView.layer.borderColor = view.backgroundColor?.cgColor
            imageView.contentMode = .scaleAspectFill
        }
        
    }
    
    //(ImagePicker)選照片的按鈕，搭配 UIAlertController 、array 及 switch，判斷要從相簿或是相機取得影像
    @IBAction func selectPhoto(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Source From", message: nil, preferredStyle: .alert)
        
        let photoController = UIImagePickerController()
        
        //創造一個enum型別，case是影像的來源選項，並使其遵從 protocol CaseIterable
        enum Source: CaseIterable {
            case Album, Camera
        }
        //呼叫 protocol 底下的 function allCases 把 enum 變成 array，並存入常數 sources
        let sources = Source.allCases
    
        //用 for-in 搭配 array，創造兩個 alert 按鈕
        for source in sources {
            
            alertController.addAction(UIAlertAction(title: String("\(source)"), style: .default, handler: { _ in
                //用 switch 搭配 enum，判斷按下按鈕後要做的事
                switch source {
                case .Camera:
                    photoController.sourceType = .camera
                case .Album:
                    photoController.sourceType = .photoLibrary
                }
                //呼叫屬性 delegate(代理)，self 代表 View Controller
                photoController.delegate = self
                self.present(photoController, animated: true)
            }))
        }
        
        alertController.addAction(UIAlertAction(title: "Cancle", style: .cancel))
        present(alertController, animated: true)
    }
    //兩個選顏色的按紐，連到同一個 IBAction func，按鈕設定 tag 搭配 if-else 判斷是要改變影像邊框或是背景顏色
    @IBAction func selectColor(_ sender: UIButton) {
        
        let controller = UIColorPickerViewController()
        
        if sender.tag == 1 {
            frameColor = true
        } else {
            frameColor = false
        }
        
        controller.delegate = self
        present(controller, animated: true)
    }
    //(PHPicker)選多張照片的按鈕
    @IBAction func selectPhotos(_ sender: Any) {
        var configuration = PHPickerConfiguration()
        //僅可以選擇影像，若要可以選影片跟照片則把.images改成nil
        configuration.filter = .images
        //呼叫 selectionLimit 設定可選取數量上限，無上限則設0
        //沒有呼叫 selectionLimit則只能選1張影像
        configuration.selectionLimit = 3
        let picker = PHPickerViewController(configuration:configuration )
        picker.delegate = self
        present(picker, animated: true)
    }
    //選檔案的按紐
    @IBAction func selectDocument(_ sender: Any) {
        //參數 forOpeningContentTypes 的array內容，控制著可顯示檔案類型
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: [.png, .text, .jpeg], asCopy: true)
        controller.delegate = self
        present(controller, animated: true)
    }
    //選字體的按紐
    @IBAction func selectFont(_ sender: Any) {
        let fontConfiguration = UIFontPickerViewController.Configuration()
        fontConfiguration.includeFaces = true
        let fontPicker = UIFontPickerViewController(configuration:fontConfiguration)
        fontPicker.delegate = self
        present(fontPicker, animated: true)
    }
}

//遵從選顏色的 protocol 及具體化其 function
extension ViewController: UIColorPickerViewControllerDelegate {
    
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        
        if frameColor == true {
            imageView.layer.borderColor = color.cgColor
        } else {
            view.backgroundColor = color
        }
        //選擇後自動離開
        dismiss(animated: true)
    }
}

//遵從選照片的 protocol 及具體化其 function
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //.originalImage(原始照片)型別是 Any 轉型成 UIImage
        imageView.image = info[.originalImage] as? UIImage
        dismiss(animated: true)
    }
}

//遵從選多張照片的 protocol 及具體化其 function
extension ViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        //results.map { $0.itemProvider }可獲得型別 [NSItemProvider] 的 array
        let itemProviders = results.map { $0.itemProvider }
        
        for (i, itemProvider) in itemProviders.enumerated() where itemProvider.canLoadObject(ofClass: UIImage.self) {
            
            let previousImage = self.imageViews[i].image
            itemProvider.loadObject(ofClass: UIImage.self) {[weak self] (image, error) in
                DispatchQueue.main.async {
                    guard let self = self, let image = image as? UIImage, self.imageViews[i].image == previousImage else {
                        return
                    }
                    self.imageViews[i].image = image
                }
            }
        }
        dismiss(animated: true)
    }
}

//遵從選檔案的 protocol 及具體化其 function
extension ViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        if let url = urls.first,
           let image = UIImage(contentsOfFile: url.path) {
            imageView.image = image
        }
    }
}

//遵從選字體的 protocol 及具體化其 function
extension ViewController: UIFontPickerViewControllerDelegate {
    
    func fontPickerViewControllerDidPickFont(_ viewController: UIFontPickerViewController) {
        if let selectfontDescriptor = viewController.selectedFontDescriptor {
            textField.font = UIFont(descriptor: selectfontDescriptor, size: textField.font!.pointSize)
        }
        dismiss(animated: true)
    }
}
