//
//  AddViewController.swift
//  Locaily
//
//  Created by SWUCOMPUTER on 6/14/19.
//  Copyright © 2019 SWUCOMPUTER. All rights reserved.
//

import UIKit
import CoreLocation

class AddViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {

    @IBOutlet var textTitle: UITextField!
    @IBOutlet var textDescription: UITextView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var buttonCamera: UIButton! // 카메라가 없을 경우 Disable 시키기 위함
    @IBOutlet var segFeeling: UISegmentedControl!
    
    let locManager: CLLocationManager = CLLocationManager()
    var latitude: String = ""
    var longitude: String = ""
    var isLocEnable: Bool = false
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { // delegate 연결
        textField.resignFirstResponder()
        textDescription.becomeFirstResponder()
        return true
    }
    
    // 현재 위치값을 변수에 저장함
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 가장 최근의 위치 값
        let location: CLLocation = locations[locations.count-1]
        latitude = String(format: "%.6f", location.coordinate.latitude)
        longitude = String(format: "%.6f", location.coordinate.longitude)
    }
    
    // 저장 버튼을 눌렀을 때 동작하는 내용(서버로 작성한 내용을 보낸다)
    @IBAction func saveLocation(_ sender: UIBarButtonItem) {
        // 입력 내용 검사
        let title = textTitle.text!
        let description = textDescription.text!
        if (title == "" || description == "") {
            let alert = UIAlertController(title: "제목/설명을 입력하세요",
                                          message: "Save Failed!!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true)
            return
        }
        guard let myImage = imageView.image else {
            let alert = UIAlertController(title: "이미지를 선택하세요",
                                          message: "Save Failed!!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true)
            return
        }
        
        // 이미지 업로드
        let myUrl = URL(string: "http://condi.swu.ac.kr/student/M04/daily/image/upload.php");
        
        var request = URLRequest(url:myUrl!);
        request.httpMethod = "POST";
        let boundary = "Boundary-\(NSUUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        guard let imageData = myImage.jpegData(compressionQuality:1) else { return }
        var body = Data()
        var dataString = "--\(boundary)\r\n"
        dataString += "Content-Disposition: form-data; name=\"userfile\"; filename=\".jpg\"\r\n"
        dataString += "Content-Type: application/octet-stream\r\n\r\n"
        if let data = dataString.data(using: .utf8) { body.append(data) }
        
        // imageData 위 아래로 boundary 정보 추가
        body.append(imageData)
        
        dataString = "\r\n"
        dataString += "--\(boundary)--\r\n"
        if let data = dataString.data(using: .utf8) { body.append(data) }
        request.httpBody = body
        
        var imageFileName: String = ""
        let semaphore = DispatchSemaphore(value: 0)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            guard responseError == nil else { print("Error: calling POST"); return;}
            guard let receivedData = responseData else {
                print("Error: not receiving Data")
                return; }
            if let utf8Data = String(data: receivedData, encoding: .utf8) { // 서버에 저장한 이미지 파일 이름이 존재할 경우
                imageFileName = utf8Data
                print(imageFileName)
                semaphore.signal()
            }
        }
        task.resume()
        
        // 이미지 파일 이름을 서버로 부터 받은 후 해당 이름을 DB에 저장하기 위해 wait()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    
        if (!isLocEnable || latitude == "" || longitude == "") {
            // 위치를 사용할 수 없는 경우, 임의의 초기값을 생성해줍니다
            latitude = "0.001467"
            longitude = "51.478049"
        }
        print("lat: " + latitude)
        print("lon: " + longitude)
        
        // 서버로 보내야하는 정보 : id, title, text, imagename, feeling, latitude, longitude, date
        let urlString: String = "http://condi.swu.ac.kr/student/M04/daily/diary/insertLocation.php"
        guard let requestURL = URL(string: urlString) else { return }
        request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        
        // 질의에 필요한 변수를 불러옴
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        guard let userID = appDelegate.ID else { return } // 아이디
        
        let formatter = DateFormatter() // 날짜 포맷
        formatter.dateFormat = "yyyy-MM-dd"
        let myDate = formatter.string(from: Date())
        let feeling = String(format: "%d", segFeeling.selectedSegmentIndex)
        
        // 질의를 위한 문자열 작성
        var restString: String = "id=" + userID + "&title=" + title
        restString += "&text=" + description
        restString += "&image=" + imageFileName
        restString += "&feeling=" + feeling
        restString += "&latitude=" + latitude + "&longitude=" + longitude
        restString += "&date=" + myDate
        request.httpBody = restString.data(using: .utf8)
        
        locManager.stopUpdatingLocation() // 위치정보 갱신을 멈춥니다
        let session2 = URLSession.shared
        let task2 = session2.dataTask(with: request) { (responseData, response, responseError) in
            guard responseError == nil else { return }
            guard let receivedData = responseData else { return }
            if let utf8Data = String(data: receivedData, encoding: .utf8) { print(utf8Data) }
        }
        task2.resume()
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func takePicture (_ sender: UIButton) {
        let myPicker = UIImagePickerController()
        myPicker.delegate = self;
        myPicker.allowsEditing = true
        myPicker.sourceType = .camera
        self.present(myPicker, animated: true, completion: nil)
    }
    
    // 앨범 이미지 선택
    @IBAction func selectPicture(_ sender: UIButton) {
        let myPicker = UIImagePickerController()
        myPicker.delegate = self;
        myPicker.sourceType = .photoLibrary
        self.present(myPicker, animated: true, completion: nil)
    }
    
    // 이미지 선택 시
    func imagePickerController (_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // 사용자가 선택한 원본 이미지를 가져옴
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imageView.image = image
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // 이미지 선택 취소 시
    func imagePickerControllerDidCancel (_ picker: UIImagePickerController) { self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 위치를 사용할 수 없을 경우 예외처리
        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .restricted {
                let alert = UIAlertController(title: "오류 발생",
                                              message: "위치서비스 기능이 꺼져있음", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
            else {
                locManager.desiredAccuracy = kCLLocationAccuracyBest
                locManager.delegate = self
                locManager.requestWhenInUseAuthorization()
                locManager.startUpdatingLocation()
                isLocEnable = true
            }
        }
        else {
            let alert = UIAlertController(title: "오류 발생", message: "위치서비스 제공 불가",
                                          preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        
        // 카메라를 사용할 수 없을 경우
        if !(UIImagePickerController.isSourceTypeAvailable(.camera)) {
            let alert = UIAlertController(title: "Error!!", message: "Device has no Camera!",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            buttonCamera.isEnabled = false // 카메라 버튼 사용을 금지시킴
        }

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
