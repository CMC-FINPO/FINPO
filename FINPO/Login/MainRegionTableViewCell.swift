//
//  MainRegionTableViewCell.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/07.
//

import UIKit
import SnapKit

class MainRegionTableViewCell: UITableViewCell {

    public var mainRegionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor(hexString: "616161", alpha: 1)
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 18)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor(hexString: "F9F9F9", alpha: 1)
        contentView.addSubview(mainRegionLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //property layout here
        mainRegionLabel.snp.makeConstraints {
            $0.center.equalTo(contentView.snp.center)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        mainRegionLabel.textColor = selected ? UIColor(hexString: "FFFFFF", alpha: 1) : UIColor(hexString: "616161")
        contentView.backgroundColor = selected ? UIColor(hexString: "5B43EF") : UIColor(hexString: "F9F9F9")
    }
}
