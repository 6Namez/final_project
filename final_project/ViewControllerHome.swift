//
//  ViewControllerHome.swift
//  final_project
//
//  Created by Caleb Willingham on 3/12/25.
//

import UIKit

class ViewControllerHome: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func getStartedTapped(_ sender: UIButton) {
        if let tabBarVC = self.tabBarController {
            tabBarVC.selectedIndex = 1 // Change to the index of your Connect Page tab
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
