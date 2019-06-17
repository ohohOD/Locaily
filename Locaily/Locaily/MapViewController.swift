//
//  MapViewController.swift
//  Locaily
//
//  Created by SWUCOMPUTER on 6/14/19.
//  Copyright © 2019 SWUCOMPUTER. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet var map: MKMapView!
    
    var fetchedArray: [LocailyData] = Array()
    var sendLocaily: Int? = 0 // 핀을 클릭했을 때 그 위치의 일기를 받아오는 변수
    
    // 앞에 있던 뷰가 지워지면서 표시되기 전에 사용하는 업데이트 함수
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchedArray = [] // 배열을 초기화하고 서버에서 자료를 다시 가져옴
        self.map.removeAnnotations(self.map.annotations)
        self.downloadDataFromServer() // 지도 데이터 갱신
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        self.title = "Locaily Map"
        fetchedArray = [] // 배열을 초기화하고 서버에서 자료를 다시 가져옴
        self.map.removeAnnotations(self.map.annotations)
        self.downloadDataFromServer() // 지도 데이터 갱신
        // Do any additional setup after loading the view.
    }
    
    @IBAction func updateMap(_ sender: UISegmentedControl) {
        if (sender.selectedSegmentIndex == 0){
            self.map.mapType = MKMapType.standard
        }
        else {
            self.map.mapType = MKMapType.satellite
        }
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

                        var Loc: LocailyAnnotation? = nil
                        var Annotation: LocailyAnnotation? = nil
                        
                        if let lat = Double(newData.latitude) {
                            if let lon = Double(newData.longitude)
                            {
                                Loc = LocailyAnnotation(title:newData.title, latitude:lat, longitude:lon, Locaily:newData, subtitle: i)
                            }
                        }
                        
                        // 화면 초기화
                        var coordinate = CLLocationCoordinate2D()
                        coordinate.latitude = 37.6291
                        coordinate.longitude = 127.0897
                        
                        self.map.setRegion(MKCoordinateRegion(
                            center: (coordinate),
                            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)), animated: false)
                        
                        // 새로운 annotation 위치가 있다면 추가
                        if let annotation = Loc {
                            Annotation = annotation
                            
                            // 해당 위치로 지도 뷰를 이동함
                            self.map.setRegion(MKCoordinateRegion(
                                center: (Loc?.coordinate)!,
                                span: MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007)), animated: true)
                            
                            self.map.addAnnotation(Annotation!)
                        }
                        
                    }
                }
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
    
    // 핀을 클릭했을 때 - 클릭한 핀으로부터 일기를 불러들입니다
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation?.subtitle != nil {
            sendLocaily = Int((view.annotation?.subtitle!)!)
        }
        else { sendLocaily = 0 }
        self.performSegue(withIdentifier: "MapToDetailView", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controllerusing segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "MapToDetailView" {
            if let destination = segue.destination as? DetailViewController {
                if let send = sendLocaily {
                    let data = fetchedArray[send]
                    destination.selectedData = data
                    destination.title = data.title
                }
            }
        }
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
