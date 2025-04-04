//
//  ParkingInfoViewController.swift
//  GGParking
//
//  Created by 이다은 on 4/3/25.
//

import UIKit

class ParkingInfoViewController: UIViewController {
    @IBOutlet weak var lblParkNM: UILabel!
    @IBOutlet weak var lblPark_DIV_NM: UILabel!
    @IBOutlet weak var lblParkAD: UILabel!
    @IBOutlet weak var lblParkTimeW: UILabel!
    @IBOutlet weak var lblParkTimeS: UILabel!
    @IBOutlet weak var lblParkTimeH: UILabel!
    @IBOutlet weak var lblPark_CHRG: UILabel!
    @IBOutlet weak var lblPark_CHRG_Info: UILabel!
    @IBOutlet weak var lblPark_CHRG_Add: UILabel!
    @IBOutlet weak var lblParkDisa: UILabel!
    
    var park : [String:String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let park else { return }
        
        lblParkNM.text = park["PARKPLC_NM"]
        lblPark_DIV_NM.text = park["PARKPLC_DIV_NM"]
        lblParkAD.text = (park["LOCPLC_LOTNO_ADDR"] ?? park["LOCPLC_ROADNM_ADDR"])
        lblParkTimeW.text = "평일: " + (park["WKDAY_OPERT_BEGIN_TM"] ?? "") + " - " + (park["WKDAY_OPERT_END_TM"] ?? "")
        lblParkTimeS.text = "토요일: " + (park["SAT_OPERT_BEGIN_TM"] ?? "") + " - " + (park["SAT_OPERT_END_TM"] ?? "")
        lblParkTimeH.text = "공휴일: " + (park["HOLIDAY_OPERT_BEGIN_TM"] ?? "") + " - " + (park["HOLIDAY_OPERT_END_TM"] ?? "")
        lblPark_CHRG.text = park["CHRG_INFO"]
        if park["CHRG_INFO"] == "유료" || park["CHRG_INFO"] == "혼합" {
            lblPark_CHRG_Info.text = "기본 " + (park["PARKNG_BASIS_TM"] ?? "") + "분 " + (park["PARKNG_BASIS_USE_CHRG"] ?? "") + "원"
            lblPark_CHRG_Add.text = "이후 " + (park["ADD_UNIT_TM"] ?? "") + "분당 " + (park["ADD_UNIT_TM2_WITHIN_USE_CHRG"] ?? "") + "원"
        } else if park["CHRG_INFO"] == "무료" {
            lblPark_CHRG_Info.text = ""
            lblPark_CHRG_Add.text = ""
        }
        lblParkDisa.text = "장애인 주차구역 보유 여부 : " + (park["TMP01"] ?? "N")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let sheet = self.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
    }
}
