//
//  ParkingTableViewController.swift
//  GGParking
//
//  Created by 이다은 on 4/3/25.
//

import UIKit

class ParkingTableViewController: UITableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    
    let apiKey = "6d0c002a5823469c88df2b45cde53488"
    
    var parkingPlaces:[[String:String]] = []
    var key:String?

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self

    }
    
    func searchParking(sigun:String) {
        let endPoint = "https://openapi.gg.go.kr/ParkingPlace?KEY=\(apiKey)&Type=xml&SIGUN_NM=\(sigun)"
        
        guard let url = URL(string: endPoint) else { return }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data else { return }
            
            self.parkingPlaces.removeAll() // 기존 데이터 초기화
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
        }.resume()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return parkingPlaces.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "parking", for: indexPath)
        
        let park = parkingPlaces[indexPath.row]

        let lblParkNM = cell.viewWithTag(1) as? UILabel
        let lblParkRAD = cell.viewWithTag(2) as? UILabel // 도로명주소
        let lblParkLAD = cell.viewWithTag(3) as? UILabel // 지번주소
        
        lblParkNM?.text = (park["PARKPLC_NM"] ?? "")
        lblParkRAD?.text = park["CHRG_INFO"]
        lblParkLAD?.text = park["LOCPLC_LOTNO_ADDR"]

        return cell
    }
}

extension ParkingTableViewController: XMLParserDelegate {
    func parserDidStartDocument(_ parser: XMLParser) {
        print("Start")
    }
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "row" {
            self.parkingPlaces.append([:])
        } else {
            self.key = elementName
        }
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard let key = self.key, var lastParking = self.parkingPlaces.last else { return }

                let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmedString.isEmpty {
                    lastParking[key] = trimmedString
                    self.parkingPlaces[self.parkingPlaces.count - 1] = lastParking // 수정된 값 저장
                }
    }
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "row" {
            print(parkingPlaces)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    func parserDidEndDocument(_ parser: XMLParser) {
        print("End")
    }
}

extension ParkingTableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchParking(sigun: searchBar.text!)
    }
}
