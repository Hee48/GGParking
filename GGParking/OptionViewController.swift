//
//  OptionViewController.swift
//  GGParking
//
//  Created by 이다은 on 4/7/25.
//

import UIKit

protocol OptionDelegate : AnyObject {
    func didChangeFreeOption(isFreeOnly: Bool)
}

class OptionViewController: UIViewController {
    @IBOutlet weak var lblSearch: UILabel!
    @IBOutlet weak var switchSearch: UISwitch!
    
    weak var delegate: OptionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 저장된 상태 불러오기
        let isFreeOnly = UserDefaults.standard.bool(forKey: "isFreeOnly")
        switchSearch.isOn = isFreeOnly
    }
    @IBAction func switchOption(_ sender: Any) {
        let isOn = switchSearch.isOn
            UserDefaults.standard.set(isOn, forKey: "isFreeOnly")
            delegate?.didChangeFreeOption(isFreeOnly: isOn)
    }
}
