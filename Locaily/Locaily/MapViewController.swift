//
//  MapViewController.swift
//  Locaily
//
//  Created by SWUCOMPUTER on 6/14/19.
//  Copyright © 2019 SWUCOMPUTER. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controllerusing segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "MapToDetailView" {
            if let destination = segue.destination as? DetailViewController {
                /*if let selectedIndex = self.tableView.indexPathsForSelectedRows?.first?.row {
                    let data = fetchedArray[selectedIndex]
                    destination.selectedData = data
                    destination.title = data.title
                } */
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
