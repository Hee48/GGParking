//
//  ParkingInfoViewController.swift
//  GGParking
//
//  Created by 이다은 on 4/3/25.
//

import UIKit

class ParkingInfoViewController: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let sheet = self.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
    }
}
