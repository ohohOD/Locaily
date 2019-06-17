//
//  ViewController.swift
//  Locaily
//
//  Created by SWUCOMPUTER on 6/14/19.
//  Copyright © 2019 SWUCOMPUTER. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var labelStatus: UILabel!
    @IBOutlet var loginUserid: UITextField!
    @IBOutlet var loginPassword: UITextField!
    @IBOutlet var switchSave: UISwitch!
    
    var IdSave: [NSManagedObject] = []
    
    // 엔터를 쳤을 때의 반응
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.loginUserid {
            textField.resignFirstResponder()
            self.loginPassword.becomeFirstResponder()
        }
        
        textField.resignFirstResponder()
        return true
    }
    
    // coredata에 저장한 값을 불러옵니다
    func getContext() -> NSManagedObjectContext { // 데이터베이스 연결
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    @IBAction func loginPressed() {
        
        // 로그인 버튼을 눌렀을 때 입력내용 검사
        if loginUserid.text == "" {
            labelStatus.text = "ID를 입력하세요"; return;
        }
        
        if loginPassword.text == "" {
            labelStatus.text = "비밀번호를 입력하세요"; return;
        }
        
        // url 요청
        // M04 Prefix의 loginUser.php를 찾는다
        let urlString: String = "http://condi.swu.ac.kr/student/M04/daily/login/loginUser.php"
        guard let requestURL = URL(string: urlString) else {
            return
        }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        
        let restString: String = "id=" + loginUserid.text! + "&password=" + loginPassword.text!
        request.httpBody = restString.data(using: .utf8)
        
        // 세션 연결
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (responseData, response, responseError) in guard responseError == nil else {
            print("Error: calling POST")
            return
            }
            
            // 데이터를 받아옵니다
            guard let receivedData = responseData else {
                print("Error: not receiving Data")
                return
            }
            
            // 받아온 정보를 해석합니다
            do {
                let response = response as! HTTPURLResponse
                if !(200...299 ~= response.statusCode) {
                    print ("HTTP Error!")
                    return
                }
                
                guard let jsonData = try JSONSerialization.jsonObject(with: receivedData, options:.allowFragments) as? [String: Any] else {
                    print("JSON Serialization Error!")
                    return
                }
                
                guard let success = jsonData["success"] as? String else {
                    print("Error: PHP failure(success)")
                    return
                }
                
                if success == "YES" {
                    if let name = jsonData["name"] as? String {
                        DispatchQueue.main.async {
                            self.labelStatus.text = name + "님 안녕하세요?"
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.ID = self.loginUserid.text
                            appDelegate.userName = name
                            self.updateID()
                            self.performSegue(withIdentifier: "toLoginSuccess", sender: self)
                        }
                    }
                } else {
                    if let errMessage = jsonData["error"] as? String {
                        DispatchQueue.main.async { self.labelStatus.text = errMessage
                        }
                    }
                }
            } catch {
                print("Error: \(error)")
            }
        }
        task.resume()
    }
    
    // 아이디를 CoreData에 저장하는 함수
    func updateID() {
        if(switchSave.isOn) { // 스위치가 켜져있을 경우
            deleteID() // CoreData에 저장되어있던 기존값이 있다면 삭제하고,
            saveID() // 아이디 값을 저장합니다
        }
        else { // 스위치가 꺼져있을 경우
            deleteID() // CoreData에 저장되어있던 기존 값을 삭제합니다
        }
    }
    
    func saveID() {
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "IDSave", in: context)
        // id record를 새로 생성함
        let object = NSManagedObject(entity: entity!, insertInto: context)
        object.setValue(loginUserid.text, forKey: "id")
        object.setValue(Date(), forKey: "date")
        do {
            try context.save()
            print("saved!")
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    // 아이디를 CoreData에서 삭제하는 함수
    func deleteID() {
        let context = self.getContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "IDSave")
        do {
            IdSave = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)") }
        
        // 값이 있을 경우, 해당 값을 삭제합니다
        if(IdSave.count != 0) {
            context.delete(IdSave[0])
            
            do {
                try context.save()
                print("deleted!")
            } catch let error as NSError {
                print("Could not delete \(error), \(error.userInfo)")
            }
        }
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let context = self.getContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "IDSave")
        do {
            IdSave = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)") }
        
        // 값이 있을 경우, 스위치를 켜고 아이디 텍스트 필드를 갱신합니다
        if(IdSave.count != 0) {
            let id = IdSave[0]
            if let idLabel = id.value(forKey: "id") as? String {
                loginUserid.text = idLabel
                switchSave.isOn = true
            }
        }
        
    }


}

