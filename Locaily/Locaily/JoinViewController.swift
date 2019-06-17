//
//  JoinViewController.swift
//  Locaily
//
//  Created by SWUCOMPUTER on 6/14/19.
//  Copyright © 2019 SWUCOMPUTER. All rights reserved.
//

import UIKit

class JoinViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var textID: UITextField!
    @IBOutlet var textPassword: UITextField!
    @IBOutlet var textName: UITextField!
    @IBOutlet var labelStatus: UILabel!
    
    // 엔터를 쳤을 때 다음 텍스트 필드로 커서를 옮김
    func textFieldShouldReturn (_ textField: UITextField) -> Bool {
        if textField == self.textName {
        textField.resignFirstResponder()
        self.textID.becomeFirstResponder()
        }
    else if textField == self.textID {
        textField.resignFirstResponder()
        self.textPassword.becomeFirstResponder()
        }
        
        textField.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // url 요청 - 세션을 연결하고 요청에 대한 응답을 받아옴
    func executeRequest (request: URLRequest) -> Void {
        var isDone: Bool = false
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            guard responseError == nil else { print("Error: calling POST")
                return
            }
            
            // 데이터를 받아옴
            guard let receivedData = responseData else { print("Error: not receiving Data")
                return
            }
            
            // 인코딩
            if let utf8Data = String(data: receivedData, encoding: .utf8) {
                DispatchQueue.main.async { // for Main Thread Checker
                    self.labelStatus.text = utf8Data
                    print(utf8Data) // php에서 출력한 echo data가 debug 창에 표시됨
                    if(utf8Data == "Insert Done!") { isDone = true }
                }
            }
            
        }
        task.resume()
        if(isDone) {
            isDone = false
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func buttonSave() {
        // 필요한 세 가지 자료가 모두 입력 되었는지 확인
        if textID.text == "" {
            labelStatus.text = "ID를 입력하세요"; return;
        }
        
        if textPassword.text == "" {
            labelStatus.text = "Password를 입력하세요"; return;
        }
        
        if textName.text == "" {
            labelStatus.text = "사용자 이름을 입력하세요"; return;
        }
        
        //let urlString: String = "http://localhost:8888/login/insertUser.php" // 내부 서버
        let urlString: String = "http://condi.swu.ac.kr/student/M04/daily/login/insertUser.php" // 외부 서버
        guard let requestURL = URL(string: urlString) else {
            return
        }
        var request = URLRequest(url: requestURL)
        
        request.httpMethod = "POST"
        let restString: String = "id=" + textID.text! + "&password=" + textPassword.text! + "&name=" + textName.text!
        request.httpBody = restString.data(using: .utf8)
        
        self.executeRequest(request: request)
    }
    
    @IBAction func buttonBack() {
        self.dismiss(animated: true, completion: nil)
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
