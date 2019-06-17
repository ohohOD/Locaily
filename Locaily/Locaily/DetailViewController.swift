//
//  DetailViewController.swift
//  Locaily
//
//  Created by SWUCOMPUTER on 6/14/19.
//  Copyright © 2019 SWUCOMPUTER. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet var feeling: UIImageView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var textDescription: UITextView!
    @IBOutlet var textDate: UILabel!
    
    let feelingImage: [UIImage?] = [UIImage(named: "feeling1-1"), UIImage(named: "feeling2-1"), UIImage(named: "feeling3-1"), UIImage(named: "feeling4-1")]
    
    var selectedData: LocailyData?
    var feelingIndex: Int!
    
    @IBAction func buttonDelete() {
        let alert=UIAlertController(title:"정말 삭제 하시겠습니까?", message: "",preferredStyle:.alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .cancel, handler: { action in
            
            
            // 이미지를 먼저 삭제합니다
            if let _ = self.imageView.image {
                print("ok")
                let urlString: String = "http://condi.swu.ac.kr/student/M04/daily/diary/deleteImage.php"
                guard let requestURL = URL(string: urlString) else { return }
                var request = URLRequest(url: requestURL)
                request.httpMethod = "POST"
                guard let locationNO = self.selectedData?.locationno else { return }
                let restString: String = "locationno=" + locationNO
                request.httpBody = restString.data(using: .utf8)
                let session = URLSession.shared
                let task = session.dataTask(with: request) { (responseData, response, responseError) in guard responseError == nil else { return }
                    guard let receivedData = responseData else { return }
                    if let utf8Data = String(data: receivedData, encoding: .utf8) { print(utf8Data) }
                }
                task.resume()
            }
            
            let urlString: String = "http://condi.swu.ac.kr/student/M04/daily/diary/deleteLocation.php"
            guard let requestURL = URL(string: urlString) else { return }
            var request = URLRequest(url: requestURL)
            request.httpMethod = "POST"
            guard let locationNO = self.selectedData?.locationno else { return }
            let restString: String = "locationno=" + locationNO
            request.httpBody = restString.data(using: .utf8)
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (responseData, response, responseError) in guard responseError == nil else { return }
                guard let receivedData = responseData else { return }
                if let utf8Data = String(data: receivedData, encoding: .utf8) { print(utf8Data) }
            }
            
            task.resume()
            self.navigationController?.popViewController(animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let LocailyData = selectedData else { return }
        self.title = LocailyData.title
        textDate.text = "Date: " + LocailyData.date
        textDescription.text = LocailyData.text
        var imageName = LocailyData.imagename // 숫자.jpg 로 저장된 파일 이름
        
        if (imageName != "") {
            let urlString = "http://condi.swu.ac.kr/student/M04/daily/image/"
            imageName = urlString + imageName
            let url = URL(string: imageName)!
            if let imageData = try? Data(contentsOf: url) {
                imageView.image = UIImage(data: imageData)
            }
        }
        
        // feeling Index를 불러와서 해당하는 그림으로 교체해준다
        feelingIndex = Int(LocailyData.feeling)
        feeling.image = feelingImage[feelingIndex]
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
