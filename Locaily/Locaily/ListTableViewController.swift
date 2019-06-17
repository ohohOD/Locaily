//
//  ListTableViewController.swift
//  Locaily
//
//  Created by SWUCOMPUTER on 6/14/19.
//  Copyright © 2019 SWUCOMPUTER. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {

    var fetchedArray: [LocailyData] = Array()
    
    // 앞에 있던 뷰가 지워지면서 표시되기 전에 사용하는 업데이트 함수
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchedArray = [] // 배열을 초기화하고 서버에서 자료를 다시 가져옴
        self.tableView.reloadData()
        self.downloadDataFromServer()
    }
    
    func downloadDataFromServer() -> Void {
        
        let urlString: String = "http://condi.swu.ac.kr/student/M04/daily/diary/fetchLocation.php"
        guard let requestURL = URL(string: urlString) else { return }
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"

        // 질의에 필요한 변수를 불러옴
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        guard let userID = appDelegate.ID else { return } // 아이디
        let restString: String = "id=" + userID
        request.httpBody = restString.data(using: .utf8)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            guard responseError == nil else { print("Error: calling POST"); return; }
            guard let receivedData = responseData else {
                print("Error: not receiving Data"); return;
                
            }
            let response = response as! HTTPURLResponse
            
            if !(200...299 ~= response.statusCode) { print("HTTP response Error!"); return }
            do {
                if let jsonData = try JSONSerialization.jsonObject (with: receivedData,
                                                                    options:.allowFragments) as? [[String: Any]] {
                    for i in 0...jsonData.count-1 {
                        let newData: LocailyData = LocailyData()
                        var jsonElement = jsonData[i]
                        newData.locationno = jsonElement["locationno"] as! String
                        newData.id = jsonElement["id"] as! String
                        newData.title = jsonElement["title"] as! String
                        newData.text = jsonElement["text"] as! String
                        newData.imagename = jsonElement["imagename"] as! String
                        newData.feeling = jsonElement["feeling"] as! String
                        newData.latitude = jsonElement["latitude"] as! String
                        newData.longitude = jsonElement["longitude"] as! String
                        newData.date = jsonElement["date"] as! String
                        self.fetchedArray.append(newData)
                    }
                    DispatchQueue.main.async { self.tableView.reloadData() } }
            } catch { print("Error: Catch") } }
        task.resume()
    }
    
    // 로그아웃 버튼을 눌렀을 때 동작하는 내용 - 해당 뷰를 삭제하고, 로그인 뷰로 돌아간다.
    @IBAction func buttonLogout(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title:"로그아웃 하시겠습니까?",message: "",preferredStyle: .alert) // 컨트롤러 객체 생성
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in // 디폴트가 로그아웃이고 - 오른쪽에 확인이 붙어있는 것으로
            let urlString: String = "http://condi.swu.ac.kr/student/M04/daily/login/logout.php" // 요청을 보낼 url
            guard let requestURL = URL(string: urlString) else { return }
            var request = URLRequest(url: requestURL)
            
            request.httpMethod = "POST" // 연결
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (responseData, response, responseError) in
                guard responseError == nil else { return }
            }
            task.resume()
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginView = storyboard.instantiateViewController(withIdentifier: "LoginView")
            self.present(loginView, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil)) // No를 눌렀을 때 캔슬이 작동되도록 하는 것
        
        self.present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Locaily list"
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fetchedArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Locaily Cell", for: indexPath)
        
        let item = fetchedArray[indexPath.row]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.date
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controllerusing segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ListToDetailView" {
            if let destination = segue.destination as? DetailViewController {
                if let selectedIndex = self.tableView.indexPathsForSelectedRows?.first?.row {
                    let data = fetchedArray[selectedIndex]
                    destination.selectedData = data
                    destination.title = data.title
                }
            }
        }
    }
}
