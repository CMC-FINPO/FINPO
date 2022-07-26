//
//  OpenSourceTableViewCell.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/20.
//

/*
 
 HomeBrew - https://github.com/mono0926/LicensePlist
 사용으로 인해 미사용
  
 */

import Foundation
import UIKit

class OpenSourceTableViewCell: UITableViewCell {
    private var mainAPILabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 20)
        return label
    }()
    
    private var apiWriterLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        return label
    }()
}
