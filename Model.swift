//
//  Model.swift
//  GGParking
//
//  Created by Hee  on 4/2/25.
//

import Foundation


struct Root: Copyable {
    let parkingPlace: [ParkingPlace]
}

struct ParkingPlace: Codable {
    let row: [Parking]
}

struct Parking: Codable {
    //주차장명
    let PARKPLC_NM: String
    //주차장구분
    let PARKPLC_DIV_NM: String
    //소재지도로명주소a
    let LOCPLC_LOTNO_ADDR: String
    //평일운영시작시간
    let WKDAY_OPERT_BEGIN_TM: String
    //평일운영종료시간
    let WKDAY_OPERT_END_TM: String
    //토요일운영시작시간
    let SAT_OPERT_BEGIN_TM: String
    //토요일운영종료시간
    let SAT_OPERT_END_TM: String
    //공휴일운영시작시간
    let HOLIDAY_OPERT_BEGIN_TM: String
    //공휴일운영종료시간
    let HOLIDAY_OPERT_END_TM: String
    //요금정보
    let CHRG_INFO: String
    //주차기본시간
    let PARKNG_BASIS_TM: String
    //주차기본요금
    let PARKNG_BASIS_USE_CHRG: String
    //추가단위시간
    let ADD_UNIT_TM: String
    //추가단위요금
    let ADD_UNIT_TM2_WITHIN_USE_CHRG: String
    //경도
    let REFINE_WGS84_LOGT: String
    //위도
    let REFINE_WGS84_LAT: String
    //장애인주차구역보유여부
    let TMP01: String
}


//
