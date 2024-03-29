//
//  SubRegionTableViewCell.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/08.
//

import UIKit

class SubRegionTableViewCell: UITableViewCell {
    
    public var subRegionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.G02
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 18)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.G09
        contentView.addSubview(subRegionLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        subRegionLabel.snp.makeConstraints {
            $0.center.equalTo(contentView.snp.center)
        }
    }

}
