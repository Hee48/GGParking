//
//  ParkingTableViewController.swift
//  GGParking
//
//  Created by 이다은 on 4/3/25.
//

import UIKit

class ParkingTableViewController: UITableViewController, OptionDelegate {
    @IBOutlet weak var searchBar: UISearchBar!

    let apiKey = "6d0c002a5823469c88df2b45cde53488"
    
    var parkingPlaces: [[String: String]] = []
    var key: String?
    var currentPark: [String: String] = [:]
    var searchKeyword: String?
    var isFreeOnly: Bool = false
    
    // 경기도 시군 리스트
    let sigunList = [
        "고양시", "수원시", "성남시", "용인시", "부천시", "화성시", "안산시", "안양시", "평택시",
        "의정부시", "시흥시", "파주시", "김포시", "광주시", "광명시", "군포시", "하남시",
        "오산시", "이천시", "안성시", "구리시", "의왕시", "양평군", "여주시", "동두천시",
        "과천시", "가평군", "연천군", "남양주시", "양주시", "포천시"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        self.navigationController?.navigationBar.tintColor = .black
    }


    
    func didChangeFreeOption(isFreeOnly: Bool) {
        if let keyword = searchKeyword {
            searchParkingByDong(keyword: keyword)
        }
    }

    func searchParkingByDong(keyword: String) {
        parkingPlaces.removeAll()
        searchKeyword = keyword
        let group = DispatchGroup()

        for sigun in sigunList {
            group.enter()
            let endPoint = "https://openapi.gg.go.kr/ParkingPlace?KEY=\(apiKey)&Type=xml&SIGUN_NM=\(sigun)"
            guard let url = URL(string: endPoint) else {
                group.leave()
                continue
            }
            let request = URLRequest(url: url)
            URLSession.shared.dataTask(with: request) { data, _, _ in
                defer { group.leave() }
                guard let data else { return }
                
                let parser = XMLParser(data: data)
                parser.delegate = self
                parser.parse()
            }.resume()
        }

        group.notify(queue: .main) {
            self.tableView.reloadData()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parkingPlaces.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "parking", for: indexPath)
        
        let park = parkingPlaces[indexPath.row]

        let lblParkNM = cell.viewWithTag(1) as? UILabel
        let lblParkRAD = cell.viewWithTag(2) as? UILabel
        let lblParkLAD = cell.viewWithTag(3) as? UILabel
        
        if let parkName = park["PARKPLC_NM"] {
            lblParkNM?.text = parkName.contains("주차장") ? parkName : "\(parkName) 주차장"
                } else {
                    lblParkNM?.text = ""
                }
        lblParkRAD?.text = park["CHRG_INFO"]
        lblParkLAD?.text = park["LOCPLC_LOTNO_ADDR"] ?? park["LOCPLC_ROADNM_ADDR"]

        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "search" {
            guard let cell = sender as? UITableViewCell,
                  let indexPath = tableView.indexPath(for: cell),
                  let targetVC = segue.destination as? ParkingInfoViewController else { return }

            let park = parkingPlaces[indexPath.row]
            targetVC.park = park
        } else if segue.identifier == "option" {
            if let optionVC = segue.destination as? OptionViewController {
                optionVC.delegate = self
            }
        }
    }
}

extension ParkingTableViewController: XMLParserDelegate {
    func parserDidStartDocument(_ parser: XMLParser) {
        currentPark = [:]
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        key = elementName
        if elementName == "row" {
            currentPark = [:]
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard let key = self.key else { return }
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            currentPark[key, default: ""] += trimmed
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "row" {
            if let keyword = searchKeyword {
                let address1 = currentPark["LOCPLC_ROADNM_ADDR"] ?? ""
                let address2 = currentPark["LOCPLC_LOTNO_ADDR"] ?? ""
                if address1.contains(keyword) || address2.contains(keyword) {
                    let isFreeOnly = UserDefaults.standard.bool(forKey: "isFreeOnly") //옵션 상태 확인
                    let chrgInfo = currentPark["CHRG_INFO"] ?? ""

                    // 무료 주차장만 보기 옵션이 켜져 있을 때는 "무료" 문자열을 포함하는 경우만 추가
                    if isFreeOnly {
                        if chrgInfo.contains("무료") {
                            parkingPlaces.append(currentPark)
                        }
                    } else {
                        parkingPlaces.append(currentPark)
                    }
                }
            }
        }
    }


    func parserDidEndDocument(_ parser: XMLParser) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension ParkingTableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let keyword = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines), !keyword.isEmpty {
            searchParkingByDong(keyword: keyword)
        }
    }
}
